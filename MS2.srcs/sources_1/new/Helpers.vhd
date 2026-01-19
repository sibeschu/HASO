----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2025 12:15:28
-- Design Name: 
-- Module Name: Helpers - Behavioral
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

package Helpers is

    type morse_type is record
        pattern : std_logic_vector(8 downto 0); -- bit0 = first element
        length  : natural range 1 to 9;
    end record;

    -- 0..25 = A..Z, 26..34 = '1'..'9', 35='0', 36=SOS
    type morse_lut_type is array (0 to 36) of morse_type;
    constant MORSE_LUT : morse_lut_type;

    constant DOT_UNIT       : natural := 1;
    constant DASH_UNIT      : natural := 3;
    constant IN_SYMBOL_GAP  : natural := 1;
    constant LETTER_GAP     : natural := 3;
    constant WORD_GAP       : natural := 7;

    function ascii_to_index(a : std_logic_vector(7 downto 0)) return integer;

end package;

package body Helpers is

    -- NOTE:
    -- pattern is stored LSB-first in time:
    -- pattern(0)=first dot/dash, pattern(1)=second, ...
    -- Therefore the string literal ends with bits b(L-1)..b0.
    constant MORSE_LUT : morse_lut_type :=
    (
        -- A-Z
        ( "000000010", 2 ), -- A .-      bits: 0,1
        ( "000000001", 4 ), -- B -...    bits: 1,0,0,0
        ( "000000101", 4 ), -- C -.-.    bits: 1,0,1,0
        ( "000000001", 3 ), -- D -..     bits: 1,0,0
        ( "000000000", 1 ), -- E .       bits: 0
        ( "000000100", 4 ), -- F ..-.    bits: 0,0,1,0
        ( "000000011", 3 ), -- G --.     bits: 1,1,0
        ( "000000000", 4 ), -- H ....    bits: 0,0,0,0
        ( "000000000", 2 ), -- I ..      bits: 0,0
        ( "000000111", 4 ), -- J .---    bits: 0,1,1,1
        ( "000000101", 3 ), -- K -.-     bits: 1,0,1
        ( "000000010", 4 ), -- L .-..    bits: 0,1,0,0
        ( "000000011", 2 ), -- M --      bits: 1,1
        ( "000000001", 2 ), -- N -.      bits: 1,0
        ( "000000111", 3 ), -- O ---     bits: 1,1,1
        ( "000000110", 4 ), -- P .--.    bits: 0,1,1,0
        ( "000001011", 4 ), -- Q --.-    bits: 1,1,0,1
        ( "000000010", 3 ), -- R .-.     bits: 0,1,0
        ( "000000000", 3 ), -- S ...     bits: 0,0,0
        ( "000000001", 1 ), -- T -       bits: 1
        ( "000000100", 3 ), -- U ..-     bits: 0,0,1
        ( "000001000", 4 ), -- V ...-    bits: 0,0,0,1
        ( "000000110", 3 ), -- W .--     bits: 0,1,1
        ( "000001001", 4 ), -- X -..-    bits: 1,0,0,1
        ( "000001101", 4 ), -- Y -.--    bits: 1,0,1,1
        ( "000000011", 4 ), -- Z --..    bits: 1,1,0,0

        -- 1..9,0
        ( "000011110", 5 ), -- 1 .----   bits: 0,1,1,1,1
        ( "000011100", 5 ), -- 2 ..---   bits: 0,0,1,1,1
        ( "000011000", 5 ), -- 3 ...--   bits: 0,0,0,1,1
        ( "000010000", 5 ), -- 4 ....-   bits: 0,0,0,0,1
        ( "000000000", 5 ), -- 5 .....   bits: 0,0,0,0,0
        ( "000000001", 5 ), -- 6 -....   bits: 1,0,0,0,0
        ( "000000011", 5 ), -- 7 --...   bits: 1,1,0,0,0
        ( "000000111", 5 ), -- 8 ---..   bits: 1,1,1,0,0
        ( "000001111", 5 ), -- 9 ----.   bits: 1,1,1,1,0
        ( "000011111", 5 ), -- 0 -----   bits: 1,1,1,1,1

        -- SOS (... --- ...)
        ( "000111000", 9 )  -- SOS
    );

    function ascii_to_index(a : std_logic_vector(7 downto 0)) return integer is
        variable idx : integer;
    begin
        if a >= x"41" and a <= x"5A" then
            idx := to_integer(unsigned(a)) - 16#41#; -- A-Z -> 0..25
        elsif a >= x"61" and a <= x"7A" then
            idx := to_integer(unsigned(a)) - 16#61#; -- a-z -> 0..25
        elsif a >= x"31" and a <= x"39" then
            idx := 26 + (to_integer(unsigned(a)) - 16#31#); -- '1'..'9' -> 26..34
        elsif a = x"30" then
            idx := 35; -- '0'
        else
            idx := 36; -- SOS fallback
        end if;
        return idx;
    end function;

end package body;
