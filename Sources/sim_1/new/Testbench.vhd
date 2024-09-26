library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Test Bench Entity
entity FSM_tb is
end FSM_tb;

architecture Behavioral of FSM_tb is

    -- Declare signals to be used in the test bench
    signal CLK_tb   : STD_LOGIC := '0';   -- Clock signal
    signal RST_tb   : STD_LOGIC := '1';   -- Reset signal
    signal A_tb     : STD_LOGIC := '0';   -- Input signal A
    signal Alive_tb : STD_LOGIC;          -- Output signal Alive

    -- Instantiate the FSM entity under test
    component FSM is
        Port (
            CLK   : in  STD_LOGIC;
            RST   : in  STD_LOGIC;
            A     : in  STD_LOGIC;
            Alive : out STD_LOGIC
        );
    end component;

begin

    -- Clock process to generate a clock signal with 10 ns period (100 MHz)
    CLK_Process : process
    begin
        CLK_tb <= '0';
        wait for 5 ns;
        CLK_tb <= '1';
        wait for 5 ns;
    end process;

    -- Instantiate FSM
    DUT: FSM
    port map (
        CLK   => CLK_tb,
        RST   => RST_tb,
        A     => A_tb,
        Alive => Alive_tb
    );

    -- Test stimulus process
    Stimulus : process
    begin
        -- Initial reset: FSM should go to IDLE
        RST_tb <= '0';  -- Assert reset (Active Low)
        wait for 20 ns;
        
        RST_tb <= '1';  -- Deassert reset (Active High) to transition to CONFIG
        wait for 10 ns;
        
        -- Test CONFIG state and Ccount
        -- Signal A goes high to start counting
        A_tb <= '1';
        wait for 10 ns;
        A_tb <= '0';
        wait for 10 ns;
        
        -- A goes high again to continue counting
        A_tb <= '1';
        wait for 10 ns;  -- Ccount should increment
        wait for 10 ns;  -- Ccount should increment
        wait for 10 ns;  -- Ccount should increment to 3 and transition to DRIVE
        
        -- Now FSM should be in DRIVE state, check Alive signal
        wait for 20 ns;
        
        -- Test reset while in DRIVE state
        RST_tb <= '0';  -- Assert reset to check transition back to IDLE
        wait for 20 ns;

        -- End of test
        wait;
    end process;

end Behavioral;
