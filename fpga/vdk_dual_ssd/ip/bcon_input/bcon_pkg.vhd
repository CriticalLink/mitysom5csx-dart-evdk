library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;

package bcon_pkg is

	constant BCON_8x1 : unsigned(3 downto 0)         := to_unsigned(0, 4);
	constant BCON_8x2 : unsigned(3 downto 0)         := to_unsigned(1, 4);
	constant BCON_12x1 : unsigned(3 downto 0)        := to_unsigned(2, 4);
	constant BCON_12x1_PACKED : unsigned(3 downto 0) := to_unsigned(3, 4);
	constant BCON_12x2 : unsigned(3 downto 0)        := to_unsigned(4, 4);
	constant BCON_12x2_PACKED : unsigned(3 downto 0) := to_unsigned(5, 4);
	constant BCON_16x1YCrCb422 : unsigned(3 downto 0):= to_unsigned(6, 4);
	constant BCON_24RGB : unsigned(3 downto 0)       := to_unsigned(7, 4);

end package;

package body bcon_pkg is

end bcon_pkg;
