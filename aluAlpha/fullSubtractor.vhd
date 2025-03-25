-- full subtractor 
-- Geeth De Silva
-- github : sagee_dev
-- v1.0
-- full substractor substract two bits b1 and b0
-- output 2 bits result r and borrown bout
-- additionally borrow bin in a input put
-- truth table as follow
-- |b1 | b0 | bin | r | bout |
------------------------------
-- |0  | 0  |  0  | 0 |  0   |
-- |0  | 0  |  1  | 1 |  1   |
-- |0  | 1  |  0  | 1 |  1   |
-- |0  | 1  |  1  | 0 |  1   |
-- |1  | 0  |  0  | 1 |  0   |
-- |1  | 0  |  1  | 0 |  0   |
-- |1  | 1  |  0  | 0 |  0   |
-- |1  | 1  |  1  | 1 |  1   |
-- r    = b1 xor b0 xor bin
-- bout = ((not b1)and(b0 xor bin)) or (b0 and bin)
-- digital electronics hardly uses ripple carry subtractors
-- often time its use 2s complement and ripple carry adders
-- to perform substaction

library ieee;
use ieee.std_logic_1164.all;

entity fullSubtractor is
port(
	signal clk : in std_logic;
	signal rst : in std_logic;
	signal b1  : in std_logic;
	signal b0  : in std_logic;
	signal bin : in std_logic;
	signal r   : out std_logic;
	signal bout: out std_logic
); 
end entity;

architecture rtl of fullSubtractor is
begin

	behaviour: process(clk) is
	begin
		if (rst = '0') then
			r    <= '0';
			bout <= '0';
		else
		
			if rising_edge(clk) then
				r    <= b1 xor b0 xor bin;
				bout <= ((not b1)and(b0 xor bin)) or (b0 and bin);
			end if;
		
		end if;
	end process;

end architecture;