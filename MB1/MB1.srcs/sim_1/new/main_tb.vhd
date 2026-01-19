-- tb_Main.vhd
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_Main is
end entity;

architecture sim of tb_Main is
  -- DUT Ports
    signal SW         : std_logic_vector(15 downto 0) := (others => '0');
    signal CLK100MHZ  : std_logic := '0';
    signal BTNC  : std_logic := '0';
    signal CPU_RESETN : std_logic := '0'; -- To Do write Stimuli
    signal LED        : std_logic_vector(15 downto 0);
    signal LED16_B    : std_logic;
    signal LED16_R    : std_logic;
    signal LED16_G    : std_logic;
    
    constant G_ClockSpeed: natural range 1 to 150*10**6 := 100*10**6;
    constant G_ClockPeriod: time := 1ns*10**9 / G_ClockSpeed;

begin
  -- DUT-Instanz
  uut: entity work.Main
    port map (
      SW         => SW,
      CLK100MHZ  => CLK100MHZ,
      CPU_RESETN => CPU_RESETN,
      LED        => LED,
      BTNC => BTNC,
      LED16_B    => LED16_B,
      LED16_R    => LED16_R,
      LED16_G    => LED16_G
    );

  -- Takt
  clk_gen : block
   begin
  		CLK100MHZ <= not CLK100MHZ after 0.5*G_ClockPeriod;
  end block;

  -- Reset
  rst_proc : process
  begin
    CPU_RESETN <= '0';
    wait for 100 ns;
    CPU_RESETN <= '1';
    wait;
  end process;

  -- Stimuli
  stim : process
  begin
    -- Initial: alle SW=0 -> Lauflicht aktiv (SW(15)='0')
    -- Warte bis erster Schritt des Lauflichts passiert
    wait for 11 ms;  -- > 100 ms, damit timer_cnt einmal auslöst

    report "Erster Lauflicht-Schritt sichtbar. LED=" & to_hstring(LED);

    -- Zweiter Schritt
    wait for 11 ms;
    report "Zweiter Lauflicht-Schritt. LED=" & to_hstring(LED);

    -- Schalte in Direktmodus: SW(15)='1', setze SW(0..1)
    SW(0)  <= '1';
    SW(1)  <= '0';
    SW(12) <= '1';  -- für LED16_B
    SW(13) <= '1';  -- für LED16_G
    SW(14) <= '0';  -- für LED16_R
    SW(15) <= '1';

    -- Werte werden erst beim nächsten 100-ms-Tick auf LED(0..1) übernommen
    wait for 11 ms;

    assert LED(0) = SW(0) and LED(1) = SW(1)
      report "Direktmodus falsch: LED(1 downto 0)=" & std_logic'image(LED(1)) &
             std_logic'image(LED(0)) severity error;

    report "Direktmodus ok. LED(1..0)=" & std_logic'image(LED(1)) &
           std_logic'image(LED(0)) &
           "  LED16_R/G/B=" & std_logic'image(LED16_R) &
           std_logic'image(LED16_G) & std_logic'image(LED16_B);

    -- Zurück ins Lauflicht
    SW(15) <= '0';
    wait for 11 ms;
    report "Zurück im Lauflicht. LED=" & to_hstring(LED);

    -- Simulation beenden nach ein paar Schritten
    wait for 22 ms;
    report "Simulation Ende." severity note;
    wait;
  end process;

end architecture;