library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_module is
    port (  clk_148_5_MHz   : in std_logic;
            reset           : in std_logic;

            sampleValid     : out std_logic;
            sampleChannel1  : out std_logic_vector(11 downto 0);
            sampleChannel2  : out std_logic_vector(11 downto 0);

            nCS_AD1         : out std_logic;
            SCK_AD1         : out std_logic;
            D0_AD1          : in std_logic;
            D1_AD1          : in std_logic);
end entity adc_module;

architecture platform_independent of adc_module is

begin

    -- implement your system here

end architecture platform_independent;