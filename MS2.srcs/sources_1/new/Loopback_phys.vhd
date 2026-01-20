library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Loopback_phys is
    generic (
        UNIT_TICKS : natural := 50_000
    );
    port (
        CPU_RESETN : in  std_logic;
        CLK100MHZ  : in  std_logic;

        SW         : in  std_logic_vector(15 downto 0);  -- SW[7:0]=ASCII, SW[15]=auto mode, SW[14]=RX invert
        BTNC       : in  std_logic;

        LED        : out std_logic_vector(15 downto 0);

        Morse_SW   : in  std_logic_vector(3 downto 0);

        -- 7-seg
        seg        : out std_logic_vector(7 downto 0);
        an         : out std_logic_vector(7 downto 0);

        -- PCB / JA pins
        TxD        : out std_logic;  -- JA7
        RxD        : in  std_logic;  -- JA8
        main_StartTx : in std_logic;
        main_NewSymbol : out std_logic;
        main_ASCII : in std_logic_vector(7 downto 0);
        main_RxASCII : out std_logic_vector(7 downto 0);
        main_TxReady : out std_logic;
        
        Buzzer_p   : out std_logic;  -- JA9
        Buzzer_n   : out std_logic   -- JA10
    );
end Loopback_phys;

architecture rtl of Loopback_phys is

    -- clocks
    signal clk1mhz : std_logic;

    -- transmitter
    signal tx_ascii : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_ascii2 : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_start : std_logic := '0';
    signal tx_ready : std_logic := '0';
    signal tx_led   : std_logic := '0';

    -- receiver
    signal rx_ascii : std_logic_vector(7 downto 0);
    signal rx_new   : std_logic;

    -- RX input after optional invert (SW14)
    signal rx_in : std_logic := '0';

    -- BTNC sync + edge detect (CLK1MHZ domain)
    signal btn_ff1, btn_ff2 : std_logic := '0';
    signal btn_prev         : std_logic := '0';
    signal btn_rise         : std_logic := '0';

    -- buzzer 1kHz (100MHz domain)
    signal buz_cnt  : unsigned(31 downto 0) := (others => '0');
    signal buz_sq   : std_logic := '0';

    -- auto message: "HAWK SOS TEST" (single spaces)
    type ram_t is array (0 to 12) of std_logic_vector(7 downto 0);
    constant TEST_RAM : ram_t := (
        x"48", x"41", x"57", x"4B",  -- H A W K
        x"20",                       -- ' '
        x"53", x"4F", x"53",         -- S O S
        x"20",                       -- ' '
        x"54", x"45", x"53", x"54"   -- T E S T
    );
    signal ram_idx : integer range 0 to 12 := 0;

    --------------------------------------------------------------------
    -- 7-seg helpers
    -- seg(7:0) = {dp,g,f,e,d,c,b,a}, active-low
    --------------------------------------------------------------------
    constant SEG_BLANK : std_logic_vector(7 downto 0) := (others => '1');
    constant SEG_DP_ON : std_logic_vector(7 downto 0) := "01111111"; -- only dp on (active-low)

    function hex_to_7seg(n : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case n is
            when "0000" => return "11000000"; -- 0
            when "0001" => return "11111001"; -- 1
            when "0010" => return "10100100"; -- 2
            when "0011" => return "10110000"; -- 3
            when "0100" => return "10011001"; -- 4
            when "0101" => return "10010010"; -- 5
            when "0110" => return "10000010"; -- 6
            when "0111" => return "11111000"; -- 7
            when "1000" => return "10000000"; -- 8
            when "1001" => return "10010000"; -- 9
            when "1010" => return "10001000"; -- A
            when "1011" => return "10000011"; -- b
            when "1100" => return "11000110"; -- C
            when "1101" => return "10100001"; -- d
            when "1110" => return "10000110"; -- E
            when others => return "10001110"; -- F
        end case;
    end function;

    signal last_tx     : std_logic_vector(7 downto 0) := (others => '0');
    signal last_rx     : std_logic_vector(7 downto 0) := (others => '0');
    signal disp_number : std_logic_vector(63 downto 0) := (others => '1');

    signal rx_dp_digit : std_logic_vector(7 downto 0);

begin

    --------------------------------------------------------------------
    -- RX invert selector (SW14)
    --------------------------------------------------------------------
    rx_in <= RxD when SW(14) = '0' else tx_led;

    rx_dp_digit <= SEG_DP_ON when rx_in = '1' else SEG_BLANK;

    --------------------------------------------------------------------
    -- Clock divider 100MHz -> 1MHz
    --------------------------------------------------------------------
    U_CLKDIV: entity work.ClkDivider
        port map (
            CPU_RESETN      => CPU_RESETN,
            clk_in          => CLK100MHZ,
            clk_out_1mhz    => clk1mhz,
            clk_out_100mhz  => open
        );

    --------------------------------------------------------------------
    -- Morse transmitter (ASCII -> TxD)
    --------------------------------------------------------------------
    U_TX: entity work.MorseTx
        generic map (
            UNIT_TICKS => UNIT_TICKS
        )
        port map (
            CPU_RESETN => CPU_RESETN,
            CLK1MHZ    => clk1mhz,
            ASCII      => main_ASCII,
            LED        => tx_led,
            Ready      => main_TxReady,
            StartTx    => main_StartTx
        );
    TxD <= tx_led;
    --------------------------------------------------------------------
    -- Morse receiver (RxD -> ASCII)
    --------------------------------------------------------------------
    U_RX: entity work.MorseRx
        generic map (
            UNIT_TICKS => UNIT_TICKS
        )
        port map (
            CPU_RESETN    => CPU_RESETN,
            CLK1MHZ       => clk1mhz,
            PhotoDiode    => tx_led, -- loopback sonst RxD
            Output_Symbol => tx_ascii2,
            NewSymbol     => main_NewSymbol
        );
    main_RxASCII <= tx_ascii2;
    --------------------------------------------------------------------
    -- BTNC sync/edge detect in clk1mhz domain
    --------------------------------------------------------------------
    process(clk1mhz)
    begin
        if rising_edge(clk1mhz) then
            if CPU_RESETN = '0' then
                btn_ff1  <= '0';
                btn_ff2  <= '0';
                btn_prev <= '0';
                btn_rise <= '0';
            else
                btn_ff1  <= BTNC;
                btn_ff2  <= btn_ff1;
                btn_rise <= (not btn_prev) and btn_ff2;
                btn_prev <= btn_ff2;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Drive tx_ascii and tx_start
    -- SW(15)=1 => auto message cycling "HAWK SOS TEST"
    -- SW(15)=0 => manual: SW(7:0) sent on BTNC rising edge
    --------------------------------------------------------------------
    process(clk1mhz)
    begin
        if rising_edge(clk1mhz) then
            if CPU_RESETN = '0' then
                tx_start <= '0';
                tx_ascii <= (others => '0');
                ram_idx  <= 0;
            else
                tx_start <= '0'; -- default

                if tx_ready = '1' then
                    if SW(15) = '1' then
                        tx_ascii <= TEST_RAM(ram_idx);

                        if ram_idx = 12 then
                            ram_idx <= 0;
                        else
                            ram_idx <= ram_idx + 1;
                        end if;

                        tx_start <= '1';
                    else
                        if btn_rise = '1' then
                            tx_ascii <= SW(7 downto 0);
                            tx_start <= '1';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Save last sent / last received bytes (for display)
    --------------------------------------------------------------------
--    process(clk1mhz)
--    begin
--        if rising_edge(clk1mhz) then
--            if CPU_RESETN = '0' then
--                last_tx <= (others => '0');
--                last_rx <= (others => '0');
--            else
--                if tx_start = '1' then
--                    last_tx <= tx_ascii;
--                end if;

--                if rx_new = '1' then
--                    last_rx <= rx_ascii;
--                end if;
--            end if;
--        end if;
--    end process;

    --------------------------------------------------------------------
    -- 7-seg content:
    -- Left:  TX hex (AN7..AN6)
    -- Right: RX hex (AN1..AN0)
    -- Middle: one digit shows RX level via DP (debug)
    --------------------------------------------------------------------
    disp_number <=
        hex_to_7seg(main_ASCII(7 downto 4)) &  -- Digit7 (AN7)
        hex_to_7seg(main_ASCII(3 downto 0)) &  -- Digit6 (AN6)
        SEG_BLANK &                         -- Digit5 (AN5)
        rx_dp_digit &                       -- Digit4 (AN4)
        SEG_BLANK &                         -- Digit3 (AN3)
        SEG_BLANK &                         -- Digit2 (AN2)
        hex_to_7seg(tx_ascii2(7 downto 4)) &  -- Digit1 (AN1)
        hex_to_7seg(tx_ascii2(3 downto 0));   -- Digit0 (AN0)

    U_SSEG: entity work.sSegDisplay
        port map (
            ck     => CLK100MHZ,
            nReset => CPU_RESETN,
            number => disp_number,
            seg    => seg,
            an     => an
        );

    --------------------------------------------------------------------
    -- Buzzer 1kHz on 100MHz clock, gated by SW(13)
    --------------------------------------------------------------------
    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN = '0' then
                buz_cnt <= (others => '0');
                buz_sq  <= '0';
            else
                if buz_cnt >= 50_000 then
                    buz_cnt <= (others => '0');
                    buz_sq  <= not buz_sq;
                else
                    buz_cnt <= buz_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    Buzzer_p <= buz_sq and SW(13) and tx_led;
    Buzzer_n <= (not buz_sq) and SW(13) and tx_led;

    --------------------------------------------------------------------
    -- LEDs (debug)
    --------------------------------------------------------------------
    LED(7 downto 0)   <= rx_ascii;
    LED(8)            <= tx_led;
    LED(9)            <= tx_ready;
    LED(10)           <= tx_start;
    LED(11)           <= rx_new;
    LED(15 downto 12) <= tx_ascii(7 downto 4);

end rtl;