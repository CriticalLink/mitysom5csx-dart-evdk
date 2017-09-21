-------------------------------------------------------------------------------
--
--     o  0                          
--     | /       Copyright (c) 2017
--    (CL)---o   Critical Link, LLC  
--      \                            
--       O                           
--
-- File       : vdk_dual_top.vhd
-- Company    : Critical Link, LLC
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top level entity for the MitySOM-5CSX Dual Camera VDK
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity vdk_dual_top is
	generic(
		HPS_DDR_D_SIZE    : integer := 40;
		HPS_DDR_A_SIZE    : integer := 15;
		HPS_DDR_NUM_CHIPS : integer := 5;
		FPGA_DDR_A_SIZE   : integer := 0
	);
	port(
		-- HPS DDR
		HPS_DDR_A         : out   std_logic_vector(HPS_DDR_A_SIZE - 1 downto 0);
		HPS_DDR_BAS       : out   std_logic_vector(2 downto 0);
		HPS_DDR_CK_P      : out   std_logic;
		HPS_DDR_CK_N      : out   std_logic;
		HPS_DDR_CKE       : out   std_logic;
		HPS_DDR_CS0_N     : out   std_logic;
		HPS_DDR_RAS_N     : out   std_logic;
		HPS_DDR_CAS_N     : out   std_logic;
		HPS_DDR_WE_N      : out   std_logic;
		HPS_DDR_RESET_N   : out   std_logic;
		HPS_DDR_D         : inout std_logic_vector(HPS_DDR_D_SIZE - 1 downto 0)    := (others => 'X');
		HPS_DDR_DQS_P     : inout std_logic_vector(HPS_DDR_NUM_CHIPS - 1 downto 0) := (others => 'X');
		HPS_DDR_DQS_N     : inout std_logic_vector(HPS_DDR_NUM_CHIPS - 1 downto 0) := (others => 'X');
		HPS_DDR_DQM       : out   std_logic_vector(HPS_DDR_NUM_CHIPS - 1 downto 0);
		HPS_RZQ0          : in    std_logic                                        := 'X';
		HPS_ODT           : out   std_logic;
		-- RGMII1
		RGMII1_TX_CLK     : out   std_logic;
		RGMII1_TXD0       : out   std_logic;
		RGMII1_TXD1       : out   std_logic;
		RGMII1_TXD2       : out   std_logic;
		RGMII1_TXD3       : out   std_logic;
		RGMII1_RXD0       : in    std_logic                                        := 'X';
		RGMII1_MDIO       : inout std_logic                                        := 'X';
		RGMII1_MDC        : out   std_logic;
		RGMII1_RX_CTL     : in    std_logic                                        := 'X';
		RGMII1_TX_CTL     : out   std_logic;
		RGMII1_RX_CLK     : in    std_logic                                        := 'X';
		RGMII1_RXD1       : in    std_logic                                        := 'X';
		RGMII1_RXD2       : in    std_logic                                        := 'X';
		RGMII1_RXD3       : in    std_logic                                        := 'X';
		RGMII1_RESETn     : inout std_logic;
		-- QSPI
		QSPI_DQ0          : inout std_logic                                        := 'X';
		QSPI_DQ1          : inout std_logic                                        := 'X';
		QSPI_DQ2          : inout std_logic                                        := 'X';
		QSPI_DQ3          : inout std_logic                                        := 'X';
		QSPI_SS0          : out   std_logic;
		QSPI_SS1          : out   std_logic;
		QSPI_CLK          : out   std_logic;
		-- SDMMC
		SDMMC_CMD         : inout std_logic                                        := 'X';
		SDMMC_D0          : inout std_logic                                        := 'X';
		SDMMC_D1          : inout std_logic                                        := 'X';
		SDMMC_CLK         : out   std_logic;
		SDMMC_D2          : inout std_logic                                        := 'X';
		SDMMC_D3          : inout std_logic                                        := 'X';
		-- USB1
		USB1_ULPI_D0      : inout std_logic                                        := 'X';
		USB1_ULPI_D1      : inout std_logic                                        := 'X';
		USB1_ULPI_D2      : inout std_logic                                        := 'X';
		USB1_ULPI_D3      : inout std_logic                                        := 'X';
		USB1_ULPI_D4      : inout std_logic                                        := 'X';
		USB1_ULPI_D5      : inout std_logic                                        := 'X';
		USB1_ULPI_D6      : inout std_logic                                        := 'X';
		USB1_ULPI_D7      : inout std_logic                                        := 'X';
		USB1_ULPI_CLK     : in    std_logic                                        := 'X';
		USB1_ULPI_STP     : out   std_logic;
		USB1_ULPI_DIR     : in    std_logic                                        := 'X';
		USB1_ULPI_NXT     : in    std_logic                                        := 'X';
		USB1_ULPI_CS      : inout std_logic;
		USB1_ULPI_RESET_N : inout std_logic;
		-- UART0
		B7A_UART0_RX      : in    std_logic                                        := 'X';
		B7A_UART0_TX      : out   std_logic;
		-- I2C0
		B7A_I2C0_SDA      : inout std_logic                                        := 'X';
		B7A_I2C0_SCL      : inout std_logic                                        := 'X';
		-- I2C1
		I2C1_SCL          : inout std_logic;
		I2C1_SDA          : inout std_logic;
		-- CAM1
		CAM1_X            : in    std_logic_vector(3 downto 0);
		CAM1_XCLK         : in    std_logic;
		CAM1_CC           : out   std_logic;
		-- CAM2
		CAM2_X            : in    std_logic_vector(3 downto 0);
		CAM2_XCLK         : in    std_logic;
		CAM2_CC           : out   std_logic;
		CAM1_ID           : inout std_logic;
		CAM2_ID           : inout std_logic;
		-- DVI
		DVI_R             : out   std_logic_vector(7 downto 0);
		DVI_G             : out   std_logic_vector(7 downto 0);
		DVI_B             : out   std_logic_vector(7 downto 0);
		DVI_HSYNC         : out   std_logic;
		DVI_VSYNC         : out   std_logic;
		DVI_DE            : out   std_logic;
		DVI_CLK_P         : out   std_logic;
		DVI_CLK_N         : out   std_logic;
		DVI_RESET_N       : inout std_logic;
		DVI_PD_N          : inout std_logic;
		DVI_MSEN          : inout std_logic;
		-- User GPIO
		UGPIO             : inout std_logic_vector(6 downto 0)
	);
end entity vdk_dual_top;

-------------------------------------------------------------------------------

architecture rtl of vdk_dual_top is
	component vdk_dual is
		port(
			hps_ddr_mem_a                      : out   std_logic_vector(HPS_DDR_A_SIZE - 1 downto 0);
			hps_ddr_mem_ba                     : out   std_logic_vector(2 downto 0);
			hps_ddr_mem_ck                     : out   std_logic;
			hps_ddr_mem_ck_n                   : out   std_logic;
			hps_ddr_mem_cke                    : out   std_logic;
			hps_ddr_mem_cs_n                   : out   std_logic;
			hps_ddr_mem_ras_n                  : out   std_logic;
			hps_ddr_mem_cas_n                  : out   std_logic;
			hps_ddr_mem_we_n                   : out   std_logic;
			hps_ddr_mem_reset_n                : out   std_logic;
			hps_ddr_mem_dq                     : inout std_logic_vector(HPS_DDR_D_SIZE - 1 downto 0)    := (others => 'X');
			hps_ddr_mem_dqs                    : inout std_logic_vector(HPS_DDR_NUM_CHIPS - 1 downto 0) := (others => 'X');
			hps_ddr_mem_dqs_n                  : inout std_logic_vector(HPS_DDR_NUM_CHIPS - 1 downto 0) := (others => 'X');
			hps_ddr_mem_odt                    : out   std_logic;
			hps_ddr_mem_dm                     : out   std_logic_vector(HPS_DDR_NUM_CHIPS - 1 downto 0);
			hps_ddr_oct_rzqin                  : in    std_logic                                        := 'X';
			hps_io_hps_io_emac1_inst_TX_CLK    : out   std_logic;
			hps_io_hps_io_emac1_inst_TXD0      : out   std_logic;
			hps_io_hps_io_emac1_inst_TXD1      : out   std_logic;
			hps_io_hps_io_emac1_inst_TXD2      : out   std_logic;
			hps_io_hps_io_emac1_inst_TXD3      : out   std_logic;
			hps_io_hps_io_emac1_inst_RXD0      : in    std_logic                                        := 'X';
			hps_io_hps_io_emac1_inst_MDIO      : inout std_logic                                        := 'X';
			hps_io_hps_io_emac1_inst_MDC       : out   std_logic;
			hps_io_hps_io_emac1_inst_RX_CTL    : in    std_logic                                        := 'X';
			hps_io_hps_io_emac1_inst_TX_CTL    : out   std_logic;
			hps_io_hps_io_emac1_inst_RX_CLK    : in    std_logic                                        := 'X';
			hps_io_hps_io_emac1_inst_RXD1      : in    std_logic                                        := 'X';
			hps_io_hps_io_emac1_inst_RXD2      : in    std_logic                                        := 'X';
			hps_io_hps_io_emac1_inst_RXD3      : in    std_logic                                        := 'X';
			hps_io_hps_io_qspi_inst_SS1        : out   std_logic;
			hps_io_hps_io_qspi_inst_IO0        : inout std_logic                                        := 'X';
			hps_io_hps_io_qspi_inst_IO1        : inout std_logic                                        := 'X';
			hps_io_hps_io_qspi_inst_IO2        : inout std_logic                                        := 'X';
			hps_io_hps_io_qspi_inst_IO3        : inout std_logic                                        := 'X';
			hps_io_hps_io_qspi_inst_SS0        : out   std_logic;
			hps_io_hps_io_qspi_inst_CLK        : out   std_logic;
			hps_io_hps_io_sdio_inst_CMD        : inout std_logic                                        := 'X';
			hps_io_hps_io_sdio_inst_D0         : inout std_logic                                        := 'X';
			hps_io_hps_io_sdio_inst_D1         : inout std_logic                                        := 'X';
			hps_io_hps_io_sdio_inst_CLK        : out   std_logic;
			hps_io_hps_io_sdio_inst_D2         : inout std_logic                                        := 'X';
			hps_io_hps_io_sdio_inst_D3         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_D0         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_D1         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_D2         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_D3         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_D4         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_D5         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_D6         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_D7         : inout std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_CLK        : in    std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_STP        : out   std_logic;
			hps_io_hps_io_usb1_inst_DIR        : in    std_logic                                        := 'X';
			hps_io_hps_io_usb1_inst_NXT        : in    std_logic                                        := 'X';
			hps_io_hps_io_uart0_inst_RX        : in    std_logic                                        := 'X';
			hps_io_hps_io_uart0_inst_TX        : out   std_logic;
			hps_io_hps_io_i2c0_inst_SDA        : inout std_logic                                        := 'X';
			hps_io_hps_io_i2c0_inst_SCL        : inout std_logic                                        := 'X';
			hps_io_hps_io_i2c1_inst_SDA        : inout std_logic                                        := 'X';
			hps_io_hps_io_i2c1_inst_SCL        : inout std_logic                                        := 'X';
			hps_io_hps_io_gpio_inst_GPIO00     : inout std_logic                                        := 'X';
			hps_io_hps_io_gpio_inst_GPIO09     : inout std_logic                                        := 'X';
			hps_io_hps_io_gpio_inst_GPIO28     : inout std_logic                                        := 'X';
			hps_io_hps_io_gpio_inst_GPIO41     : inout std_logic                                        := 'X';
			hps_io_hps_io_gpio_inst_GPIO44     : inout std_logic                                        := 'X';
			hps_io_hps_io_gpio_inst_GPIO48     : inout std_logic                                        := 'X';
			hps_io_hps_io_gpio_inst_GPIO49     : inout std_logic                                        := 'X';
			hps_io_hps_io_gpio_inst_GPIO50     : inout std_logic                                        := 'X';
			cam1_bcon_bm_interface_i_bcon_x    : in    std_logic_vector(3 downto 0)                     := (others => 'X');
			cam1_bcon_bm_interface_i_bcon_xclk : in    std_logic                                        := 'X';
			cam1_bcon_bm_interface_o_bcon_cc   : out   std_logic;
			cam1_bcon_bm_interface_o_fpga_trig : out   std_logic;
			cam2_bcon_bm_interface_i_bcon_x    : in    std_logic_vector(3 downto 0)                     := (others => 'X');
			cam2_bcon_bm_interface_i_bcon_xclk : in    std_logic                                        := 'X';
			cam2_bcon_bm_interface_o_bcon_cc   : out   std_logic;
			cam2_bcon_bm_interface_o_fpga_trig : out   std_logic;
			cvo_clocked_video_vid_data         : out   std_logic_vector(23 downto 0);
			cvo_clocked_video_underflow        : out   std_logic;
			cvo_clocked_video_vid_mode_change  : out   std_logic;
			cvo_clocked_video_vid_std          : out   std_logic;
			cvo_clocked_video_vid_datavalid    : out   std_logic;
			cvo_clocked_video_vid_v_sync       : out   std_logic;
			cvo_clocked_video_vid_h_sync       : out   std_logic;
			cvo_clocked_video_vid_f            : out   std_logic;
			cvo_clocked_video_vid_h            : out   std_logic;
			cvo_clocked_video_vid_v            : out   std_logic;
			vid_out_clk                        : out   std_logic;
			ugpio_export                       : inout std_logic_vector(6 downto 0)                     := (others => 'X')
		);
	end component vdk_dual;

	component ddout is
		port(
			datain_h : in  std_logic_vector(0 downto 0);
			datain_l : in  std_logic_vector(0 downto 0);
			outclock : in  std_logic;
			dataout  : out std_logic_vector(0 downto 0)
		);
	end component ddout;

	signal vid_out_clk : std_logic := '0';
	signal dvi_hsync_i : std_logic;
	signal dvi_vsync_i : std_logic;
	signal dvi_de_i    : std_logic;

begin                                   -- architecture rtl

	----------------------------------------------------------------------------
	-- Component instantiations
	----------------------------------------------------------------------------

	u0 : component vdk_dual
		port map(
			hps_ddr_mem_a                            => HPS_DDR_A,
			hps_ddr_mem_ba                           => HPS_DDR_BAS,
			hps_ddr_mem_ck                           => HPS_DDR_CK_P,
			hps_ddr_mem_ck_n                         => HPS_DDR_CK_N,
			hps_ddr_mem_cke                          => HPS_DDR_CKE,
			hps_ddr_mem_cs_n                         => HPS_DDR_CS0_N,
			hps_ddr_mem_ras_n                        => HPS_DDR_RAS_N,
			hps_ddr_mem_cas_n                        => HPS_DDR_CAS_N,
			hps_ddr_mem_we_n                         => HPS_DDR_WE_N,
			hps_ddr_mem_reset_n                      => HPS_DDR_RESET_N,
			hps_ddr_mem_dq                           => HPS_DDR_D,
			hps_ddr_mem_dqs                          => HPS_DDR_DQS_P,
			hps_ddr_mem_dqs_n                        => HPS_DDR_DQS_N,
			hps_ddr_mem_odt                          => HPS_ODT,
			hps_ddr_mem_dm                           => HPS_DDR_DQM,
			hps_ddr_oct_rzqin                        => HPS_RZQ0,
			hps_io_hps_io_emac1_inst_TX_CLK          => RGMII1_TX_CLK,
			hps_io_hps_io_emac1_inst_TXD0            => RGMII1_TXD0,
			hps_io_hps_io_emac1_inst_TXD1            => RGMII1_TXD1,
			hps_io_hps_io_emac1_inst_TXD2            => RGMII1_TXD2,
			hps_io_hps_io_emac1_inst_TXD3            => RGMII1_TXD3,
			hps_io_hps_io_emac1_inst_RXD0            => RGMII1_RXD0,
			hps_io_hps_io_emac1_inst_RXD1            => RGMII1_RXD1,
			hps_io_hps_io_emac1_inst_RXD2            => RGMII1_RXD2,
			hps_io_hps_io_emac1_inst_RXD3            => RGMII1_RXD3,
			hps_io_hps_io_emac1_inst_MDIO            => RGMII1_MDIO,
			hps_io_hps_io_emac1_inst_MDC             => RGMII1_MDC,
			hps_io_hps_io_emac1_inst_RX_CTL          => RGMII1_RX_CTL,
			hps_io_hps_io_emac1_inst_TX_CTL          => RGMII1_TX_CTL,
			hps_io_hps_io_emac1_inst_RX_CLK          => RGMII1_RX_CLK,
			hps_io_hps_io_qspi_inst_SS1              => QSPI_SS1,
			hps_io_hps_io_qspi_inst_IO0              => QSPI_DQ0,
			hps_io_hps_io_qspi_inst_IO1              => QSPI_DQ1,
			hps_io_hps_io_qspi_inst_IO2              => QSPI_DQ2,
			hps_io_hps_io_qspi_inst_IO3              => QSPI_DQ3,
			hps_io_hps_io_qspi_inst_SS0              => QSPI_SS0,
			hps_io_hps_io_qspi_inst_CLK              => QSPI_CLK,
			hps_io_hps_io_sdio_inst_CMD              => SDMMC_CMD,
			hps_io_hps_io_sdio_inst_D0               => SDMMC_D0,
			hps_io_hps_io_sdio_inst_D1               => SDMMC_D1,
			hps_io_hps_io_sdio_inst_D2               => SDMMC_D2,
			hps_io_hps_io_sdio_inst_D3               => SDMMC_D3,
			hps_io_hps_io_sdio_inst_CLK              => SDMMC_CLK,
			hps_io_hps_io_usb1_inst_D0               => USB1_ULPI_D0,
			hps_io_hps_io_usb1_inst_D1               => USB1_ULPI_D1,
			hps_io_hps_io_usb1_inst_D2               => USB1_ULPI_D2,
			hps_io_hps_io_usb1_inst_D3               => USB1_ULPI_D3,
			hps_io_hps_io_usb1_inst_D4               => USB1_ULPI_D4,
			hps_io_hps_io_usb1_inst_D5               => USB1_ULPI_D5,
			hps_io_hps_io_usb1_inst_D6               => USB1_ULPI_D6,
			hps_io_hps_io_usb1_inst_D7               => USB1_ULPI_D7,
			hps_io_hps_io_usb1_inst_CLK              => USB1_ULPI_CLK,
			hps_io_hps_io_usb1_inst_STP              => USB1_ULPI_STP,
			hps_io_hps_io_usb1_inst_DIR              => USB1_ULPI_DIR,
			hps_io_hps_io_usb1_inst_NXT              => USB1_ULPI_NXT,
			hps_io_hps_io_uart0_inst_RX              => B7A_UART0_RX,
			hps_io_hps_io_uart0_inst_TX              => B7A_UART0_TX,
			hps_io_hps_io_i2c0_inst_SDA              => B7A_I2C0_SDA,
			hps_io_hps_io_i2c0_inst_SCL              => B7A_I2C0_SCL,
			hps_io_hps_io_i2c1_inst_SDA              => I2C1_SDA,
			hps_io_hps_io_i2c1_inst_SCL              => I2C1_SCL,
			hps_io_hps_io_gpio_inst_GPIO00           => USB1_ULPI_CS,
			hps_io_hps_io_gpio_inst_GPIO09           => USB1_ULPI_RESET_N,
			hps_io_hps_io_gpio_inst_GPIO28           => RGMII1_RESETn,
			hps_io_hps_io_gpio_inst_GPIO41           => DVI_PD_N,
			hps_io_hps_io_gpio_inst_GPIO44           => DVI_MSEN,
			hps_io_hps_io_gpio_inst_GPIO48           => DVI_RESET_N,
			hps_io_hps_io_gpio_inst_GPIO49           => CAM2_ID,
			hps_io_hps_io_gpio_inst_GPIO50           => CAM1_ID,
			cam1_bcon_bm_interface_i_bcon_x          => CAM1_X,
			cam1_bcon_bm_interface_i_bcon_xclk       => CAM1_XCLK,
			cam1_bcon_bm_interface_o_bcon_cc         => CAM1_CC,
			cam1_bcon_bm_interface_o_fpga_trig       => open,
			cam2_bcon_bm_interface_i_bcon_x          => CAM2_X,
			cam2_bcon_bm_interface_i_bcon_xclk       => CAM2_XCLK,
			cam2_bcon_bm_interface_o_bcon_cc         => CAM2_CC,
			cam2_bcon_bm_interface_o_fpga_trig       => open,
			cvo_clocked_video_vid_data(23 downto 16) => DVI_R,
			cvo_clocked_video_vid_data(15 downto 8)  => DVI_G,
			cvo_clocked_video_vid_data(7 downto 0)   => DVI_B,
			cvo_clocked_video_underflow              => open,
			cvo_clocked_video_vid_mode_change        => open,
			cvo_clocked_video_vid_std                => open,
			cvo_clocked_video_vid_datavalid          => dvi_de_i,
			cvo_clocked_video_vid_v_sync             => dvi_vsync_i,
			cvo_clocked_video_vid_h_sync             => dvi_hsync_i,
			cvo_clocked_video_vid_f                  => open,
			cvo_clocked_video_vid_h                  => open,
			cvo_clocked_video_vid_v                  => open,
			vid_out_clk                              => vid_out_clk,
			ugpio_export                             => UGPIO
		);

	DVI_DE    <= dvi_de_i;
	DVI_VSYNC <= dvi_vsync_i;
	DVI_HSYNC <= dvi_hsync_i;

	cvo_clk_p_ddio : ddout
		PORT MAP(
			datain_h(0) => '1',
			datain_l(0) => '0',
			outclock    => vid_out_clk,
			dataout(0)  => DVI_CLK_P
		);

	cvo_clk_n_ddio : ddout
		PORT MAP(
			datain_h(0) => '0',
			datain_l(0) => '1',
			outclock    => vid_out_clk,
			dataout(0)  => DVI_CLK_N
		);
end architecture rtl;

-------------------------------------------------------------------------------
