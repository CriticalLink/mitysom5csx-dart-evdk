# For enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdo]

create_clock -period "100 MHz" [get_ports pcie_refclk_clk]
create_clock -period "125 MHz" -name {coreclk} {*coreclk*}

derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

create_clock -period 10.000 [get_ports CLK2DDR]

# HPS peripherals ignores, these are in hard silicon so they will not affect routing 
create_clock -period 10.000 [get_ports USB1_ULPI_CLK]
create_clock -period 10.000 [get_ports B7A_I2C0_SCL]
create_clock -period 10.000 [get_ports I2C1_SCL]

# HDMI interface (outputs)
# create_generated_clock -name hdmi_outclk -source [get_pins XXX] [get_ports HDMI_IDCK_P]
# TFP Setup requirements 1.2 ns, assume 0.5 ns skew
# TFP Hold Requirements 1.3 ns, assume 0.5 ns skew
create_generated_clock -name hdmi_outclk -source [get_pins {cvo_clk_p_ddio|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|muxsel}] -invert [get_ports {DVI_CLK_P}]
set_output_delay -clock { hdmi_outclk } -clock_fall 1.7 [get_ports DVI_R\[*\]]
set_output_delay -clock { hdmi_outclk } -clock_fall 1.7 [get_ports DVI_G\[*\]]
set_output_delay -clock { hdmi_outclk } -clock_fall 1.7 [get_ports DVI_B\[*\]]
set_output_delay -clock { hdmi_outclk } -clock_fall 1.7 [get_ports DVI_HSYNC]
set_output_delay -clock { hdmi_outclk } -clock_fall 1.7 [get_ports DVI_VSYNC]
set_output_delay -clock { hdmi_outclk } -clock_fall 1.7 [get_ports DVI_DE]

set_false_path -to [get_ports {DVI_CLK_*}]
set_false_path -to [get_ports {UGPIO*}]  
set_false_path -from [get_ports {UGPIO*}] 
set_false_path -to [get_ports {CAM1_CC*}]

set_false_path -from [get_ports {B7A_CAN0_RX}] -to *
set_false_path -from [get_ports {B7A_CAN1_RX}] -to *
set_false_path -from [get_ports {B7A_I2C0_SDA}] -to *
set_false_path -from [get_ports {B7A_UART0_RX}] -to *
set_false_path -from [get_ports {I2C1_SDA}] -to *
set_false_path -from [get_ports {QSPI_DQ0}] -to *
set_false_path -from [get_ports {QSPI_DQ1}] -to *
set_false_path -from [get_ports {QSPI_DQ2}] -to *
set_false_path -from [get_ports {QSPI_DQ3}] -to *
set_false_path -from [get_ports {RGMII1_MDIO}] -to *
set_false_path -from [get_ports {RGMII1_RESETn}] -to *
set_false_path -from [get_ports {RGMII1_RXD0}] -to *
set_false_path -from [get_ports {RGMII1_RXD1}] -to *
set_false_path -from [get_ports {RGMII1_RXD2}] -to *
set_false_path -from [get_ports {RGMII1_RXD3}] -to *
set_false_path -from [get_ports {RGMII1_RX_CLK}] -to *
set_false_path -from [get_ports {RGMII1_RX_CTL}] -to *
set_false_path -from [get_ports {SDMMC_CMD}] -to *
set_false_path -from [get_ports {SDMMC_D0}] -to *
set_false_path -from [get_ports {SDMMC_D1}] -to *
set_false_path -from [get_ports {SDMMC_D2}] -to *
set_false_path -from [get_ports {SDMMC_D3}] -to *
set_false_path -from [get_ports {USB1_ULPI_CLK}] -to *
set_false_path -from [get_ports {USB1_ULPI_CS}] -to *
set_false_path -from [get_ports {USB1_ULPI_D0}] -to *
set_false_path -from [get_ports {USB1_ULPI_D1}] -to *
set_false_path -from [get_ports {USB1_ULPI_D2}] -to *
set_false_path -from [get_ports {USB1_ULPI_D3}] -to *
set_false_path -from [get_ports {USB1_ULPI_D3}] -to *
set_false_path -from [get_ports {USB1_ULPI_D4}] -to *
set_false_path -from [get_ports {USB1_ULPI_D5}] -to *
set_false_path -from [get_ports {USB1_ULPI_D6}] -to *
set_false_path -from [get_ports {USB1_ULPI_D7}] -to *
set_false_path -from [get_ports {USB1_ULPI_DIR}] -to *
set_false_path -from [get_ports {USB1_ULPI_NXT}] -to *
set_false_path -from [get_ports {USB1_ULPI_RESET_N}] -to *

set_false_path -from * -to [get_ports {B7A_CAN0_TX}]
set_false_path -from * -to [get_ports {B7A_CAN1_TX}]
set_false_path -from * -to [get_ports {B7A_I2C0_SCL}]
set_false_path -from * -to [get_ports {B7A_I2C0_SDA}]
set_false_path -from * -to [get_ports {B7A_UART0_TX}]
set_false_path -from * -to [get_ports {I2C1_SCL}]
set_false_path -from * -to [get_ports {I2C1_SDA}]
set_false_path -from * -to [get_ports {QSPI_CLK}]
set_false_path -from * -to [get_ports {QSPI_DQ0}]
set_false_path -from * -to [get_ports {QSPI_DQ1}]
set_false_path -from * -to [get_ports {QSPI_DQ2}]
set_false_path -from * -to [get_ports {QSPI_DQ3}]
set_false_path -from * -to [get_ports {QSPI_SS0}]
set_false_path -from * -to [get_ports {QSPI_SS1}]
set_false_path -from * -to [get_ports {RGMII1_MDC}]
set_false_path -from * -to [get_ports {RGMII1_MDIO}]
set_false_path -from * -to [get_ports {RGMII1_RESETn}]
set_false_path -from * -to [get_ports {RGMII1_TXD0}]
set_false_path -from * -to [get_ports {RGMII1_TXD1}]
set_false_path -from * -to [get_ports {RGMII1_TXD2}]
set_false_path -from * -to [get_ports {RGMII1_TXD3}]
set_false_path -from * -to [get_ports {RGMII1_TX_CLK}]
set_false_path -from * -to [get_ports {RGMII1_TX_CTL}]
set_false_path -from * -to [get_ports {SDMMC_CLK}]
set_false_path -from * -to [get_ports {SDMMC_CMD}]
set_false_path -from * -to [get_ports {SDMMC_D0}]
set_false_path -from * -to [get_ports {SDMMC_D1}]
set_false_path -from * -to [get_ports {SDMMC_D2}]
set_false_path -from * -to [get_ports {SDMMC_D3}]
set_false_path -from * -to [get_ports {USB1_ULPI_CLK}]
set_false_path -from * -to [get_ports {USB1_ULPI_CS}]
set_false_path -from * -to [get_ports {USB1_ULPI_D0}]
set_false_path -from * -to [get_ports {USB1_ULPI_D1}]
set_false_path -from * -to [get_ports {USB1_ULPI_D2}]
set_false_path -from * -to [get_ports {USB1_ULPI_D3}]
set_false_path -from * -to [get_ports {USB1_ULPI_D4}]
set_false_path -from * -to [get_ports {USB1_ULPI_D5}]
set_false_path -from * -to [get_ports {USB1_ULPI_D6}]
set_false_path -from * -to [get_ports {USB1_ULPI_D7}]
set_false_path -from * -to [get_ports {USB1_ULPI_RESET_N}]
set_false_path -from * -to [get_ports {USB1_ULPI_STP}]


#set_false_path -from {dev_5cs:u0|bcon_input:cam1_input|s_srst_reg} -to *
#set_false_path -from {dev_5cs:u0|bcon_input:cam1_input|s_pll_rst_reg} -to *
