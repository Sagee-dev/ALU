-- Pipo Shift Left fsm register
-- Geeth De Silva
-- github : sagee-dev
-- v1.1
	--shiftCycle_0 replaced with sLim_0 debug
-- Finite state machine (FSM)
-- Pipo parallel input parallel output
-- Input register with N number of bits
-- Shift to predefined number of bits
-- Output shifted value



library ieee;
use ieee.std_logic_1164.all;

-- Entity definition: pipoShiftLeftFsmRegister
-- Defines the interface of the shift-left FSM register.
entity pipoShiftLeftFsmRegister is
    generic(registerWidth : integer);  -- Generic to define the width of the register
    port(
        clk : in std_logic;  -- Clock input
        rst : in std_logic;  -- Reset input
        data: in std_logic_vector(registerWidth-1 downto 0);  -- Input data (registerWidth bits)
        sLim: in integer;  -- Shift limit (number of cycles to shift, currently used in the process)
        rslt: out std_logic_vector(registerWidth-1 downto 0)  -- Shifted output result (registerWidth bits)
    );
end entity;

-- Architecture definition: rtl
-- This is the main behavioral description of the shift-left FSM register.
architecture rtl of pipoShiftLeftFsmRegister is 

    -- Defining states for the FSM: IDLE, SET_INPUT, SHIFT, SET_OUTPUT
    type states is (IDLE, SET_INPUT, SHIFT, SET_OUTPUT);
    signal currentState : states := IDLE;  -- Stores the current state of the FSM
    signal nextState     : states;  -- Stores the next state to transition to
    signal data_0 : std_logic_vector(registerWidth-1 downto 0);  -- Holds the previous input data for comparison
	signal sLim_0 : integer;
    signal data_d : std_logic_vector(registerWidth-1 downto 0);  -- Data being processed, to be shifted
    signal rslt_d : std_logic_vector(registerWidth-1 downto 0);  -- Data that will be output after shifting

begin

    -- Generate a series of flip-flops based on registerWidth
    -- Each flip-flop stores one bit of the shifted data
    genFlipflop: for i in registerWidth-1 downto 0 generate
        dflipflop: entity work.dflipflop(rtl)  -- Instantiating flip-flops for each bit in the register
            port map(
                clk => clk,  -- Clock input for flip-flops
                d => data_d(i),  -- Data input to the flip-flop (from data_d)
                q => rslt_d(i)  -- Output from the flip-flop (stored in rslt_d)
            );
    end generate;

    -- Process block, triggered on clock edges
    behaviour: process(clk) is
        variable shiftCycles    : integer := 0;  -- Variable to count the remaining shift cycles
    begin
        -- Reset condition
        if(rst = '0') then
            nextState <= SET_INPUT;  -- On reset, move to the SET_INPUT state
            shiftCycles := 0;  -- Reset shift cycles counter
            data_d <= (others => '0');  -- Clear data register

        else

            -- On rising clock edge, update current state and proceed with state transitions
            if rising_edge(clk) then
                currentState <= nextState;  -- Move to the next state
                
                -- FSM state transitions and actions
                case currentState is

                    -- IDLE state: Waits for input data change and shift cycle completion
                    when IDLE =>
                        -- If data or shift limint haven't changed, stay in IDLE state
                        if(data_0 = data and sLim_0 = sLim) then
                            nextState <= IDLE;
                        else
                            nextState <= SET_INPUT;  -- Otherwise, move to SET_INPUT state
                        end if;

                    -- SET_INPUT state: Loads input data into the shift register and prepares for shifting
                    when SET_INPUT =>
                        data_d <= data;  -- Load input data into data_d register
                        data_0 <= data_d;  -- Store input data in data_0 for future comparison
						sLim_0 <= sLim;
                        shiftCycles   := sLim*2;  -- Set the number of shift cycles (using sLim)
                        nextState <= SHIFT;  -- Transition to SHIFT state

                    -- SHIFT state: Shifts the data left by 1 bit on each clock cycle
                    when SHIFT =>
                        if(shiftCycles > 0) then
                            shiftCycles := shiftCycles - 1;  -- Decrease remaining shift cycles

                            -- Shift left by 1 bit, set LSB to '0'
                            data_d(0) <= '0';  -- Set the least significant bit (LSB) to 0
                            -- Shift the other bits to the left
                            data_d(registerWidth-1 downto 1) <= rslt_d(registerWidth-2 downto 0);
                        else
                            nextState <= SET_OUTPUT;  -- Once all shift cycles are done, move to SET_OUTPUT state
                        end if;

                    -- SET_OUTPUT state: Outputs the shifted data and goes back to IDLE state
                    when SET_OUTPUT =>
                        data_d <= rslt_d;  -- Load the shifted data into data_d
                        rslt   <= rslt_d;  -- Output the shifted result to rslt
                        nextState <= IDLE;  -- Return to IDLE state after processing

                    -- Default case for safety: If an unknown state occurs, transition to IDLE
                    when others =>
                        nextState <= IDLE;  -- Always default to IDLE state

                end case;

            end if;

        end if;

    end process;

end architecture;
