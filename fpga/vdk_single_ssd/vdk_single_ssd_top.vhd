-------------------------------------------------------------------------------
--
--     o  0                          
--     | /       Copyright (c) 2017
--    (CL)---o   Critical Link, LLC  
--      \                            
--       O                           
--
-- File       : vdk_single_ssd_top.vhd
-- Company    : Critical Link, LLC
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top level entity for the MitySOM-5CSX Development Board
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity vdk_single_ssd_top is
	generic(
		HPS_DDR_D_SIZE    : integer := 40;
		HPS_DDR_A_SIZE    : integer := 15;
		HPS_DDR_NUM_CHIPS : integer := 5;
		FPGA_DDR_A_SIZE    : integer := 0
		);
	port(
		-- HPS DDR
		HPS_DDR_A         : out   std_logic_vector(HPS_DDR_A_SIZE-1 downto 0);
		HPS_DDR_BAS       : out   std_logic_vector(2 downto 0);
		HPS_DDR_CK_P      : out   std_logic;
		HPS_DDR_CK_N      : out   std_logic;
		HPS_DDR_CKE       : out   std_logic;
		HPS_DDR_CS0_N     : out   std_logic;
		HPS_DDR_RAS_N     : out   std_logic;
		HPS_DDR_CAS_N     : out   std_logic;
		HPS_DDR_WE_N      : out   std_logic;
		HPS_DDR_RESET_N   : out   std_logic;
		HPS_DDR_D         : inout std_logic_vector(HPS_DDR_D_SIZE-1 downto 0) := (others => 'X');
		HPS_DDR_DQS_P     : inout std_logic_vector(HPS_DDR_NUM_CHIPS-1 downto 0)  := (others => 'X');
		HPS_DDR_DQS_N     : inout std_logic_vector(HPS_DDR_NUM_CHIPS-1 downto 0)  := (others => 'X');
		HPS_DDR_DQM       : out   std_logic_vector(HPS_DDR_NUM_CHIPS-1 downto 0);
		HPS_RZQ0          : in    std_logic                     := 'X';
		HPS_ODT           : out   std_logic;
		-- RGMII1
		RGMII1_TX_CLK     : out   std_logic;
		RGMII1_TXD0       : out   std_logic;
		RGMII1_TXD1       : out   std_logic;
		RGMII1_TXD2       : out   std_logic;
		RGMII1_TXD3       : out   std_logic;
		RGMII1_RXD0       : in    std_logic                     := 'X';
		RGMII1_MDIO       : inout std_logic                     := 'X';
		RGMII1_MDC        : out   std_logic;
		RGMII1_RX_CTL     : in    std_logic                     := 'X';
		RGMII1_TX_CTL     : out   std_logic;
		RGMII1_RX_CLK     : in    std_logic                     := 'X';
		RGMII1_RXD1       : in    std_logic                     := 'X';
		RGMII1_RXD2       : in    std_logic                     := 'X';
		RGMII1_RXD3       : in    std_logic                     := 'X';
		RGMII1_RESETn     : inout std_logic;
		-- QSPI
		QSPI_DQ0          : inout std_logic                     := 'X';
		QSPI_DQ1          : inout std_logic                     := 'X';
		QSPI_DQ2          : inout std_logic                     := 'X';
		QSPI_DQ3          : inout std_logic                     := 'X';
		QSPI_SS0          : out   std_logic;
		QSPI_SS1          : out   std_logic;
		QSPI_CLK          : out   std_logic;
		-- SDMMC
		SDMMC_CMD         : inout std_logic                     := 'X';
		SDMMC_D0          : inout std_logic                     := 'X';
		SDMMC_D1          : inout std_logic                     := 'X';
		SDMMC_CLK         : out   std_logic;
		SDMMC_D2          : inout std_logic                     := 'X';
		SDMMC_D3          : inout std_logic                     := 'X';
		-- USB1
		USB1_ULPI_D0      : inout std_logic                     := 'X';
		USB1_ULPI_D1      : inout std_logic                     := 'X';
		USB1_ULPI_D2      : inout std_logic                     := 'X';
		USB1_ULPI_D3      : inout std_logic                     := 'X';
		USB1_ULPI_D4      : inout std_logic                     := 'X';
		USB1_ULPI_D5      : inout std_logic                     := 'X';
		USB1_ULPI_D6      : inout std_logic                     := 'X';
		USB1_ULPI_D7      : inout std_logic                     := 'X';
		USB1_ULPI_CLK     : in    std_logic                     := 'X';
		USB1_ULPI_STP     : out   std_logic;
		USB1_ULPI_DIR     : in    std_logic                     := 'X';
		USB1_ULPI_NXT     : in    std_logic                     := 'X';
		USB1_ULPI_CS      : inout std_logic;
		USB1_ULPI_RESET_N : inout std_logic;
		-- UART0
		B7A_UART0_RX      : in    std_logic                     := 'X';
		B7A_UART0_TX      : out   std_logic;
		-- I2C0
		B7A_I2C0_SDA      : inout std_logic                     := 'X';
		B7A_I2C0_SCL      : inout std_logic                     := 'X';
		-- I2C1
		I2C1_SCL          : inout std_logic;
		I2C1_SDA          : inout std_logic;

		-- CAM1
		CAM1_X : in std_logic_vector(3 downto 0);
		CAM1_XCLK : in std_logic;
		CAM1_CC : out std_logic;

		CAM1_ID : inout std_logic;
		CAM2_ID : inout std_logic;
	
		-- DVI
		DVI_R : out std_logic_vector(7 downto 0);
		DVI_G : out std_logic_vector(7 downto 0);
		DVI_B : out std_logic_vector(7 downto 0);
		DVI_HSYNC : out std_logic;
		DVI_VSYNC : out std_logic;
		DVI_DE : out std_logic;
		DVI_CLK_P : out std_logic;
		DVI_CLK_N : out std_logic;
		DVI_RESET_N : inout std_logic;
		DVI_PD_N : inout std_logic;
		DVI_MSEN : inout std_logic;

		pcie_refclk_clk : in std_logic;
		pcie_hip_rx_in0 : in std_logic;
		pcie_hip_rx_in1 : in std_logic;
		pcie_hip_rx_in2 : in std_logic;
		pcie_hip_rx_in3 : in std_logic;
		pcie_hip_tx_out0 : out std_logic;
		pcie_hip_tx_out1 : out std_logic;
		pcie_hip_tx_out2 : out std_logic;
		pcie_hip_tx_out3 : out std_logic;
		pcie_perstn : inout std_logic;

		-- User GPIO
		UGPIO : out std_logic_vector(6 downto 0)

	);
end entity vdk_single_ssd_top;

-------------------------------------------------------------------------------

architecture rtl of vdk_single_ssd_top is
	component vdk_single_ssd is
		port (
			cam1_bcon_bm_interface_i_bcon_x                        : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- i_bcon_x
			cam1_bcon_bm_interface_i_bcon_xclk                     : in    std_logic                     := 'X';             -- i_bcon_xclk
			cam1_bcon_bm_interface_o_bcon_cc                       : out   std_logic;                                        -- o_bcon_cc
			cam1_bcon_bm_interface_o_fpga_trig                     : out   std_logic;                                        -- o_fpga_trig
			cvo_clocked_video_vid_data                             : out   std_logic_vector(23 downto 0);                    -- vid_data
			cvo_clocked_video_underflow                            : out   std_logic;                                        -- underflow
			cvo_clocked_video_vid_mode_change                      : out   std_logic;                                        -- vid_mode_change
			cvo_clocked_video_vid_std                              : out   std_logic;                                        -- vid_std
			cvo_clocked_video_vid_datavalid                        : out   std_logic;                                        -- vid_datavalid
			cvo_clocked_video_vid_v_sync                           : out   std_logic;                                        -- vid_v_sync
			cvo_clocked_video_vid_h_sync                           : out   std_logic;                                        -- vid_h_sync
			cvo_clocked_video_vid_f                                : out   std_logic;                                        -- vid_f
			cvo_clocked_video_vid_h                                : out   std_logic;                                        -- vid_h
			cvo_clocked_video_vid_v                                : out   std_logic;                                        -- vid_v
			hps_ddr_mem_a                                          : out   std_logic_vector(14 downto 0);                    -- mem_a
			hps_ddr_mem_ba                                         : out   std_logic_vector(2 downto 0);                     -- mem_ba
			hps_ddr_mem_ck                                         : out   std_logic;                                        -- mem_ck
			hps_ddr_mem_ck_n                                       : out   std_logic;                                        -- mem_ck_n
			hps_ddr_mem_cke                                        : out   std_logic;                                        -- mem_cke
			hps_ddr_mem_cs_n                                       : out   std_logic;                                        -- mem_cs_n
			hps_ddr_mem_ras_n                                      : out   std_logic;                                        -- mem_ras_n
			hps_ddr_mem_cas_n                                      : out   std_logic;                                        -- mem_cas_n
			hps_ddr_mem_we_n                                       : out   std_logic;                                        -- mem_we_n
			hps_ddr_mem_reset_n                                    : out   std_logic;                                        -- mem_reset_n
			hps_ddr_mem_dq                                         : inout std_logic_vector(39 downto 0) := (others => 'X'); -- mem_dq
			hps_ddr_mem_dqs                                        : inout std_logic_vector(4 downto 0)  := (others => 'X'); -- mem_dqs
			hps_ddr_mem_dqs_n                                      : inout std_logic_vector(4 downto 0)  := (others => 'X'); -- mem_dqs_n
			hps_ddr_mem_odt                                        : out   std_logic;                                        -- mem_odt
			hps_ddr_mem_dm                                         : out   std_logic_vector(4 downto 0);                     -- mem_dm
			hps_ddr_oct_rzqin                                      : in    std_logic                     := 'X';             -- oct_rzqin
			hps_io_hps_io_emac1_inst_TX_CLK                        : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
			hps_io_hps_io_emac1_inst_TXD0                          : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
			hps_io_hps_io_emac1_inst_TXD1                          : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
			hps_io_hps_io_emac1_inst_TXD2                          : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
			hps_io_hps_io_emac1_inst_TXD3                          : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
			hps_io_hps_io_emac1_inst_RXD0                          : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
			hps_io_hps_io_emac1_inst_MDIO                          : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
			hps_io_hps_io_emac1_inst_MDC                           : out   std_logic;                                        -- hps_io_emac1_inst_MDC
			hps_io_hps_io_emac1_inst_RX_CTL                        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
			hps_io_hps_io_emac1_inst_TX_CTL                        : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
			hps_io_hps_io_emac1_inst_RX_CLK                        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
			hps_io_hps_io_emac1_inst_RXD1                          : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
			hps_io_hps_io_emac1_inst_RXD2                          : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
			hps_io_hps_io_emac1_inst_RXD3                          : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
			hps_io_hps_io_qspi_inst_SS1                            : out   std_logic;                                        -- hps_io_qspi_inst_SS1
			hps_io_hps_io_qspi_inst_IO0                            : inout std_logic                     := 'X';             -- hps_io_qspi_inst_IO0
			hps_io_hps_io_qspi_inst_IO1                            : inout std_logic                     := 'X';             -- hps_io_qspi_inst_IO1
			hps_io_hps_io_qspi_inst_IO2                            : inout std_logic                     := 'X';             -- hps_io_qspi_inst_IO2
			hps_io_hps_io_qspi_inst_IO3                            : inout std_logic                     := 'X';             -- hps_io_qspi_inst_IO3
			hps_io_hps_io_qspi_inst_SS0                            : out   std_logic;                                        -- hps_io_qspi_inst_SS0
			hps_io_hps_io_qspi_inst_CLK                            : out   std_logic;                                        -- hps_io_qspi_inst_CLK
			hps_io_hps_io_sdio_inst_CMD                            : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0                             : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1                             : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK                            : out   std_logic;                                        -- hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2                             : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3                             : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0                             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1                             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2                             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3                             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4                             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5                             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6                             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7                             : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK                            : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP                            : out   std_logic;                                        -- hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR                            : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT                            : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
			hps_io_hps_io_uart0_inst_RX                            : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX                            : out   std_logic;                                        -- hps_io_uart0_inst_TX
			hps_io_hps_io_i2c0_inst_SDA                            : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
			hps_io_hps_io_i2c0_inst_SCL                            : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
			hps_io_hps_io_i2c1_inst_SDA                            : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
			hps_io_hps_io_i2c1_inst_SCL                            : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
			hps_io_hps_io_gpio_inst_GPIO00                         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO00
			hps_io_hps_io_gpio_inst_GPIO09                         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
			hps_io_hps_io_gpio_inst_GPIO28                         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO28
			hps_io_hps_io_gpio_inst_GPIO41                         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO41
			hps_io_hps_io_gpio_inst_GPIO44                         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO44
			hps_io_hps_io_gpio_inst_GPIO48                         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO48
			hps_io_hps_io_gpio_inst_GPIO49                         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO49
			hps_io_hps_io_gpio_inst_GPIO50                         : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO50
			pio_rp_reset_external_connection_in_port               : in    std_logic                     := 'X';             -- in_port
			pio_rp_reset_external_connection_out_port              : out   std_logic;                                        -- out_port
			ugpio_export                                           : inout std_logic_vector(6 downto 0)  := (others => 'X'); -- export
			pcie_cv_hip_avmm_0_refclk_clk                          : in    std_logic                     := 'X';             -- clk
			pcie_cv_hip_avmm_0_npor_npor                           : in    std_logic                     := 'X';             -- npor
			pcie_cv_hip_avmm_0_npor_pin_perst                      : in    std_logic                     := 'X';             -- pin_perst
			pcie_cv_hip_avmm_0_hip_ctrl_test_in                    : in    std_logic_vector(31 downto 0) := (others => 'X'); -- test_in
			pcie_cv_hip_avmm_0_hip_ctrl_simu_mode_pipe             : in    std_logic                     := 'X';             -- simu_mode_pipe
			pcie_cv_hip_avmm_0_reconfig_clk_locked_fixedclk_locked : out   std_logic;                                        -- fixedclk_locked
			pcie_cv_hip_avmm_0_hip_serial_rx_in0                   : in    std_logic                     := 'X';             -- rx_in0
			pcie_cv_hip_avmm_0_hip_serial_rx_in1                   : in    std_logic                     := 'X';             -- rx_in1
			pcie_cv_hip_avmm_0_hip_serial_rx_in2                   : in    std_logic                     := 'X';             -- rx_in2
			pcie_cv_hip_avmm_0_hip_serial_rx_in3                   : in    std_logic                     := 'X';             -- rx_in3
			pcie_cv_hip_avmm_0_hip_serial_tx_out0                  : out   std_logic;                                        -- tx_out0
			pcie_cv_hip_avmm_0_hip_serial_tx_out1                  : out   std_logic;                                        -- tx_out1
			pcie_cv_hip_avmm_0_hip_serial_tx_out2                  : out   std_logic;                                        -- tx_out2
			pcie_cv_hip_avmm_0_hip_serial_tx_out3                  : out   std_logic;                                        -- tx_out3
			pcie_cv_hip_avmm_0_hip_pipe_sim_pipe_pclk_in           : in    std_logic                     := 'X';             -- sim_pipe_pclk_in
			pcie_cv_hip_avmm_0_hip_pipe_sim_pipe_rate              : out   std_logic_vector(1 downto 0);                     -- sim_pipe_rate
			pcie_cv_hip_avmm_0_hip_pipe_sim_ltssmstate             : out   std_logic_vector(4 downto 0);                     -- sim_ltssmstate
			pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel0             : out   std_logic_vector(2 downto 0);                     -- eidleinfersel0
			pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel1             : out   std_logic_vector(2 downto 0);                     -- eidleinfersel1
			pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel2             : out   std_logic_vector(2 downto 0);                     -- eidleinfersel2
			pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel3             : out   std_logic_vector(2 downto 0);                     -- eidleinfersel3
			pcie_cv_hip_avmm_0_hip_pipe_powerdown0                 : out   std_logic_vector(1 downto 0);                     -- powerdown0
			pcie_cv_hip_avmm_0_hip_pipe_powerdown1                 : out   std_logic_vector(1 downto 0);                     -- powerdown1
			pcie_cv_hip_avmm_0_hip_pipe_powerdown2                 : out   std_logic_vector(1 downto 0);                     -- powerdown2
			pcie_cv_hip_avmm_0_hip_pipe_powerdown3                 : out   std_logic_vector(1 downto 0);                     -- powerdown3
			pcie_cv_hip_avmm_0_hip_pipe_rxpolarity0                : out   std_logic;                                        -- rxpolarity0
			pcie_cv_hip_avmm_0_hip_pipe_rxpolarity1                : out   std_logic;                                        -- rxpolarity1
			pcie_cv_hip_avmm_0_hip_pipe_rxpolarity2                : out   std_logic;                                        -- rxpolarity2
			pcie_cv_hip_avmm_0_hip_pipe_rxpolarity3                : out   std_logic;                                        -- rxpolarity3
			pcie_cv_hip_avmm_0_hip_pipe_txcompl0                   : out   std_logic;                                        -- txcompl0
			pcie_cv_hip_avmm_0_hip_pipe_txcompl1                   : out   std_logic;                                        -- txcompl1
			pcie_cv_hip_avmm_0_hip_pipe_txcompl2                   : out   std_logic;                                        -- txcompl2
			pcie_cv_hip_avmm_0_hip_pipe_txcompl3                   : out   std_logic;                                        -- txcompl3
			pcie_cv_hip_avmm_0_hip_pipe_txdata0                    : out   std_logic_vector(7 downto 0);                     -- txdata0
			pcie_cv_hip_avmm_0_hip_pipe_txdata1                    : out   std_logic_vector(7 downto 0);                     -- txdata1
			pcie_cv_hip_avmm_0_hip_pipe_txdata2                    : out   std_logic_vector(7 downto 0);                     -- txdata2
			pcie_cv_hip_avmm_0_hip_pipe_txdata3                    : out   std_logic_vector(7 downto 0);                     -- txdata3
			pcie_cv_hip_avmm_0_hip_pipe_txdatak0                   : out   std_logic;                                        -- txdatak0
			pcie_cv_hip_avmm_0_hip_pipe_txdatak1                   : out   std_logic;                                        -- txdatak1
			pcie_cv_hip_avmm_0_hip_pipe_txdatak2                   : out   std_logic;                                        -- txdatak2
			pcie_cv_hip_avmm_0_hip_pipe_txdatak3                   : out   std_logic;                                        -- txdatak3
			pcie_cv_hip_avmm_0_hip_pipe_txdetectrx0                : out   std_logic;                                        -- txdetectrx0
			pcie_cv_hip_avmm_0_hip_pipe_txdetectrx1                : out   std_logic;                                        -- txdetectrx1
			pcie_cv_hip_avmm_0_hip_pipe_txdetectrx2                : out   std_logic;                                        -- txdetectrx2
			pcie_cv_hip_avmm_0_hip_pipe_txdetectrx3                : out   std_logic;                                        -- txdetectrx3
			pcie_cv_hip_avmm_0_hip_pipe_txelecidle0                : out   std_logic;                                        -- txelecidle0
			pcie_cv_hip_avmm_0_hip_pipe_txelecidle1                : out   std_logic;                                        -- txelecidle1
			pcie_cv_hip_avmm_0_hip_pipe_txelecidle2                : out   std_logic;                                        -- txelecidle2
			pcie_cv_hip_avmm_0_hip_pipe_txelecidle3                : out   std_logic;                                        -- txelecidle3
			pcie_cv_hip_avmm_0_hip_pipe_txswing0                   : out   std_logic;                                        -- txswing0
			pcie_cv_hip_avmm_0_hip_pipe_txswing1                   : out   std_logic;                                        -- txswing1
			pcie_cv_hip_avmm_0_hip_pipe_txswing2                   : out   std_logic;                                        -- txswing2
			pcie_cv_hip_avmm_0_hip_pipe_txswing3                   : out   std_logic;                                        -- txswing3
			pcie_cv_hip_avmm_0_hip_pipe_txmargin0                  : out   std_logic_vector(2 downto 0);                     -- txmargin0
			pcie_cv_hip_avmm_0_hip_pipe_txmargin1                  : out   std_logic_vector(2 downto 0);                     -- txmargin1
			pcie_cv_hip_avmm_0_hip_pipe_txmargin2                  : out   std_logic_vector(2 downto 0);                     -- txmargin2
			pcie_cv_hip_avmm_0_hip_pipe_txmargin3                  : out   std_logic_vector(2 downto 0);                     -- txmargin3
			pcie_cv_hip_avmm_0_hip_pipe_txdeemph0                  : out   std_logic;                                        -- txdeemph0
			pcie_cv_hip_avmm_0_hip_pipe_txdeemph1                  : out   std_logic;                                        -- txdeemph1
			pcie_cv_hip_avmm_0_hip_pipe_txdeemph2                  : out   std_logic;                                        -- txdeemph2
			pcie_cv_hip_avmm_0_hip_pipe_txdeemph3                  : out   std_logic;                                        -- txdeemph3
			pcie_cv_hip_avmm_0_hip_pipe_phystatus0                 : in    std_logic                     := 'X';             -- phystatus0
			pcie_cv_hip_avmm_0_hip_pipe_phystatus1                 : in    std_logic                     := 'X';             -- phystatus1
			pcie_cv_hip_avmm_0_hip_pipe_phystatus2                 : in    std_logic                     := 'X';             -- phystatus2
			pcie_cv_hip_avmm_0_hip_pipe_phystatus3                 : in    std_logic                     := 'X';             -- phystatus3
			pcie_cv_hip_avmm_0_hip_pipe_rxdata0                    : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata0
			pcie_cv_hip_avmm_0_hip_pipe_rxdata1                    : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata1
			pcie_cv_hip_avmm_0_hip_pipe_rxdata2                    : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata2
			pcie_cv_hip_avmm_0_hip_pipe_rxdata3                    : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata3
			pcie_cv_hip_avmm_0_hip_pipe_rxdatak0                   : in    std_logic                     := 'X';             -- rxdatak0
			pcie_cv_hip_avmm_0_hip_pipe_rxdatak1                   : in    std_logic                     := 'X';             -- rxdatak1
			pcie_cv_hip_avmm_0_hip_pipe_rxdatak2                   : in    std_logic                     := 'X';             -- rxdatak2
			pcie_cv_hip_avmm_0_hip_pipe_rxdatak3                   : in    std_logic                     := 'X';             -- rxdatak3
			pcie_cv_hip_avmm_0_hip_pipe_rxelecidle0                : in    std_logic                     := 'X';             -- rxelecidle0
			pcie_cv_hip_avmm_0_hip_pipe_rxelecidle1                : in    std_logic                     := 'X';             -- rxelecidle1
			pcie_cv_hip_avmm_0_hip_pipe_rxelecidle2                : in    std_logic                     := 'X';             -- rxelecidle2
			pcie_cv_hip_avmm_0_hip_pipe_rxelecidle3                : in    std_logic                     := 'X';             -- rxelecidle3
			pcie_cv_hip_avmm_0_hip_pipe_rxstatus0                  : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus0
			pcie_cv_hip_avmm_0_hip_pipe_rxstatus1                  : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus1
			pcie_cv_hip_avmm_0_hip_pipe_rxstatus2                  : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus2
			pcie_cv_hip_avmm_0_hip_pipe_rxstatus3                  : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus3
			pcie_cv_hip_avmm_0_hip_pipe_rxvalid0                   : in    std_logic                     := 'X';             -- rxvalid0
			pcie_cv_hip_avmm_0_hip_pipe_rxvalid1                   : in    std_logic                     := 'X';             -- rxvalid1
			pcie_cv_hip_avmm_0_hip_pipe_rxvalid2                   : in    std_logic                     := 'X';             -- rxvalid2
			pcie_cv_hip_avmm_0_hip_pipe_rxvalid3                   : in    std_logic                     := 'X';             -- rxvalid3
			alt_xcvr_reconfig_0_reconfig_mgmt_address              : in    std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			alt_xcvr_reconfig_0_reconfig_mgmt_read                 : in    std_logic                     := 'X';             -- read
			alt_xcvr_reconfig_0_reconfig_mgmt_readdata             : out   std_logic_vector(31 downto 0);                    -- readdata
			alt_xcvr_reconfig_0_reconfig_mgmt_waitrequest          : out   std_logic;                                        -- waitrequest
			alt_xcvr_reconfig_0_reconfig_mgmt_write                : in    std_logic                     := 'X';             -- write
			alt_xcvr_reconfig_0_reconfig_mgmt_writedata            : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			vid_out_clk                                            : out   std_logic                                         -- clk
		);
	end component vdk_single_ssd;
	
	component ddout is port
		(
			datain_h		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			datain_l		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			outclock		: IN STD_LOGIC ;
			dataout		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
		);
	END component ddout;

	signal vid_out_clk : std_logic := '0';
	signal dvi_hsync_i :  std_logic;
	signal dvi_vsync_i :  std_logic;
	signal dvi_de_i :  std_logic;
	signal ugpio_i  :  std_logic_vector(6 downto 0);
	signal s_pcie_npor_pin_perst : std_logic := '0';

begin                                   -- architecture rtl

	----------------------------------------------------------------------------
	-- Component instantiations
	----------------------------------------------------------------------------

	u0 : component vdk_single_ssd
		port map(
			hps_ddr_mem_a                     => HPS_DDR_A,
			hps_ddr_mem_ba                    => HPS_DDR_BAS,
			hps_ddr_mem_ck                    => HPS_DDR_CK_P,
			hps_ddr_mem_ck_n                  => HPS_DDR_CK_N,
			hps_ddr_mem_cke                   => HPS_DDR_CKE,
			hps_ddr_mem_cs_n                  => HPS_DDR_CS0_N,
			hps_ddr_mem_ras_n                 => HPS_DDR_RAS_N,
			hps_ddr_mem_cas_n                 => HPS_DDR_CAS_N,
			hps_ddr_mem_we_n                  => HPS_DDR_WE_N,
			hps_ddr_mem_reset_n               => HPS_DDR_RESET_N,
			hps_ddr_mem_dq                    => HPS_DDR_D,
			hps_ddr_mem_dqs                   => HPS_DDR_DQS_P,
			hps_ddr_mem_dqs_n                 => HPS_DDR_DQS_N,
			hps_ddr_mem_odt                   => HPS_ODT,
			hps_ddr_mem_dm                    => HPS_DDR_DQM,
			hps_ddr_oct_rzqin                 => HPS_RZQ0,
			hps_io_hps_io_emac1_inst_TX_CLK   => RGMII1_TX_CLK,
			hps_io_hps_io_emac1_inst_TXD0     => RGMII1_TXD0,
			hps_io_hps_io_emac1_inst_TXD1     => RGMII1_TXD1,
			hps_io_hps_io_emac1_inst_TXD2     => RGMII1_TXD2,
			hps_io_hps_io_emac1_inst_TXD3     => RGMII1_TXD3,
			hps_io_hps_io_emac1_inst_RXD0     => RGMII1_RXD0,
			hps_io_hps_io_emac1_inst_RXD1     => RGMII1_RXD1,
			hps_io_hps_io_emac1_inst_RXD2     => RGMII1_RXD2,
			hps_io_hps_io_emac1_inst_RXD3     => RGMII1_RXD3,
			hps_io_hps_io_emac1_inst_MDIO     => RGMII1_MDIO,
			hps_io_hps_io_emac1_inst_MDC      => RGMII1_MDC,
			hps_io_hps_io_emac1_inst_RX_CTL   => RGMII1_RX_CTL,
			hps_io_hps_io_emac1_inst_TX_CTL   => RGMII1_TX_CTL,
			hps_io_hps_io_emac1_inst_RX_CLK   => RGMII1_RX_CLK,
			hps_io_hps_io_qspi_inst_SS1       => QSPI_SS1,
			hps_io_hps_io_qspi_inst_IO0       => QSPI_DQ0,
			hps_io_hps_io_qspi_inst_IO1       => QSPI_DQ1,
			hps_io_hps_io_qspi_inst_IO2       => QSPI_DQ2,
			hps_io_hps_io_qspi_inst_IO3       => QSPI_DQ3,
			hps_io_hps_io_qspi_inst_SS0       => QSPI_SS0,
			hps_io_hps_io_qspi_inst_CLK       => QSPI_CLK,
			hps_io_hps_io_sdio_inst_CMD       => SDMMC_CMD,
			hps_io_hps_io_sdio_inst_D0        => SDMMC_D0,
			hps_io_hps_io_sdio_inst_D1        => SDMMC_D1,
			hps_io_hps_io_sdio_inst_D2        => SDMMC_D2,
			hps_io_hps_io_sdio_inst_D3        => SDMMC_D3,
			hps_io_hps_io_sdio_inst_CLK       => SDMMC_CLK,
			hps_io_hps_io_usb1_inst_D0        => USB1_ULPI_D0,
			hps_io_hps_io_usb1_inst_D1        => USB1_ULPI_D1,
			hps_io_hps_io_usb1_inst_D2        => USB1_ULPI_D2,
			hps_io_hps_io_usb1_inst_D3        => USB1_ULPI_D3,
			hps_io_hps_io_usb1_inst_D4        => USB1_ULPI_D4,
			hps_io_hps_io_usb1_inst_D5        => USB1_ULPI_D5,
			hps_io_hps_io_usb1_inst_D6        => USB1_ULPI_D6,
			hps_io_hps_io_usb1_inst_D7        => USB1_ULPI_D7,
			hps_io_hps_io_usb1_inst_CLK       => USB1_ULPI_CLK,
			hps_io_hps_io_usb1_inst_STP       => USB1_ULPI_STP,
			hps_io_hps_io_usb1_inst_DIR       => USB1_ULPI_DIR,
			hps_io_hps_io_usb1_inst_NXT       => USB1_ULPI_NXT,
			hps_io_hps_io_uart0_inst_RX       => B7A_UART0_RX,
			hps_io_hps_io_uart0_inst_TX       => B7A_UART0_TX,
			hps_io_hps_io_i2c0_inst_SDA       => B7A_I2C0_SDA,
			hps_io_hps_io_i2c0_inst_SCL       => B7A_I2C0_SCL,
			hps_io_hps_io_i2c1_inst_SDA       => I2C1_SDA,
			hps_io_hps_io_i2c1_inst_SCL       => I2C1_SCL,
			hps_io_hps_io_gpio_inst_GPIO00    => USB1_ULPI_CS,
			hps_io_hps_io_gpio_inst_GPIO09    => USB1_ULPI_RESET_N,
			hps_io_hps_io_gpio_inst_GPIO28    => RGMII1_RESETn,
			hps_io_hps_io_gpio_inst_GPIO41    => DVI_PD_N,
			hps_io_hps_io_gpio_inst_GPIO44    => DVI_MSEN,
			hps_io_hps_io_gpio_inst_GPIO48    => DVI_RESET_N,
			hps_io_hps_io_gpio_inst_GPIO49    => CAM2_ID,
			hps_io_hps_io_gpio_inst_GPIO50    => CAM1_ID,
			cam1_bcon_bm_interface_i_bcon_x  => CAM1_X,
			cam1_bcon_bm_interface_i_bcon_xclk      => CAM1_XCLK,
			cam1_bcon_bm_interface_o_bcon_cc     => CAM1_CC, 
			cam1_bcon_bm_interface_o_fpga_trig   => open,   
			cvo_clocked_video_vid_data(23 downto 16) => DVI_R, 
			cvo_clocked_video_vid_data(15 downto 8) => DVI_G, 
			cvo_clocked_video_vid_data(7 downto 0) => DVI_B,
			cvo_clocked_video_underflow     => open, 
			cvo_clocked_video_vid_mode_change => open,
			cvo_clocked_video_vid_std       => open, 
			cvo_clocked_video_vid_datavalid => dvi_de_i, 
			cvo_clocked_video_vid_v_sync    => dvi_vsync_i, 
			cvo_clocked_video_vid_h_sync    => dvi_hsync_i, 
			cvo_clocked_video_vid_f         => open, 
			cvo_clocked_video_vid_h         => open,  
			cvo_clocked_video_vid_v         => open,
			vid_out_clk => vid_out_clk,
			ugpio_export => ugpio_i,
			pcie_cv_hip_avmm_0_refclk_clk                          => pcie_refclk_clk,                          --              pcie_cv_hip_avmm_0_refclk.clk
			pcie_cv_hip_avmm_0_reconfig_clk_locked_fixedclk_locked => open, -- pcie_cv_hip_avmm_0_reconfig_clk_locked.fixedclk_locked
			pcie_cv_hip_avmm_0_npor_npor                           => pcie_perstn,                           --                pcie_cv_hip_avmm_0_npor.npor
			pcie_cv_hip_avmm_0_npor_pin_perst                      => pcie_perstn,                      --                                         .pin_perst
			pcie_cv_hip_avmm_0_hip_serial_rx_in0                   => pcie_hip_rx_in0,                   --          pcie_cv_hip_avmm_0_hip_serial.rx_in0
			pcie_cv_hip_avmm_0_hip_serial_rx_in1                   => pcie_hip_rx_in1,                   --                                         .rx_in1
			pcie_cv_hip_avmm_0_hip_serial_rx_in2                   => pcie_hip_rx_in2,                   --                                         .rx_in2
			pcie_cv_hip_avmm_0_hip_serial_rx_in3                   => pcie_hip_rx_in3,                   --                                         .rx_in3
			pcie_cv_hip_avmm_0_hip_serial_tx_out0                  => pcie_hip_tx_out0,                  --                                         .tx_out0
			pcie_cv_hip_avmm_0_hip_serial_tx_out1                  => pcie_hip_tx_out1,                  --                                         .tx_out1
			pcie_cv_hip_avmm_0_hip_serial_tx_out2                  => pcie_hip_tx_out2,                  --                                         .tx_out2
			pcie_cv_hip_avmm_0_hip_serial_tx_out3                  => pcie_hip_tx_out3,                  --                                         .tx_out3
			pcie_cv_hip_avmm_0_hip_pipe_sim_pipe_pclk_in           => '0',           --            pcie_cv_hip_avmm_0_hip_pipe.sim_pipe_pclk_in
			pcie_cv_hip_avmm_0_hip_pipe_sim_pipe_rate              => open,              --                                         .sim_pipe_rate
			pcie_cv_hip_avmm_0_hip_pipe_sim_ltssmstate             => open,             --                                         .sim_ltssmstate
			pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel0             => open,             --                                         .eidleinfersel0
			pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel1             => open,             --                                         .eidleinfersel1
			pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel2             => open,             --                                         .eidleinfersel2
			pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel3             => open,             --                                         .eidleinfersel3
			pcie_cv_hip_avmm_0_hip_pipe_powerdown0                 => open,                 --                                         .powerdown0
			pcie_cv_hip_avmm_0_hip_pipe_powerdown1                 => open,                 --                                         .powerdown1
			pcie_cv_hip_avmm_0_hip_pipe_powerdown2                 => open,                 --                                         .powerdown2
			pcie_cv_hip_avmm_0_hip_pipe_powerdown3                 => open,                 --                                         .powerdown3
			pcie_cv_hip_avmm_0_hip_pipe_rxpolarity0                => open,                --                                         .rxpolarity0
			pcie_cv_hip_avmm_0_hip_pipe_rxpolarity1                => open,                --                                         .rxpolarity1
			pcie_cv_hip_avmm_0_hip_pipe_rxpolarity2                => open,                --                                         .rxpolarity2
			pcie_cv_hip_avmm_0_hip_pipe_rxpolarity3                => open,                --                                         .rxpolarity3
			pcie_cv_hip_avmm_0_hip_pipe_txcompl0                   => open,                   --                                         .txcompl0
			pcie_cv_hip_avmm_0_hip_pipe_txcompl1                   => open,                   --                                         .txcompl1
			pcie_cv_hip_avmm_0_hip_pipe_txcompl2                   => open,                   --                                         .txcompl2
			pcie_cv_hip_avmm_0_hip_pipe_txcompl3                   => open,                   --                                         .txcompl3
			pcie_cv_hip_avmm_0_hip_pipe_txdata0                    => open,                    --                                         .txdata0
			pcie_cv_hip_avmm_0_hip_pipe_txdata1                    => open,                    --                                         .txdata1
			pcie_cv_hip_avmm_0_hip_pipe_txdata2                    => open,                    --                                         .txdata2
			pcie_cv_hip_avmm_0_hip_pipe_txdata3                    => open,                    --                                         .txdata3
			pcie_cv_hip_avmm_0_hip_pipe_txdatak0                   => open,                   --                                         .txdatak0
			pcie_cv_hip_avmm_0_hip_pipe_txdatak1                   => open,                   --                                         .txdatak1
			pcie_cv_hip_avmm_0_hip_pipe_txdatak2                   => open,                   --                                         .txdatak2
			pcie_cv_hip_avmm_0_hip_pipe_txdatak3                   => open,                   --                                         .txdatak3
			pcie_cv_hip_avmm_0_hip_pipe_txdetectrx0                => open,                --                                         .txdetectrx0
			pcie_cv_hip_avmm_0_hip_pipe_txdetectrx1                => open,                --                                         .txdetectrx1
			pcie_cv_hip_avmm_0_hip_pipe_txdetectrx2                => open,                --                                         .txdetectrx2
			pcie_cv_hip_avmm_0_hip_pipe_txdetectrx3                => open,                --                                         .txdetectrx3
			pcie_cv_hip_avmm_0_hip_pipe_txelecidle0                => open,                --                                         .txelecidle0
			pcie_cv_hip_avmm_0_hip_pipe_txelecidle1                => open,                --                                         .txelecidle1
			pcie_cv_hip_avmm_0_hip_pipe_txelecidle2                => open,                --                                         .txelecidle2
			pcie_cv_hip_avmm_0_hip_pipe_txelecidle3                => open,                --                                         .txelecidle3
			pcie_cv_hip_avmm_0_hip_pipe_txswing0                   => open,                   --                                         .txswing0
			pcie_cv_hip_avmm_0_hip_pipe_txswing1                   => open,                   --                                         .txswing1
			pcie_cv_hip_avmm_0_hip_pipe_txswing2                   => open,                   --                                         .txswing2
			pcie_cv_hip_avmm_0_hip_pipe_txswing3                   => open,                   --                                         .txswing3
			pcie_cv_hip_avmm_0_hip_pipe_txmargin0                  => open,                  --                                         .txmargin0
			pcie_cv_hip_avmm_0_hip_pipe_txmargin1                  => open,                  --                                         .txmargin1
			pcie_cv_hip_avmm_0_hip_pipe_txmargin2                  => open,                  --                                         .txmargin2
			pcie_cv_hip_avmm_0_hip_pipe_txmargin3                  => open,                  --                                         .txmargin3
			pcie_cv_hip_avmm_0_hip_pipe_txdeemph0                  => open,                  --                                         .txdeemph0
			pcie_cv_hip_avmm_0_hip_pipe_txdeemph1                  => open,                  --                                         .txdeemph1
			pcie_cv_hip_avmm_0_hip_pipe_txdeemph2                  => open,                  --                                         .txdeemph2
			pcie_cv_hip_avmm_0_hip_pipe_txdeemph3                  => open,                 --                                         .txdeemph3
			pio_rp_reset_external_connection_in_port                 => s_pcie_npor_pin_perst,                 --         pio_rp_reset_external_connection.in_port
			pio_rp_reset_external_connection_out_port                => s_pcie_npor_pin_perst,                 --                                         .out_port
			alt_xcvr_reconfig_0_reconfig_mgmt_address         => (others=>'0'),
			alt_xcvr_reconfig_0_reconfig_mgmt_read            => '0',
			alt_xcvr_reconfig_0_reconfig_mgmt_readdata        => open,
			alt_xcvr_reconfig_0_reconfig_mgmt_waitrequest     => open,
			alt_xcvr_reconfig_0_reconfig_mgmt_write           => '0',
			alt_xcvr_reconfig_0_reconfig_mgmt_writedata       => (others=>'0')
		);

	DVI_DE <= dvi_de_i;
	DVI_VSYNC <= dvi_vsync_i; 
	DVI_HSYNC <= dvi_hsync_i; 

	UGPIO(0) <= dvi_de_i;
	UGPIO(1) <= dvi_hsync_i;
	UGPIO(2) <= dvi_vsync_i;

	cvo_clk_p_ddio : ddout 
	PORT MAP (
		datain_h(0)	 => '1',
		datain_l(0)	 => '0',
		outclock	 => vid_out_clk,
		dataout(0)	 => DVI_CLK_P
	);

	cvo_clk_n_ddio : ddout 
	PORT MAP (
		datain_h(0)	 => '0',
		datain_l(0)	 => '1',
		outclock	 => vid_out_clk,
		dataout(0)	 => DVI_CLK_N
	);
	pcie_perstn <= '0' when s_pcie_npor_pin_perst = '1' else 'Z';
end architecture rtl;

-------------------------------------------------------------------------------
