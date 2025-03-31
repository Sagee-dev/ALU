-- Alu Alpha
-- Geeth De Silva
-- github : sagee-dev
-- v1.1
-- simple alu to to perform addition, subtraction, and multiplication
-- dedicated ripple carry adder
-- dedicated ripple borrow subtractor, and 
-- dedicated multiplier available 

library ieee;
use ieee.std_logic_1164.all;

entity aluAlpha is
    -- Define the generic and ports for the ALU entity
    generic(aluWidth : integer);  -- ALU width (bit-width)
    port(
        clk : in std_logic;  -- Clock input
        rst : in std_logic;  -- Reset input
        opCode : in std_logic_vector(3 downto 0);  -- Operation code
        operendOne : in std_logic_vector(aluWidth - 1 downto 0);  -- First operand
        operandTwo : in std_logic_vector(aluWidth - 1 downto 0);  -- Second operand
        result     : out std_logic_vector(2*(aluWidth) -1 downto 0)  -- Result of ALU operation
    );
end entity;

architecture rtl of aluAlpha is

    -- Define states for FSM controlling the ALU operation
    type states is (IDLE, SET_INPUT, CALCULATE, SET_OUTPUT);
    
    -- Signal definitions for adder
    signal adderInOne    : std_logic_vector(aluWidth-1 downto 0);
    signal adderInTwo    : std_logic_vector(aluWidth-1 downto 0);
    signal carryIn       : std_logic;
    signal carryOut      : std_logic;
    signal adderOutResult: std_logic_vector(aluWidth-1 downto 0);
    
    -- Signal definitions for subtractor
    signal subtractorInOne    : std_logic_vector(aluWidth-1 downto 0);
    signal subtractorInTwo    : std_logic_vector(aluWidth-1 downto 0);
    signal borrowIn           : std_logic;
    signal borrowOut          : std_logic;
    signal subtractorOutResult: std_logic_vector(aluWidth-1 downto 0);
    
    -- Signal definitions for multiplier
    signal multiplierInOne    : std_logic_vector(aluWidth-1 downto 0);
    signal multiplierInTwo    : std_logic_vector(aluWidth-1 downto 0);
    signal multiplierOutResult: std_logic_vector(2*(aluWidth) -1 downto 0);
    
    -- State variable to control FSM
    signal state : states := IDLE;
    
    -- Temporary signal storage for opcode and operands
    signal opCode_0     : std_logic_vector(3 downto 0);
    signal operendOne_0 : std_logic_vector(aluWidth - 1 downto 0);
    signal operandTwo_0 : std_logic_vector(aluWidth - 1 downto 0);
    
    -- Temporary signal for the result of the operation
    signal result_a : std_logic_vector(2*(aluWidth) -1 downto 0) := (others => '0');
    
    -- Wait cycles to control delays in operations (for multiplication)
    signal waitCycles : integer := 100;
    
begin

    -- Instantiate the ripple carry adder entity
    adder: entity work.rippleCarryAdder(rtl)
    generic map(bitwidth => aluWidth-1)  -- Decide the size of the adder 
    port map(
        clk => clk,
        rst => rst,
        cin => carryIn,
        cout => carryOut,
        d0  => adderInOne,
        d1  => adderInTwo,
        r   => adderOutResult
    );
    
    -- Instantiate the ripple borrow subtractor entity
    substractor: entity work.rippleBorrowSubtractor(rtl)
    generic map(bitwidth => aluWidth-1)  -- Decide the size of the subtractor
    port map(
        clk => clk,
        rst => rst,
        bin => borrowIn,
        bout => borrowOut,
        d0  => subtractorInOne,
        d1  => subtractorInTwo,
        r   => subtractorOutResult
    );
    
    -- Instantiate the multiplier entity
    multiplier: entity work.nbymMultiplier(rtl)
    port map(
        clk => clk,
        rst => rst,
        multiplicand => multiplierInOne,
        multiplier   => multiplierInTwo,
        product      => multiplierOutResult
    );
    
    -- Process to control the ALU behavior
    behaviour: process(clk) is
    
    begin
    
        -- Reset condition (if rst is low)
        if(rst = '0') then
            -- Reset ALU logic here (if necessary)
        else
        
            -- Rising edge of the clock
            if rising_edge(clk) then
                
                -- State machine controlling the ALU operation
                case state is
                
                    -- IDLE state: No operation is performed, waits for inputs
                    when IDLE =>
                        if(opCode_0 = opCode and operendOne_0 = operendOne and operandTwo_0 = operandTwo) then
                        else
                            state <= SET_INPUT;
                        end if;
                    
                    -- SET_INPUT state: Capture the opcode and operands
                    when SET_INPUT =>
                        opCode_0     <= opCode;
                        operendOne_0 <= operendOne;
                        operandTwo_0 <= operandTwo;
                        
                        -- Depending on the opcode, set the respective inputs for the operation
                        if(opCode = "0001") then
                            -- Addition Operation
                            adderInOne <= operendOne;
                            adderInTwo <= operandTwo;
                            carryIn    <= '0';
                            state <= CALCULATE;
                        elsif(opCode = "0010") then
                            -- Subtraction Operation
                            subtractorInTwo <= operendOne;
                            subtractorInOne <= operandTwo;
                            borrowIn        <= '0';
                            state <= CALCULATE;
                        elsif(opCode = "0011") then
                            -- Multiplication Operation
                            multiplierInOne <= operendOne;
                            multiplierInTwo <= operandTwo;
                            waitCycles <= 2000;  -- Set the wait cycles for multiplication
                            state <= CALCULATE;
                        else
                            state <= IDLE;
                        end if;
                    
                    -- CALCULATE state: Perform the operation (addition, subtraction, or multiplication)
                    when CALCULATE =>
                        if (waitCycles = 0) then
                            -- Handle the result after waiting for operations like multiplication
                            if(opCode = "0001") then
                                -- Addition Operation
                                result_a(aluWidth-1 downto 0) <= adderOutResult;
                            elsif(opCode = "0010") then
                                -- Subtraction Operation
                                result_a(aluWidth-1 downto 0) <= subtractorOutResult;
                            elsif(opCode = "0011") then
                                -- Multiplication Operation
                                result_a <= multiplierOutResult;
                            else
                                state <= IDLE;
                            end if;
                            state <= SET_OUTPUT;
                        else
                            -- Decrement wait cycles for multiplications
                            waitCycles <= waitCycles - 1;
                        end if;
                    
                    -- SET_OUTPUT state: Output the result and reset for next operation
                    when SET_OUTPUT => 
                        result <= result_a;
                        state <= IDLE;
                        waitCycles <= 100;
                
                end case;
                
            end if;
        end if;
        
    end process;
    
end architecture;
