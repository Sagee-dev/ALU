-- ripple carry adder
-- Geeth De Silva
-- github : sagee_dev
--generic ripple carry adderbit width to be defined from tb
--input d1 (2nd nuber binary) d0 (1st number binay)
-- output r sum of the addition co carry out
library ieee;
use ieee.std_logic_1164.all;

entity rippleCarryAdder is
generic(bitwidth : integer); --decide the size of the adder 
port(
	signal clk : in std_logic;
	signal rst : in std_logic;
	signal cin : in  std_logic;
	signal cout: out std_logic;
	signal d0: in std_logic_vector(bitwidth downto 0);
	signal d1: in std_logic_vector(bitwidth downto 0);
	signal r : out std_logic_vector(bitwidth downto 0)
	
);
end entity;
architecture rtl of rippleCarryAdder is

	signal c_fa : std_logic_vector(bitwidth downto 0); -- intermediate vector to store carry bits
	signal d0_fa: std_logic_vector(bitwidth downto 0);
	signal d1_fa: std_logic_vector(bitwidth downto 0);
	signal s_fa : std_logic_vector(bitwidth downto 0); --for output
begin

	rca: for i in bitwidth downto 0 generate
		--carry in should be cin for LSB
		gen1: if i  = 0 generate
			fal: entity work.fullAdder(rtl)
			port map(
				clk => clk,
				rst=>rst,
				b0 => d0_fa(i),
				b1 => d1_fa(i),
				ci => cin,
				co => c_fa(i),
				s  => s_fa(i)
			);
		end generate;
		--carry in should be previous carry out
		gen2: if i>0 and   i<bitwidth generate
			far: entity work.fullAdder(rtl)
			port map(
				clk => clk,
				rst=>rst,
				b0 => d0_fa(i),
				b1 => d1_fa(i),
				ci => c_fa(i-1),
				co => c_fa(i),
				s  => s_fa(i)
			);
		end generate;
		-- carry out should be cout for MSB
		gen3: if i  = bitwidth generate
			fal: entity work.fullAdder(rtl)
			port map(
				clk => clk,
				rst=>rst,
				b0 => d0_fa(i),
				b1 => d1_fa(i),
				ci => c_fa(i-1),
				co => cout,
				s  => s_fa(i)
			);
		end generate;
	end generate;
	
	test: process(clk) is
	begin
	
		if(rst = '0') then
		--reset functionality
			d0_fa <= (others => '0');
			d1_fa <= (others => '0');
			r     <= (others => '0');
		else
			if rising_edge(clk) then 
				
				d0_fa <= d0; --set inputs to intermidiate inputs for rca
				d1_fa <= d1;
				r     <= s_fa;
			end if;
		end if;
	
	end process;
	

end architecture;
