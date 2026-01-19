----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2025 11:26:02
-- Design Name: 
-- Module Name: MorseTx - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
library work;
use work.Helpers.all;

entity MorseTx is
    generic (
        UNIT_TICKS : natural := 1_000_000
    );
    Port (
        CPU_RESETN : in  std_logic;
        CLK1MHZ    : in  std_logic;
        ASCII      : in  std_logic_vector(7 downto 0);
        LED        : out std_logic;
        Ready      : out std_logic;
        StartTx    : in  std_logic
    );
end MorseTx;

architecture Behavioral of MorseTx is

    type state_machine_type is (RESET, IDLE, LOAD, MARK, GAP);
    signal current_state : state_machine_type := RESET;

    signal tick_cnt   : natural range 0 to UNIT_TICKS-1 := 0;
    signal units_left : natural := 0;

    signal current_pattern : std_logic_vector(8 downto 0) := (others => '0');
    signal pattern_length  : natural range 0 to 9 := 0;
    signal symbol_index    : natural range 0 to 8 := 0;

    signal is_space : std_logic := '0';

begin

    process(CLK1MHZ)
        variable idx : integer;
    begin
        if rising_edge(CLK1MHZ) then

            if CPU_RESETN = '0' then
                current_state   <= RESET;
                LED             <= '0';
                Ready           <= '0';
                tick_cnt        <= 0;
                units_left      <= 0;
                symbol_index    <= 0;
                pattern_length  <= 0;
                current_pattern <= (others => '0');
                is_space        <= '0';

            else
                case current_state is

                    when RESET =>
                        LED           <= '0';
                        Ready         <= '0';
                        tick_cnt      <= 0;
                        units_left    <= 0;
                        current_state <= IDLE;

                    when IDLE =>
                        LED   <= '0';
                        Ready <= '1';
                        if StartTx = '1' then
                            Ready         <= '0';
                            current_state <= LOAD;
                        end if;

                    when LOAD =>
                        LED   <= '0';
                        Ready <= '0';

                        symbol_index <= 0;
                        tick_cnt     <= 0;
                        units_left   <= 0;

                        if ASCII = x"20" then
                            -- space -> word gap only (LED stays off)
                            is_space      <= '1';
                            pattern_length <= 0;
                            current_pattern <= (others => '0');
                            current_state  <= GAP;
                        else
                            is_space <= '0';
                            idx := ascii_to_index(ASCII);

                            current_pattern <= MORSE_LUT(idx).pattern;
                            pattern_length  <= MORSE_LUT(idx).length;

                            current_state <= MARK;
                        end if;

                    when MARK =>
                        LED   <= '1';
                        Ready <= '0';

                        -- Entry: load symbol duration
                        if units_left = 0 then
                            tick_cnt <= 0;
                            if current_pattern(symbol_index) = '0' then
                                units_left <= DOT_UNIT;
                            else
                                units_left <= DASH_UNIT;
                            end if;
                        else
                            -- Count ticks for 1 unit
                            if tick_cnt = UNIT_TICKS-1 then
                                tick_cnt <= 0;

                                if units_left = 1 then
                                    units_left    <= 0;
                                    current_state <= GAP;
                                else
                                    units_left <= units_left - 1;
                                end if;

                            else
                                tick_cnt <= tick_cnt + 1;
                            end if;
                        end if;

                    when GAP =>
                        LED   <= '0';
                        Ready <= '0';

                        -- Entry: load gap duration
                        if units_left = 0 then
                            tick_cnt <= 0;

                            if is_space = '1' then
                                units_left <= WORD_GAP;
                            elsif symbol_index < pattern_length-1 then
                                units_left <= IN_SYMBOL_GAP;
                            else
                                units_left <= LETTER_GAP;
                            end if;

                        else
                            if tick_cnt = UNIT_TICKS-1 then
                                tick_cnt <= 0;

                                if units_left = 1 then
                                    units_left <= 0;

                                    if is_space = '1' then
                                        current_state <= IDLE;
                                    elsif symbol_index = pattern_length-1 then
                                        current_state <= IDLE;
                                    else
                                        symbol_index  <= symbol_index + 1;
                                        current_state <= MARK;
                                    end if;

                                else
                                    units_left <= units_left - 1;
                                end if;

                            else
                                tick_cnt <= tick_cnt + 1;
                            end if;
                        end if;

                end case;
            end if;
        end if;
    end process;

end Behavioral;
