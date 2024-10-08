----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.10.2024 11:58:00
-- Design Name: 
-- Module Name: JTAG - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity JTAG_TAP_CONTROLLER is
    Port ( 
        CLK : in std_logic;
        TMS : in STD_LOGIC;
        TCK : in STD_LOGIC;
        RST : in STD_LOGIC;
        TDO : out STD_LOGIC;
        TDI : in std_logic;
        IR_OUT: out std_logic_vector (7 downto 0); -- Instruction Register Output
        DR_OUT: out std_logic_vector (31 downto 0) -- Data Register Output
        );
end JTAG_TAP_CONTROLLER;

architecture Behavioral of JTAG_TAP_CONTROLLER is

    type state_type is (TLR,RTI, SDR, CDR, SDR_SHIFT, E1DR, PDR, E2DR, UDR,
                        SIR, CIR, SIR_SHIFT, E1IR, PIR, E2IR, UIR);
    SIGNAL STATE,NEXT_STATE : state_type;       

    -- Data size
    constant DATA_SIZE : integer := 31; -- replace 32 with the size of your register

    -- Signals for Data Register (DR) and Instruction Register (IR)

    signal ir : std_logic_vector (7 downto 0);
    signal dr : std_logic_vector (DATA_SIZE downto 0); --Temporary Register for UDR

    -- 32 bit internal registers
    signal curr_local_dr_reg : std_logic_vector (DATA_SIZE downto 0) := X"C0FFEE00";
    signal next_local_dr_reg : std_logic_vector (DATA_SIZE downto 0);

    -- Counter
    signal counter : integer := 0;

    begin

    --State Transition
    process (CLK, RST)
    begin 
        if RST = '1' then
            state <= TLR;
        elsif rising_edge (TCK) then
            state <= next_state;
        end if;
    end process;

    --State Transition Logic
    process (STATE, TMS)
    begin
        case( STATE ) is
        
            when TLR =>
                if TMS = '1' then
                    NEXT_STATE <= RTI;
                else
                    NEXT_STATE <= TLR;
                end if;
                
            when RTI =>
                if TMS = '1' then
                    NEXT_STATE <= SDR;
                else
                    NEXT_STATE <= RTI;
                end if;
                
            when SDR =>
                if TMS = '1' then
                    NEXT_STATE <= SIR;
                else
                    NEXT_STATE <= CDR;
                end if;
                
            when CDR =>
                if TMS = '0' then
                    NEXT_STATE <= SDR_SHIFT;
                else
                    NEXT_STATE <= E1DR;
                end if;
                
            when SDR_SHIFT =>
                if TMS = '1' then
                    NEXT_STATE <= E1DR;
                else
                    NEXT_STATE <= SDR_SHIFT;
                end if;
                
            when E1DR =>
                if TMS = '0' then
                    NEXT_STATE <= PDR;
                else
                    NEXT_STATE <= UDR;
                end if;
                
            when PDR =>
                if TMS = '1' then
                    NEXT_STATE <= E2DR;
                else
                    NEXT_STATE <= PDR;
                end if;
                
            when E2DR =>
                if TMS = '1' then
                    NEXT_STATE <= UDR;
                else
                    NEXT_STATE <= SDR;
                end if;
                
            when UDR =>
                if TMS = '0' then
                    NEXT_STATE <= RTI;
                else
                    NEXT_STATE <= SDR;
                end if;
                
            when SIR =>
                if TMS = '1' then
                    NEXT_STATE <= TLR;
                else
                    NEXT_STATE <= CIR;
                end if;
                
            when CIR =>
                if TMS = '0' then
                    NEXT_STATE <= SIR_SHIFT;
                else
                    NEXT_STATE <= E1IR;
                end if;
                
            when SIR_SHIFT =>
                if TMS = '1' then
                    NEXT_STATE <= E1IR;
                else
                    NEXT_STATE <= SIR_SHIFT;
                end if;
                
            when E1IR =>
                if TMS = '0' then
                    NEXT_STATE <= PIR;
                else
                    NEXT_STATE <= UIR;
                end if;
                
            when PIR =>
                if TMS = '1' then
                    NEXT_STATE <= E2IR;
                else
                    NEXT_STATE <= PIR;
                end if;
            
            when E2IR =>
                if TMS = '1' then
                    NEXT_STATE <= UIR;
                else
                    NEXT_STATE <= SIR_SHIFT;
                end if;
                
            when UIR =>
                if TMS = '0' then
                    NEXT_STATE <= RTI;
                else
                    NEXT_STATE <= SDR;
                end if;
                
            when others =>
                NEXT_STATE <= TLR;
            
        
        end case ;
    end process;

    -- Counter Decrement
    process (CLK, STATE)
    begin 
        if rising_edge(CLK) then
            if STATE = SDR_SHIFT then
                if counter = 0 then
                    counter <= DATA_SIZE;
                else
                    counter <= counter - 1;
                end if;
            else
                counter <= DATA_SIZE;
            end if;
        end if;
    end process;

    -- Data Register (DR) and Instruction Register (IR) Output
    process (CLK, STATE, counter, RST)
    begin
        if RST = '1' then
            curr_local_dr_reg <= X"C0FFEE00";
        end if;
        if rising_edge(CLK) then
            case STATE is
                when SDR_SHIFT =>
                    TDO <= curr_local_dr_reg(counter);
                    dr(counter) <= TDI;
                
                when UDR =>
                    next_local_dr_reg <= dr;
                
                when CDR =>
                    curr_local_dr_reg <= next_local_dr_reg;
                
                when others =>
                    null;
                
            end case;
        end if;
    end process;



end Behavioral;
