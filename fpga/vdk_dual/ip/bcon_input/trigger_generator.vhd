library IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.trig_gen_pkg.ALL;

entity trigger_generator is
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
end entity trigger_generator;

architecture rtl of trigger_generator is
	signal div_clk : std_logic := '0';	
	signal div_clk_r1 : std_logic := '0';
	signal div_clk_ctr : unsigned(15 downto 0) := (others => '0');

	signal s_cc : std_logic_vector(3 downto 0) := (others => '0');

	signal period_ctr : unsigned(15 downto 0) := (others => '0');
begin

	div_clk_gen : process(i_clk, i_reset)
		variable v_div_clk_ctr : unsigned(15 downto 0) := (others => '0');
	begin
		if i_reset = '1' then
			div_clk_ctr <= (others => '0');
			v_div_clk_ctr := (others => '0');
		elsif rising_edge(i_clk) then
			v_div_clk_ctr := div_clk_ctr + 1;
			div_clk_ctr <= v_div_clk_ctr;

			if v_div_clk_ctr(TO_INTEGER(i_clk_div_reg)) = '1' then
				div_clk <= NOT(div_clk);
				div_clk_ctr <= (others => '0');
			end if;
		end if;
	end process;

	cc_gen : process(i_clk, i_reset)
	begin
		if i_reset = '1' then
			period_ctr <= (others => '0');
			s_cc <= (others => '0');
		elsif rising_edge(i_clk) then
			div_clk_r1 <= div_clk;
			if div_clk_r1 = '0' AND div_clk = '1' then
				period_ctr <= period_ctr + 1;

				if period_ctr >= i_clk_period then
					period_ctr <= (others => '0');
				end if;

				for i in 3 downto 0 loop
					if period_ctr >= i_cc_compare_strt(i) then
						s_cc(i) <= '1';
					end if;

					if period_ctr >= i_cc_compare_end(i) then
						s_cc(i) <= '0';
					end if;
				end loop;
			end if;
		end if;
	end process;

	cc_out_assign : for idx in 3 downto 0 generate
		o_cc(idx) <= (s_cc(idx) XOR i_cc_inv(idx)) AND i_cc_en(idx);
	end generate;

	o_to_fpga <= s_cc(TO_INTEGER(i_cc_sel));

end rtl;

