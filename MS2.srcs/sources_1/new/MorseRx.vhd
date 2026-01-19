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

entity MorseRx is
    generic (
        UNIT_TICKS : natural := 1_000_000  -- ticks per Morse unit at CLK1MHZ
    );
    port (
        CPU_RESETN    : in  std_logic;
        CLK1MHZ       : in  std_logic;
        PhotoDiode    : in  std_logic;

        Output_Symbol : out std_logic_vector(7 downto 0);
        NewSymbol     : out std_logic
    );
end MorseRx;

architecture Behavioral of MorseRx is

    type state_t is (IDLE, MARK, GAP);
    signal state : state_t := IDLE;

    -- 2FF synchronizer
    signal pd_ff1, pd_ff2 : std_logic := '0';
    signal pd_prev        : std_logic := '0';

    -- measure durations in ticks
    signal high_ticks : natural := 0;
    signal low_ticks  : natural := 0;

    -- accumulate one letter pattern (LSB-first: bit0 is first dot/dash)
    signal pattern_reg    : std_logic_vector(8 downto 0) := (others => '0');
    signal pattern_length : natural range 0 to 9 := 0;

    signal letter_emitted : std_logic := '0';
    signal space_emitted  : std_logic := '0';

    function to_ascii_from_index(i : integer) return std_logic_vector is
        variable c : integer;
    begin
        if i >= 0 and i <= 25 then
            c := 16#41# + i; -- A..Z
        elsif i >= 26 and i <= 34 then
            c := 16#31# + (i - 26); -- '1'..'9'
        elsif i = 35 then
            c := 16#30#; -- '0'
        else
            c := 16#3F#; -- '?'
        end if;
        return std_logic_vector(to_unsigned(c, 8));
    end function;

    function decode_morse(p : std_logic_vector(8 downto 0);
                          l : natural) return std_logic_vector is
        variable i : integer;
    begin
        if l = 0 then
            return x"3F"; -- '?'
        end if;

        for i in MORSE_LUT'range loop
            if MORSE_LUT(i).length = l and MORSE_LUT(i).pattern = p then
                return to_ascii_from_index(i);
            end if;
        end loop;

        return x"3F"; -- unknown -> '?'
    end function;

begin

    process(CLK1MHZ)
        variable high_units : natural;
        variable bit_val    : std_logic;
    begin
        if rising_edge(CLK1MHZ) then
            NewSymbol <= '0';

            -- sync
            pd_ff1 <= PhotoDiode;
            pd_ff2 <= pd_ff1;

            if CPU_RESETN = '0' then
                state          <= IDLE;
                pd_prev        <= '0';

                high_ticks     <= 0;
                low_ticks      <= 0;

                pattern_reg    <= (others => '0');
                pattern_length <= 0;

                letter_emitted <= '0';
                space_emitted  <= '0';

                Output_Symbol  <= (others => '0');
                NewSymbol      <= '0';

            else
                pd_prev <= pd_ff2;

                case state is

                    when IDLE =>
                        high_ticks     <= 0;
                        low_ticks      <= 0;
                        pattern_reg    <= (others => '0');
                        pattern_length <= 0;
                        letter_emitted <= '0';
                        space_emitted  <= '0';

                        -- wait for first rising edge (start of mark)
                        if (pd_prev = '0') and (pd_ff2 = '1') then
                            state      <= MARK;
                            high_ticks <= 1;
                        end if;

                    when MARK =>
                        if pd_ff2 = '1' then
                            high_ticks <= high_ticks + 1;
                        end if;

                        -- falling edge: end of mark -> dot or dash
                        if (pd_prev = '1') and (pd_ff2 = '0') then
                            -- ticks -> units (rounded)
                            high_units := (high_ticks + (UNIT_TICKS/2)) / UNIT_TICKS;

                            if high_units < 2 then
                                bit_val := '0'; -- dot
                            else
                                bit_val := '1'; -- dash
                            end if;

                            if pattern_length <= 8 then
                                pattern_reg(pattern_length) <= bit_val;
                                pattern_length <= pattern_length + 1;
                            end if;

                            state      <= GAP;
                            low_ticks  <= 1;
                            high_ticks <= 0;

                            letter_emitted <= '0';
                            space_emitted  <= '0';
                        end if;

                    when GAP =>
                        if pd_ff2 = '0' then
                            low_ticks <= low_ticks + 1;
                        end if;

                        -- rising edge: next mark begins (could be intra-symbol or next letter)
                        if (pd_prev = '0') and (pd_ff2 = '1') then
                            state      <= MARK;
                            high_ticks <= 1;
                            -- keep low_ticks running is not needed anymore
                        else
                            -- if low gap reaches letter gap, finalize letter once
                            if (letter_emitted = '0') and (pattern_length > 0) and
                               (low_ticks >= (LETTER_GAP * UNIT_TICKS)) then
                                Output_Symbol <= decode_morse(pattern_reg, pattern_length);
                                NewSymbol     <= '1';
                                letter_emitted <= '1';

                                -- clear for next letter while staying low
                                pattern_reg    <= (others => '0');
                                pattern_length <= 0;
                            end if;

                            -- if low gap reaches word gap, emit space once
                            if (space_emitted = '0') and (low_ticks >= (WORD_GAP * UNIT_TICKS)) then
                                Output_Symbol <= x"20";
                                NewSymbol     <= '1';
                                space_emitted <= '1';
                            end if;
                        end if;

                end case;
            end if;
        end if;
    end process;

end Behavioral;
