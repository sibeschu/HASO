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

entity ClkDivider is
    Port (
        CPU_RESETN      : in  std_logic;
        clk_in          : in  std_logic;  -- 100 MHz
        clk_out_1mhz    : out std_logic;
        clk_out_100mhz  : out std_logic
    );
end ClkDivider;

architecture Behavioral of ClkDivider is
    signal count   : unsigned(5 downto 0) := (others => '0'); -- 0..49
    signal clk_div : std_logic := '0';
begin

    clk_out_100mhz <= clk_in;

    process (clk_in)
    begin
        if rising_edge(clk_in) then
            if CPU_RESETN = '0' then
                count   <= (others => '0');
                clk_div <= '0';
            else
                -- toggle every 50 cycles => 100 MHz / (2*50) = 1 MHz
                if count = 49 then
                    count   <= (others => '0');
                    clk_div <= not clk_div;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;

    clk_out_1mhz <= clk_div;

end Behavioral;
