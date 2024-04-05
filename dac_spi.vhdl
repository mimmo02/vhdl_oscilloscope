library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_spi is
    port (  clk_148_5_MHz   : in std_logic;
            reset           : in std_logic;
            
            start   : in std_logic;
            data0   : in std_logic_vector(9 downto 0);
            data1   : in std_logic_vector(9 downto 0);
            
            nCS     : out std_logic;
            D0      : out std_logic;
            D1      : out std_logic;
            SCK     : out std_logic);
end entity dac_spi;

architecture platform_independent of dac_spi is

    type states is (IDLE, SPI_WAIT, SPI_SHIFT);
    signal state_reg, state_next : states;

    signal shift_reg_D0, shift_reg_D0_next : std_logic_vector(15 downto 0);
    signal shift_reg_D1, shift_reg_D1_next : std_logic_vector(15 downto 0);
    signal shift_counter, shift_counter_next : unsigned(4 downto 0);
    signal clk_div : unsigned(1 downto 0);

begin

    -- generate SPI tick frequency for SCK of 37.125 MHz (=> 18.5625 MHz SCK clock frequency)
    clkDiv : process (clk_148_5_MHz, reset) is
    begin
        if reset = '1' then
            clk_div <= (others => '1');
        elsif rising_edge(clk_148_5_MHz) then
				if start = '1' then
					clk_div <= (others => '1');
				else
					clk_div <= clk_div - 1;
				end if;
        end if;
    end process clkDiv;

    reg : process (clk_148_5_MHz, reset) is
    begin
        if reset = '1' then
            state_reg <= IDLE;
            shift_reg_D0 <= (others => '0');
            shift_reg_D1 <= (others => '0');
            shift_counter <= (others => '0');
        elsif rising_edge(clk_148_5_MHz) then
            state_reg <= state_next;
            shift_reg_D0 <= shift_reg_D0_next;
            shift_reg_D1 <= shift_reg_D1_next;
            shift_counter <= shift_counter_next;
        end if;
    end process reg;

    nsl : process (state_reg, start, data0, data1, clk_div, shift_counter, shift_reg_D0, shift_reg_D1) is
    begin
        -- avoid latches
        state_next <= state_reg;
        shift_reg_D0_next <= shift_reg_D0;
        shift_reg_D1_next <= shift_reg_D1;
        shift_counter_next <= shift_counter;

        case state_reg is
            when IDLE =>
                if start = '1' then 
                    state_next <= SPI_WAIT;
                    shift_reg_D0_next <= "0000" & data0 & "00";
                    shift_reg_D1_next <= "0000" & data1 & "00";
                    shift_counter_next <= to_unsigned(1, 5);
                end if;
            when SPI_WAIT =>
                if clk_div = 0 then
                    state_next <= SPI_SHIFT;
                end if;
            when SPI_SHIFT =>
                if clk_div = 0 then
                    if shift_counter = 16 then
                        state_next <= IDLE;
                    else
                        state_next <= SPI_WAIT;
                        shift_reg_D0_next <= shift_reg_D0(14 downto 0) & '0';
                        shift_reg_D1_next <= shift_reg_D1(14 downto 0) & '0';
                        shift_counter_next <= shift_counter + 1;
                    end if;
                end if;
            when others =>
                state_next <= IDLE;
        end case;
    end process nsl;

    -- output signals
    nCS <=  '1' when state_reg = IDLE else
            '0';

    SCK <=  '0' when state_reg = SPI_SHIFT else
            '1';

    D0 <= shift_reg_D0(15);
    D1 <= shift_reg_D1(15);
    
end architecture;