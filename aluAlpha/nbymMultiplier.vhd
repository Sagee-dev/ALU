-- n by m multiplier
-- Geeth De Silva
-- github : sagee-dev
-- multiplies binary numbers with different bith widths
-- product = multiplicand x multiplier
-- multiplicand width is n bit
-- multiplicand width is m bits
-- inputs are multiplicand and multiplier
-- output is product and will be the size n + m;
-- use shifting and adding 
-- use shift registers and ripple carry adders
-- To DO 
	--further timing anaylsis 
	--replace intermidiate buffers with registers to be done

library ieee;
use ieee.std_logic_1164.all;

entity nbymMultiplier is 
port(
	signal clk : in std_logic;
	signal rst : in std_logic;
	signal multiplicand : in std_logic_vector;
	signal multiplier   : in std_logic_vector;
	signal product      : out std_logic_vector
);
end entity;

architecture rtl of nbymMultiplier is
	type states is (IDLE,SET_INPUT,SHIFT,ACCUMILATE,SET_OUTPUT);
	constant multiplicandLen : integer := multiplicand'length;
	constant multiplierLen   : integer := multiplier'length;
	constant resultLen       : integer := multiplicandLen + multiplierLen;
	signal currentState : states;
	signal nextState    : states := IDLE;
	signal multiplicand_0 : std_logic_vector(multiplicandLen-1 downto 0);
	signal multiplier_0   : std_logic_vector(multiplierLen-1 downto 0);
	signal multiplicand_m : std_logic_vector(resultLen-1 downto 0):=(others => '0');
	signal multiplier_m   : std_logic_vector(resultLen-1 downto 0):=(others => '0');
	signal adderData0In_m : std_logic_vector(resultLen-1 downto 0):=(others => '0');
	signal adderData1In_m : std_logic_vector(resultLen-1 downto 0):=(others => '0');
	signal adderDataOut_m : std_logic_vector(resultLen-1 downto 0):=(others =>'0');
	signal shiftRegisterIn_m : std_logic_vector(resultLen-1 downto 0);
	signal shiftRegisterOut_m: std_logic_vector(resultLen-1 downto 0);
	signal product_m      : std_logic_vector(resultLen-1 downto 0);
	signal result   : std_logic_vector(resultLen-1 downto 0);
	signal bitCount : integer := 0;
	signal waitCycles: integer := 100;
	
	-- I/O for shift Register
	signal shiftRegisterIn : std_logic_vector(resultLen-1 downto 0);
	signal shiftRegisterout: std_logic_vector(resultLen-1 downto 0);
	signal shiftLen        : integer :=0 ;
	
	-- I/O for adder
	signal cin : std_logic;
	signal cout: std_logic;
	signal adderData0In : std_logic_vector(resultLen-1 downto 0);
	signal adderData1In : std_logic_vector(resultLen-1 downto 0);
	signal adderDataOut : std_logic_vector(resultLen-1 downto 0);
	
	
	
begin

	LeftShifter: entity work.pipoShiftLeftFsmRegister(rtl)
	generic map(registerWidth => resultLen)
	port map(
		clk  => clk,
        rst  => rst,
        data => shiftRegisterIn,
        sLim => shiftLen,
        rslt => shiftRegisterOut
	);
	adder: entity work.rippleCarryAdder(rtl)
	generic map(bitwidth => resultLen-1)
	port map(
		clk => clk,
		rst => rst,
		cin => '0',
		cout=> cout,
		d0  => adderData0In,
		d1  => adderData1In,
		r   => adderDataOut 
	);
	
	behaviour: process(clk) is
	begin
		if(rst ='0') then
			--reset multiplier here
		else
			if rising_edge(clk) then
				--currentState <= nextState;
				
				case currentState is
					when IDLE =>
						if(multiplicand_0 = multiplicand and multiplier_0 = multiplier) then
							currentState <= IDLE;
							product <= product_m;
						else
							currentState <= SET_INPUT;
							multiplicand_0 <= multiplicand;
							multiplier_0 <= multiplier;
							multiplicand_m(multiplicandLen-1 downto 0) <= multiplicand;
							multiplier_m(multiplierLen-1 downto 0) <= multiplier;
						end if;
						
					when SET_INPUT =>
						if(waitCycles = 0 )then
							currentState <= SHIFT;
							waitCycles <= 100;
						else
							shiftRegisterIn <= multiplicand_m;
							adderData0In <= adderData0In_m;
							adderData1In <= adderData1In_m;
							waitCycles <= waitCycles -1;
						end if;
					when SHIFT =>
						if(bitCount = multiplierLen) then
							shiftLen <= 0;
							waitCycles <= 100;
							currentState <= SET_OUTPUT;
						else
							if(multiplier(bitCount)='0') then
								currentState <= ACCUMILATE;
								adderData0In <= adderDataOut;
								adderData1In <= (others=>'0');
							else
								if(waitCycles = 0) then
									currentState <= ACCUMILATE;
									adderData0In <= adderDataOut;
									adderData1In <= shiftRegisterOut;
									waitCycles <= 100;
								else
									waitCycles <= waitCycles -1;
								end if;
							end if;
						end if;
						
					when ACCUMILATE =>
						if(waitCycles = 0) then 
							bitCount <= bitCount +1;
							waitCycles <= 100;
							currentState <= SHIFT;
							shiftLen <= shiftLen + 1;
						else
							waitCycles <= waitCycles -1;
						end if;
						
					when SET_OUTPUT =>
						product_m <= adderDataOut;
						currentState <= IDLE;
						bitCount <= 0;
				end case;
			end if;
		end if;
	end process;

end architecture;
