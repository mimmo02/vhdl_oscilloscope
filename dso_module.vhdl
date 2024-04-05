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


begin

    -- implement your system here

    DISPLAY : entity work.display_module(platform_independent)
        port map(
            clk_148_5_MHz       => clk_148_5_MHz,
            reset               => reset,
        
            ChannelOneOn        => '0',
            ChannelTwoOn        => '0',
            ChannelOneDot       => '0',
            ChannelTwoDot       => '0', 
            ChannelOneSample    => "0000000000",
            ChannelTwoSample    => "0000000000",
            ChannelOneOffset    => "0000000000",
            ChannelTwoOffset    => "0000000000",
            TriggerLevel        => "0000000000",
            TriggerPoint        => "00000000000",
            TriggerChannelOne   => '0',

            RequestSample       => open,
            NextLine            => open,
            NextScreen          => open,

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

				

end architecture platform_independent;