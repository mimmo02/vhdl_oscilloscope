library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_transmission is
    generic (   
            -- horizontal timing features
            frontPorch_h         : integer := 110;
            backPorch_h          : integer := 220;
            activePixels_h       : integer := 1280;
            syncWidth_h          : integer := 40;
            totalPixels_h        : integer := 1650;
            -- vertical timing features
            frontPorch_v         : integer := 5;
            backPorch_v          : integer := 20;
            activeLines_v        : integer := 720;
            syncWidth_v          : integer := 5;
            totalLines_v         : integer := 750);

    port (  clk_148_5_MHz   : in  std_logic;
            reset           : in  std_logic;
            nextScreen      : out std_logic;
            nextLine        : out std_logic;
            index_h         : out std_logic_vector(10 downto 0);
            index_v         : out std_logic_vector(9 downto 0);
            ACTIVE_VIDEO    : out std_logic;
            HDMI_CLOCK      : out std_logic;
            HSYNC           : out std_logic;
            VSYNC           : out std_logic);
end entity display_transmission;

architecture transmission of display_transmission is

    signal s_clk_74_25_MHz : std_logic := '0';                               -- internal 74.25 MHz clock signal
    signal s_h_counter : integer range 0 to totalPixels_h := 0;              -- horizontal counter
    signal s_v_counter : integer range 0 to totalLines_v := totalLines_v;    -- vertical counter
    signal s_end_of_line : std_logic := '0';                                 -- end of line signal
    signal s_end_of_frame : std_logic := '0';                                -- end of frame signal

    type STATETYPE is (Sync, ActiveVideo, FrontPorch, BackPorch);          -- definition of the timing phases
    signal s_state_h : STATETYPE := Sync;                                    -- horizontal states       
    signal s_state_v : STATETYPE := Sync;                                    -- vertical states

begin

    -----------------------------------------------------------------------------------------------
    -- Clock Handling
    -----------------------------------------------------------------------------------------------

    -- divide clock by 2 to get pixel clock for HDMI
    -- 148.5 MHz / 2 = 74.25 MHz
    CLOCK_DIVIDER: process(clk_148_5_MHz, reset) is
    begin
        if reset = '1' then     
            s_clk_74_25_MHz <= '0';
        elsif rising_edge(clk_148_5_MHz) then
                s_clk_74_25_MHz <= not s_clk_74_25_MHz;
        end if;
    end process CLOCK_DIVIDER;

    -- get out the clock signal for HDMI
    HDMI_CLOCK <= s_clk_74_25_MHz;

    -----------------------------------------------------------------------------------------------
    -- Horizontal Timing counter
    -----------------------------------------------------------------------------------------------
    
    -- horizontal counter, count the pixel in each line
    PIXEL_COUNTER: process(clk_148_5_MHz, reset) is
    begin
        if reset = '1' then
            s_h_counter <= 0;
            s_end_of_line <= '0';
        elsif rising_edge(clk_148_5_MHz) then
            if s_clk_74_25_MHz = '0' then
                if s_h_counter = (totalPixels_h - 1) then
                    s_h_counter <= 0;
                    s_end_of_line <= '1';
                else
                    s_h_counter <= s_h_counter + 1;
                    s_end_of_line <= '0';
                end if;
            end if;
        end if;
    end process PIXEL_COUNTER;

    -- vertical counter, count the lines
    LINE_COUNTER: process(clk_148_5_MHz, reset) is
    begin
        if reset = '1' then
            s_v_counter <= 0;
            s_end_of_frame <= '0';
        elsif rising_edge(clk_148_5_MHz) then
            if s_clk_74_25_MHz = '0' and s_h_counter = (totalPixels_h - 1) then
                if s_v_counter = (totalLines_v - 1) then        -- check if the end of the frame is reached
                    s_v_counter <= 0;
                    s_end_of_frame <= '1';
                else
                    s_v_counter <= s_v_counter + 1;
                    s_end_of_frame <= '0';
                end if;
            end if;
        end if;
    end process LINE_COUNTER;

    -----------------------------------------------------------------------------------------------
    -- assign the timing states 
    -----------------------------------------------------------------------------------------------

    -- assign the state of the horizontal timing
    s_state_h <= Sync when s_h_counter < syncWidth_h else
               BackPorch when s_h_counter < syncWidth_h + backPorch_h else
               ActiveVideo when s_h_counter < syncWidth_h + backPorch_h + activePixels_h else
               FrontPorch;

    -- assign the state of the vertical timing
    s_state_v <= Sync when s_v_counter < syncWidth_v else
               BackPorch when s_v_counter < syncWidth_v + backPorch_v else
               ActiveVideo when s_v_counter < syncWidth_v + backPorch_v + activeLines_v else
               FrontPorch;

    -----------------------------------------------------------------------------------------------
    -- Output signals
    -----------------------------------------------------------------------------------------------

    -- get out the horizontal index
    index_h <= std_logic_vector(to_unsigned(s_h_counter - syncWidth_h - backPorch_h + 1, 11));

    -- get out the vertical index
    index_v <= std_logic_vector(to_unsigned(s_v_counter - syncWidth_v - backPorch_v + 1, 10));

    -- get out the next screen signal
    nextScreen <= s_end_of_frame;

    -- get out the next line signal
    nextLine <= s_end_of_line;

    -- get out the horizontal sync signal
    HSYNC <= '1' when s_state_h = Sync else 
             '0';
    
    -- get out the vertical sync signal
    VSYNC <= '1' when s_state_v = Sync else 
             '0';
    
    -- get out the active video signal
    ACTIVE_VIDEO <= '1' when s_state_h = ActiveVideo and s_state_v = ActiveVideo else
                    '0';


end architecture transmission;