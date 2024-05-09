---------------------------------------------------------------------------------------------------------------
-- File: display_module.vhd
-- Author: Domenico Aquilino <aquid1@bfh.ch>
-- Date: 2024-04-05
-- Version: 1.0

-- description: This file contains the VHDL code for the display module. The display module is responsible for
-- displaying the data of the two channels on the screen. The display module receives the data of the two channels
-- and the trigger data. The display module is responsible for displaying the data of the two channels on the screen.
-- The display module receives the data of the two channels and the trigger data.
---------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_module is
    port (  clk_148_5_MHz       : in std_logic;
            reset               : in std_logic;
        
            ChannelOneOn        : in std_logic;                         -- Show channel 1
            ChannelTwoOn        : in std_logic;                         -- Show channel 2
            ChannelOneDot       : in std_logic;                         -- If active, only the individual sample points are displayed for channel 1. Otherwise, a vertical line is drawn between sample n and sample n+1.
            ChannelTwoDot       : in std_logic;                         -- If active, only the individual sample points are displayed for channel 2. Otherwise, a vertical line is drawn between sample n and sample n+1.
            ChannelOneSample    : in std_logic_vector(9 downto 0);      -- Current sample of channel 1
            ChannelTwoSample    : in std_logic_vector(9 downto 0);      -- Current sample of channel 2
            ChannelOneOffset    : in std_logic_vector(9 downto 0);      -- Channel 1 offset
            ChannelTwoOffset    : in std_logic_vector(9 downto 0);      -- Channel 2 offset
            TriggerLevel        : in std_logic_vector(9 downto 0);      -- Magnitude of trigger
            TriggerPoint        : in std_logic_vector(10 downto 0);     -- X-position of trigger
            TriggerChannelOne   : in std_logic;                         -- If active, the trigger refers to channel 1, otherwise it refers to channel 2.

            RequestSample       : out std_logic;                        -- Request new samples for channel 1 and channel 2
            NextLine            : out std_logic;                        -- End of line
            NextScreen          : out std_logic;                        -- End of frame

            HSYNC               : out std_logic;                        -- Horizontal synchronization signal
            VSYNC               : out std_logic;                        -- Vertical synchronization signal
            RED                 : out std_logic;                        -- Red color channel
            GREEN               : out std_logic;                        -- Green color channel
            BLUE                : out std_logic;                        -- Blue color channel
            HDMI_CLOCK          : out std_logic;                        -- Pixel clock for hdmi-screen
            ACTIVE_VIDEO        : out std_logic);                       -- If active, the current pixel is inside the active video region
end entity display_module;

architecture platform_independent of display_module is

-- address signals
signal s_index_h : std_logic_vector(10 downto 0);
signal s_index_v : std_logic_vector(9 downto 0);

-- constants
constant c_pixels_h : integer := 1280;
constant c_lines_v  : integer := 720;
-- grid constants
constant c_num_square_h : integer  := 10;
constant c_num_square_v : integer  := 8;
constant c_square_width : integer  := c_pixels_h / c_num_square_h;
constant c_square_height : integer := c_lines_v / c_num_square_v;

-- pixel signals
signal s_pixel_out           : std_logic_vector(2 downto 0);
signal s_pixel_grid          : std_logic;
signal s_pixel_border        : std_logic;
signal s_ch1_offset          : std_logic;
signal s_ch2_offset          : std_logic;
signal s_pixel_trigger_pos   : std_logic;
signal s_pixel_trigger_ampl  : std_logic;
signal s_ch1_sample_pre      : std_logic_vector(9 downto 0);
signal s_ch2_sample_pre      : std_logic_vector(9 downto 0);
signal s_trigger_color       : std_logic_vector(2 downto 0);
signal s_ch1                 : std_logic;
signal s_ch2                 : std_logic;
signal s_ch1_dot             : std_logic;
signal s_ch1_vert            : std_logic;
signal s_ch2_dot             : std_logic;
signal s_ch2_vert            : std_logic;

signal s_NextLine            : std_logic;
signal s_NextScreen          : std_logic;
signal s_ACTIVE_VIDEO        : std_logic;
signal s_HDMI_CLOCK          : std_logic;

begin

    -----------------------------------------------------------------------------------------------
    -- TRANSMISSION PROCEDURE ENTITY INSTANTIATION
    -----------------------------------------------------------------------------------------------    
    DISPLAY_TRANSMISSION : entity work.display_transmission(transmission)
        generic map(
            frontPorch_h   => 110,
            backPorch_h    => 220,
            activePixels_h => 1280,
            syncWidth_h    => 40,
            totalPixels_h  => 1650,

            frontPorch_v   => 5,
            backPorch_v    => 20,
            activeLines_v  => 720,
            syncWidth_v    => 5,
            totalLines_v   => 750
        )
        port map(
            clk_148_5_MHz => clk_148_5_MHz,
            reset         => reset,      
            nextScreen    => s_NextScreen,  
            nextLine      => s_NextLine,  
            index_h       => s_index_h,   
            index_v       => s_index_v,
            ACTIVE_VIDEO  => s_ACTIVE_VIDEO,
            HDMI_CLOCK    => s_HDMI_CLOCK,
            HSYNC         => HSYNC,
            VSYNC         => VSYNC
        );

    NextLine <= s_NextLine;
    NextScreen <= s_NextScreen;
    ACTIVE_VIDEO <= s_ACTIVE_VIDEO;
    HDMI_CLOCK <= s_HDMI_CLOCK;

    RequestSample <= '1' when s_ACTIVE_VIDEO = '1' and s_HDMI_CLOCK = '1' else
                     '0';
    -----------------------------------------------------------------------------------------------
    -- GRID DISPLAY
    -----------------------------------------------------------------------------------------------
    -- GRID: yellow: "110"   
    s_pixel_grid <= '1' when unsigned(s_index_h) mod c_square_width = 0 or unsigned(s_index_v) mod c_square_height = 0 else
                    '0';

    --BORDER: yellow: "110"
    s_pixel_border <= '1' when unsigned(s_index_h) = 1 or
                                 unsigned(s_index_h) = c_pixels_h or
                                 unsigned(s_index_v) = 1 or
                                 unsigned(s_index_v) = c_lines_v else
                      '0';
    -----------------------------------------------------------------------------------------------
    -- OFFSET DISPLAY
    -----------------------------------------------------------------------------------------------
    -- channel 1 offset: cyan = "011"
    s_ch1_offset <= '1' when unsigned(s_index_h) < (c_square_width/2) and
                               unsigned(s_index_v) = (c_lines_v - unsigned(ChannelOneOffset)) else
                    '0';
    -- channel 2 offset: magenta = "101"
    s_ch2_offset <= '1' when unsigned(s_index_h) < (c_square_width/2) and
                               unsigned(s_index_v) = (c_lines_v - unsigned(ChannelTwoOffset)) else
                    '0';
    -----------------------------------------------------------------------------------------------
    -- TRIGGER DISPLAY
    -----------------------------------------------------------------------------------------------
    -- trigger position display
    s_pixel_trigger_pos <= '1' when unsigned(s_index_h) = unsigned(TriggerPoint) and
                                                   unsigned(s_index_v) < (c_square_height/2) else
                           '0';
    -- trigger amplitude display
    s_pixel_trigger_ampl <= '1' when unsigned(s_index_h) > (9*c_square_width + c_square_width/2) and                   
                                                    unsigned(s_index_v) = (c_lines_v - unsigned(TriggerLevel)) else
                            '0';
    -----------------------------------------------------------------------------------------------
    -- CHANNEL DISPLAY
    -----------------------------------------------------------------------------------------------

    SAMPLE_PRE : process(clk_148_5_MHz,reset)
    begin
        if reset = '1' then 
            s_ch1_sample_pre <= (others => '0');
            s_ch2_sample_pre <= (others => '0');
        elsif rising_edge(clk_148_5_MHz) then
            if s_ACTIVE_VIDEO = '1' and s_HDMI_CLOCK = '0' then
                s_ch1_sample_pre <= ChannelOneSample;
                s_ch2_sample_pre <= ChannelTwoSample;
            end if;
        end if;
    end process SAMPLE_PRE;

    s_ch1_dot <= '1' when (c_lines_v - unsigned(s_index_v)) = unsigned(ChannelOneSample) else
                 '0';

    s_ch1_vert <= '1' when unsigned(ChannelOneSample) >= unsigned(s_ch1_sample_pre) and
                           (c_lines_v - unsigned(s_index_v)) >= unsigned(s_ch1_sample_pre) and
                           (c_lines_v - unsigned(s_index_v)) <= unsigned(ChannelOneSample) else
                  '1' when unsigned(ChannelOneSample) <= unsigned(s_ch1_sample_pre) and
                           (c_lines_v - unsigned(s_index_v)) <= unsigned(s_ch1_sample_pre) and
                           (c_lines_v - unsigned(s_index_v)) >= unsigned(ChannelOneSample) else
                  '0';
                
    s_ch1 <= s_ch1_dot or s_ch1_vert when ChannelOneOn = '1' and ChannelOneDot = '0' else
             s_ch1_dot               when ChannelOneOn = '1' and ChannelOneDot = '1' else
             '0';

    s_ch2_dot <= '1' when (c_lines_v - unsigned(s_index_v)) = unsigned(ChannelTwoSample) else
                 '0';

    s_ch2_vert <= '1' when unsigned(ChannelTwoSample) >= unsigned(s_ch2_sample_pre) and
                           (c_lines_v - unsigned(s_index_v)) >= unsigned(s_ch2_sample_pre) and
                           (c_lines_v - unsigned(s_index_v)) <= unsigned(ChannelTwoSample) else
                  '1' when unsigned(ChannelTwoSample) <= unsigned(s_ch2_sample_pre) and
                           (c_lines_v - unsigned(s_index_v)) <= unsigned(s_ch2_sample_pre) and
                           (c_lines_v - unsigned(s_index_v)) >= unsigned(ChannelTwoSample) else
                  '0';

    s_ch2 <= s_ch2_dot or s_ch2_vert when ChannelTwoOn = '1' and ChannelTwoDot = '0' else
             s_ch2_dot               when ChannelTwoOn = '1' and ChannelTwoDot = '1' else
             '0';

    -----------------------------------------------------------------------------------------------
    -- PIXEL OUT SUPERPOSITION 
    -----------------------------------------------------------------------------------------------

    s_trigger_color <= "011" when TriggerChannelOne = '1' else
                       "101";

    s_pixel_out <= s_trigger_color when s_pixel_trigger_pos = '1' else               -- high priority of superposition
                   s_trigger_color when s_pixel_trigger_ampl = '1' else
                   "011" when s_ch1_offset = '1' and ChannelOneOn = '1' else                           
                   "101" when s_ch2_offset = '1' and ChannelTwoOn = '1' else
                   "111" when s_ch1 = '1' and s_ch2 = '1' else
                   "011" when s_ch1 = '1' else
                   "101" when s_ch2 = '1' else
                   "110" when s_pixel_grid = '1' or s_pixel_border = '1' else       -- low priority of superposition
                   "000";

    -----------------------------------------------------------------------------------------------
    -- PIXELS ASSIGNMENT
    -----------------------------------------------------------------------------------------------
    RED <=   '1' when s_pixel_out(2) = '1' else 
             '0';
    GREEN <= '1' when s_pixel_out(1) = '1' else 
             '0';
    BLUE <=  '1' when s_pixel_out(0) = '1' else
             '0';

end platform_independent;
