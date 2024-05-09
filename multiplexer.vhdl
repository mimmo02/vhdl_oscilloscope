-------------------------------------------------------------------------------
-- Title      : Module to choice witch param is display
-- Project    : BTE5024
-------------------------------------------------------------------------------
-- File       : multiplexer.vhdl
-- Author     : Lohann Steiner  <steil18@bfh.ch>
-- Company    : BFH-EIT
-- Created    : 2024-04-30
-- Last update: 2024-04-30
-- Platform   : Intel Quartus Prime 18.1
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2024 BFH-EIT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-04-30  1.0      steil18	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.led_matrix_pkg.all;

entity multiplexer is
    port (  clk_148_5_MHz       : in std_logic;
            Sel_Chan            : in std_logic_vector(1 downto 0);

            Offset_ch1          : in std_logic_vector(5 downto 0);        -- offset channel 1 signal
            Sig_amplitude_ch1   : in std_logic_vector(2 downto 0);        -- define amplitude of channel 1 signal
            ChannelOneOn        : in std_logic;                           -- Show channel 1
            ChannelOneDot       : in std_logic;                           -- If active, only the individual sample points are displayed for channel 1. Otherwise, a vertical line is drawn between sample n and sample n+1.

            Offset_ch2          : in std_logic_vector(5 downto 0);        -- offset channel 1 signal
            Sig_amplitude_ch2   : in std_logic_vector(2 downto 0);        -- define amplitude of channel 1 signal
            ChannelTwoOn        : in std_logic;                           -- Show channel 1
            ChannelTwoDot       : in std_logic;                           -- If active, only the individual sample points are displayed for channel 2. Otherwise, a vertical line is drawn between sample n and sample n+1.


            Trigger_ref         : in std_logic_vector(5 downto 0);        -- trigger level signal
            Trigger_pos         : in std_logic_vector(5 downto 0);        -- trigger position (from 0 to 1280 - middle at 640)
            Trigger_ch1         : in std_logic;                           -- trigger channel signal 1 = ch1 
            Trigger_on_rising   : in std_logic;                           -- trigger on rising edge

            TimeBase            : in std_logic_vector(2 downto 0);        -- time base signal (1 to 6 samples per pixel)

            
            matrix_out          : out led_array);

            
end entity multiplexer;

architecture mux of multiplexer is
    signal s_temp : led_array;
    
begin
    process(clk_148_5_MHz, Sel_Chan)
    begin
        if rising_edge(clk_148_5_MHz) then
            case Sel_Chan is
                when "01" => 
                    s_temp(0)(0 to 10) <= (others => ChannelOneOn);
                    s_temp(1)(0 to 10) <= (others => '0');
                    s_temp(2)(0 to 10) <= (others => ChannelOneDot);
                    s_temp(3)(0 to 10) <= (others => '0');
                    s_temp(4)(0 to 10) <= "00000000" & Sig_amplitude_ch1;
                    s_temp(5)(0 to 10) <= (others => '0');
                    s_temp(6)(0 to 10) <= "00000" & Offset_ch1;
                    s_temp(7)(0 to 10) <= (others => '0');
                    s_temp(8)(0 to 10) <= (others => '0');
                    s_temp(9)(0 to 10) <= (others => '0');
                    
                when "10" => 
                    s_temp(0)(0 to 10) <= (others => ChannelTwoOn);
                    s_temp(1)(0 to 10) <= (others => '0');
                    s_temp(2)(0 to 10) <= (others => ChannelTwoDot);
                    s_temp(3)(0 to 10) <= (others => '0');
                    s_temp(4)(0 to 10) <= "00000000" & Sig_amplitude_ch2;
                    s_temp(5)(0 to 10) <= (others => '0');
                    s_temp(6)(0 to 10) <= "00000" & Offset_ch2;
                    s_temp(7)(0 to 10) <= (others => '0');
                    s_temp(8)(0 to 10) <= (others => '0');
                    s_temp(9)(0 to 10) <= (others => '0');

                when "11" =>
                    s_temp(0)(0 to 10) <= (others => Trigger_ch1);
                    s_temp(1)(0 to 10) <= (others => '0');
                    s_temp(2)(0 to 10) <= "00000" & Trigger_pos;
                    s_temp(3)(0 to 10) <= (others => '0');
                    s_temp(4)(0 to 10) <= "00000" & Trigger_ref;
                    s_temp(5)(0 to 10) <= (others => '0');
                    s_temp(6)(0 to 10) <= (others => Trigger_on_rising);
                    s_temp(7)(0 to 10) <= (others => '0');
                    s_temp(8)(0 to 10) <= "00000000" & TimeBase;
                    s_temp(9)(0 to 10) <= (others => '0');

                when others =>
                    s_temp(0)(0 to 10) <= (others => '0');
                    s_temp(1)(0 to 10) <= (others => '0');
                    s_temp(2)(0 to 10) <= (others => '0');
                    s_temp(3)(0 to 10) <= (others => '0');
                    s_temp(4)(0 to 10) <= (others => '0');
                    s_temp(5)(0 to 10) <= (others => '0');
                    s_temp(6)(0 to 10) <= (others => '0');
                    s_temp(7)(0 to 10) <= (others => '0');
                    s_temp(8)(0 to 10) <= (others => '0');
                    s_temp(9)(0 to 10) <= (others => '0');
            end case;

            matrix_out <= s_temp;
        
        end if;
    end process;
end mux;