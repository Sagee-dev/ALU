-- n bit register
-- Geeth De Silva
-- github : sagee_dev
-- n bit register is a register made of d flipflop
-- register width can be any integer
-- and register has asynchronus reset
-- inputs clk rst vector of inout bits
-- outputs vector of output bits

library ieee;
use ieee.std_logic_1164.all;

entity nbitRegister is
generic(registerWidth : integer); --generic register width width need to be set from tb
port(signal d : in  std_logic_vector(registerWidth downto 0);-- input outputs for the module
	 signal q : out std_logic_vector(registerWidth downto 0);
	 signal clk : in std_logic;
	 signal rst : in std_logic);
end entity;

architecture rtl of nbitRegister is

	signal d_d :  std_logic_vector(registerwidth downto 0); --inputs to flipflops
	signal d_q :  std_logic_vector(registerWidth downto 0); --outputs from flipflops
	
begin

	gen: for i in registerWidth downto 0 generate -- generate required flipflops 
		dut: entity work.dFlipflop(rtl)           -- using a for loop
		port map(clk => clk,
				 d => d_d(i),
				 q => d_q(i));
	end generate;
	
	behaviour: process(clk) is
	begin
		if(rst ='0') then
			d_d <= (others => '0'); --reset logic
		else
			if rising_edge(clk) then
				d_d <= d; -- set input to for flipflops 
				q   <= d_q; -- set outputs of flipflops
			end if;
		end if;
	
	end process;

end architecture;