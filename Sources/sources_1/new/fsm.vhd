library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Define the FSM entity
entity FSM is
    Port (
        CLK   : in  STD_LOGIC;      -- Clock signal
        RST   : in  STD_LOGIC;      -- Reset signal
        A     : in  STD_LOGIC;      -- Input signal
        Alive : out STD_LOGIC       -- Output signal
    );
end FSM;

architecture Behavioral of FSM is

    -- Define the FSM states
    type state_type is (IDLE, CONFIG, DRIVE);
    signal state, next_state : state_type;   
    -- Define the internal counter (Ccount)
    signal Ccount : STD_LOGIC_VECTOR(1 downto 0);  -- 2-bit counter (0 to 3)

    begin
    
    process (CLK, RST) -- Clock Process
    begin
        if rising_edge(CLK) then
            if RST = '0' then
                -- Reset state to IDLE and reset the counter
                state <= IDLE;
                
            else
                -- Move to the next state
                state <= next_state;
            end if;
        end if;
    end process;
    
    process (state, Ccount) --Combinatorial Process
    begin 
        case state is 
            when IDLE =>
                Alive <= '0';
                next_state <= CONFIG;

            when CONFIG =>
                Alive <= '0';
                if Ccount = "11" then 
                    next_state <= DRIVE;
                else 
                    next_state <= CONFIG;
                end if;    
                       
            when DRIVE =>
                Alive <= '1';
            
        end case;     
    end process;
    
    process (CLK, A, state) -- Count Process
    begin
        if rising_edge(CLK) then
            if (state = CONFIG and A = '1') then
                Ccount <= Ccount + "1";
            else 
                Ccount <= "00";
            end if;
        end if;
    end process;
    
end Behavioral;


