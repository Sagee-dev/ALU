-- Ripple Borrow Substractor block
-- consist of array of full subtraction
-- capable of subtraction of multiple bit
-- bitwith is generic
-- 3 inpot d1 (std_logic_vector) d2 (std_logic_vector) bin std_logic_vector
-- 2 outputs r (std_logic_vector) bout (std_logic)
library ieee;
use ieee.std_logic_1164.all;

entity rippleBorrowSubtractor is
generic(bitwidth : integer ); --decide the size of the subtractor
port(
	signal clk : in std_logic;
	signal rst : in std_logic;
	signal bin : in  std_logic;
	signal bout: out std_logic;
	signal d0: in std_logic_vector(bitwidth downto 0);
	signal d1: in std_logic_vector(bitwidth downto 0);
	signal r : out std_logic_vector(bitwidth downto 0)
	
);
end entity;
architecture rtl of rippleBorrowSubtractor is

	signal b_fs : std_logic_vector(bitwidth downto 0); -- intermediate vector to store borrow bits
	signal d0_fs: std_logic_vector(bitwidth downto 0);
	signal d1_fs: std_logic_vector(bitwidth downto 0);
	signal s_fs : std_logic_vector(bitwidth downto 0); --for output
begin

	rca: for i in bitwidth downto 0 generate
		--carry in should be cin for LSB
		gen1: if i  = 0 generate
			fal: entity work.fullSubtractor(rtl)
			port map(
				clk => clk,
				rst => rst,
				b0   => d0_fs(i),
				b1   => d1_fs(i),
				bin  => bin,
				bout => b_fs(i),
				r    => s_fs(i)
			);
		end generate;
		--carry in should be previous carry out
		gen2: if i>0 and   i<bitwidth generate
			far: entity work.fullSubtractor(rtl)
			port map(
				clk => clk,
				rst => rst,
				b0   => d0_fs(i),
				b1   => d1_fs(i),
				bin  => b_fs(i-1),
				bout => b_fs(i),
				r  => s_fs(i)
			);
		end generate;
		-- carry out should be cout for MSB
		gen3: if i  = bitwidth generate
			fal: entity work.fullSubtractor(rtl)
			port map(
				clk => clk,
				rst=>rst,
				b0 => d0_fs(i),
				b1 => d1_fs(i),
				bin => b_fs(i-1),
				bout => bout,
				r  => s_fs(i)
			);
		end generate;
	end generate;
	
	test: process(clk) is
	begin
	
		if(rst = '0') then
		--reset functionality
			d0_fs <= (others => '0');
			d1_fs <= (others => '0');
			r     <= (others => '0');
		else
			if rising_edge(clk) then 
				
				d0_fs <= d0; --set inputs to intermidiate inputs for rca
				d1_fs <= d1;
				r     <= s_fs;
			end if;
		end if;
	
	end process;
	

end architecture;