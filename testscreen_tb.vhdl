library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------

entity testscreen_tb is

end entity testscreen_tb;

-------------------------------------------------------------------------

architecture bench of testscreen_tb is

    constant CLK_PERIOD : delay_length := 20ns;

    -- component ports
    signal clk : std_logic := '1';
    signal reset : std_logic;
    signal HSYNC : std_logic;
    signal VSYNC : std_logic;
    signal RED : std_logic;
    signal GREEN : std_logic;
    signal BLUE : std_logic;
    signal HDMI_CLOCK : std_logic;
    signal ACTIVE_VIDEO : std_logic;

begin

    -- component instantiation
    DUT : entity work.test_screen
    port map (
        clk_148_5_MHz => clk,
        reset => reset,
        HSYNC => HSYNC,
        VSYNC => VSYNC,
        RED => RED,
        GREEN => GREEN,
        BLUE => BLUE,
        HDMI_CLOCK => HDMI_CLOCK,
        ACTIVE_VIDEO => ACTIVE_VIDEO
    );

    -- clock and reset generation
    clk <= not clk after 0.5 * CLK_PERIOD;
    reset <= '0', '1' after 0.25 * CLK_PERIOD, '0' after 1.25 * CLK_PERIOD;

end architecture bench;

-------------------------------------------------------------------------

