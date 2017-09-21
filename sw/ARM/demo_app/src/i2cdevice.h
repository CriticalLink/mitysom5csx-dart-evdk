#ifndef I2CDEVICE_H
#define I2CDEVICE_H

namespace MityDSP
{

class tcI2CDevice
{
public:
    static const int gnBaseErr    = -1000;
    static const int gnBaseDevErr = -1100;
    
    tcI2CDevice(int bus, int slave_addr);
    virtual ~tcI2CDevice(void);
    
    virtual int Open(void);
    virtual int Close(void);
    virtual const char* GetError(int err);
    int Bus() const { return mnBus; }
    int Addr() const { return mnAddr; }

protected:
    int  mnFd;
    int  mnBus;
    int  mnAddr;

};

};

#endif
