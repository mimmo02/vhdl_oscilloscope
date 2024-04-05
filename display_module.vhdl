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
signal s_pixel_grid          : std_logic_vector(2 downto 0);
signal s_pixel_border        : std_logic_vector(2 downto 0);
signal s_pixel_ch1_offset    : std_logic_vector(2 downto 0);
signal s_pixel_ch2_offset    : std_logic_vector(2 downto 0);
signal s_pixel_trigger_pos   : std_logic_vector(2 downto 0);
signal s_pixel_trigger_ampl  : std_logic_vector(2 downto 0);

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
            nextScreen    => NextScreen,  
            nextLine      => NextLine,  
            index_h       => s_index_h,   
            index_v       => s_index_v,
            ACTIVE_VIDEO  => ACTIVE_VIDEO,
            HDMI_CLOCK    => HDMI_CLOCK,
            HSYNC         => HSYNC,
            VSYNC         => VSYNC
        );


    -----------------------------------------------------------------------------------------------
    -- PIXELS ASSIGNMENT
    -----------------------------------------------------------------------------------------------
    RED <=   '1' when s_pixel_out(2) = '1' else 
             '0';
    GREEN <= '1' when s_pixel_out(1) = '1' else 
             '0';
    BLUE <=  '1' when s_pixel_out(0) = '1' else
             '0';
    -----------------------------------------------------------------------------------------------
    -- GRID DISPLAY
    -----------------------------------------------------------------------------------------------
    -- GRID: yellow: "110"   
    s_pixel_grid <= "110" when to_integer(unsigned(s_index_h)) mod c_square_width = 0 or to_integer(unsigned(s_index_v)) mod c_square_height = 0 else
                    "000";

    --BORDER: yellow: "110"
    s_pixel_border <= "110" when to_integer(unsigned(s_index_h)) = 1 or
                          to_integer(unsigned(s_index_h)) = 1280 or
                          to_integer(unsigned(s_index_v)) = 1 or
                          to_integer(unsigned(s_index_v)) = 720 else
                      "000";

    -----------------------------------------------------------------------------------------------
    -- OFFSET DISPLAY
    -----------------------------------------------------------------------------------------------
    -- channel 1: cyan: "011"
    s_pixel_ch1_offset <= "011" when to_integer(unsigned(s_index_h)) < (c_square_width/2) and
                                     to_integer(unsigned(s_index_v)) = (c_lines_v - 45) else        -- change 45 with the level
                          "000";

    -- channel 2: magenta: "101"
    s_pixel_ch2_offset <= "101" when to_integer(unsigned(s_index_h)) < (c_square_width/2) and
                                     to_integer(unsigned(s_index_v)) = (c_lines_v - 135) else        -- change 135 with the level
                          "000";

    -----------------------------------------------------------------------------------------------
    -- TRIGGER DISPLAY
    -----------------------------------------------------------------------------------------------
    s_pixel_trigger_pos <= "011" when to_integer(unsigned(s_index_h)) = 576 and                    -- change 576 with the position
                                      to_integer(unsigned(s_index_v)) < (c_square_height/2) else
                           "000";

    s_pixel_trigger_ampl <= "011" when to_integer(unsigned(s_index_h)) > (9*c_square_width + c_square_width/2) and                   
                                       to_integer(unsigned(s_index_v)) = (c_lines_v - 370) else    -- change 360 with the position
                            "000";

    -----------------------------------------------------------------------------------------------
    -- PIXEL OUT SUPERPOSITION 
    -----------------------------------------------------------------------------------------------
    s_pixel_out <= s_pixel_grid(2 downto 0) or 
                   s_pixel_border(2 downto 0) or 
                   s_pixel_ch1_offset(2 downto 0) or
                   s_pixel_ch2_offset(2 downto 0) or 
                   s_pixel_trigger_pos(2 downto 0) or
                   s_pixel_trigger_ampl(2 downto 0);

   

end platform_independent;

