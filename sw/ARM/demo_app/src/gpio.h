/*
 * gpio.h
 *
 *      Author: mikew
 */

#ifndef GPIO_H_
#define GPIO_H_

/* Check for HAVE_PTHREAD_H defined by configure */
# if defined(HAVE_PTHREAD_H)
#  define USE_PTHREAD
#  include <pthread.h>
# endif /* HAVE_PTHREAD_H */
#include <time.h>

namespace MityDSP {

class tcGpio {
public:
	class Observer {
	public:
		Observer(void) {}
		virtual ~Observer(void) {}
		virtual void Handler(unsigned int gpionum,
				     unsigned int val) = 0;
	};

	typedef void (*ChangeHandler)(unsigned int gpionum, 
				      unsigned int val,
				      void* apUserData);

	typedef struct PinConfig
	{
		unsigned int	gpionum;//!< logical gpio number
		unsigned int	output; //!< non-zero if should be output
		unsigned int	val;	//!< value to set if output
		unsigned int	rising_edge; //!< non-zero for notification
		unsigned int	falling_edge; //!< non-zero for notification
		unsigned int	active_low;  //!< non-zero if active low
		ChangeHandler	handler; //!< optional callback for change
		void*		handler_data; //!< optional data for handler callback
		Observer*	observer; //!< optional observer object for change
		char*		name; //!< optional name for pin
	} tsPinConfig;

	tcGpio(tsPinConfig* apConfigs, unsigned int NumPins);
	virtual ~tcGpio(void);

	int SetDirection(unsigned int gpionum, unsigned int output,
			 unsigned int value);
	int SetDirection(char* name, unsigned int output, unsigned int value);

	int SetActiveLow(unsigned int gpionum, unsigned int active_low);
	int SetActiveLow(char* name, unsigned int active_low);

	int SetValue(unsigned int gpionum, unsigned int value);
	int SetValue(char* name, unsigned int value);

	int GetValue(unsigned int gpionum);
	int GetValue(char* name);

	int WaitForInterrupt(time_t tv_sec=1, time_t tv_nsec=0);
	void ShutdownThread();

protected:
	int FindIndex(char* name);
	int FindIndex(unsigned int gpionum);
	int _setdirection(int index, unsigned int output, unsigned int value);
	int _setactivelow(int index, unsigned int active_low);
	int _setvalue(int index, unsigned int value);
	int _getvalue(int index);
	int _setedge(int index, unsigned int falling_edge, unsigned int rising_edge);
	static void* DispatchMonitor(void* apThis);
	void* MonitorThread(void);

	typedef struct PinState
	{
		tsPinConfig config;	//!< working configuration of pin
		int	    config_ok;	//!< non-zero if init was OK
		int	    val_fd;	//!< file descriptor of sysfs... val file
	} tsPinState;

	tsPinState*	mpPins;		//!< list of pins we are managing
	unsigned int	mnNumPins;	//!< size of the list
	volatile bool   mbShutDown;     //!< true when shutting down

#ifdef USE_PTHREAD
	pthread_t mcThread;
#endif
};

} /* namespace MityDSP */
#endif /* GPIO_H_ */
