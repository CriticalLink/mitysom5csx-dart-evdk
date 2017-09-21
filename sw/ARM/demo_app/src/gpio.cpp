#include "gpio.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <unistd.h>
#include <fcntl.h>

using namespace MityDSP;

tcGpio::tcGpio(tsPinConfig* apConfigs, unsigned int NumPins)
: mnNumPins(NumPins)
, mbShutDown(false)
{
	int fid;
	unsigned int i;
	char buff[256];
	bool hasCallback = false;
	mpPins = new tsPinState[mnNumPins];

	for (i = 0; i < mnNumPins; i++)
	{
		mpPins[i].config = apConfigs[i];
		mpPins[i].config_ok = 0;

		// export the pin
		fid = open("/sys/class/gpio/export", O_WRONLY);
		if (fid >= 0)
		{
			snprintf(buff, 256, "%d\n",mpPins[i].config.gpionum);
			write(fid,buff,strlen(buff));
			close(fid);
		}
		else
		{
			perror("Unable to open export file");
			// Don't skip incase export has wrong permissions but gpio already exported
			// Will error out on "value" open if there is a problem
			//continue;
		}

		// grab a reference to fd 
		snprintf(buff, 256, "/sys/class/gpio/gpio%d/value",mpPins[i].config.gpionum);
		mpPins[i].val_fd = open(buff,O_RDWR);
		if (mpPins[i].val_fd < 0)
		{
			perror(buff);
			continue;
		}

		// Configure active low before setting direction
		_setactivelow(i,mpPins[i].config.active_low);
		_setdirection(i,mpPins[i].config.output, mpPins[i].config.val);

		if (mpPins[i].config.handler != NULL || mpPins[i].config.observer != NULL)
		{
			hasCallback = true;	
			_setedge(i, mpPins[i].config.falling_edge, mpPins[i].config.rising_edge);
		}

		mpPins[i].config_ok = 1;
	}

	// launch thread to monitor inputs with callbacks specified
#ifdef USE_PTHREAD
	if (hasCallback)
	{
		int ret = pthread_create(&mcThread, NULL, DispatchMonitor, (void*)this);
	}
#endif
}

/**
 * Use pselect to block for interrupt and call appropriate handler when interrupt occurs.
 * Call function again to wait for next interrupt
 * @param tv_sec timeout in seconds
 * @param tv_nsec timeout in nano seconds
 * @return <1 if error, 0 if timeout, >1 if interrupt
 */
int tcGpio::WaitForInterrupt(time_t tv_sec, time_t tv_nsec)
{
	int max_fd;
	unsigned int i;
	struct timespec ts;
	fd_set set;

	// Timeout configuration
	ts.tv_sec = tv_sec;
	ts.tv_nsec = tv_nsec;

	FD_ZERO(&set);
	max_fd = -1;
	// Loop through gpio with handlers and configure fd_set
	for (i = 0; i < mnNumPins; i++)
	{
		if (!mpPins[i].config_ok)
			continue;
		if (!mpPins[i].config.output &&
				(mpPins[i].config.handler || mpPins[i].config.observer))
		{
			if (max_fd < mpPins[i].val_fd)
				max_fd = mpPins[i].val_fd;
			FD_SET(mpPins[i].val_fd, &set);
		}
	}
	max_fd += 1;

	// Block till interrupt or timeout
	int rv = pselect(max_fd, NULL, NULL, &set, &ts, NULL);
	if (rv > 0)
	{
		int cnt = 0;
		// Loop through gpio and check for interrupts
		for (i = 0; i < mnNumPins; i++)
		{
			if (mpPins[i].val_fd < 0)
				continue;
			if (FD_ISSET(mpPins[i].val_fd, &set))
			{
				// call handler
				if (mpPins[i].config.handler)
					mpPins[i].config.handler(mpPins[i].config.gpionum,
							GetValue(mpPins[i].config.gpionum),
							mpPins[i].config.handler_data);

				if (mpPins[i].config.observer)
					mpPins[i].config.observer->Handler(mpPins[i].config.gpionum, GetValue(mpPins[i].config.gpionum));

				// bail if all FD's set are processed
				if (++cnt == rv)
					break;
			}
		}
	}
	else if (rv < 0)
	{
		perror("GPIO Select");
	}
	// else rv == 0 -> timeout

	return rv;
}

void* tcGpio::DispatchMonitor(void* apThis)
{
	return ((tcGpio*)apThis)->MonitorThread();
}

void* tcGpio::MonitorThread(void)
{
	// Keep watching for interrupt until thread shutdown
	while(!mbShutDown)
	{
		WaitForInterrupt();
	}
	return NULL;
}

tcGpio::~tcGpio(void)
{
	unsigned int i;
	for(i = 0; i < mnNumPins; i++)
	{
		if (mpPins[i].val_fd >= 0)
			close(mpPins[i].val_fd);
	}
	delete [] mpPins;
}

int tcGpio::FindIndex(char* name)
{
	unsigned int i;

	// loop through, could be faster with hash or index...
	for (i = 0; i < mnNumPins; i++)
	{
		if (!mpPins[i].config.name)
			continue;

		if (!strcmp(name, mpPins[i].config.name))
			break;
	}

	if (i == mnNumPins)
		return -1;

	if (!mpPins[i].config_ok)
		return -2;

	return i;
}

int tcGpio::FindIndex(unsigned int gpionum)
{
	unsigned int i;

	// loop through, could be faster with hash or index...
	for (i = 0; i < mnNumPins; i++)
	{
		if (mpPins[i].config.gpionum == gpionum)
			break;
	}

	if (i == mnNumPins)
		return -1;

	if (!mpPins[i].config_ok)
		return -2;

	return i;
}

int tcGpio::_setdirection(int index, unsigned int output, unsigned int val)
{
	char path[256];
	char buff[5] = {0};
	int rv;

	snprintf(path, 256, "/sys/class/gpio/gpio%d/direction",mpPins[index].config.gpionum);
	int fid = open(path,O_RDWR);
	if (fid >= 0)
	{
		// We need to read the direction and only change it if needed.
		// BUG: If setting to output, linux will reset value to 0 even if the
		// direction is already set to output.  So if the gpio is controlling
		// a reset you didn't want to go low, there will be a glitch.
		rv = read(fid,buff,4);
		if (rv < 0)
			return rv;

		// Need to seek back to beginning of file
		rv = lseek(fid,0,SEEK_SET);
		if (rv < 0)
			return rv;

		if (output && strncmp(buff, "out\n", 4) != 0) {
			write(fid,"out\n",4);
		}
		else if (!output && strncmp(buff, "in\n", 4) != 0) {
			write(fid,"in\n",3);
		}

		mpPins[index].config.output = output;
		close(fid);
		return _setvalue(index, val);
	}
	else
	{
		perror(path);
		return -1;
	}
}

int tcGpio::_setactivelow(int index, unsigned int active_low)
{
	char path[256];

	snprintf(path, 256, "/sys/class/gpio/gpio%d/active_low",mpPins[index].config.gpionum);
	int fid = open(path,O_WRONLY);
	if (fid >= 0)
	{
		if (active_low)
			write(fid,"1\n",4);
		else
			write(fid,"0\n",3);
		mpPins[index].config.active_low = active_low;
		close(fid);
		return 0;
	}
	else
	{
		perror(path);
		return -1;
	}
}

int tcGpio::_setvalue(int index, unsigned int value)
{
	int rc = 0;

	lseek(mpPins[index].val_fd, 0, SEEK_SET);
	if (value)
		rc = write(mpPins[index].val_fd,"1\n",2);
	else
		rc = write(mpPins[index].val_fd,"0\n",2);

	return rc;
}

int tcGpio::SetDirection(unsigned int gpionum, unsigned int output,
			 unsigned int value)
{
	int index = FindIndex(gpionum);
	if (index < 0)
		return index;
	return _setdirection(index, output, value);
}

int tcGpio::SetDirection(char* name, unsigned int output, unsigned int value)
{
	int index = FindIndex(name);
	if (index < 0)
		return index;
	return _setdirection(index, output, value);
}

int tcGpio::SetActiveLow(unsigned int gpionum, unsigned int active_low)
{
	int index = FindIndex(gpionum);
	if (index < 0)
		return index;
	return _setactivelow(index, active_low);
}

int tcGpio::SetActiveLow(char* name, unsigned int active_low)
{
	int index = FindIndex(name);
	if (index < 0)
		return index;
	return _setactivelow(index, active_low);
}

int tcGpio::SetValue(unsigned int gpionum, unsigned int value)
{
	int index = FindIndex(gpionum);
	if (index < 0)
		return index;
	return _setvalue(index, value);
}

int tcGpio::SetValue(char* name, unsigned int value)
{
	int index = FindIndex(name);
	if (index < 0)
		return index;
	return _setvalue(index, value);
}

int tcGpio::_getvalue(int index)
{
	char buff[3];
	int rv = 0;

	rv = lseek(mpPins[index].val_fd,0,SEEK_SET);
	rv = read(mpPins[index].val_fd,buff,3);
	if (rv < 0)
		return rv;
	return (buff[0] == '1') ? 1 : 0;
}

int tcGpio::GetValue(unsigned int gpionum)
{
	int index = FindIndex(gpionum);
	if (index < 0)
		return index;
	return _getvalue(index);
}

int tcGpio::GetValue(char* name)
{
	int index = FindIndex(name);
	if (index < 0)
		return index;
	return _getvalue(index);
}

int tcGpio::_setedge(int index, unsigned int falling_edge, unsigned int rising_edge)
{
	char path[256];

	snprintf(path, 256, "/sys/class/gpio/gpio%d/edge",mpPins[index].config.gpionum);
	int fid = open(path,O_WRONLY);
	if (fid >= 0)
	{
		if (falling_edge && rising_edge)
		{
			write(fid, "both\n", 5);
		}
		else if (falling_edge)
		{
			write(fid, "falling\n", 8);
		}
		else if (rising_edge)
		{
			write(fid, "rising\n", 7);
		}
		else
		{
			write(fid, "none\n", 5);
		}
		close(fid);
		return 0;
	}
	else
	{
		perror(path);
		return -1;
	}
}

void tcGpio::ShutdownThread()
{ 
	mbShutDown = true; 
#ifdef USE_PTHREAD
	pthread_join(mcThread, NULL);
#endif
}

#ifdef GPIO_APP

using namespace MityDSP;

void print_help(char* cmd_name)
{
	fprintf(stderr, "Usage: %s gpionum <command>\n", cmd_name);
	fprintf(stderr, "Supported Commands\n"
		"    get : set pin as input and dump the state\n"
		"    monitor : set pin as input and monitor state of pin and exit when 'q' is hit\n"
		"    set <0|1> : set pin as output and drive to value\n"
		"    toggle <width_ms> <cycles> : toggle state of pin once every <width_ms> msecs for <cycles> toggles and exit\n"
	);
}

#ifdef USE_PTHREAD
void MonitorHandler(unsigned int gpionum, unsigned int val, void* apUserData)
{
	printf("GPIO %d value is %d\n", gpionum, val);
}
#endif

int main(int argc, char* argv[])
{
	tcGpio* lpGpio;
	int rv = -1;
	int	gpionum, val;
	unsigned int width_ms, cycles;
	int monitor_time_s = 10;
	bool infinite;
	signed char opt;

	while ((opt = getopt(argc, argv, "h")) != -1)
	{
		switch (opt)
		{
		case 'h': /* '?' */
		default: /* '?' */
			print_help(argv[0]);
			return -1;
		}
	}

	if (optind >= argc)
	{
		fprintf(stderr, "Not enough arguments\n");
		print_help(argv[0]);
		return -1;
	}

	gpionum = atoi(argv[optind]);
	optind++;
	if (optind >= argc)
	{
		fprintf(stderr, "Not enough arguments\n");
		print_help(argv[0]);
		return -1;
	}

#ifndef _POSIX_THREADS
	printf("No posix threads\n");
#else
	printf("Posix threads\n");
#endif

	tcGpio::tsPinConfig config;
	config.gpionum = gpionum;
	config.rising_edge = 1;
	config.falling_edge = 1;
	config.active_low = 0;
	config.output = 0;
	config.val = 0;
	config.handler_data = NULL;
	config.handler = NULL;
	config.observer = NULL;
	config.name = (char*)"GPIO Test Pin";

	if (!strncasecmp("monitor", argv[optind], 7))
	{
#ifdef USE_PTHREAD
		/* Add handler */
		config.handler = MonitorHandler;

		printf("Watching GPIO %d for %d secs\n", gpionum, monitor_time_s);

		lpGpio = new tcGpio(&config, 1);

		/* Watch for 10 seconds */
		sleep(monitor_time_s);

		printf("Shutting down the gpio monitor\n");
		lpGpio->ShutdownThread();

		delete lpGpio;
#else
		printf("Not implemented yet\n");
		return -1;
#endif
	}
	else if (!strncasecmp("get", argv[optind], 3))
	{
		lpGpio = new tcGpio(&config, 1);
		val = lpGpio->GetValue(gpionum);
		printf("GPIO %d value is %d\n", gpionum, val);
		delete lpGpio;
	}
	else if (!strncasecmp("toggle", argv[optind], 6))
	{
		optind++;
		if (optind+1 >= argc)
		{
			fprintf(stderr, "not enough arguments provided\n");
			rv = -1;
			goto err_exit;
		}
		width_ms = atoi(argv[optind]);
		cycles = atoi(argv[optind+1]);
		infinite = cycles == 0;

		printf("Toggling GPIO %d:", gpionum);
		config.output = 1;
		lpGpio = new tcGpio(&config, 1);
		for (unsigned int i = 0; i < cycles || infinite; i++)
		{
			rv = lpGpio->SetValue(gpionum, 1);
			usleep(width_ms * 1000);
			rv = lpGpio->SetValue(gpionum, 0);
			usleep(width_ms * 1000);
		}
		printf(" %d\n", rv);
		delete lpGpio;
	}
	else if (!strncasecmp("set", argv[optind], 3))
	{
		optind++;
		if (optind >= argc)
		{
			fprintf(stderr, "no value provided\n");
			rv = -1;
			goto err_exit;
		}
		val = atoi(argv[optind]);
		printf("Setting GPIO %d to %d :", gpionum, val);
		config.output = 1;
		config.val = val;
		lpGpio = new tcGpio(&config,1);
		rv = lpGpio->SetValue(gpionum, val);
		printf(" %d\n", rv);
		delete lpGpio;
	}
	else
	{
		fprintf(stderr, "unknown command\n");
		print_help(argv[0]);
		rv = -1;
	}

err_exit:
    return rv;
}


#endif
