
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

entity MorseTx_TB is
end MorseTx_TB;

architecture Behavioral of MorseTx_TB is

    -- make simulation fast
    constant UNIT_TICKS_SIM : natural := 10;

    signal clk100mhz   : std_logic := '0';
    signal clk1mhz     : std_logic;

    signal cpu_resetn  : std_logic := '0';

    signal ascii       : std_logic_vector(7 downto 0) := (others => '0');
    signal start_tx    : std_logic := '0';
    signal led         : std_logic;
    signal ready       : std_logic;

begin

    U_CLKDIV: entity work.ClkDivider
        port map(
            CPU_RESETN      => cpu_resetn,
            clk_in          => clk100mhz,
            clk_out_1mhz    => clk1mhz,
            clk_out_100mhz  => open
        );

    U_MORSE: entity work.MorseTx
        generic map (
            UNIT_TICKS => UNIT_TICKS_SIM
        )
        port map(
            CPU_RESETN => cpu_resetn,
            CLK1MHZ    => clk1mhz,
            ASCII      => ascii,
            LED        => led,
            Ready      => ready,
            StartTx    => start_tx
        );

    -- 100 MHz clock (10 ns period)
    clk100_proc: process
    begin
        while true loop
            clk100mhz <= '0'; wait for 5 ns;
            clk100mhz <= '1'; wait for 5 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        -- reset
        cpu_resetn <= '0';
        wait for 200 ns;
        cpu_resetn <= '1';

        -- wait until ready
        wait until ready = '1';

        -- Send 'A'
        ascii    <= x"41";
        start_tx <= '1';
        wait for 2 us;      -- must be >= one clk1mhz period
        start_tx <= '0';

        -- wait for completion
        wait until ready = '1';
        wait for 10 us;

        -- Send 'B'
        ascii    <= x"42";
        start_tx <= '1';
        wait for 2 us;
        start_tx <= '0';

        wait until ready = '1';
        wait for 10 us;

        -- Send invalid char -> SOS
        ascii    <= x"3F"; -- '?'
        start_tx <= '1';
        wait for 2 us;
        start_tx <= '0';

        wait until ready = '1';
        wait for 10 us;

        -- space -> word gap
        ascii    <= x"20";
        start_tx <= '1';
        wait for 2 us;
        start_tx <= '0';

        wait until ready = '1';
        wait for 10 us;

        wait;
    end process;

end Behavioral;
