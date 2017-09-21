/*
 * tcHdmiDriver is a class which uses tcTfp410 and tcGpio::Observer to provide
 * the necessary functionality.
 */

#include "gpio.h"
#include "tfp410.h"
 
#ifndef HDMIDRIVER_H_
#define HDMIDRIVER_H_

class tcHdmiDriver : public MityDSP::tcGpio::Observer {
public:
	class MsenObserver {
	public:
		virtual void displayConnected(bool abConnected) = 0;
	};

	tcHdmiDriver(MsenObserver *apObserver = NULL);
	virtual ~tcHdmiDriver();

	int initialize();

	unsigned int getVRes();
	unsigned int getHRes();

	virtual void Handler(unsigned int gpionum, unsigned int val);
private:
	MityDSP::tcTFP410 *mpTfp;

	MsenObserver *mpObserver;
};

#endif /* HDMIDRIVER_H_ */
