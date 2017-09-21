# executables
bin_PROGRAMS = demo_app 

if DEBUG
AM_CFLAGS = -g3 -O0
AM_CXXFLAGS = -g3 -O0 -std=c++11
else
AM_CFLAGS = -O2
AM_CXXFLAGS = -O2 -std=c++11
endif                                                                                                                                                                                                      
AM_LDFLAGS = \
-lpthread \
-lfpga \
-lpylonbase \
-lpylonutility \
-lGenApi_gcc_v3_0_Basler_pylon_v5_0 \
-lGCBase_gcc_v3_0_Basler_pylon_v5_0 

demo_app_SOURCES = \
GenICamModel.cpp \
gpio.cpp \
i2cdevice.cpp \
tfp410.cpp \
hdmidriver.cpp \
main.cpp

demo_app_CXXFLAGS = $(AM_CXXFLAGS)

