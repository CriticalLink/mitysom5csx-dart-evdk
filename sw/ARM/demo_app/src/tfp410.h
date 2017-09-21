#ifndef TFP410_H
#define TFP410_H

#include "gpio.h"
#include "i2cdevice.h"
#include <stdio.h>

namespace MityDSP
{

class tcTFP410 : public tcI2CDevice
{
public:
	/**
	 * These are the GPIOs for controlling/monitoring the TFP410.
	 *
	 * Currently, this class only controls the device by I2C; if it is in 
	 * static configuration mode, there is no need to control it.
	 *
	 * Set to -1 (default) if the pin is not connected.
	 */
	class PinMapping {
	public:
		PinMapping()
		: mnRST_N(-1)
		, mnPD_N(-1)
		, mnMSEN(-1)
		, mbMSenRising(false)
		, mbMSenFalling(false)
		, mpMsenChangeObserver(NULL)
		{}

		unsigned int mnRST_N;
		unsigned int mnPD_N;
		unsigned int mnMSEN;

		bool mbMSenRising;
		bool mbMSenFalling;
		tcGpio::Observer *mpMsenChangeObserver;

	private:
		int pinCount();
		tcGpio::tsPinConfig *gpioPinConfig();

		friend class tcTFP410;
	};
	
	/**
	 * Enum used to select the MSEN functionality.
	 */
	enum teMsenSelect {
		eeMsenDisabled = 0b0000000,   // MSEN is disabled; always high.
		// When using the MDI bit, remember to call clearInterrupt()
		eeMsenMdiRsen = 0b0010000,    // MSEN reflects the MDI bit (monitoring RSEN)
		eeMsenMdiHtplg = 0b0011000,   // MSEN reflects the MDI bit (monitoring HTPLG)
		eeMsenRsen = 0b0100000,       // MSEN reflects the RSEN bit
		eeMsenHtplg = 0b0110000       // MSEN reflects the HTPLG bit
	};

    tcTFP410(int bus, int addr = 0x38, PinMapping acPins = PinMapping());
    virtual ~tcTFP410(void);
    int   Initialize(void);
    
    int DumpRegisters(FILE* apStream = NULL);
    int setVertSyncPol(int high);
    int getVertSyncPol(void);
    int setHorSyncPol(int high);
    int getHorSyncPol(void);
	
	typedef union tuCtl1Register
	{
		struct
		{					      //	Bit		Default	Comment
			unsigned char PD_N :1;//	0		0		Power down (active low)
			unsigned char EDGE :1;//	1		0		Data latch edge (1 = rising edge)
			unsigned char BSEL :1;//	2		0		Bit-select (1 = 24-bit single-edge; 0 = 12-bit double-edge)
			unsigned char DSEL :1;//	3		0		See Table 1 in datasheet.
			unsigned char HEN  :1;//	4		0		HSYNC enable (0 = low; 1 = transmitted in original state)
			unsigned char VEN  :1;//	5		0		VSYNC enable (0 = low; 1 = transmitted in original state)
			unsigned char TDIS :1;//	6		0		T.M.D.S circuit (0 = PD_N state; 1 = disabled)
			unsigned char RSVD :1;//	7		0		
		} msBits;
		unsigned char mnWord;
	} tuCtl1Register;
	
	tuCtl1Register getCtlReg();
	void setCtlReg(tuCtl1Register &arReg);
	
	void setDEGenerator(bool abEnable, 
	                    unsigned short de_dly, 
						unsigned char de_top, 
						unsigned short de_cnt, 
						unsigned short de_lin);

	void setDeskew(bool abEnable, char anDeskew);
	void setCTLBits(char anCtl);
	
	unsigned int getHRes();
	unsigned int getVRes();
	
	void setMsenPin(teMsenSelect aeMsenSelection);
	int getMsenPin(teMsenSelect &arMsenState);
	void clearInterrupt();
    int interrupt();
	
private:
	unsigned int get16BitVal(unsigned int regLo, unsigned int regHi);

	void setPinDirection(unsigned int anPin, unsigned int direction, unsigned int value = 0);
	void setPinValue(unsigned int anPin, unsigned int value);

	PinMapping mcPinMap;
	tcGpio *mpPins;
};

}

#endif
