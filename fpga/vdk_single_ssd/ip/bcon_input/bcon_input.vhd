--- Title: bcon_input.vhd
---
---
---     o  0
---     | /       Copyright (c) 2016
---    (CL)---o   Critical Link, LLC
---      \
---       O
---
--- Company: Critical Link, LLC.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
library WORK;
use work.trig_gen_pkg.ALL;
use work.bcon_pkg.ALL;

LIBRARY altera_mf;
USE altera_mf.all;

entity bcon_input is
	generic
	(
		g_lane_invert : std_logic_vector(4 downto 0) := "00000";
		g_vid_data_mode : std_logic := '0' --! 0 is color, 1 is mono 
	);
	port 
	(
		i_register_clock : in  std_logic;
		o_pixel_clock : out std_logic; 

		i_rst : in std_logic;

		-- register access interface
		i_reg_addr : in  std_logic_vector(4 downto 0);
		i_reg_read_en : in  std_logic;
		i_reg_write_en : in  std_logic;
		i_reg_writedata : in  std_logic_vector(31 downto 0);
		o_reg_readdata : out std_logic_vector(31 downto 0);
		o_reg_waitrequest : out std_logic;
		
		vid_clk            : out  std_logic;                     
		vid_data           : out  std_logic_vector(23 downto 0); 
		vid_de             : out  std_logic;                     
		vid_datavalid      : out  std_logic;                    
		vid_locked         : out  std_logic;                   
		vid_f              : out  std_logic;                  
		vid_v_sync         : out  std_logic;                 
		vid_h_sync         : out  std_logic;                
		vid_std            :  out std_logic;                     
		vid_color_encoding :  out std_logic_vector(7 downto 0);
		vid_bit_width      :  out std_logic_vector(7 downto 0);
		sof                : in   std_logic;                    
		sof_locked         : in   std_logic;                 
		refclk_div         : in   std_logic;                
		overflow           : in   std_logic;                    

		-- PLL reconfig
		reconfig_to_pll   : in  std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_to_pll
		reconfig_from_pll : out std_logic_vector(63 downto 0);                    -- reconfig_from_pll

		-- bcon_bm_interface
		i_bcon_x : in std_logic_vector(3 downto 0);
		i_bcon_xclk : in std_logic;
		o_bcon_cc : out std_logic;
		o_fpga_trig : out std_logic  -- one of CC lines (selectable) routed to GPIO alt_input
	);
end entity bcon_input;

architecture rtl of bcon_input is

	------------------------------------------------------------------------------
	-- Constants
	------------------------------------------------------------------------------
	constant VERS_REG_OFFSET : std_logic_vector(4 downto 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(0, 5));
	constant CTRL_REG_OFFSET : std_logic_vector(4 downto 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(1, 5));
	-- TODO: remove
	constant SIZE_REG_OFFSET : std_logic_vector(4 downto 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(2, 5));
	-- TODO: remove
	constant ROIS_REG_OFFSET : std_logic_vector(4 downto 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(3, 5));
	constant TCTL_REG_OFFSET : std_logic_vector(4 downto 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(4, 5));
	constant T1C_REG_OFFSET : std_logic_vector(4 downto 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(5, 5));

	-- VERSION HISTORY
	-- 0x00010000 - Initial code.
	constant VERSION : std_logic_vector(31 downto 0) := x"00010000";

	component altlvdsrx_5x7
		PORT
		(
			rx_channel_data_align		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			rx_enable		: IN STD_LOGIC ;
			rx_in		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			rx_inclock		: IN STD_LOGIC ;
			rx_out		: OUT STD_LOGIC_VECTOR (34 DOWNTO 0)
		);
	end component;

	component pll_1x7_reconfig is
		port (
			refclk            : in  std_logic                     := 'X';             -- clk
			rst               : in  std_logic                     := 'X';             -- reset
			outclk_0          : out std_logic;                                        -- clk
			outclk_1          : out std_logic;                                        -- clk
			outclk_2          : out std_logic;                                        -- clk
			locked            : out std_logic;                                        -- export
			reconfig_to_pll   : in  std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_to_pll
			reconfig_from_pll : out std_logic_vector(63 downto 0)                     -- reconfig_from_pll
		);
	end component pll_1x7_reconfig;

	component cyclonev_pll_lvds_output
	generic (
		pll_loaden_enable_disable  : STRING;
		pll_lvdsclk_enable_disable : STRING
	);
	port (
		ccout           : in  std_logic_vector (1 downto 0);
		loaden          : out std_logic ;
		lvdsclk         : out std_logic 
	);
	end component;
	
	------------------------------------------------------------------------------
	-- Signals
	------------------------------------------------------------------------------
	signal s_srst_reg : std_logic := '1';
	signal s_pll_rst_reg : std_logic := '1';
	signal s_pll_x_locked_reg : std_logic := '0';
	signal s_xclk_locked_reg : std_logic := '0';  -- when '1', means X lanes are locked / bit aligned
	signal s_xclk_locked_reg_m : std_logic := '0';  -- when '1', means X lanes are locked / bit aligned
	signal s_xclk_notlocked_sticky_reg : std_logic := '0';  -- when '1', means X lanes are locked / bit aligned
	signal s_trig_clk_div_reg : unsigned(3 downto 0) := to_unsigned(1, 4);
	signal s_clk_period_reg : unsigned(15 downto 0) := to_unsigned(1, 16);
	signal s_cc_compare_strt_reg : compare_array := (others=>(others=>'0'));
	signal s_cc_compare_end_reg :  compare_array := (others=>(others=>'0'));
	signal s_cc_en_reg : std_logic_vector(3 downto 0) := (others=>'0');
	signal s_cc_inv_reg : std_logic_vector(3 downto 0) := (others=>'0');
	signal s_cc_sel_reg : unsigned(1 downto 0) := to_unsigned(1, 2);

	signal s_x_channel_data_align : std_logic_vector(4 downto 0) := (others=>'0');
	signal s_x_enable : std_logic := '0';
	signal s_x_inclock : std_logic := '0';
	signal s_x_out : std_logic_vector(27 downto 0) := (others=>'0');
	signal s_x_clkout : std_logic_vector(6 downto 0) := (others=>'0');
	signal s_x_out_preinv : std_logic_vector(27 downto 0) := (others=>'0');
	signal s_x_clkout_preinv : std_logic_vector(6 downto 0) := (others=>'0');
	signal s_x_rx_clk : std_logic := '0';
	signal s_x_locked : std_logic := '0';

	signal s_x_lval : std_logic := '0';
	signal s_x_fval : std_logic := '0';

	signal s_x_enable_unbuf : std_logic := '0';
	signal s_x_inclock_unbuf : std_logic := '0';
	signal s_align_clk : unsigned(3 downto 0) := (others=>'0');

	signal s_databits    : std_logic_vector(23 downto 0) := (others=>'0');
	signal s_outputs : std_logic_vector(1 downto 0) := (others=>'0');
	
begin

	o_reg_waitrequest <= '0'; -- Should never have a need to force wait.

	--! Process to handle register writes by the HPS.
	REG_WRITE_PROC : process(i_register_clock) 
	begin
		if rising_edge(i_register_clock) then
			if (i_reg_write_en = '1') then
				case i_reg_addr is
					when CTRL_REG_OFFSET =>
						s_srst_reg <= i_reg_writedata(0);
						s_pll_rst_reg <= i_reg_writedata(1);
						if i_reg_writedata(5) = '1' then
							s_xclk_notlocked_sticky_reg <= '0';
						end if;

					when TCTL_REG_OFFSET =>
						s_trig_clk_div_reg <= unsigned(i_reg_writedata(3 downto 0));
						s_cc_en_reg <= i_reg_writedata(7 downto 4);
						s_cc_inv_reg <= i_reg_writedata(15 downto 12);
						s_cc_sel_reg <= unsigned(i_reg_writedata(9 downto 8));
						s_clk_period_reg <= unsigned(i_reg_writedata(31 downto 16));

					when T1C_REG_OFFSET =>
						s_cc_compare_strt_reg(0) <= unsigned(i_reg_writedata(15 downto 0));
						s_cc_compare_end_reg(0)  <= unsigned(i_reg_writedata(31 downto 16));

					when others => 
						null;
				end case;		
			else
				-- sticky bit on xclk lock drifting
				if s_xclk_locked_reg_m = '0' then
					s_xclk_notlocked_sticky_reg <= '1';
				end if;
				
			end if;
		end if;
	end process REG_WRITE_PROC;

	--! Process to handle register reads by the HPS.
	REG_READ_PROC : process(i_register_clock) 
	begin
		if rising_edge(i_register_clock) then
			o_reg_readdata <= (others => '0');
			s_pll_x_locked_reg <= s_x_locked;
			s_xclk_locked_reg_m <= s_xclk_locked_reg;
			

			if (i_reg_read_en = '1') then
				case i_reg_addr is
					when VERS_REG_OFFSET =>
						o_reg_readdata <= VERSION;

					when CTRL_REG_OFFSET =>
						o_reg_readdata(0) <= s_srst_reg;
						o_reg_readdata(1) <= s_pll_rst_reg;
						o_reg_readdata(2) <= s_pll_x_locked_reg;
						o_reg_readdata(4) <= s_xclk_locked_reg_m;
						o_reg_readdata(5) <= s_xclk_notlocked_sticky_reg;

					when TCTL_REG_OFFSET =>
						o_reg_readdata(3 downto 0) <= std_logic_vector(s_trig_clk_div_reg);
						o_reg_readdata(7 downto 4) <= s_cc_en_reg;
						o_reg_readdata(15 downto 12) <= s_cc_inv_reg;
						o_reg_readdata(9 downto 8) <= std_logic_vector(s_cc_sel_reg);
						o_reg_readdata(31 downto 16) <= std_logic_vector(s_clk_period_reg);

					when T1C_REG_OFFSET =>
						o_reg_readdata(15 downto 0) <= std_logic_vector(s_cc_compare_strt_reg(0));
						o_reg_readdata(31 downto 16) <= std_logic_vector(s_cc_compare_end_reg(0));

					when others => 
						o_reg_readdata <= (others => '0');
				end case;		
			end if;
		end if;
	end process REG_READ_PROC;


	-- see spec
	s_x_lval <= s_x_out(4);
	s_x_fval <= s_x_out(3);
	
	databit1 : for i in 0 to 6 generate
	begin
		s_databits(23 - i) <= s_x_out(21 + i);
	end generate;
	
	databit2 : for i in 0 to 6 generate
	begin
		s_databits(16 - i) <= s_x_out(14 + i);
	end generate;
	
	databit3 : for i in 0 to 6 generate
	begin
		s_databits(9 - i) <= s_x_out(7 + i);
	end generate;
	
	databit4 : for i in 0 to 2 generate
	begin
		s_databits(2 - i) <= s_x_out(i);
	end generate;
	
	s_outputs <= s_x_out(5) & s_x_out(6);

	vid_clk <= s_x_rx_clk;

	-- for RGB, data is output on camera as BGR (B=bit 23-16). VIPII wants RGB(R=bit23-16)
	vid_data(23 downto 16) <= s_databits(7 downto 0);
	vid_data(15 downto 8)  <= s_databits(15 downto 8) when g_vid_data_mode = '0' else s_databits(7 downto 0);
	vid_data(7 downto 0)   <= s_databits(23 downto 16) when g_vid_data_mode = '0' else s_databits(7 downto 0);
	vid_de <= s_x_lval and s_x_fval;
	vid_datavalid <= '1';
	vid_locked <= '1';
	vid_f <= '0';
	vid_v_sync <= not s_x_fval;
	vid_h_sync <= not s_x_lval;
	vid_std <= '0';
	vid_color_encoding <= (others=>'0');
	vid_bit_width <= (others=>'0');

	x_5x7_inst : altlvdsrx_5x7
	PORT MAP
	(
		rx_channel_data_align	 => s_x_channel_data_align,
		rx_enable		 => s_x_enable,
		rx_in(3 downto 0)	 => i_bcon_x,
		rx_in(4)		 => i_bcon_xclk,
		rx_inclock		 => s_x_inclock,
		rx_out(27 downto 0)	 => s_x_out_preinv,
		rx_out(34 downto 28)	 => s_x_clkout_preinv
	);

	o_pixel_clock <= s_x_rx_clk;

	inv_inputlanes : for i in 0 to 6 generate
	begin
		s_x_clkout(i) <= s_x_clkout_preinv(i) xor g_lane_invert(0);
		s_x_out(i)    <= s_x_out_preinv(i)    xor g_lane_invert(1);
		s_x_out(7+i)  <= s_x_out_preinv(7+i)  xor g_lane_invert(2);
		s_x_out(14+i) <= s_x_out_preinv(14+i) xor g_lane_invert(3);
		s_x_out(21+i) <= s_x_out_preinv(21+i) xor g_lane_invert(4);
	end generate inv_inputlanes;

	pllx_5x7_inst : pll_1x7_reconfig
	port map
	(
		refclk			=> i_bcon_xclk,
		rst			=> s_pll_rst_reg,
		outclk_0		=> s_x_inclock_unbuf,
		outclk_1		=> s_x_enable_unbuf,
		outclk_2		=> s_x_rx_clk,
		locked			=> s_x_locked,
		reconfig_to_pll		=> reconfig_to_pll,
		reconfig_from_pll	=> reconfig_from_pll
	);

	LVDS_clock_buffer_inst0 : cyclonev_pll_lvds_output
	generic map (
		pll_loaden_enable_disable  => "true",
		pll_lvdsclk_enable_disable => "true"
	)
	port map (
		ccout(0)           => s_x_inclock_unbuf,
		ccout(1)           => s_x_enable_unbuf,
		loaden             => s_x_enable,
		lvdsclk            => s_x_inclock
	);

	-- use RX clock to bit align received data patterns
	clk_x_align : process(s_x_rx_clk)
	begin
		if rising_edge(s_x_rx_clk) then
			s_x_channel_data_align <= "00000";
			if s_x_locked = '1' then
				if s_align_clk = to_unsigned(0, s_align_clk'length) then
					if s_x_clkout /= "1100011" then
						s_x_channel_data_align <= "11111";
						s_xclk_locked_reg <= '0';
						s_align_clk <= s_align_clk + 1;
					else
						s_xclk_locked_reg <= '1';
					end if;
				else
					if s_align_clk = to_unsigned(4, s_align_clk'length) then
						s_align_clk <= (others=>'0');
					else
						s_align_clk <= s_align_clk + 1;
					end if;
				end if;
			else
				s_align_clk <= (others=>'0');
			end if;
		end if;
	end process;

	-- TODO: Check history of "Jeff's spiffy stuff"
	-- use Jeff's spiffy stuff
	cc_gen: trigger_generator PORT MAP (
		i_clk => i_register_clock,
		i_reset => i_rst,
		i_clk_div_reg => s_trig_clk_div_reg,
		i_clk_period => s_clk_period_reg,
		i_cc_compare_strt => s_cc_compare_strt_reg,
		i_cc_compare_end => s_cc_compare_end_reg,
		i_cc_en => s_cc_en_reg,
		i_cc_inv => s_cc_inv_reg,
		i_cc_sel => s_cc_sel_reg,
		o_cc(0) => o_bcon_cc,
		o_cc(3 downto 1) => open,
		o_to_fpga => o_fpga_trig
	);

end architecture; -- of bcon_input

