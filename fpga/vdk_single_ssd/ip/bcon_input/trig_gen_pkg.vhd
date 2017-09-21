library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE ieee.numeric_std.ALL;

package trig_gen_pkg is
	type compare_array is array(3 downto 0) of unsigned(15 downto 0);

	component trigger_generator is
		port (
			i_clk : in std_logic;

			i_reset : in std_logic;

			i_clk_div_reg : in unsigned(3 downto 0);
			i_clk_period : in unsigned(15 downto 0);
			i_cc_compare_strt : in compare_array;
			i_cc_compare_end : in compare_array;

			i_cc_en : in std_logic_vector(3 downto 0);
			i_cc_inv : in std_logic_vector(3 downto 0);
			i_cc_sel : in unsigned(1 downto 0);

			o_cc : out std_logic_vector(3 downto 0);
			o_to_fpga : out std_logic
		);
	end component trigger_generator;

end trig_gen_pkg;

package body trig_gen_pkg is 
end trig_gen_pkg;
