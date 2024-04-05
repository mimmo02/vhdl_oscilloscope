library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

use work.led_matrix_pkg.all;

entity dso_top_leguan is
    port (  clk                 : in std_logic;
            n_reset             : in std_logic;

            -- buttons
            n_btn_sel_channel   : in std_logic;
            n_btn_sel_parameter : in std_logic;
            n_btn_sel_acq_mode  : in std_logic;
            n_btn_run           : in std_logic;
            n_btn_plus          : in std_logic;
            n_btn_minus         : in std_logic;
            
            -- pmods
            HSYNC               : out std_logic;
            VSYNC               : out std_logic;
            RED                 : out std_logic;
            GREEN               : out std_logic;
            BLUE                : out std_logic;
            HDMI_CLOCK          : out std_logic;
            ACTIVE_VIDEO        : out std_logic;

            nCS_DA2             : out std_logic;
            D0_DA2              : out std_logic;
            D1_DA2              : out std_logic;
            SCK_DA2             : out std_logic;

            nCS_AD1             : out std_logic;
            D0_AD1              : in std_logic;
            D1_AD1              : in std_logic;
            SCK_AD1             : out std_logic;

            -- ssd
            n_seg1              : out std_logic_vector(6 downto 0);
            n_seg2              : out std_logic_vector(6 downto 0);
            n_seg3              : out std_logic_vector(6 downto 0);
            n_seg4              : out std_logic_vector(6 downto 0);
            
            -- led matrix
            columnAddress       : out std_logic_vector(3 downto 0);
            rowRedLeds_b        : out std_logic_vector(9 downto 0);
            rowGreenLeds_b      : out std_logic_vector(9 downto 0);
            rowBlueLeds_b       : out std_logic_vector(9 downto 0));
end entity;

architecture rtl of dso_top_leguan is

    component RGBArrayColumnScanning
        generic (
            singleColor : std_logic;
            singleColorValueRGB : std_logic_vector( 2 downto 0 )
        );
        port (
            clk_148_5_MHz : in std_logic;
            internalRedLeds : in std_logic_vector( 109 downto 0 );
            internalBlueLeds : in std_logic_vector( 109 downto 0 );
            internalGreenLeds : in std_logic_vector( 109 downto 0 );
            columnAddress : out std_logic_vector( 3 downto 0 );
            rowRedLeds_b : out std_logic_vector( 9 downto 0 );
            rowGreenLeds_b : out std_logic_vector( 9 downto 0 );
            rowBlueLeds_b : out std_logic_vector( 9 downto 0 )
        );
    end component;

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

    signal s_locked             : std_logic;
    signal s_inClocks           : std_logic_vector( 1 downto 0 );
    signal s_outClocks          : std_logic_vector( 4 downto 0 );
    signal s_clk_148_5_MHz      : std_logic;

    signal s_reset              : std_logic;
    signal s_btn_sel_channel    : std_logic;
    signal s_btn_sel_parameter  : std_logic;
    signal s_btn_sel_acq_mode   : std_logic;
    signal s_btn_run            : std_logic;
    signal s_btn_plus           : std_logic;
    signal s_btn_minus          : std_logic;

    signal s_seg1               : std_logic_vector(6 downto 0);
    signal s_seg2               : std_logic_vector(6 downto 0);
    signal s_seg3               : std_logic_vector(6 downto 0);
    signal s_seg4               : std_logic_vector(6 downto 0);

    signal s_leds               : std_logic_vector(109 downto 0);
    signal s_led_matrix         : led_array;

begin

    -- toggle active low input signals
    s_reset             <= not(n_reset);
    s_btn_sel_channel   <= not(n_btn_sel_channel);
    s_btn_sel_parameter <= not(n_btn_sel_parameter);
    s_btn_sel_acq_mode  <= not(n_btn_sel_acq_mode);
    s_btn_run           <= not(n_btn_run);
    s_btn_plus          <= not(n_btn_plus);
    s_btn_minus         <= not(n_btn_minus);

    -- active low output signals
    n_seg1 <= not(s_seg1);
    n_seg2 <= not(s_seg2);
    n_seg3 <= not(s_seg3);
    n_seg4 <= not(s_seg4);

    -- convert led matrix array to a single vector
    process (s_led_matrix)
    begin
        for i in 0 to LED_MATRIX_COLS - 1 loop
            for j in 0 to LED_MATRIX_ROWS -1 loop
                s_leds(i * LED_MATRIX_ROWS + j) <= s_led_matrix(j)(i);
            end loop;        
        end loop;
    end process;

    -- wire signals
    s_inClocks <= '0' & clk;
    s_clk_148_5_MHz <= s_outClocks(0);

    -- instantiate components
    dso_module_inst : entity work.dso_module
    port map (
        clk_148_5_MHz => s_clk_148_5_MHz,
        reset => s_reset,
        btn_sel_channel => s_btn_sel_channel,
        btn_sel_parameter => s_btn_sel_parameter,
        btn_sel_acq_mode => s_btn_sel_acq_mode,
        btn_run => s_btn_run,
        btn_plus => s_btn_plus,
        btn_minus => s_btn_minus,
        HSYNC => HSYNC,
        VSYNC => VSYNC,
        RED => RED,
        GREEN => GREEN,
        BLUE => BLUE,
        HDMI_CLOCK => HDMI_CLOCK,
        ACTIVE_VIDEO => ACTIVE_VIDEO,
        nCS_DA2 => nCS_DA2,
        D0_DA2 => D0_DA2,
        D1_DA2 => D1_DA2,
        SCK_DA2 => SCK_DA2,
        nCS_AD1 => nCS_AD1,
        D0_AD1 => D0_AD1,
        D1_AD1 => D1_AD1,
        SCK_AD1 => SCK_AD1,
        seg1 => s_seg1,
        seg2 => s_seg2,
        seg3 => s_seg3,
        seg4 => s_seg4,
        led_matrix => s_led_matrix
    );

    RGBArrayColumnScanning_inst : entity work.RGBArrayColumnScanning
    generic map (
        singleColor => '1',
        singleColorValueRGB => "100"
    )
    port map (
        clk_148_5_MHz => s_clk_148_5_MHz,
        internalRedLeds => s_leds,
        internalBlueLeds => s_leds,
        internalGreenLeds => s_leds,
        columnAddress => columnAddress,
        rowRedLeds_b => rowRedLeds_b,
        rowGreenLeds_b => rowGreenLeds_b,
        rowBlueLeds_b => rowBlueLeds_b
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