--Full Adder
--Geeth De Silva
--Github : sagee_dev
--full adder add two bit with carry in
--and output sum and carry out
--inputs bit 0 (b0), bit 1 (b1) carry in(ci)
--outputs sum (s) carry out (co)
-- Truth table as follow
-- |b0  |b1  |ci  |s  |co |
-- |----|----|----|---|---|
-- | 0  | 0  | 0  |0  | 0 |
-- | 0  | 0  | 1  |1  | 0 |
-- | 0  | 1  | 0  |1  | 0 |
-- | 0  | 1  | 1  |0  | 1 |
-- | 1  | 0  | 0  |1  | 0 |
-- | 1  | 0  | 1  |0  | 1 |
-- | 1  | 1  | 0  |0  | 1 |
-- | 1  | 1  | 1  |1  | 1 |    
-- s  = bo xor b1 xor ci
-- co = (b0 xor b0)ci or (b0 and b1)
--there will be additional clk signal 
--and a reset signal to update and reset memory element 

library ieee;
use ieee.std_logic_1164.all;

entity fullAdder is
--define inputs and outputs
port(signal clk : in  std_logic;
	 signal rst : in  std_logic;
	 signal b0  : in  std_logic;
	 signal b1  : in  std_logic;
	 signal ci  : in  std_logic;
	 signal s   : out std_logic;
	 signal co  : out std_logic);
end entity;

architecture rtl of fullAdder is
begin
	addition: process(clk) is 
	begin
		if rising_edge(clk) then
			if rst = '0' then
				-- reset adders outputs
				s  <= '0';
				co <= '0';
				
			else
				s <= (b0 xor b1 xor ci); --set sumbit
				co <= (((b0 xor b1)and ci) or (b0 and b1)); --set carry bit
			end if;
		end if;
	end process;
end architecture;
 