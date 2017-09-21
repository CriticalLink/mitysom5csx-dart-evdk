#include "i2cdevice.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <linux/i2c-dev.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

using namespace MityDSP;

tcI2CDevice::tcI2CDevice(int bus, int slave_addr)
: mnFd(-1)
, mnBus(bus)
, mnAddr(slave_addr)
{
}

tcI2CDevice::~tcI2CDevice(void)
{
   if (mnFd >= 0)
   {
       Close();
   }
}
    
int tcI2CDevice::Open(void)
{
    int ret;
    char fname[100];
    char buff[128];
    sprintf(fname,"/dev/i2c-%d",mnBus);
    mnFd = open(fname,O_RDWR);
    if (mnFd < 0) 
    {
	sprintf(buff, "tcI2CDevice::Open:%s:",fname);
	perror(buff);
        return mnFd;
    }
    ret = ioctl(mnFd, I2C_SLAVE, mnAddr);
    if (ret < 0)
    {
	perror("tcI2CDevice::Open:ioctl:");
        Close();
    }
    return ret;
}

int tcI2CDevice::Close(void)
{
    //Return success if nothing to close
    int retval = 0;
    
    if (mnFd >= 0)
    {
        retval = close(mnFd);
        mnFd = -1;
    }

    return retval;
}

const char* tcI2CDevice::GetError(int /* err */)
{
    return "Unknown";
}
