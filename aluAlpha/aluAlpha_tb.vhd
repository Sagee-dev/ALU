-- ALU Alpha test bench
-- Geeth De Silva
-- github : sagee-dev
-- v1.0
-- Test bench file for ALU Alpha component
-- Observes ALU output and tests different inputs to the ALU
library ieee;
use ieee.std_logic_1164.all;

-- Testbench entity for ALU Alpha
entity aluAlpha_tb is
end entity;

architecture sim of aluAlpha_tb is
    -- Define ALU width for the testbench (8 bits in this case)
    constant aluWidth: integer := 8;
    
    -- Signals for the clock, reset, opcode, operands, and result
    signal clk : std_logic := '0';  -- Clock signal initialized to '0'
    signal rst : std_logic := '1';  -- Reset signal initialized to '1' (active low)
    
    -- ALU input signals
    signal opCode : std_logic_vector(3 downto 0);  -- Operation code (4 bits)
    signal operendOne : std_logic_vector(aluWidth -1 downto 0);  -- First operand (8 bits)
    signal operendTwo : std_logic_vector(aluWidth -1 downto 0);  -- Second operand (8 bits)
    
    -- ALU output signal
    signal result : std_logic_vector(2*(aluWidth)-1 downto 0);  -- Result of ALU operation (16 bits for 8-bit operands)
    
    -- Clock parameters
    constant clkFrequency : integer := 1e6;  -- Clock frequency (1 MHz)
    constant clkPeriod    : time := 1000 ms / clkFrequency;  -- Clock period
    constant dutyCycle    : time := clkPeriod / 2;  -- Duty cycle for the clock

begin

    -- Instantiate the ALU Alpha component under test (UUT)
    alu: entity work.aluAlpha(rtl) 
    generic map(aluWidth => aluWidth)  -- Set the ALU width to 8 bits
    port map(
        clk => clk,
        rst => rst,
        opCode => opCode,
        operendOne => operendOne,
        operandTwo => operendTwo,
        result => result
    );
    
    -- Generate the clock signal with a period defined by the dutyCycle
    clk <= not clk after dutyCycle;
    
    -- Test process to apply test vectors to the ALU and check the outputs
    test: process is
    begin
        
        -- Wait for one clock cycle before applying the first test case
        wait for 1*dutyCycle;
        
        -- Test Case 1: Multiplication (opcode = "0011")
        opCode <= "0011";  -- Set operation code for multiplication
        operendOne <= x"08";  -- Set first operand to 0x08 (8 in decimal)
        operendTwo <= x"02";  -- Set second operand to 0x02 (2 in decimal)
        wait for 5000*clkPeriod;  -- Wait for sufficient time for ALU to process
        -- Assert the expected result (0x0010 = 16 in decimal)
        assert( result = x"0010") report("Case 1 : Module error");
        
        -- Wait for one clock cycle before applying the next test case
        wait for 1*dutyCycle;
        
        -- Test Case 2: Addition (opcode = "0001")
        opCode <= "0001";  -- Set operation code for addition
        operendOne <= x"08";  -- Set first operand to 0x08 (8 in decimal)
        operendTwo <= x"0A";  -- Set second operand to 0x0A (10 in decimal)
        wait for 100*clkPeriod;  -- Wait for processing time
        -- Assert the expected result (0x0012 = 18 in decimal)
        assert( result = x"0012") report("Case 2 : Module error");
        
        -- Wait for one clock cycle before applying the next test case
        wait for 1*dutyCycle;
        
        -- Test Case 3: Addition with negative value (opcode = "0001")
        opCode <= "0001";  -- Set operation code for addition
        operendOne <= x"FF";  -- Set first operand to 0xFF (-1 in signed 8-bit representation)
        operendTwo <= x"AA";  -- Set second operand to 0xAA (170 in decimal)
        wait for 100*clkPeriod;  -- Wait for processing time
        -- Assert the expected result (0x0055 = 85 in decimal, after adding -1 and 170)
        assert( result = x"0055") report("Case 3 : Module error");
        
        -- End the process
        wait;
    end process;
end architecture;

