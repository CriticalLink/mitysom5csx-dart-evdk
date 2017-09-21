# TCL File Generated by Component Editor 16.0
# Mon Jul 17 10:35:20 EDT 2017
# DO NOT MODIFY


# 
# bcon_input "bcon_input" v1.1
#  2017.07.17.10:35:20
# Input data via Basler BCON LVDS Protocol.
# 

# 
# request TCL package from ACDS 16.0
# 
package require -exact qsys 16.0


# 
# module bcon_input
# 
set_module_property DESCRIPTION "Input data via Basler BCON LVDS Protocol."
set_module_property NAME bcon_input
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME bcon_input
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL bcon_input
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file bcon_input.vhd VHDL PATH bcon_input.vhd TOP_LEVEL_FILE
add_fileset_file bcon_input.sdc SDC PATH bcon_input.sdc
add_fileset_file altlvdsrx_5x7.qip OTHER PATH altlvdsrx_5x7.qip
add_fileset_file pll_1x7_reconfig.qip OTHER PATH pll_1x7_reconfig.qip
add_fileset_file altlvdsrx_5x7.vhd VHDL PATH altlvdsrx_5x7.vhd
add_fileset_file trig_gen_pkg.vhd VHDL PATH trig_gen_pkg.vhd
add_fileset_file bcon_pkg.vhd VHDL PATH bcon_pkg.vhd
add_fileset_file trigger_generator.vhd VHDL PATH trigger_generator.vhd
add_fileset_file pll_1x7_reconfig.vhd VHDL PATH pll_1x7_reconfig.vhd
add_fileset_file pll_1x7_reconfig/pll_1x7_reconfig_0002.v VERILOG PATH pll_1x7_reconfig/pll_1x7_reconfig_0002.v
add_fileset_file pll_1x7_reconfig/pll_1x7_reconfig_0002.qip OTHER PATH pll_1x7_reconfig/pll_1x7_reconfig_0002.qip


# 
# parameters
# 
add_parameter g_lane_invert STD_LOGIC_VECTOR 0 "Inverts BCON link lanes.  Bits 4-0 X3..X0..XCLK"
set_parameter_property g_lane_invert DEFAULT_VALUE 0
set_parameter_property g_lane_invert DISPLAY_NAME "BCON Link Lane Invert vector 1F (XX)"
set_parameter_property g_lane_invert TYPE STD_LOGIC_VECTOR
set_parameter_property g_lane_invert UNITS None
set_parameter_property g_lane_invert ALLOWED_RANGES 0:31
set_parameter_property g_lane_invert DESCRIPTION "Inverts BCON link lanes.  Bits 4-0 X3..X0..XCLK"
set_parameter_property g_lane_invert HDL_PARAMETER true


# 
# display items
# 


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock register_clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset i_rst reset Input 1


# 
# connection point register_access
# 
add_interface register_access avalon end
set_interface_property register_access addressUnits WORDS
set_interface_property register_access associatedClock register_clock
set_interface_property register_access associatedReset reset
set_interface_property register_access bitsPerSymbol 8
set_interface_property register_access burstOnBurstBoundariesOnly false
set_interface_property register_access burstcountUnits WORDS
set_interface_property register_access explicitAddressSpan 0
set_interface_property register_access holdTime 0
set_interface_property register_access linewrapBursts false
set_interface_property register_access maximumPendingReadTransactions 0
set_interface_property register_access maximumPendingWriteTransactions 0
set_interface_property register_access readLatency 1
set_interface_property register_access readWaitTime 1
set_interface_property register_access setupTime 0
set_interface_property register_access timingUnits Cycles
set_interface_property register_access writeWaitTime 0
set_interface_property register_access ENABLED true
set_interface_property register_access EXPORT_OF ""
set_interface_property register_access PORT_NAME_MAP ""
set_interface_property register_access CMSIS_SVD_VARIABLES ""
set_interface_property register_access SVD_ADDRESS_GROUP ""

add_interface_port register_access i_reg_addr address Input 5
add_interface_port register_access i_reg_read_en read Input 1
add_interface_port register_access i_reg_write_en write Input 1
add_interface_port register_access i_reg_writedata writedata Input 32
add_interface_port register_access o_reg_readdata readdata Output 32
add_interface_port register_access o_reg_waitrequest waitrequest Output 1
set_interface_assignment register_access embeddedsw.configuration.isFlash 0
set_interface_assignment register_access embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment register_access embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment register_access embeddedsw.configuration.isPrintableDevice 0


# 
# connection point register_clock
# 
add_interface register_clock clock end
set_interface_property register_clock clockRate 0
set_interface_property register_clock ENABLED true
set_interface_property register_clock EXPORT_OF ""
set_interface_property register_clock PORT_NAME_MAP ""
set_interface_property register_clock CMSIS_SVD_VARIABLES ""
set_interface_property register_clock SVD_ADDRESS_GROUP ""

add_interface_port register_clock i_register_clock clk Input 1


# 
# connection point pixel_clock
# 
add_interface pixel_clock clock start
set_interface_property pixel_clock associatedDirectClock ""
set_interface_property pixel_clock clockRate 0
set_interface_property pixel_clock clockRateKnown false
set_interface_property pixel_clock ENABLED true
set_interface_property pixel_clock EXPORT_OF ""
set_interface_property pixel_clock PORT_NAME_MAP ""
set_interface_property pixel_clock CMSIS_SVD_VARIABLES ""
set_interface_property pixel_clock SVD_ADDRESS_GROUP ""

add_interface_port pixel_clock o_pixel_clock clk Output 1

# 
# connection point bcon_bm_interface
# 
add_interface bcon_bm_interface conduit end
set_interface_property bcon_bm_interface associatedClock ""
set_interface_property bcon_bm_interface associatedReset ""
set_interface_property bcon_bm_interface ENABLED true
set_interface_property bcon_bm_interface EXPORT_OF ""
set_interface_property bcon_bm_interface PORT_NAME_MAP ""
set_interface_property bcon_bm_interface CMSIS_SVD_VARIABLES ""
set_interface_property bcon_bm_interface SVD_ADDRESS_GROUP ""

add_interface_port bcon_bm_interface i_bcon_x i_bcon_x Input 4
add_interface_port bcon_bm_interface i_bcon_xclk i_bcon_xclk Input 1
add_interface_port bcon_bm_interface o_bcon_cc o_bcon_cc Output 1
add_interface_port bcon_bm_interface o_fpga_trig o_fpga_trig Output 1

# 
# connection point reconfig_to_pll
# 
add_interface reconfig_to_pll conduit end
set_interface_property reconfig_to_pll associatedClock ""
set_interface_property reconfig_to_pll associatedReset ""
set_interface_property reconfig_to_pll ENABLED true
set_interface_property reconfig_to_pll EXPORT_OF ""
set_interface_property reconfig_to_pll PORT_NAME_MAP ""
set_interface_property reconfig_to_pll CMSIS_SVD_VARIABLES ""
set_interface_property reconfig_to_pll SVD_ADDRESS_GROUP ""

add_interface_port reconfig_to_pll reconfig_to_pll reconfig_to_pll Input 64


# 
# connection point reconfig_from_pll
# 
add_interface reconfig_from_pll conduit end
set_interface_property reconfig_from_pll associatedClock ""
set_interface_property reconfig_from_pll associatedReset ""
set_interface_property reconfig_from_pll ENABLED true
set_interface_property reconfig_from_pll EXPORT_OF ""
set_interface_property reconfig_from_pll PORT_NAME_MAP ""
set_interface_property reconfig_from_pll CMSIS_SVD_VARIABLES ""
set_interface_property reconfig_from_pll SVD_ADDRESS_GROUP ""

add_interface_port reconfig_from_pll reconfig_from_pll reconfig_from_pll Output 64

# 
# connection point cvi
# 
add_interface cvi conduit end
set_interface_property cvi associatedReset ""
set_interface_property cvi ENABLED true
set_interface_property cvi EXPORT_OF ""
set_interface_property cvi PORT_NAME_MAP ""
set_interface_property cvi CMSIS_SVD_VARIABLES ""
set_interface_property cvi SVD_ADDRESS_GROUP ""

add_interface_port cvi vid_clk vid_clk Output 1
add_interface_port cvi vid_data vid_data Output 24
add_interface_port cvi vid_de vid_de Output 1
add_interface_port cvi vid_datavalid vid_datavalid Output 1
add_interface_port cvi vid_locked vid_locked Output 1
add_interface_port cvi vid_f vid_f Output 1
add_interface_port cvi vid_v_sync vid_v_sync Output 1
add_interface_port cvi vid_h_sync vid_h_sync Output 1
add_interface_port cvi vid_std vid_std Output 1
add_interface_port cvi vid_color_encoding  vid_color_encoding Output 8
add_interface_port cvi vid_bit_width vid_bit_width Output 8 
add_interface_port cvi sof sof Input 1
add_interface_port cvi sof_locked  sof_locked Input 1
add_interface_port cvi refclk_div refclk_div Input 1
add_interface_port cvi overflow overflow Input 1

