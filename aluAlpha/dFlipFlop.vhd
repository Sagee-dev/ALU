-- D Flip Flop
-- Geeth De Silva
-- github : sagee_dev
-- v1.0
-- d flip flop has one input (d) and a clock (clk)
-- and one output (q)
-- at the clock rising edge input d will be
-- set to output (q)

library ieee;
use ieee.std_logic_1164.all;

entity dFlipflop is
port(
	signal clk : in  std_logic;
	signal d   : in  std_logic;
	signal q   : inout std_logic
);
end entity;

architecture rtl of dFlipflop is
begin

	action: process(clk) is
	begin
		if rising_edge(clk) then
			q <= d; --set input to output at every rising click edge
		end if;
	end process;

end architecture;