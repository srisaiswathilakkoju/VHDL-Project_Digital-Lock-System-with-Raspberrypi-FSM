
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.EE638.all;
 
entity Digital_Lock_System is
    Port (
        clk                 : in  std_logic;
        reset               : in  std_logic;
        passcode_in         : in  std_logic_vector(3 downto 0); -- Switch input for passcode
        correct_passcode    : in  std_logic_vector(3 downto 0); -- Example passcode
        ssd1_output, ssd2_output, ssd3_output, ssd4_output : out std_logic_vector(6 downto 0); -- SSD outputs
        raspberry_pi_signal,rpi_led : out std_logic -- Signal to Raspberry Pi for intruder image capture
    );
end Digital_Lock_System;

architecture Behavioral of Digital_Lock_System is
    --  the states for the lock system
    type state_type is (IDLE, ENTER_PASS, CHECK_PASS, PASS, FAIL, LOCK);
    signal current_state, next_state : state_type := IDLE;

    --  counters and signals
    signal failed_attempts : integer range 0 to 4 := 0;
    signal lock_flag : std_logic := '0';
    signal permanent_lock_flag : std_logic := '0'; -- flag to enforce staying in LOCK
    signal RS, clkout : std_logic;

begin

    CLKDIV: CLK_DVD port map(clk, RS, clkout);
    RS <= '1';

    process(clkout, reset)
    begin
        if reset = '0' then
            -- Resetting all variables and states
            current_state <= IDLE;
            next_state <= IDLE;
            failed_attempts <= 0;
            lock_flag <= '0';
            permanent_lock_flag <= '0'; -- Clearing the permanent lock on reset
            raspberry_pi_signal <= '0';
				rpi_led <='0';
            ssd1_output <= "1001111"; -- Display "I"
            ssd2_output <= "1000000"; -- Display "D"
            ssd3_output <= "1000111"; -- Display "L"
            ssd4_output <= "0000110"; -- Display "E"
        elsif rising_edge(clkout) then
            if permanent_lock_flag = '1' then
                next_state <= LOCK; -- Stay in LOCK state if permanently locked
            else
                case current_state is
                    when IDLE =>
                        if lock_flag = '0' then
                            next_state <= ENTER_PASS;
                        else
                            next_state <= LOCK;
                        end if;

                    when ENTER_PASS =>
                        ssd1_output <= "0000110"; -- Display "ENTR"
                        ssd2_output <= "1001000";
                        ssd3_output <= "0000111";
                        ssd4_output <= "0001000";
                        next_state <= CHECK_PASS;

                    when CHECK_PASS =>
                        if passcode_in = correct_passcode then
                            next_state <= PASS;
                        else
                            next_state <= FAIL;
                        end if;

                    when PASS =>
                        ssd1_output <= "1000000"; -- Display "OPEN"
                        ssd2_output <= "0001100";
                        ssd3_output <= "0000110";
                        ssd4_output <= "1001000";
                        failed_attempts <= 0;
                        lock_flag <= '0';
                        next_state <= PASS;

                    when FAIL =>
                        failed_attempts <= failed_attempts + 1;
                        ssd1_output <= "0001110"; -- Display "FAIL"
                        ssd2_output <= "0001000";
                        ssd3_output <= "1001111";
                        ssd4_output <= "1000111";
                        if failed_attempts >= 4 then
                            next_state <= LOCK;
                        else
                            next_state <= ENTER_PASS;
                        end if;

                    when LOCK =>
                        ssd1_output <= "1000111"; -- Display "LOCK"
                        ssd2_output <= "1000000";
                        ssd3_output <= "1000110";
                        ssd4_output <= "0001001";
                        lock_flag <= '1';
                        raspberry_pi_signal <= '1';
								rpi_led <='1';
                        permanent_lock_flag <= '1'; -- Setting permanent lock
                        next_state <= LOCK;
 

                    when others =>
                        next_state <= IDLE;
                end case;
            end if;
            current_state <= next_state;
        end if;
    end process;
end Behavioral;
 