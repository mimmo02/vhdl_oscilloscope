library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_generator is
    port (  clk_148_5_MHz   : in std_logic;
            reset           : in std_logic;
            
            nCS_DA2         : out std_logic;
            D0_DA2          : out std_logic;
            D1_DA2          : out std_logic;
            SCK_DA2         : out std_logic);
end entity test_generator;

architecture platform_independent of test_generator is

    signal s_counter : unsigned(10 downto 0);
    signal s_start : std_logic;
    signal s_data : std_logic_vector(19 downto 0);

begin

    s_start <=  '1' when s_counter = 0 else
                '0';

    -- generate DAC sampling frequency of 125kHz
    makeCounter : process (clk_148_5_MHz, reset) is
    begin
        if reset = '1' then
            s_counter <= to_unsigned(1188,11);
        elsif rising_edge(clk_148_5_MHz) then
            if s_start = '1' then
                s_counter <= to_unsigned(1188,11);
            else
                s_counter <= s_counter - 1;
            end if;
        end if;
    end process makeCounter;

    -- instantiate components
    test_signal_inst : entity work.test_signal
    port map (
        clk_148_5_MHz => clk_148_5_MHz,
        reset => reset,
        next_sample => s_start,
        address => open,
        data => s_data
    );
  
    dac_spi_inst : entity work.dac_spi
    port map (
        clk_148_5_MHz => clk_148_5_MHz,
        reset => reset,
        start => s_start,
        data0 => s_data(19 downto 10),
        data1 => s_data(9 downto 0),
        nCS => nCS_DA2,
        D0 => D0_DA2,
        D1 => D1_DA2,
        SCK => SCK_DA2
    );

end architecture;