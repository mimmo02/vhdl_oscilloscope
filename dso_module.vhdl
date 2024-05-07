library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.led_matrix_pkg.all;

entity dso_module is
    port (  clk_148_5_MHz       : in std_logic;
            reset               : in std_logic;

            -- buttons
            btn_sel_channel     : in std_logic;
            btn_sel_parameter   : in std_logic;
            btn_sel_acq_mode    : in std_logic;
            btn_run             : in std_logic;
            btn_plus            : in std_logic;
            btn_minus           : in std_logic;

            -- hdmi interface
            HSYNC               : out std_logic;
            VSYNC               : out std_logic;
            RED                 : out std_logic;
            GREEN               : out std_logic;
            BLUE                : out std_logic;
            HDMI_CLOCK          : out std_logic;
            ACTIVE_VIDEO        : out std_logic;

            -- dac interface
            nCS_DA2             : out std_logic;
            D0_DA2              : out std_logic;
            D1_DA2              : out std_logic;
            SCK_DA2             : out std_logic;

            -- adc interface
            nCS_AD1             : out std_logic;
            D0_AD1              : in std_logic;
            D1_AD1              : in std_logic;
            SCK_AD1             : out std_logic;

            -- ssd
            seg1                : out std_logic_vector(6 downto 0);
            seg2                : out std_logic_vector(6 downto 0);
            seg3                : out std_logic_vector(6 downto 0);
            seg4                : out std_logic_vector(6 downto 0);

            -- led matrix
            led_matrix          : out led_array);
end entity dso_module;


architecture platform_independent of dso_module is

    signal s_HSYNC : std_logic;
    signal s_VSYNC : std_logic;
    signal s_RED : std_logic;
    signal s_GREEN : std_logic;
    signal s_BLUE : std_logic;
    signal s_HDMI_CLOCK : std_logic;
    signal s_ACTIVE_VIDEO : std_logic;

    signal s_RequestSample : std_logic;
    signal s_NextLine : std_logic;
    signal s_NextScreen : std_logic;

    signal s_ChannelOneOn : std_logic;
    signal s_ChannelTwoOn : std_logic;
    signal s_ChannelOneDot : std_logic;
    signal s_ChannelTwoDot : std_logic;
    signal s_Trigger_ref : std_logic_vector(5 downto 0);
    signal s_Trigger_pos : std_logic_vector(5 downto 0);
    signal s_Offset_ch1 : std_logic_vector(5 downto 0);
    signal s_Offset_ch2 : std_logic_vector(5 downto 0);
    signal s_ChannelOneSample : std_logic_vector(9 downto 0);
    signal s_ChannelTwoSample : std_logic_vector(9 downto 0);
    signal s_ChannelOneOffset : std_logic_vector(9 downto 0);
    signal s_ChannelTwoOffset : std_logic_vector(9 downto 0);
    signal s_TriggerLevel : std_logic_vector(9 downto 0);
    signal s_TriggerPoint : std_logic_vector(10 downto 0);
    signal s_TriggerChannelOne : std_logic;
    signal s_amplitude_ch1 : std_logic_vector(2 downto 0);
    signal s_amplitude_ch2 : std_logic_vector(2 downto 0);

    signal s_TriggerOnRising : std_logic;
    signal s_TimeBase : std_logic_vector(2 downto 0);

    -- ADC
    signal s_Sample_ADC_ch1 : std_logic_vector(8 downto 0);
    signal s_Sample_ADC_ch2 : std_logic_vector(8 downto 0);
    signal s_ValidIn_ADC : std_logic;


begin

    -- DISPLAY

    s_TriggerLevel <= std_logic_vector(unsigned(s_Trigger_ref) * 16);
    s_TriggerPoint <= std_logic_vector(unsigned(s_Trigger_pos) * 32);
    s_ChannelOneOffset <= std_logic_vector(unsigned(s_Offset_ch1) * 16);
    s_ChannelTwoOffset <= std_logic_vector(unsigned(s_Offset_ch2) * 16);

    DISPLAY : entity work.display_module(platform_independent)
        port map(
            clk_148_5_MHz       => clk_148_5_MHz,
            reset               => reset,
        
            ChannelOneOn        => s_ChannelOneOn,
            ChannelTwoOn        => s_ChannelTwoOn,
            ChannelOneDot       => s_ChannelOneDot,
            ChannelTwoDot       => s_ChannelTwoDot, 
            ChannelOneSample    => s_ChannelOneSample,    
            ChannelTwoSample    => s_ChannelTwoSample,
            ChannelOneOffset    => s_ChannelOneOffset,
            ChannelTwoOffset    => s_ChannelTwoOffset,
            TriggerLevel        => s_TriggerLevel,
            TriggerPoint        => s_TriggerPoint,
            TriggerChannelOne   => s_TriggerChannelOne,

            RequestSample       => s_RequestSample,
            NextLine            => s_NextLine,
            NextScreen          => s_NextScreen,

            HSYNC               => s_HSYNC,                        -- Horizontal synchronization signal
            VSYNC               => s_VSYNC,                        -- Vertical synchronization signal
            RED                 => s_RED,                          -- Red color channel
            GREEN               => s_GREEN,                        -- Green color channel
            BLUE                => s_BLUE,                         -- Blue color channel
            HDMI_CLOCK          => s_HDMI_CLOCK,                   -- Clock signal for the HDMI interface
            ACTIVE_VIDEO        => s_ACTIVE_VIDEO                  -- Active video signal for the HDMI interface


        );

        HSYNC <= s_HSYNC;
        VSYNC <= s_VSYNC;
        RED <= s_RED;
        GREEN <= s_GREEN;
        BLUE <= s_BLUE;
        HDMI_CLOCK <= s_HDMI_CLOCK;
        ACTIVE_VIDEO <= s_ACTIVE_VIDEO;

    -- MEMORY HANDLER

    MEMORY_HANDLER : entity work.memory_handler(platform_independent)
        port map(
            clk => clk_148_5_MHz,               
            rst => reset,               

            -- trigger
            Trigger_ref => s_Trigger_ref,        
            Trigger_pos => s_Trigger_pos,   
            Trigger_ch1 => s_TriggerChannelOne,         
            Trigger_on_rising => s_TriggerOnRising,
            TimeBase => s_TimeBase,            

            -- ADC
            sample_in_ch1 => s_Sample_ADC_ch1,     
            sample_in_ch2 => s_Sample_ADC_ch2,     
            valid_in => s_ValidIn_ADC,           

            -- display
            RequestSample => s_RequestSample,     
            NextLine => s_NextLine,           
            NextScreen => s_NextScreen,       

            Offset_ch1 => s_Offset_ch1,         
            Offset_ch2 => s_Offset_ch2,      
            Sig_amplitude_ch1 => s_amplitude_ch1,  
            Sig_amplitude_ch2 => s_amplitude_ch2,  
            
            ChannelOneSample => s_ChannelOneSample,   
            ChannelTwoSample => s_ChannelTwoSample   
        );

    -- DAC 

    -- ADC

    -- SYSTEM FSM

    -- LED MATRIX

    -- 7 SEG
    DISPLAY_7_SEG1 : entity work.bcd_to_7seg(dfl)
        port map(
            bcd => -- number to show
            seg => seg1
        );

    DISPLAY_7_SEG2 : entity work.bcd_to_7seg(dfl)   
        port map(
            bcd => -- number to show
            seg => seg2
        );

    DISPLAY_7_SEG3 : entity work.bcd_to_7seg(dfl)
        port map(
            bcd => -- number to show
            seg => seg3
        );

    DISPLAY_7_SEG4 : entity work.bcd_to_7seg(dfl)
        port map(
            bcd => -- number to show
            seg => seg4
        );
				

end architecture platform_independent;