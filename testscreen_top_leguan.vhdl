library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

entity testscreen_top_leguan is
    port (  clk             : in std_logic;
            n_reset         : in std_logic;

            HSYNC           : out std_logic;
            VSYNC           : out std_logic;
            RED             : out std_logic;
            GREEN           : out std_logic;
            BLUE            : out std_logic;
            HDMI_CLOCK      : out std_logic;
            ACTIVE_VIDEO    : out std_logic);
end entity;

architecture rtl of testscreen_top_leguan is

    COMPONENT altpll
	GENERIC (
		bandwidth_type		: STRING;
		clk0_divide_by		: NATURAL;
		clk0_duty_cycle		: NATURAL;
		clk0_multiply_by		: NATURAL;
		clk0_phase_shift		: STRING;
		compensate_clock		: STRING;
		inclk0_input_frequency		: NATURAL;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_type		: STRING;
		operation_mode		: STRING;
		pll_type		: STRING;
		port_activeclock		: STRING;
		port_areset		: STRING;
		port_clkbad0		: STRING;
		port_clkbad1		: STRING;
		port_clkloss		: STRING;
		port_clkswitch		: STRING;
		port_configupdate		: STRING;
		port_fbin		: STRING;
		port_inclk0		: STRING;
		port_inclk1		: STRING;
		port_locked		: STRING;
		port_pfdena		: STRING;
		port_phasecounterselect		: STRING;
		port_phasedone		: STRING;
		port_phasestep		: STRING;
		port_phaseupdown		: STRING;
		port_pllena		: STRING;
		port_scanaclr		: STRING;
		port_scanclk		: STRING;
		port_scanclkena		: STRING;
		port_scandata		: STRING;
		port_scandataout		: STRING;
		port_scandone		: STRING;
		port_scanread		: STRING;
		port_scanwrite		: STRING;
		port_clk0		: STRING;
		port_clk1		: STRING;
		port_clk2		: STRING;
		port_clk3		: STRING;
		port_clk4		: STRING;
		port_clk5		: STRING;
		port_clkena0		: STRING;
		port_clkena1		: STRING;
		port_clkena2		: STRING;
		port_clkena3		: STRING;
		port_clkena4		: STRING;
		port_clkena5		: STRING;
		port_extclk0		: STRING;
		port_extclk1		: STRING;
		port_extclk2		: STRING;
		port_extclk3		: STRING;
		self_reset_on_loss_lock		: STRING;
		width_clock		: NATURAL
	);
	PORT (
        areset	: IN STD_LOGIC ;
        inclk	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        clk	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        locked	: OUT STD_LOGIC 
	);
	END COMPONENT;

    -- signals
    signal s_reset          : std_logic;
    signal s_clk_148_5_MHz  : std_logic;
    signal s_inClocks       : std_logic_vector(1 downto 0);
    signal s_outClocks      : std_logic_vector(4 downto 0);
    signal s_locked         : std_logic;

begin

    -- toggle active low input signals
    s_reset <= not(n_reset);

    -- wire signals
    s_inClocks <= '0' & clk;
    s_clk_148_5_MHz <= s_outClocks(0);

    -- instantiate components
    test_screen_inst : entity work.test_screen
    port map (
        clk_148_5_MHz => s_clk_148_5_MHz,
        reset => s_reset,
        HSYNC => HSYNC,
        VSYNC => VSYNC,
        RED => RED,
        GREEN => GREEN,
        BLUE => BLUE,
        HDMI_CLOCK => HDMI_CLOCK,
        ACTIVE_VIDEO => ACTIVE_VIDEO
    );

    altpll_component : altpll
        GENERIC MAP (
            bandwidth_type => "AUTO",
            clk0_divide_by => 1,
            clk0_duty_cycle => 50,
            clk0_multiply_by => 2,
            clk0_phase_shift => "0",
            compensate_clock => "clk0",
            inclk0_input_frequency => 13468,
            intended_device_family => "Cyclone 10 LP",
            lpm_hint => "CBX_MODULE_PREFIX=alt_pll",
            lpm_type => "altpll",
            operation_mode => "NORMAL",
            pll_type => "AUTO",
            port_activeclock => "PORT_UNUSED",
            port_areset => "PORT_USED",
            port_clkbad0 => "PORT_UNUSED",
            port_clkbad1 => "PORT_UNUSED",
            port_clkloss => "PORT_UNUSED",
            port_clkswitch => "PORT_UNUSED",
            port_configupdate => "PORT_UNUSED",
            port_fbin => "PORT_UNUSED",
            port_inclk0 => "PORT_USED",
            port_inclk1 => "PORT_UNUSED",
            port_locked => "PORT_USED",
            port_pfdena => "PORT_UNUSED",
            port_phasecounterselect => "PORT_UNUSED",
            port_phasedone => "PORT_UNUSED",
            port_phasestep => "PORT_UNUSED",
            port_phaseupdown => "PORT_UNUSED",
            port_pllena => "PORT_UNUSED",
            port_scanaclr => "PORT_UNUSED",
            port_scanclk => "PORT_UNUSED",
            port_scanclkena => "PORT_UNUSED",
            port_scandata => "PORT_UNUSED",
            port_scandataout => "PORT_UNUSED",
            port_scandone => "PORT_UNUSED",
            port_scanread => "PORT_UNUSED",
            port_scanwrite => "PORT_UNUSED",
            port_clk0 => "PORT_USED",
            port_clk1 => "PORT_UNUSED",
            port_clk2 => "PORT_UNUSED",
            port_clk3 => "PORT_UNUSED",
            port_clk4 => "PORT_UNUSED",
            port_clk5 => "PORT_UNUSED",
            port_clkena0 => "PORT_UNUSED",
            port_clkena1 => "PORT_UNUSED",
            port_clkena2 => "PORT_UNUSED",
            port_clkena3 => "PORT_UNUSED",
            port_clkena4 => "PORT_UNUSED",
            port_clkena5 => "PORT_UNUSED",
            port_extclk0 => "PORT_UNUSED",
            port_extclk1 => "PORT_UNUSED",
            port_extclk2 => "PORT_UNUSED",
            port_extclk3 => "PORT_UNUSED",
            self_reset_on_loss_lock => "OFF",
            width_clock => 5
        )
        PORT MAP (
            areset => s_reset,
            inclk => s_inClocks,
            clk => s_outClocks,
            locked => s_locked
        );

end architecture rtl;