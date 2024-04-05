library ieee,altera_mf;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_screen is
    port (  clk_148_5_MHz   : in  std_logic;
            reset           : in  std_logic;

            HSYNC           : out std_logic;
            VSYNC           : out std_logic;
            RED             : out std_logic;
            GREEN           : out std_logic;
            BLUE            : out std_logic;
            HDMI_CLOCK      : out std_logic;
            ACTIVE_VIDEO    : out std_logic);
end test_screen;

architecture platform_independant of test_screen is

    signal s_ChannelOneSample   : std_logic_vector(9 downto 0);
    signal s_ChannelTwoSample   : std_logic_vector(9 downto 0);
    signal s_ChannelOneOffset   : std_logic_vector(9 downto 0);
    signal s_ChannelTwoOffset   : std_logic_vector(9 downto 0);
    signal s_TriggerPoint       : unsigned(10 downto 0);
    signal s_TriggerPdir        : std_logic;
    signal s_TriggerLev         : unsigned(9 downto 0);
    signal s_TriggerLdir        : std_logic;
    signal s_channelOn          : unsigned(3 downto 0);
    signal s_sampleCount        : unsigned(9 downto 0);
    signal s_RequestSample      : std_logic;
    signal s_NextLine           : std_logic;
    signal s_NextScreen         : std_logic;

begin

    ----------------------------------------------------------------
    ---                                                          ---
    --- Here the Trigger Point walking is defined                ---
    ---                                                          ---
    ----------------------------------------------------------------
    makeTriggerPdir : process (reset, clk_148_5_MHz)
    begin
        if reset = '1' then
            s_TriggerPdir <='1';
        elsif rising_edge(clk_148_5_MHz) then
            if (s_TriggerPoint = to_unsigned(1,11) and s_TriggerPdir = '0') then 
                s_TriggerPdir <='1';
            elsif s_TriggerPoint = to_unsigned(1280,11) and s_TriggerPdir = '1' then 
                s_TriggerPdir <='0';
            end if;
        end if;
    end process makeTriggerPdir;

    MakeTriggerPoint : process (reset, clk_148_5_MHz)
    begin
        if reset = '1' then
            s_TriggerPoint <= to_unsigned(1,11);
        elsif rising_edge(clk_148_5_MHz) then
            if s_NextScreen = '1' then
                if s_TriggerPdir = '1' then
                    s_TriggerPoint <= s_TriggerPoint + 1;
                else
                    s_TriggerPoint <= s_TriggerPoint - 1;
                end if;
            end if;
        end if;
    end process MakeTriggerPoint;

    makeTriggerLdir : process (reset, clk_148_5_MHz)
    begin
        if reset = '1' then
            s_channelOn <= (others => '0');
            s_TriggerLdir <= '1';
        elsif rising_edge(clk_148_5_MHz) then
            if s_TriggerLev = to_unsigned(1,10) and s_TriggerLdir = '0' then 
                s_TriggerLdir <='1';
                s_channelOn <= s_channelOn + 1;
            elsif s_TriggerLev = to_unsigned(720,10) and s_TriggerLdir = '1' then 
                s_TriggerLdir <='0';
                s_channelOn <= s_channelOn + 1;
            end if;
        end if;
    end process makeTriggerLdir;

    MakeTriggerL : process (reset, clk_148_5_MHz)
    begin
        if reset = '1' then
            s_TriggerLev <= to_unsigned(1,10);
        elsif rising_edge(clk_148_5_MHz) then
            if s_NextScreen = '1' then
                if s_TriggerLdir = '1' then
                    s_TriggerLev <= s_TriggerLev + 1;
                else
                    s_TriggerLev <= s_TriggerLev - 1;
                end if;
            end if;
        end if;
    end process MakeTriggerL;

    MakeSampleCount : process (reset, clk_148_5_MHz)
    begin
        if reset = '1' then
            s_sampleCount <= to_unsigned(0,10);
        elsif rising_edge(clk_148_5_MHz) then
            if (s_sampleCount >= to_unsigned(240,10) and s_RequestSample = '1') or s_NextLine = '1' then
                s_sampleCount <= to_unsigned(0,10);
            elsif s_RequestSample = '1' then 
                s_sampleCount <= s_sampleCount + 3;
            end if;
        end if;
    end process MakeSampleCount;

    ----------------------------------------------------------------
    ---                                                          ---
    --- Here the channel samples and offsets are assigned         ---
    ---                                                          ---
    ----------------------------------------------------------------
    s_ChannelOneSample <= std_logic_vector(s_TriggerLev + s_sampleCount);
    s_ChannelTwoSample <= std_logic_vector(to_unsigned(720,10) - s_TriggerLev + to_unsigned(300,10) - s_sampleCount);
    s_ChannelOneOffset <= std_logic_vector(s_TriggerLev);
    s_ChannelTwoOffset <= std_logic_vector(to_unsigned(720,10) - s_TriggerLev);

    ----------------------------------------------------------------
    ---                                                          ---
    --- Here the components are mapped                           ---
    ---                                                          ---
    ----------------------------------------------------------------
    display_module_inst : entity work.display_module(platform_independent)
        port map (
            clk_148_5_MHz => clk_148_5_MHz,
            reset => reset,
            ChannelOneOn => s_channelOn(0),
            ChannelTwoOn => s_channelOn(1),
            ChannelOneDot => s_channelOn(2),
            ChannelTwoDot => s_channelOn(3),
            ChannelOneSample => s_ChannelOneSample,
            ChannelTwoSample => s_ChannelTwoSample,
            ChannelOneOffset => s_ChannelOneOffset,
            ChannelTwoOffset => s_ChannelTwoOffset,
            TriggerLevel => std_logic_vector(s_TriggerLev),
            TriggerPoint => std_logic_vector(s_TriggerPoint),
            TriggerChannelOne => s_TriggerPdir,
            RequestSample => s_RequestSample,
            NextLine => s_NextLine,
            NextScreen => s_NextScreen,
            HSYNC => HSYNC,
            VSYNC => VSYNC,
            RED => RED,
            GREEN => GREEN,
            BLUE => BLUE,
            HDMI_CLOCK => HDMI_CLOCK,
            ACTIVE_VIDEO => ACTIVE_VIDEO
        );

end platform_independant;
