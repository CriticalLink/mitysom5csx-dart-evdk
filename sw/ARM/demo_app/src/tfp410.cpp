#include "tfp410.h"
#include <stdio.h>
#include <stdint.h>
#include "i2c-dev.h"

using namespace MityDSP;

/* register definitions according to the TFP410 data sheet */
#define TFP410_VID		0x014C
#define TFP410_DID		0x0410

#define TFP410_VID_LO		0x00
#define TFP410_VID_HI		0x01
#define TFP410_DID_LO		0x02
#define TFP410_DID_HI		0x03
#define TFP410_REV		0x04

#define TFP410_CTL_1		0x08
#define TFP410_CTL_1_TDIS	(1<<6)
#define TFP410_CTL_1_VEN	(1<<5)
#define TFP410_CTL_1_HEN	(1<<4)
#define TFP410_CTL_1_DSEL	(1<<3)
#define TFP410_CTL_1_BSEL	(1<<2)
#define TFP410_CTL_1_EDGE	(1<<1)
#define TFP410_CTL_1_PD		(1<<0)

#define TFP410_CTL_2		0x09
#define TFP410_CTL_2_VLOW	(1<<7)
#define TFP410_CTL_2_MSEL_MASK	(0x7<<4)
#define TFP410_CTL_2_MSEL	(1<<4)
#define TFP410_CTL_2_TSEL	(1<<3)
#define TFP410_CTL_2_RSEN	(1<<2)
#define TFP410_CTL_2_HTPLG	(1<<1)
#define TFP410_CTL_2_MDI	(1<<0)

#define TFP410_CTL_3		0x0A
#define TFP410_CTL_3_DK_MASK 	(0x7<<5)
#define TFP410_CTL_3_DK		(1<<5)
#define TFP410_CTL_3_DKEN	(1<<4)
#define TFP410_CTL_3_CTL_MASK	(0x7<<1)
#define TFP410_CTL_3_CTL	(1<<1)

#define TFP410_USERCFG		0x0B

#define TFP410_DE_DLY		0x32

#define TFP410_DE_CTL		0x33
#define TFP410_DE_CTL_DEGEN	(1<<6)
#define TFP410_DE_CTL_VSPOL	(1<<5)
#define TFP410_DE_CTL_HSPOL	(1<<4)
#define TFP410_DE_CTL_DEDLY8	(1<<0)

#define TFP410_DE_TOP		0x34

#define TFP410_DE_CNT_LO	0x36
#define TFP410_DE_CNT_HI	0x37

#define TFP410_DE_LIN_LO	0x38
#define TFP410_DE_LIN_HI	0x39

#define TFP410_H_RES_LO		0x3A
#define TFP410_H_RES_HI		0x3B

#define TFP410_V_RES_LO		0x3C
#define TFP410_V_RES_HI		0x3D

/**
 * Construct a TFP410 controller.
 *
 * @param bus - the I2C bus this device lives on
 * @param addr - the address on the I2C bus this device lives on
 * @param acPins - the GPIO pin configuration connected to the device
 */
tcTFP410::tcTFP410(int bus, int addr, PinMapping acPins)
: tcI2CDevice(bus, addr)
, mcPinMap(acPins)
, mpPins(NULL)
{
	tcGpio::tsPinConfig *pins = mcPinMap.gpioPinConfig();
	mpPins = new tcGpio(pins, mcPinMap.pinCount());
	delete [] pins;
}

/**
 * Destroy the device; just deletes the GPIOs.
 *
 * Does not power down the device or change any configurations.
 */
tcTFP410::~tcTFP410(void)
{
	delete mpPins;
}

/**
 * Pretty print function. Accepts a FILE* to writes the current state of all
 * registers to that FILE.
 *
 * @param apStream FILE* to write the register contents to.
 * @return 0
 */
int tcTFP410::DumpRegisters(FILE* apStream)
{
	uint8_t val, val2;
    int32_t temp;
    if (NULL == apStream)
    {
        apStream = stdout;
    }

	val = i2c_smbus_read_byte_data(mnFd, TFP410_REV);
	fprintf(apStream, "TFP410_REV: 0x%02X\n", val);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_1);
	fprintf(apStream, "TFP410_CTL1: 0x%02X\n", val);
    fprintf(apStream, "   PD:%d\tEDGE:%d\tBSEL:%d\tDSEL:%d\n"
                      "   HEN:%d\tVEN:%d\tTDIS:%d\t\n",
                      val&0x1?1:0,
                      val&0x2?1:0,
                      val&0x4?1:0,
                      val&0x8?1:0,
                      val&0x10?1:0,
                      val&0x20?1:0,
                      val&0x40?1:0);                      
	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_2);
	fprintf(apStream, "TFP410_CTL2: 0x%02X\n", val);
    fprintf(apStream, "   MDI:%d\tHTPLG:%d\tRSEN:%d\tTSEL:%d\n"
                      "   MSEL:%d\tVLOW:%d\n",
                      val&0x1?1:0,
                      val&0x2?1:0,
                      val&0x4?1:0,
                      val&0x8?1:0,
                      (val&0x70)>>4,
                      val&0x80?1:0);                      
	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_3);
	fprintf(apStream, "TFP410_CTL3: 0x%02X\n", val);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_USERCFG);
	fprintf(apStream, "TFP410_USERCFG: 0x%02X\n", val);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_DLY);
	fprintf(apStream, "TFP410_DE_DLY: 0x%02X\n", val);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CTL);
	fprintf(apStream, "TFP410_DE_CTL: 0x%02X\n", val);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_TOP);
    val &= 0x7F;
	fprintf(apStream, "TFP410_DE_TOP: 0x%02X (%d lines)\n", val, val);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CNT_LO);
	val2 = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CNT_HI);
    temp = val2;
    temp <<= 8;
    temp |= val;
    temp &= 0x7FF;
	fprintf(apStream, "TFP410_DE_CNT: 0x%02X%02X (%d pixels)\n", val2, val, temp);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_LIN_LO);
	val2 = i2c_smbus_read_byte_data(mnFd, TFP410_DE_LIN_HI);
    temp = val2;
    temp <<= 8;
    temp |= val;
    temp &= 0x7FF;
	fprintf(apStream, "TFP410_DE_LIN: 0x%02X%02X (%d lines)\n", val2, val, temp);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_H_RES_LO);
	val2 = i2c_smbus_read_byte_data(mnFd, TFP410_H_RES_HI);
    temp = val2;
    temp <<= 8;
    temp |= val;
    temp &= 0x7FF;
	fprintf(apStream, "TFP410_H_RES: 0x%02X%02X (%d cols)\n", val2, val, temp);
	val = i2c_smbus_read_byte_data(mnFd, TFP410_V_RES_LO);
	val2 = i2c_smbus_read_byte_data(mnFd, TFP410_V_RES_HI);
    temp = val2;
    temp <<= 8;
    temp |= val;
    temp &= 0x7FF;
	fprintf(apStream, "TFP410_V_RES: 0x%02X%02X (%d lines)\n", val2, val, temp);

	return 0;
}

/**
 * Set VSYNC active polarity.
 *
 * @param high 1 for active high polarity, 0 for active low polarity
 * @return 0
 */
int tcTFP410::setVertSyncPol(int high)
{
	uint8_t val;
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CTL);
    if (high)
        val |= TFP410_DE_CTL_VSPOL;
    else
        val &= ~TFP410_DE_CTL_VSPOL;
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_CTL, val);
    return 0;
}

/**
 * Get VSYNC active polarity.
 *
 * @return 1 for active high polarity, 0 for active low polarity
 */
int tcTFP410::getVertSyncPol(void)
{
	uint8_t val;
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CTL);
    return (val & TFP410_DE_CTL_VSPOL) ? 1 : 0;
}

/**
 * Set HSYNC active polarity.
 *
 * @param high 1 for active high polarity, 0 for active low polarity
 * @return 0
 */
int tcTFP410::setHorSyncPol(int high)
{
	uint8_t val;
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CTL);
    if (high)
        val |= TFP410_DE_CTL_HSPOL;
    else
        val &= ~TFP410_DE_CTL_HSPOL;
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_CTL, val);
    return 0;
}

/**
 * Get HSYNC active polarity.
 *
 * @return 1 for active high polarity, 0 for active low polarity
 */
int tcTFP410::getHorSyncPol(void)
{
	uint8_t val;
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CTL);
    return (val & TFP410_DE_CTL_HSPOL) ? 1 : 0;
}

/**
 * Initialize the device.
 *
 * This toggles the GPIOs to take the device out of power down, and reset to
 * place it into I2C control mode.
 *
 * @return 0 for success; non-zero for error
 */
int tcTFP410::Initialize(void)
{
	int ret;

	// Set power up.
	setPinDirection(mcPinMap.mnPD_N, 1, 1);
	// RST low, then high to select I2C
	setPinDirection(mcPinMap.mnRST_N, 1, 0);
	setPinValue(mcPinMap.mnRST_N, 1);

	ret = Open();
    return ret;
}

/**
 * Set the configuration for MSEN. Use teMsenSelect enum to configure.
 *
 * @param the configuration for the MSEN pin.
 */
void tcTFP410::setMsenPin(tcTFP410::teMsenSelect aeMsenSelection)
{
	uint8_t val = aeMsenSelection;
    i2c_smbus_write_byte_data(mnFd, TFP410_CTL_2, val);
}

/**
 * Clears the interrupt asserted by MDI by writing a 1 to the register.
 */
void tcTFP410::clearInterrupt()
{
	uint8_t val;
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_2);
	val |= TFP410_CTL_2_MDI;
    i2c_smbus_write_byte_data(mnFd, TFP410_CTL_2, val);
}

/**
 * Retrieves the MSEN pin configuration.
 *
 * @param[out] arMsenState reference to teMSenSelect where the state will go
 * @return 0 on success, non-zero on error
 */
int tcTFP410::getMsenPin(tcTFP410::teMsenSelect &arMsenState)
{
	int rv = 0;
	uint8_t val;
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_2);
	
	val &= (TFP410_CTL_2_MSEL_MASK | TFP410_CTL_2_TSEL);
	switch(val)
	{
	case eeMsenDisabled:
	case eeMsenMdiRsen:
	case eeMsenMdiHtplg:
	case eeMsenRsen:
	case eeMsenHtplg:
		arMsenState = (teMsenSelect)val;
		break;
	default:
		rv = -1;
		break;
	}
	
	return rv;
}

/**
 * Returns the current state of the MDI interrupt assertion.
 *
 * The MDI bit is set when it is armed, when asserted it is set to logic '0'
 *
 * @return 1 if the bit indicates a logic level change; 0 if the bit is armed
 */
int tcTFP410::interrupt()
{
	uint8_t val;
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_2);
	
   	// Inverted logic; when the bit is high, it has not detected a change
   	// so when the bit is low, it is asserting an interrupt
	return (val & TFP410_CTL_2_MDI ? 0 : 1);
}

/**
 * Enable/Disable and set the data deskew.
 *
 * @param abEnable true to enable the deskew circuitry, false to disable
 * @param anDeskew the setting for the deskew amount. Valid range is [0, 7]
 */
void tcTFP410::setDeskew(bool abEnable, char anDeskew)
{
	uint8_t val;
	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_3);
	
	val &= ~(TFP410_CTL_3_DK_MASK | TFP410_CTL_3_DKEN);
	val |= ((anDeskew << 5) & TFP410_CTL_3_DK_MASK);
	
    i2c_smbus_write_byte_data(mnFd, TFP410_CTL_3, val);
}

/**
 * Sets the CTL bits.
 *
 * @param anCtl the CTL bits output on the DVI port
 */
void tcTFP410::setCTLBits(char anCtl)
{
	uint8_t val;
	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_3);
	
	val &= ~(TFP410_CTL_3_CTL_MASK);
	val |= ((anCtl << 1) & TFP410_CTL_3_CTL_MASK);
	
    i2c_smbus_write_byte_data(mnFd, TFP410_CTL_3, val);
}

/**
 * Fetch the current state of CTL_1_MODE register.
 *
 * @return the current CTL_1_MODE register
 */
tcTFP410::tuCtl1Register tcTFP410::getCtlReg()
{
	tuCtl1Register rv;
	
	uint8_t val;
	val = i2c_smbus_read_byte_data(mnFd, TFP410_CTL_1);
	
	rv.mnWord = val;
	
	return rv;
}

/**
 * Set the CTL_1_MODE register.
 *
 * @param arReg the register settings to write
 */
void tcTFP410::setCtlReg(tuCtl1Register &arReg)
{
    i2c_smbus_write_byte_data(mnFd, TFP410_CTL_1, arReg.mnWord);
}

/**
 * Enable/disable and configure the DE generator.
 *
 * @param abEnable true to enable the DE generator; false to disable it
 * @param de_dly pixels to wait after HSYNC goes active before DE is generated. range [0,1023]
 * @param de_top pixels to wait after VSYNC goes active before DE is generated. range [0,255]
 * @param de_cnt active display width when generator active. range [0,2047]
 * @param de_lin active display height when generator active. range [0,2047]
 */
void tcTFP410::setDEGenerator(bool abEnable, 
								unsigned short de_dly, 
								unsigned char de_top, 
								unsigned short de_cnt, 
								unsigned short de_lin)
{
	uint8_t val;
	
	// Disable the generator first and set/clear the top order de_dly bit.
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CTL);
	val &= ~TFP410_DE_CTL_DEGEN;
	if (de_dly & (1 << 8))
		val |= (1);
	else
		val &= ~(1);
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_CTL, val);
	
	// DE_DLY
	val = (uint8_t)de_dly;
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_DLY, val);
	
	// DE_TOP
	val = (uint8_t)de_top;
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_TOP, val);
	
	// DE_CNT
	val = (uint8_t)de_cnt;
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_CNT_LO, val);
	val = (uint8_t)(de_cnt >> 8);
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_CNT_HI, val);
	
	// DE_LIN
	val = (uint8_t)de_lin;
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_LIN_LO, val);
	val = (uint8_t)(de_lin >> 8);
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_LIN_HI, val);
	
	// Write in the final enable/disable state of the ctrl register.
   	val = i2c_smbus_read_byte_data(mnFd, TFP410_DE_CTL);
    if (abEnable)
        val |= TFP410_DE_CTL_DEGEN;
    else
        val &= ~TFP410_DE_CTL_DEGEN;
    i2c_smbus_write_byte_data(mnFd, TFP410_DE_CTL, val);
}

/**
 * @return the current state of the H_RES registers.
 */
unsigned int tcTFP410::getHRes()
{
	return get16BitVal(TFP410_H_RES_LO, TFP410_H_RES_HI);
}

/**
 * @return the current state of the V_RES registers.
 */
unsigned int tcTFP410::getVRes()
{
	return get16BitVal(TFP410_V_RES_LO, TFP410_V_RES_HI);
}

unsigned int tcTFP410::get16BitVal(unsigned int regLo, unsigned int regHi)
{
	unsigned int rv = 0;
	uint8_t val;
   	val = i2c_smbus_read_byte_data(mnFd, regLo);
	rv |= val;
   	val = i2c_smbus_read_byte_data(mnFd, regHi);
	rv |= (val << 8);
	
	return rv;
}

/* -- GPIO Functionality -- */

void tcTFP410::setPinDirection(unsigned int anPin, unsigned int direction, unsigned int value)
{
	if(anPin != -1) {
		mpPins->SetDirection(anPin, direction, value);
	}
}

void tcTFP410::setPinValue(unsigned int anPin, unsigned int value)
{
	if(anPin != -1) {
		mpPins->SetValue(anPin, value);
	}
}

int tcTFP410::PinMapping::pinCount()
{
	int count = 0;
	unsigned int num = count;
	for(int i = 0; i < 3; i++) {
		switch(i) {
		case 0:
			num = mnRST_N;
			break;
		case 1:
			num = mnPD_N;
			break;
		case 2:
			num = mnMSEN;
			break;
		}
		
		if(num != -1) {
			count++;
		}
	}
	
	return count;
}

tcGpio::tsPinConfig *tcTFP410::PinMapping::gpioPinConfig()
{
	tcGpio::tsPinConfig *rv = NULL;
	
	int count = pinCount();

	rv = new tcGpio::tsPinConfig[count];
	memset(rv, 0, sizeof(tcGpio::tsPinConfig)*count);
	
	unsigned int num;
	for(int i = 0; i < 3; i++) {
		switch(i) {
		case 0:
			num = mnRST_N;
			break;
		case 1:
			num = mnPD_N;
			break;
		case 2:
			num = mnMSEN;
			if(num != -1) {
				rv[i].rising_edge = mbMSenRising;
				rv[i].falling_edge = mbMSenFalling;
				rv[i].observer = mpMsenChangeObserver;
			}
			break;
		}
		
		if(num != 0) {
			rv[i].gpionum = num;
			rv[i].output = 0; //!< non-zero if should be output
		}
	}

	return rv;
}

/* -- Test App -- */

#ifdef TFP420_TEST
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
int main(int argc, char* argv[])
{
    tcTFP410* lpTFP410;
    int bus = 1;
    int opt;
    opterr = 0;
    
    while ((opt = getopt(argc, argv, "b:h")) != -1)
    {
        switch (opt)
        {
        case 'b':
            bus = strtoul(optarg,NULL,10);
            break;		

        case 'h': /* '?' */
        default: /* '?' */
            fprintf(stderr, "Usage: %s [-b busnum] <command>\n", argv[0]);
            fprintf(stderr, "Supported Commands\n"
                            "    dump        : dump state of controller\n"
                            "    vspol [0|1] : get/set vertical sync polarity (1=active high)\n"
                            "    hspol [0|1] : get/set horizontal sync polarity (1=active high)\n"
                            );
            return -1;
        }
    }
    
    if (optind >= argc)
    {
        fprintf(stderr, "Not enough arguments\n");
    }
    
    lpTFP410 = new tcTFP410(bus);
    if (lpTFP410->Initialize())
    {
        fprintf(stderr, "unable to open device\n");
        delete lpTFP410;
        return -1;
    }
    
    if (!strncasecmp("dump", argv[optind],4))
    {
        lpTFP410->DumpRegisters(stdout);
    }
    else if (!strncasecmp("vspol", argv[optind],5))
    {
        if (optind+1 < argc)
        {
            int high_low = strtoul(argv[optind+1],NULL,10);
            lpTFP410->setVertSyncPol(high_low);
        }
        else
        {
            int high_low = lpTFP410->getVertSyncPol();
            fprintf(stdout,"VSPOL = %d (%s)\n", high_low, high_low ? "active high" : "active_low");
        }
    }
    else if (!strncasecmp("hspol", argv[optind],5))
    {
        if (optind+1 < argc)
        {
            int high_low = strtoul(argv[optind+1],NULL,10);
            lpTFP410->setHorSyncPol(high_low);
        }
        else
        {
            int high_low = lpTFP410->getHorSyncPol();
            fprintf(stdout,"HSPOL = %d (%s)\n", high_low, high_low ? "active high" : "active_low");
        }
    }
    
    delete lpTFP410;
    return 0;
    
}
#endif
