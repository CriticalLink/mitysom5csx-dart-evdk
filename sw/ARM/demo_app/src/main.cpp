// main.cpp
// Include files to use the PYLON API.
#include <pylon/PylonIncludes.h>
#ifdef PYLON_WIN_BUILD
#    include <pylon/PylonGUI.h>
#endif

#include "BCONInput.h"
#include "GenICamModel.h"
#include "altera_vip/Mixer.hpp"
#include "frame_buffer_manager.h"
#include "hdmidriver.h"
#include "altera_vip/Clocked_Video_Output.hpp"

#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/input.h>
#include <getopt.h>
#include <fstream>

// Namespace for using pylon objects.
using namespace Pylon;
using namespace GenApi;

using namespace std;

static const uint32_t OVERLAY_FB_RD_ONLY_REGS_ADDR = 0xFF202000;
static const uint32_t VIP_MIXER_REGS_ADDR = 0xFF203000;
static const uint32_t CVO_REGS_ADDR = 0xFF204000; 
static const uint32_t BCON_INPUT_REGS_ADDR[2] = {0xFF205000, 0xFF20A000};
static const uint32_t PLL_REGS_ADDR[2] = {0xFF206000, 0xFF20B000};
static const uint32_t CAM_FB_WR_ONLY_REGS_ADDR[2] = {0xFF207000, 0xFF20C000};
static const uint32_t CAM_FB_RD_ONLY_REGS_ADDR[2] = {0xFF208000, 0xFF20D000};

#define MIXER_LAYER_OVERLAY (0)
#define MIXER_LAYER_CAM1 (1)
#define MIXER_LAYER_CAM2 (2)

static const uint32_t OVERLAY_FRAMES_BASE_ADDR = 0x20000000; //!< RAM address 
	//!< where overlay graphics are read from by FPGA.
static const uint32_t WR_ONLY_FRAMES_BASE_ADDR[2] = {0x23000000, 0x26000000}; //!< Where Writer
	//!< Only core writes received frames. Used by Reader Only for FPGA
	//!< passthrough (no Pylon) case.
static const uint32_t RD_ONLY_FRAMES_BASE_ADDR[2] = {0x29000000, 0x2C000000}; //!< Where Reader
	//!< Only reads frames from in pylon case.

static const uint32_t MAX_NUM_FRAMES = 3; //!< Number of frames each VIP FBII
	//!< core has to work with. 
// needs to change based on number of cameras...
// static const uint32_t FRAME_BYTES_PER_PIXEL = 1;
#define FRAME_BYTES_PER_PIXEL ((num_cams == 1) ? 3 : 1)

static const uint32_t MAX_BCON_FRAME_WIDTH = 2592; //!< Maximum frame width
	//!< supported by daA2500-14bc
static const uint32_t MAX_BCON_FRAME_HEIGHT = 1944; //!< Maximum frame height 
	//!< supported by daA2500-14bc

static const uint32_t OUTPUT_V_RES = 720; //!< Vertical resolution for output
	//!< source (i.e. HDMI monitor).
static const uint32_t OUTPUT_H_RES = 1280; //!< Horizontal resolution for output
	//!< source (i.e. HDMI monitor).

const string SINGLE_CAM_MODEL_NAMES[] = {"daA2500-14bc"};
const string DUAL_CAM_MODEL_NAMES[] = {"daA1280-54bm", "daA1280-54lm"};

//TODO: make this a better utility function? Rename to dumpInputFrame?
void dumpFrame(int BytesPerPixel)
{
	uint32_t FRAME_BYTES = MAX_BCON_FRAME_WIDTH*MAX_BCON_FRAME_HEIGHT*BytesPerPixel;
	tcFPGARegister<uint8_t> buff(WR_ONLY_FRAMES_BASE_ADDR[1], FRAME_BYTES);

	FILE* fp = fopen("/tmp/frame.raw", "w");
	if (!fp){
		cout << "Could not open file /tmp/frame.raw" << endl;
		return;
	}

	size_t retval = fwrite((const void*)&buff[0], 1, FRAME_BYTES, fp);

	if (retval != FRAME_BYTES){
		cout << "Only wrote " << retval << " of " << FRAME_BYTES << " to file" << endl;
	}

	fclose(fp);
}

void LogOutput(int level, const char *pFormat, ...)
{
	va_list(args);
	vprintf(pFormat, args);
}

/**
 * Fill the overlay framebuffer with logo image data.
 * 
 * \param[inout] frameBuffer Location to write image data to.
 * 
 * \return None.
 */
void fillOverlayFb(uint8_t* frameBuffer)
{
	const uint32_t BASLER_LOGO_WIDTH = 380;
	const uint32_t CL_LOGO_WIDTH = 190;
	const uint32_t LOGO_HEIGHT = 100;
	const uint32_t LOGO_BYTES_PER_PIXEL = 3;

	FILE* fp_basler = fopen("/home/root/basler_logo.raw", "r");
	if (!fp_basler)
	{
		cout << "Failed to open basler_logo.raw" << endl;
		return;
	}
	FILE* fp_cl = fopen("/home/root/critical_link_logo.raw", "r");
	if (!fp_cl)
	{
		cout << "Failed to open critical_link_logo.raw" << endl;
		fclose(fp_basler);
		return;
	}

	bool err_reported = false;
	
	int overlay_fb_offset = 0;
	for (int line = 0; line < LOGO_HEIGHT; line++)
	{
		size_t retval = 0;
		uint8_t pixel[3];

		for (int cnt = 0; cnt < CL_LOGO_WIDTH; cnt++)
		{
			retval = fread(&pixel, 1, 3, fp_cl);
			if (3 != retval && !err_reported)
			{
				err_reported = true;
				cout << "Error reading Critical Link logo at line " 
					<< line << " pixel " << cnt << endl;
			}
			uint8_t tmp = pixel[0];
			pixel[0] = pixel[2];
			pixel[2] = tmp;
			frameBuffer[overlay_fb_offset + 0] = pixel[0];
			frameBuffer[overlay_fb_offset + 1] = pixel[1];
			frameBuffer[overlay_fb_offset + 2] = pixel[2];
			overlay_fb_offset += 3;
		}

		for (int cnt = 0; cnt < BASLER_LOGO_WIDTH; cnt++)
		{
			retval = fread(&pixel, 1, 3, fp_basler);
			if (3 != retval && !err_reported)
			{
				err_reported = true;
				cout << "Error reading Basler logo at line " 
					<< line << " pixel " << cnt << endl;
			}
			uint8_t tmp = pixel[0];
			pixel[0] = pixel[2];
			pixel[2] = tmp;
			frameBuffer[overlay_fb_offset + 0] = pixel[0];
			frameBuffer[overlay_fb_offset + 1] = pixel[1];
			frameBuffer[overlay_fb_offset + 2] = pixel[2];
			overlay_fb_offset += 3;
		}
	}

	fclose(fp_basler);
	fclose(fp_cl);
}

/**
 * \return True if stdin has data to be read.
 */
bool inputAvailable()
{
	struct timeval tv;
	fd_set fds;
	tv.tv_sec = 0;
	tv.tv_usec = 0;
	FD_ZERO(&fds);
	FD_SET(STDIN_FILENO, &fds);
	select(STDIN_FILENO+1, &fds, NULL, NULL, &tv);
	return (FD_ISSET(0, &fds));
}

/**
 * Print application usage to stderr.
 * 
 * \return None.
 */
void printUsage(const char* exeName)
{
	fprintf(stderr, "Usage: %s [OPTIONS]\n", exeName);
	fprintf(stderr,
	"Options include:\n"
	"--no-pylon-stream   - set this to disable using Pylon Stream API\n" 
	"                      for direct buffer access\n"
	"--help              - this menu\n"
	);
}

/*
/TODO: planning input args:
single_cam_app
--brightness
--framerate
--width
--height
--x-offset
--y-offset
--no-pylon-stream (Use FPGA passthrough)
 */

#define SYSID_FNAME "/sys/devices/soc/ff200000.bus/ff200000.sysid/sysid/id"

/**
 * Command line application entry point.
 */
int main(int argc, char* argv[])
{
	// set this based on FPGA id register.  IDs > 0xFFFF are dual camera
	int num_cams = 1;
	std::ifstream sysid_file;
	sysid_file.open(SYSID_FNAME);
	if (!sysid_file)
	{
		cerr << "unable to open FPGA ID file." << endl;
		exit(1);
	}
	int sysid;
	sysid_file >> sysid;
	if (sysid > 0x0000FFFF)
	{
		num_cams = 2;
	}
	sysid_file.close();

	uint32_t img_width = 1280; // width of frame being captured 
	// for Dual cams cut in half for now so we can display half of each camera on bottom and top halves of screen
	uint32_t img_height = 720/num_cams; // height of frame being captured

	bool no_pylon_stream = false; //!< If true bypass pylon streaming adapter
		//!< and pass image data straight through FPGA.

	int exit_code = EXIT_SUCCESS;
	int retval = 0;

	int opt;
	int option_index = 0;
	static struct option long_options[] =                                   
	{                                                               
		{"no-pylon-stream", no_argument, 0, 'n'},
		{"version", no_argument, 0, 'v'},
		{"help", no_argument, 0, 'h'}
	};      

	cout << "Build Info: " << __DATE__ << " " << __TIME__ << endl;

	// Parse command line arguments                                         
	while ((opt = getopt_long(argc, argv, "nhv", long_options, &option_index)) != -1)
	{
		switch (opt) 
		{
			case 'n':
				no_pylon_stream = true;
				break;

			case 'h':
				printUsage(argv[0]);
				return EXIT_SUCCESS;
				break;

			case 'v':
				return EXIT_SUCCESS;
				break;

			default:
				printf("Uknonwn input argumetn.\n");
				printUsage(argv[0]);
				return EXIT_SUCCESS;
				break;
		}
	}

	if (no_pylon_stream)
	{
		cout << "Bypassing Pylon Stream for image display." << endl << endl;
	}
	else
	{
		cout << "Going to use Pylon Stream to capture and display images." << endl << endl;
	}

	// number of channels needs to change based on number of cameras
	Mixer* mixer = new Mixer(VIP_MIXER_REGS_ADDR, 1 + num_cams);
	mixer->stop();

	// need multiple of these for dual camera case
	tcFrameBufferManager* cam_fb_reader_only[2] = {NULL, NULL};
	tcFrameBufferManager* cam_fb_wr_rd[2] = {NULL, NULL};
	tcBCONInput* bcon_input[2] = {NULL, NULL};
	if (!no_pylon_stream)
	{
		for (int cnt = 0; cnt < num_cams; cnt++)
		{
			cam_fb_reader_only[cnt] = new tcFrameBufferManager(0, 
				CAM_FB_RD_ONLY_REGS_ADDR[cnt], RD_ONLY_FRAMES_BASE_ADDR[cnt],
				MAX_NUM_FRAMES, img_width, img_height, 
				FRAME_BYTES_PER_PIXEL);
			cam_fb_reader_only[cnt]->enableRd(false);
		}
	}
	else
	{
		// loop based on number of cameras expected.
		for (int cnt = 0; cnt < num_cams; cnt++)
		{
			bcon_input[cnt] = new tcBCONInput(BCON_INPUT_REGS_ADDR[cnt]);

			bcon_input[cnt]->reset(true);
			usleep(200000);
			bcon_input[cnt]->reset(false);
			usleep(200000);
			bcon_input[cnt]->resetPLL(true);
			usleep(200000);
			bcon_input[cnt]->resetPLL(false);

			bcon_input[cnt]->reset(false);
			bcon_input[cnt]->resetPLL(false);
			cout << "Cam " << cnt+1 << ": Resetting PLL..." << flush;
			while(!bcon_input[cnt]->inputClockLocked()) 
			{
				usleep(100);
			}
			cout << "done" << endl;

			cam_fb_wr_rd[cnt] = new tcFrameBufferManager(CAM_FB_WR_ONLY_REGS_ADDR[cnt], 
				CAM_FB_RD_ONLY_REGS_ADDR[cnt], WR_ONLY_FRAMES_BASE_ADDR[cnt], 
				MAX_NUM_FRAMES, MAX_BCON_FRAME_WIDTH, 
				MAX_BCON_FRAME_HEIGHT, FRAME_BYTES_PER_PIXEL);
			cam_fb_wr_rd[cnt]->enableRd(false);
			cam_fb_wr_rd[cnt]->enableWr(false);
		}
	}

	tcFrameBufferManager* overlay_fb_reader_only = new tcFrameBufferManager(0, 
		OVERLAY_FB_RD_ONLY_REGS_ADDR, OVERLAY_FRAMES_BASE_ADDR, 
		MAX_NUM_FRAMES, OUTPUT_H_RES, OUTPUT_V_RES, 
		FRAME_BYTES_PER_PIXEL);
	overlay_fb_reader_only->enableRd(false);

	Clocked_Video_Output* cvo = new Clocked_Video_Output(CVO_REGS_ADDR); 
	cvo->stop();

	tcHdmiDriver* hdmi_driver = new tcHdmiDriver();

	// Before using any pylon methods, the pylon runtime must be initialized. 
	PylonInitialize();

	CInstantCamera* cameras[2] = {NULL, NULL};

	try
	{
		DeviceInfoList_t dev_infos;
		CTlFactory& factory = CTlFactory::GetInstance();
		int num_detected_cams = factory.EnumerateDevices(dev_infos);
		if (num_cams  < 1 || num_cams > 2 || num_cams != dev_infos.size() || num_detected_cams != num_cams)
		{
			cout << "Enumerated " << num_detected_cams << " cameras. FPGA expects " << num_cams << ". Exiting." << endl;
			return EXIT_FAILURE;
		}

		for (int cnt = 0; cnt < num_cams; cnt++)
		{
			const CDeviceInfo& dev_info = dev_infos[cnt];
			const string model_name(dev_info.GetModelName());
			const string dev_factory(dev_info.GetDeviceFactory());
			cout << "Model Name for Camera " << cnt+1 << " of " << 
				num_cams << " is: " << model_name << endl;
			cout << "Device Factory for Camera " << cnt+1 << " of " << 
				num_cams << " is: " << dev_factory << endl;
			if (1 == num_cams)
			{
				// Go through the list of supported single cameras
				bool foundModel = false;
				for (int i = 0; i < sizeof(SINGLE_CAM_MODEL_NAMES); i++)
				{
					foundModel |= model_name == SINGLE_CAM_MODEL_NAMES[i];
				}
				if (!foundModel)
				{
					cout << "In correct Model Name for Single Camera Configuration. Exiting." << endl;
					return EXIT_FAILURE;
				}
			}
			else if (2 == num_cams)
			{
				// Go through the list of supported dual cameras
				bool foundModel = false;
				for (int i = 0; i < sizeof(DUAL_CAM_MODEL_NAMES); i++)
				{
					foundModel |= model_name == DUAL_CAM_MODEL_NAMES[i];
				}
				if (!foundModel)
				{
					cout << "In correct Model Name for Dual Camera Configuration. Exiting." << endl;
					return EXIT_FAILURE;
				}
			}
			// TODO this is a work-around for dual camera examples.  Currently there is no obvious way to 
			// determine which enumerated BCON stream / camera is which.  For whatever reason, the 
			// Basler API is enumerating them in reverse order.  I think there may be a way to figure 
			// out which one is which via the transport layer node map, but for now this will be OK.
			cameras[num_cams - 1 - cnt] = new CInstantCamera(factory.CreateDevice(dev_info));
		}

		for (int idx = 0; idx < num_cams; idx++)
		{
			cameras[idx]->Open();

			INodeMap& control = cameras[idx]->GetNodeMap();

			if (num_cams == 1)
			{
				const CEnumerationPtr pf = control.GetNode("PixelFormat");
				if (!pf)
				{
					cout << "Failure getting PixelFormat node. Exiting." << endl;
					return EXIT_FAILURE;
				}
				string colorspace = "RGB8";
				IEnumEntry *f = pf->GetEntryByName(colorspace.c_str());
				if (!f)
				{
					cout << "Failure getting " << colorspace << 
						" entry from PixelFormat node. Exiting." << endl;
					return EXIT_FAILURE;
				}
				pf->SetIntValue(f->GetValue());
			}

			const CBooleanPtr revY = control.GetNode("ReverseY");
			if (!revY)
			{
				cout << "Failure getting ReverseY node. Exiting." << endl;
				return EXIT_FAILURE;
			}
			revY->SetValue(true);

			const CBooleanPtr revX = control.GetNode("ReverseX");
			if (!revX)
			{
				cout << "Failure getting RevserseX node. Exiting." << endl;
				return EXIT_FAILURE;
			}
			revX->SetValue(true);

			// TODO: set based on input arguments... but also check against max FPGA can support
			const CIntegerPtr width = control.GetNode("Width");
			if (!width)
			{
				cout << "Failure getting Width node. Exiting." << endl;
				return EXIT_FAILURE;
			}
			const CIntegerPtr height = control.GetNode("Height");
			if (!height)
			{
				cout << "Failure getting Height node. Exiting." << endl;
				return EXIT_FAILURE;
			}
			const CIntegerPtr startX = control.GetNode("OffsetX");
			if (!startX)
			{
				cout << "Failure getting OffsetX node. Exiting." << endl;
				return EXIT_FAILURE;
			}
			const CIntegerPtr startY = control.GetNode("OffsetY");
			if (!startY)
			{
				cout << "Failure getting OffsetY node. Exiting." << endl;
				return EXIT_FAILURE;
			}
			startX->SetValue(0, true);
			startY->SetValue(0, true);
			width->SetValue(img_width, true);
			height->SetValue(img_height, true);

			const CCommandPtr stop = control.GetNode("AcquisitionStop");
			if (!stop)
			{
				cout << "Failure getting AcquisitionStop node. Exiting." << endl;
				return EXIT_FAILURE;
			}
			stop->Execute(true);

			const CCommandPtr start = control.GetNode("AcquisitionStart");
			if (!start)
			{
				cout << "Failure getting AcquisitionStart node. Exiting." << endl;
				return EXIT_FAILURE;
			}
			start->Execute(true);

			tcGenICamModel model(control);

			if (1 == num_cams)
			{
				retval = model.SetParam("BslColorSpaceMode", "RGB");
				if (retval)
				{
					cout << "Failed to setting BslColorSpaceMode to RGB. Exiting." << endl;
					return EXIT_FAILURE;
				}
			}
			retval = model.SetParam("AutoTargetBrightness", "0.3");
			if (retval)
			{
				cout << "Failed to setting AutoTargetBrightness to 0.3. Exiting." << endl;
				return EXIT_FAILURE;
			}
			retval = model.SetParam("AcquisitionFrameRate", "70");
			if (retval)
			{
				cout << "Failed to setting AcquisitionFrameRate to 70. Exiting." << endl;
				return EXIT_FAILURE;
			}
		}

		bool overlay_enabled = false;
		uint32_t overlay_width = 190 + 380;
		uint32_t overlay_height = 100;
		overlay_fb_reader_only->setRdFrameSize(overlay_width, overlay_height);
		uint8_t* overlay_buff = (uint8_t*)overlay_fb_reader_only->getRelRdFrame(1);
		if (!overlay_buff)
		{
			cout << "Could not get overlay buffer. Skipping drawing of overlay" << endl;
		}
		else
		{
			fillOverlayFb(overlay_buff);
			overlay_fb_reader_only->enableRd(true);
			overlay_fb_reader_only->incRdFrame();
			overlay_enabled = true;
		}

		if (!no_pylon_stream)
		{
			for (int cnt = 0; cnt < num_cams; cnt++)
			{
				cam_fb_reader_only[cnt]->enableRd(true);
			}
		}
		else
		{
			for (int cnt = 0; cnt < num_cams; cnt++)
			{
				retval = cam_fb_wr_rd[cnt]->launchPassthroughThread();
				if (retval){
					cout << "Error: cam_fb_wr_rd->launchPassthroughThread()" << endl;
					return EXIT_FAILURE;
				}
			}
		}

		mixer->start();
		mixer->set_background_resolution(OUTPUT_H_RES, OUTPUT_V_RES);	
		mixer->set_background_color(0, 255, 255);

		mixer->get_layer(MIXER_LAYER_OVERLAY).set_offset(OUTPUT_H_RES 
			- overlay_width - 5, OUTPUT_V_RES - overlay_height - 5);
		mixer->get_layer(MIXER_LAYER_OVERLAY).set_layer_position(num_cams);
		mixer->get_layer(MIXER_LAYER_OVERLAY).enable_layer();
		mixer->get_layer(MIXER_LAYER_OVERLAY).set_static_alpha_value(0xFF);

		mixer->get_layer(MIXER_LAYER_CAM1).set_offset(0, 0);
		mixer->get_layer(MIXER_LAYER_CAM1).set_layer_position(0);
		mixer->get_layer(MIXER_LAYER_CAM1).disable_layer();
		mixer->get_layer(MIXER_LAYER_CAM1).enable_layer();
		mixer->get_layer(MIXER_LAYER_CAM1).set_static_alpha_value(0x80);

		if (num_cams > 1)
		{
			// position cam2 below cam1 on screen
			mixer->get_layer(MIXER_LAYER_CAM2).set_offset(0, img_height);
			mixer->get_layer(MIXER_LAYER_CAM2).set_layer_position(1);
			mixer->get_layer(MIXER_LAYER_CAM2).disable_layer();
			mixer->get_layer(MIXER_LAYER_CAM2).enable_layer();
			mixer->get_layer(MIXER_LAYER_CAM2).set_static_alpha_value(0x80);
		}

		{
		// Output 1280x720 on attached monitor
		unsigned int bank_sel = 0;
		bool interlaced = 0;
		bool sequential = 0;
		unsigned int sample_count = 1280;
		unsigned int f0_line_count = 720;
		unsigned int f1_line_count = 0;
		unsigned int h_front_porch = 72;
		unsigned int h_sync_length = 80;
		unsigned int h_blanking = 368;
		unsigned int v_front_porch = 3;
		unsigned int v_sync_length = 4;
		unsigned int v_blanking = 30;
		unsigned int f0_v_front_porch = 0;
		unsigned int f0_v_sync_length = 0;
		unsigned int f0_v_blanking = 0;
		unsigned int active_picture_line = 0;
		unsigned int f0_v_rising = 0;
		unsigned int field_rising = 0;
		unsigned int field_falling = 0;
		unsigned int ancillary_line = 0;
		unsigned int f0_ancillary_line = 0;
		bool h_sync_polarity = 1;
		bool v_sync_polarity = 1;
		unsigned int vid_std = 0;
		unsigned int sof_sample = 6576;
		unsigned int sof_line = 749;
		unsigned int vco_clk_div = 1;
		cvo->set_output_mode(bank_sel, interlaced, sequential, 
			sample_count, f0_line_count, f1_line_count, 
			h_front_porch, h_sync_length, h_blanking, 
			v_front_porch, v_sync_length, v_blanking, 
			f0_v_front_porch, f0_v_sync_length, f0_v_blanking, 
			active_picture_line, f0_v_rising, field_rising, 
			field_falling, ancillary_line, f0_ancillary_line,  
			h_sync_polarity, v_sync_polarity, vid_std, 
			sof_sample, sof_line, vco_clk_div);
		}
		cvo->start();

		retval = hdmi_driver->initialize();
		if (retval){
			cout << "HDMI driver failed to init" << endl;
			return EXIT_FAILURE;
		}

		if (!no_pylon_stream)
		{
			for (int cnt = 0; cnt < num_cams; cnt++)
			{
				cameras[cnt]->StartGrabbing();
			}
		}

		const int STATS_UPDATE_CNT = 32;
		int stats_cnt = 0;

		cout << endl;
		cout << "Enter 'o' to enable/disable overlay" << endl;
		cout << "Enter 'q' to quit " << argv[0] << endl;

		// Blank spaces to back up over when displaying frame rate
		cout << endl << endl << endl << endl;

		size_t cmd_in_size = 1024;
		char* cmd_in = (char*)malloc(cmd_in_size * sizeof(char));
		if (!cmd_in)
		{
			cout << "Could not allocate cmd_in buffer. Exiting." << endl;
			return EXIT_FAILURE;
		}

		while(1)
		{
			if (inputAvailable())
			{
				if (getline(&cmd_in, &cmd_in_size, stdin))
				{
					if (cmd_in[0] == 'q')
						break;
					if (cmd_in[0] == 'o')
					{
						if (overlay_enabled)
						{
							mixer->get_layer(MIXER_LAYER_OVERLAY).disable_layer();
						}
						else
						{
							mixer->get_layer(MIXER_LAYER_OVERLAY).enable_layer();
						}
						overlay_enabled = !overlay_enabled;
					}
					else if (cmd_in[0] == 'd')
					{
						dumpFrame(FRAME_BYTES_PER_PIXEL);
					}
					cout << "\033[1A";
				}
			}

			if (!no_pylon_stream)
			{
				// Loop on all available cameras.
				CGrabResultPtr grabResult;
				for (int cnt = 0; cnt < num_cams; cnt++)
				{
					if (!cameras[cnt]->RetrieveResult(2000, grabResult))
					{
						cout << "Grab timeout?" << endl;
						exit_code = EXIT_FAILURE;
						break;
					}

					if (grabResult->GrabSucceeded())
					{
						void* buf = (void*)cam_fb_reader_only[cnt]->getRelRdFrame(1);
						if (!buf)
						{
							cout << "getRelRdFrame() failed" <<  endl;
							continue;
						}
						memcpy(buf, grabResult->GetBuffer(), grabResult->GetPayloadSize());

						do 
						{
							retval = cam_fb_reader_only[cnt]->incRdFrame();
						}
						while (retval);
					}
					else
					{
						cout << "Grab failed" << endl;
						exit_code = EXIT_FAILURE;
						break;
					}

				}
			} 
			else
			{
				usleep(20 * 1000);
			}

			stats_cnt++;
			if (stats_cnt >= STATS_UPDATE_CNT)
			{
				stats_cnt = 0;

				uint32_t num_frames[2] = {0, 0};
				double diff_time[2] = {0.0, 0.0};
				double frame_rate[2] = {0.0, 0.0};

				cout << "\033[1A" << "\033[1A" << "\033[1A";

				retval = 0;
				for (int cnt = 0; cnt < num_cams; cnt++)
				{
					if (!no_pylon_stream)
					{
						retval |= cam_fb_reader_only[cnt]->getRdFrameStats(diff_time[cnt], num_frames[cnt]);
					}
					else
					{
						retval |= cam_fb_wr_rd[cnt]->getRdFrameStats(diff_time[cnt], num_frames[cnt]);
					}
				}
				if (retval)
				{
					cout << "Error calculating frame rate..." << endl << endl << endl;
				}
				else
				{
					if (num_frames[0])
						frame_rate[0] = (double)num_frames[0]/diff_time[0];
					if (num_frames[1])
						frame_rate[1] = (double)num_frames[1]/diff_time[1];
					printf("Num Frames:\t% 3d\t% 3d\n ", num_frames[0], num_frames[1]);
					printf("Calc Period:\t% 1.03lf\t% 1.03lf\n", diff_time[0], diff_time[1]);
					printf("Frame Rate:\t% 2.03lf\t% 2.03lf\n", frame_rate[0], frame_rate[1]);
				}
			}
		}
	
		free(cmd_in);

		if (!no_pylon_stream)
		{
			for (int cnt = 0; cnt < num_cams; cnt++)
			{
				cameras[cnt]->StopGrabbing();
			}
		}
	}
	catch (const GenericException &e)
	{
		// Error handling.
		cerr << "Exception occurred: " << e.GetDescription() << endl;
		exit_code = EXIT_FAILURE;
	}

	cout << "Terminating " << argv[0] << endl;

	if (!cameras[0])
		delete cameras[0];
	if (!cameras[1])
		delete cameras[1];

	// Releases all pylon resources. 
	PylonTerminate();  

	delete hdmi_driver;
	delete cvo;
	delete overlay_fb_reader_only;
	if (cam_fb_reader_only[0]);
		delete cam_fb_reader_only[0];
	if (cam_fb_reader_only[1]);
		delete cam_fb_reader_only[1];
	if (cam_fb_wr_rd[0])
		delete cam_fb_wr_rd[0];
	if (cam_fb_wr_rd[1])
		delete cam_fb_wr_rd[1];
	if (bcon_input[0])
		delete bcon_input[0];
	if (bcon_input[1])
		delete bcon_input[1];
	delete mixer;

	cout << "Cleanup complete." << endl;
	cout << "Exiting with return value " << exit_code << endl;
	cout << "Thank you!" << endl;

	return exit_code;
}
