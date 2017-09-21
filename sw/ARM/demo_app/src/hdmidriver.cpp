#include <iostream>
#include <cstring>

#include "hdmidriver.h"
using namespace MityDSP;

// These are configurable:
#define TFP_BUS		(1)
#define A3_BIT		(0)
#define A2_BIT		(0)
#define A1_BIT		(0)

#define MSEN_PIN	(213)
#define PD_N_PIN	(210)
#define RST_N_PIN	(217)

// Address is defined by the Ax bits above. Do not change this.
#define TFP_ADDR	(0x38 | ((A3_BIT << 2) | (A2_BIT << 1) | (A1_BIT << 0)))

/**
 * tcHdmiDriver has a tcTFP410 and tcGpio for manipulating it.
 */
tcHdmiDriver::tcHdmiDriver(MsenObserver *apObserver)
: tcGpio::Observer()
, mpObserver(apObserver)
{
	// Setup the TFP410
	tcTFP410::PinMapping pins;
	pins.mnMSEN = MSEN_PIN;
	pins.mnPD_N = PD_N_PIN;
	pins.mnRST_N = RST_N_PIN;

	pins.mbMSenFalling = true;
	pins.mbMSenRising = true;
	pins.mpMsenChangeObserver = this;

	mpTfp = new tcTFP410(TFP_BUS, TFP_ADDR, pins);
}

tcHdmiDriver::~tcHdmiDriver()
{
	delete mpTfp;
}

/**
 * Opens the I2C defice and default configures the TFP410:
 *    - PD_N set to 1 (so it is powered up)
 *    - 24-bit data input
 *    - Rising-edge latched
 *    - differential clock
 *    - HSYNC/VSYNC transmitted as supplied
 *    - TMDS enabled
 *    - Clock deskew disabled
 *    - DE generator disabled
 *    - MSEN pin set to monitor/follow HTPLG
 *
 * @return 0 if successful.
 */
int tcHdmiDriver::initialize()
{
	int rv = 0;

	// Address/DKEN pins are driven at construction time of mpGpio.

	// Initialize the TFP410 I2C interface
	rv = mpTfp->Initialize();

	// With all the objects initialized, configure the TFP410.
	if(rv == 0) {
		tcTFP410::tuCtl1Register ctrl = mpTfp->getCtlReg();
		ctrl.msBits.PD_N = 1; // Not powered down, 24-bit single-edge, rising-edge latched, differential clock.
		ctrl.msBits.EDGE = 1;
		ctrl.msBits.BSEL = 1;
        ctrl.msBits.DSEL = 1;
		ctrl.msBits.HEN  = 1; // HSYNC and VSYNC transmitted as supplied
		ctrl.msBits.VEN  = 1;
		ctrl.msBits.TDIS = 0; // TMDS enabled according to PD_N state.
		mpTfp->setCtlReg(ctrl);

		// Clock deskew; set to disabled
		mpTfp->setDeskew(false, 0);

		// Disable the DE Generator.
		mpTfp->setDEGenerator(false, 0, 0, 0, 0);

		mpTfp->setVertSyncPol(1);
		mpTfp->setHorSyncPol(1);
		
		// Configure the Msen pin to observe HTPLG.
		mpTfp->setMsenPin(tcTFP410::eeMsenHtplg);
	}

	return rv;
}

/**
 * @return the vertical resolution as reported by the TFP410
 */
unsigned int tcHdmiDriver::getVRes()
{
	return mpTfp->getVRes();
}

/**
 * @return the horizontal resolution as reported by the TFP410
 */
unsigned int tcHdmiDriver::getHRes()
{
	return mpTfp->getHRes();
}

/**
 * Watches the transitions of MSEN to denote changes to the HTPLG bit.
 */
void tcHdmiDriver::Handler(unsigned int gpionum, unsigned int val)
{
	if(mpObserver)
	{
		if(val)
		{
			mpObserver->displayConnected(true);
		}
		else
		{
			mpObserver->displayConnected(false);
		}
	} else {
		if(val)
		{
			std::cout << "HTPLG rising edge.\n";
		}
		else
		{
			std::cout << "HTPLG falling edge.\n";
		}
	}
}


