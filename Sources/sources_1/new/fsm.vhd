-- Testbench for JTAG TAP Controller
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_jtag_tap is
end tb_jtag_tap;

architecture behavior of tb_jtag_tap is

    -- Signals
    signal TCK   : std_logic := '0';
    signal TMS   : std_logic := '0';
    signal TDI   : std_logic := '0';
    signal TDO   : std_logic;
    signal TRST  : std_logic := '1';  -- Test reset

    -- Clock period
    constant TCK_PERIOD : time := 20 ns;

begin

    -- DUT instantiation
    uut: entity work.JTAG_TAP_CONTROLLER
        port map (
            TCK  => TCK,
            TMS  => TMS,
            TDI  => TDI,
            TDO  => TDO,
            TRST => TRST
        );

    -- Generate TCK clock
    TCK_process: process
    begin
        while true loop
            TCK <= '0';
            wait for TCK_PERIOD / 2;
            TCK <= '1';
            wait for TCK_PERIOD / 2;
        end loop;
    end process;

    -- Main test process
    test_process: process
    begin
        -- Reset the TAP controller
        TRST <= '0';
        wait for 3 * TCK_PERIOD;
        TRST <= '1';

        -- Move to 'Run-Test/Idle' state
        TMS <= '0';  -- From Test-Logic-Reset to Run-Test/Idle
        wait for TCK_PERIOD;

        -- Transition through various states
        -- Select-DR-Scan
        TMS <= '1';  wait for TCK_PERIOD;
        -- Capture-DR
        TMS <= '0';  wait for TCK_PERIOD;
        -- Shift-DR
        TMS <= '0';  wait for TCK_PERIOD;
        
        -- Provide a test input via TDI and observe TDO
        TDI <= '1';  wait for TCK_PERIOD;
        TDI <= '0';  wait for TCK_PERIOD;
        
        -- Exit1-DR
        TMS <= '1';  wait for TCK_PERIOD;
        -- Update-DR
        TMS <= '1';  wait for TCK_PERIOD;

        -- Return to Run-Test/Idle
        TMS <= '0';  wait for TCK_PERIOD;
        
        -- Finish simulation
        wait;
    end process;

end behavior;
