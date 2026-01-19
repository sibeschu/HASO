----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2025 16:49:52
-- Design Name: 
-- Module Name: tb_Loopback - Behavioral
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

entity tb_Loopback is
end tb_Loopback;

architecture Behavioral of tb_Loopback is

    constant UNIT_TICKS_SIM : natural := 10;

    signal clk100mhz  : std_logic := '0';
    signal clk1mhz    : std_logic;
    signal CPU_RESETN : std_logic := '0';

    -- sender (MorseTx = transmitter)
    signal ASCII   : std_logic_vector(7 downto 0) := (others => '0');
    signal StartTx : std_logic := '0';
    signal LED     : std_logic;
    signal Ready   : std_logic;

    -- receiver (MorseRx = receiver)
    signal Output_Symbol : std_logic_vector(7 downto 0);
    signal NewSymbol     : std_logic;

    type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
    constant EXPECTED : word_t := (x"54", x"45", x"53", x"54"); -- TEST

    signal prev_NewSymbol : std_logic := '0';

begin

    -- 100 MHz clock
    clk100_proc: process
    begin
        while true loop
            clk100mhz <= '0'; wait for 5 ns;
            clk100mhz <= '1'; wait for 5 ns;
        end loop;
    end process;

    -- divider
    U_CLKDIV: entity work.ClkDivider
        port map(
            CPU_RESETN      => CPU_RESETN,
            clk_in          => clk100mhz,
            clk_out_1mhz    => clk1mhz,
            clk_out_100mhz  => open
        );

    -- sender
    U_TX: entity work.MorseTx
        generic map(
            UNIT_TICKS => UNIT_TICKS_SIM
        )
        port map(
            CPU_RESETN => CPU_RESETN,
            CLK1MHZ    => clk1mhz,
            ASCII      => ASCII,
            LED        => LED,
            Ready      => Ready,
            StartTx    => StartTx
        );

    -- receiver
    U_RX: entity work.MorseRx
        generic map(
            UNIT_TICKS => UNIT_TICKS_SIM
        )
        port map(
            CPU_RESETN    => CPU_RESETN,
            CLK1MHZ       => clk1mhz,
            PhotoDiode    => LED,
            Output_Symbol => Output_Symbol,
            NewSymbol     => NewSymbol
        );

    -- sample NewSymbol for edge detect
    edge_sample_proc: process(clk1mhz)
    begin
        if rising_edge(clk1mhz) then
            if CPU_RESETN = '0' then
                prev_NewSymbol <= '0';
            else
                prev_NewSymbol <= NewSymbol;
            end if;
        end if;
    end process;
stim_proc: process
    type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
    constant WORD_TEST : word_t := (x"54", x"45", x"53", x"54"); -- TEST

    variable send_i : integer := 0;
    variable got_i  : integer := 0;

    procedure pulse_start is
    begin
        StartTx <= '1';
        wait for 2 us;      -- must be >= 1 clk1mhz period
        StartTx <= '0';
    end procedure;

begin
    -- reset
    CPU_RESETN <= '0';
    ASCII      <= (others => '0');
    StartTx    <= '0';
    wait for 5 us;
    CPU_RESETN <= '1';

    -- SEND: TEST
    for send_i in 0 to 3 loop
        wait until Ready = '1';
        ASCII <= WORD_TEST(send_i);
        pulse_start;
    end loop;

    -- RECEIVE: wait for 4 non-space symbols
    got_i := 0;
    while got_i < 4 loop
        wait until rising_edge(clk1mhz);
        if (prev_NewSymbol = '0') and (NewSymbol = '1') then
            if Output_Symbol = x"20" then
                -- ignore spaces
                null;
            else
                assert Output_Symbol = WORD_TEST(got_i)
                    report "Mismatch at pos " & integer'image(got_i) &
                           " got=" & integer'image(to_integer(unsigned(Output_Symbol))) &
                           " exp=" & integer'image(to_integer(unsigned(WORD_TEST(got_i))))
                    severity error;
                got_i := got_i + 1;
            end if;
        end if;
    end loop;

    report "PASS: Received TEST" severity note;

    wait for 20 us;
    assert false report "End of simulation" severity failure;
end process;


end Behavioral;


