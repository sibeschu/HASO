----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.09.2025 20:20:37
-- Design Name: 
-- Module Name: Main - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main is
    Port (
            SW : in std_logic_vector (15 downto 0); 
            CLK100MHZ : in STD_LOGIC;
            CPU_RESETN : in STD_LOGIC;
            BTNC : in STD_LOGIC;
            
            LED : out std_logic_vector (15 downto 0);
            LED16_B : out STD_LOGIC;
            LED16_R : out STD_LOGIC;
            LED16_G : out STD_LOGIC
           );
end Main;

architecture Behavioral of Main is
	signal timer_cnt : unsigned(31 downto 0);
	signal LaufLicht : std_logic_vector (15 downto 0);
	signal LinksRechts : std_logic;
begin
    process (CLK100MHZ, CPU_RESETN)
    begin
        if (CPU_RESETN = '0') then
            LED <= (others => '0');
            timer_cnt <= (others => '0');
            Lauflicht <= x"0001";
            LinksRechts <= '1';
        elsif rising_edge(CLK100MHZ) then
            if (BTNC = '1') then
                LED <= SW;
            else
                LED <= LaufLicht;
            end if;

            if (timer_cnt >= 50000000) then
                timer_cnt <= (others => '0');
                
                -- Lauflicht
                if (Lauflicht = x"4000") then
                    LinksRechts <= '0';
                elsif (Lauflicht = x"0002") then 
                    LinksRechts <= '1';
                end if;
                
                if (LinksRechts = '1') then
                    LaufLicht <= LaufLicht(14 downto 0) & '0';
                else
                    LaufLicht <= '0' & LaufLicht(15 downto 1);
                end if;
            else
                timer_cnt <= timer_cnt + 1;
            end if;            
        end if;
    end process;
    
    LED16_R <= SW(14);
    LED16_G <= SW(13);
    LED16_B <= SW(12);
     
end Behavioral;
