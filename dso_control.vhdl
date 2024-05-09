-------------------------------------------------------------------------------
-- Title      : Module to 
-- Project    : BTE5024
-------------------------------------------------------------------------------
-- File       : dso_control.vhdl
-- Author     : Lohann Steiner  <steil18@bfh.ch>
-- Company    : BFH-EIT
-- Created    : 2024-03-26
-- Last update: 2024-04-28
-- Platform   : Intel Quartus Prime 18.1
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2024 BFH-EIT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-04-02  1.0      steil18	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dso_control is
    port (  clk_148_5_MHz   : in std_logic;
            reset           : in std_logic;
            btn_sel_channel     : in std_logic;
            btn_sel_parameter   : in std_logic;
            btn_sel_acq_mode    : in std_logic;
            btn_run             : in std_logic;
            btn_plus            : in std_logic;
            btn_minus           : in std_logic;

            Sel_Chan            : out std_logic_vector(1 downto 0);
            Sel_Para            : out std_logic_vector(2 downto 0);

            Offset_ch1          : out std_logic_vector(5 downto 0);        -- offset channel 1 signal
            Sig_amplitude_ch1   : out std_logic_vector(2 downto 0);        -- define amplitude of channel 1 signal
            ChannelOneOn        : out std_logic;                           -- Show channel 1
            ChannelOneDot       : out std_logic;                           -- If active, only the individual sample points are displayed for channel 1. Otherwise, a vertical line is drawn between sample n and sample n+1.

            Offset_ch2          : out std_logic_vector(5 downto 0);        -- offset channel 1 signal
            Sig_amplitude_ch2   : out std_logic_vector(2 downto 0);        -- define amplitude of channel 1 signal
            ChannelTwoOn        : out std_logic;                           -- Show channel 1
            ChannelTwoDot       : out std_logic;                           -- If active, only the individual sample points are displayed for channel 2. Otherwise, a vertical line is drawn between sample n and sample n+1.


            Trigger_ref         : out std_logic_vector(5 downto 0);        -- trigger level signal
            Trigger_pos         : out std_logic_vector(5 downto 0);        -- trigger position (from 0 to 1280 - middle at 640)
            Trigger_ch1         : out std_logic;                           -- trigger channel signal 1 = ch1 
            Trigger_on_rising   : out std_logic;                           -- trigger on rising edge

            TimeBase            : out std_logic_vector(2 downto 0));               -- time base signal (1 to 6 samples per pixel)

    


            
end entity dso_control;

architecture rtl of dso_control is
    type states is (ChanOne_Set, ChanOne_Rep, ChanOne_Amp, ChanOne_Offset, ChanTwo_Set, ChanTwo_Rep, ChanTwo_Amp, ChanTwo_Offset, Trigger_CH, Trigger_Posx, Trigger_Posy, Trigger_Decl, Base_Temp);
    signal state_reg, state_next : states;


    signal btn_channel_deb, btn_para_deb, btn_acq_deb, btn_run_deb, btn_plus_deb, btn_minus_deb : std_logic := '0';
    signal s_ChannelOneOn, s_ChannelOneDot, s_ChannelTwoOn, s_ChannelTwoDot, s_Trigger_ch1, s_Trigger_on_rising : std_logic := '0';
    signal s_Chan1_amp, s_Chan1_amp_next, s_Chan2_amp, s_Chan2_amp_next : unsigned(2 downto 0) := "001";
    signal s_Temp_Base, s_Temp_Base_next : unsigned(2 downto 0) := "001";
    signal s_Chan1_Offset, s_Chan1_Offset_next, s_Chan2_Offset, s_Chan2_Offset_next : unsigned(5 downto 0) := "000001";
    signal s_Trigg_Posx, s_Trigg_Posx_next : unsigned(5 downto 0) := "000001";
    signal s_Trigg_Posy, s_Trigg_Posy_next : unsigned(5 downto 0) := "000000";
    

begin
    debounce_inst_chan : entity work.debounce
        port map (
            clk_148_5_MHz => clk_148_5_MHz,
            in_btn => btn_sel_channel,
            out_btn => btn_channel_deb);

    debounce_inst_para : entity work.debounce
        port map (
            clk_148_5_MHz => clk_148_5_MHz,
            in_btn => btn_sel_parameter,
            out_btn => btn_para_deb);

    debounce_inst_acq : entity work.debounce
        port map (
            clk_148_5_MHz => clk_148_5_MHz,
            in_btn => btn_sel_acq_mode,
            out_btn => btn_acq_deb);
    
    debounce_inst_run : entity work.debounce
        port map (
            clk_148_5_MHz => clk_148_5_MHz,
            in_btn => btn_run,
            out_btn => btn_run_deb);

    debounce_inst_plus : entity work.debounce
        port map (
            clk_148_5_MHz => clk_148_5_MHz,
            in_btn => btn_plus,
            out_btn => btn_plus_deb);
    
    debounce_inst_minus : entity work.debounce
        port map (
            clk_148_5_MHz => clk_148_5_MHz,
            in_btn => btn_minus,
            out_btn => btn_minus_deb);
    
    reg : process (clk_148_5_MHz, reset) is
    begin
        if reset = '1' then
            state_reg <= ChanOne_Set;
            
        elsif rising_edge(clk_148_5_MHz) then
            state_reg <= state_next;
            s_Chan1_amp <= s_Chan1_amp_next;
            s_Chan2_amp <= s_Chan2_amp_next;
            s_Chan1_Offset <= s_Chan1_Offset_next;
            s_Chan2_Offset <= s_Chan2_Offset_next;
            s_Temp_Base <= s_Temp_Base_next;
            s_Trigg_Posx <= s_Trigg_Posx_next;
            s_Trigg_Posy <= s_Trigg_Posy_next;
        end if;
    end process reg;

    nsl : process (state_reg, btn_channel_deb, btn_para_deb) is
    begin
        -- avoid latches
        state_next <= state_reg;
        
        case state_reg is
            when ChanOne_Set =>
                Sel_Chan <= "01";
                Sel_Para <= "001";

                if btn_channel_deb = '1' then 
                    state_next <= Chantwo_Set;
                elsif btn_para_deb = '1' then 
                    state_next <= ChanOne_Rep;
                end if;

            when ChanOne_Rep =>
                Sel_Chan <= "01";
                Sel_Para <= "010";

                if btn_channel_deb = '1' then 
                    state_next <= Chantwo_Rep;
                elsif btn_para_deb = '1' then 
                    state_next <= ChanOne_Amp;
                end if;

            when ChanOne_Amp =>
                Sel_Chan <= "01";
                Sel_Para <= "011";

                if btn_channel_deb = '1' then 
                    state_next <= Chantwo_Amp;
                elsif btn_para_deb = '1' then 
                    state_next <= ChanOne_Offset;
                end if;
            
            when ChanOne_Offset =>
                Sel_Chan <= "01";
                Sel_Para <= "100";

                if btn_channel_deb = '1' then 
                    state_next <= ChanTwo_Offset;
                elsif btn_para_deb = '1' then 
                    state_next <= ChanOne_Set;
                end if;

            when ChanTwo_Set =>
                Sel_Chan <= "10";
                Sel_Para <= "001";

                if btn_channel_deb = '1' then 
                    state_next <= Trigger_CH;
                elsif btn_para_deb = '1' then 
                    state_next <= ChanTwo_Rep;
                end if;

            when ChanTwo_Rep =>
                Sel_Chan <= "10";
                Sel_Para <= "010";

                if btn_channel_deb = '1' then 
                    state_next <= Trigger_Posx;
                elsif btn_para_deb = '1' then 
                    state_next <= ChanTwo_Amp;
                end if;

            when ChanTwo_Amp =>
                Sel_Chan <= "10";
                Sel_Para <= "011";

                if btn_channel_deb = '1' then 
                    state_next <= Trigger_Posy;
                elsif btn_para_deb = '1' then 
                    state_next <= ChanTwo_Offset;
                end if;
            
            when ChanTwo_Offset =>
                Sel_Chan <= "10";
                Sel_Para <= "100";

                if btn_channel_deb = '1' then 
                    state_next <= Trigger_Decl;
                elsif btn_para_deb = '1' then 
                    state_next <= ChanTwo_Set;
                end if;
            
            when Trigger_CH =>
                Sel_Chan <= "11";
                Sel_Para <= "001";

                if btn_channel_deb = '1' then 
                    state_next <= ChanOne_Set;
                elsif btn_para_deb = '1' then 
                    state_next <= Trigger_Posx;
                end if;

            when Trigger_Posx =>
                Sel_Chan <= "11";
                Sel_Para <= "010";

                if btn_channel_deb = '1' then 
                    state_next <= ChanOne_Rep;
                elsif btn_para_deb = '1' then 
                    state_next <= Trigger_Posy;
                end if;

            when Trigger_Posy =>
                Sel_Chan <= "11";
                Sel_Para <= "011";

                if btn_channel_deb = '1' then 
                    state_next <= ChanOne_Amp;
                elsif btn_para_deb = '1' then 
                    state_next <= Trigger_Decl;
                end if;
            
            when Trigger_Decl =>
                Sel_Chan <= "11";
                Sel_Para <= "100";

                if btn_channel_deb = '1' then 
                    state_next <= ChanOne_Offset;
                elsif btn_para_deb = '1' then 
                    state_next <=  Base_Temp;
                end if;
            
            when Base_Temp =>
                Sel_Chan <= "11";
                Sel_Para <= "101";

                if btn_channel_deb = '1' then 
                    state_next <= ChanOne_Set;
                elsif btn_para_deb = '1' then 
                    state_next <= Trigger_CH;
                end if;
            
            when others =>
                state_next <= ChanOne_Set;
        end case;
    end process nsl;


    par : process(state_reg, btn_minus_deb, btn_plus_deb, s_Chan1_amp, s_Chan2_amp, s_Chan1_Offset, s_Chan2_Offset, s_Temp_Base, s_Trigg_Posx, s_Trigg_Posy) is
    begin

        s_Chan1_amp_next <= s_Chan1_amp;
        s_Chan2_amp_next <= s_Chan2_amp;
        s_Chan1_Offset_next <= s_Chan1_Offset;
        s_Chan2_Offset_next <= s_Chan2_Offset;
        s_Temp_Base_next <= s_Temp_Base;
        s_Trigg_Posx_next <= s_Trigg_Posx;
        s_Trigg_Posy_next <= s_Trigg_Posy;

        case state_reg is
            when ChanOne_Set =>
                if btn_minus_deb = '1' then 
                    s_ChannelOneOn <= '0';
                elsif btn_plus_deb = '1' then 
                    s_ChannelOneOn <= '1';
                end if;

            when ChanOne_Rep =>
                if btn_minus_deb = '1' then 
                    s_ChannelOneDot <= '0';
                elsif btn_plus_deb = '1' then 
                    s_ChannelOneDot <= '1';
                end if;

            when ChanOne_Amp =>                
                if btn_minus_deb = '1'  and s_Chan1_amp > "000" then 
                    s_Chan1_amp_next <= s_Chan1_amp - 1;
                elsif btn_plus_deb = '1'  and s_Chan1_amp < "101" then 
                    s_Chan1_amp_next <= s_Chan1_amp + 1;
                end if;

            
            when ChanOne_Offset =>
                if btn_minus_deb = '1' and s_Chan1_Offset > "000000" then 
                    s_Chan1_Offset_next <= s_Chan1_Offset - 1;
                elsif btn_plus_deb = '1'and s_Chan1_Offset < "101101" then 
                    s_Chan1_Offset_next <= s_Chan1_Offset + 1;
                end if;

            when ChanTwo_Set =>
                if btn_minus_deb = '1' then 
                    s_ChannelTwoOn <= '0';
                elsif btn_plus_deb = '1' then 
                    s_ChannelTwoOn <= '1';
                end if;

            when ChanTwo_Rep =>                
                if btn_minus_deb = '1' then 
                    s_ChannelTwoDot <= '0';
                elsif btn_plus_deb = '1' then 
                    s_ChannelTwoDot <= '1';
                end if;

            when ChanTwo_Amp =>
                if btn_minus_deb = '1' and s_Chan2_amp > "000" then 
                    s_Chan2_amp_next <= s_Chan2_amp - 1;
                elsif btn_plus_deb = '1' and s_Chan2_amp < "101" then 
                    s_Chan2_amp_next <= s_Chan2_amp + 1;
                end if;


            when ChanTwo_Offset =>
                if btn_minus_deb = '1' and s_Chan2_Offset > "000000" then 
                    s_Chan2_Offset_next <= s_Chan2_Offset - 1;
                elsif btn_plus_deb = '1' and s_Chan2_Offset < "101101" then 
                    s_Chan2_Offset_next <= s_Chan2_Offset + 1;
                end if;

            
            when Trigger_CH =>
                if btn_minus_deb = '1' then 
                    s_Trigger_ch1 <= '0';
                elsif btn_plus_deb = '1' then 
                    s_Trigger_ch1 <= '1';
                end if;

            when Trigger_Posx =>
                if btn_minus_deb = '1' and s_Trigg_Posx > "000000"  then 
                    s_Trigg_Posx_next <= s_Trigg_Posx - 1;
                elsif btn_plus_deb = '1' and s_Trigg_Posx < "101000" then 
                    s_Trigg_Posx_next <= s_Trigg_Posx + 1;
                end if;

            when Trigger_Posy =>
                if btn_minus_deb = '1' and s_Trigg_Posy > "000000" then 
                    s_Trigg_Posy_next <= s_Trigg_Posy - 1;
                elsif btn_plus_deb = '1' and s_Trigg_Posy < "101101" then 
                    s_Trigg_Posy_next <= s_Trigg_Posy + 1;
                end if;
            
            when Trigger_Decl =>
                if btn_minus_deb = '1' then 
                    s_Trigger_on_rising <= '0';
                elsif btn_plus_deb = '1' then 
                    s_Trigger_on_rising <= '1';
                end if;
            
            when Base_Temp =>
                if btn_minus_deb = '1' and s_Temp_Base > "001" then 
                    s_Temp_Base_next <= s_Temp_Base - 1;
                elsif btn_plus_deb = '1' and s_Temp_Base < "110" then 
                    s_Temp_Base_next <= s_Temp_Base + 1;
                end if;

            when others =>
               
        end case;
    end process par;

    Offset_ch1 <= std_logic_vector(s_Chan1_Offset);
    Sig_amplitude_ch1 <= std_logic_vector(s_Chan1_amp);

    Offset_ch2 <= std_logic_vector(s_Chan2_Offset);
    Sig_amplitude_ch2 <= std_logic_vector(s_Chan2_amp);

    Trigger_ref <= std_logic_vector(s_Trigg_Posy);
    Trigger_pos <= std_logic_vector(s_Trigg_Posx);

    TimeBase <= std_logic_vector(s_Temp_Base);

    ChannelOneOn <= s_ChannelOneOn;
    ChannelOneDot <= s_ChannelOneDot;

    ChannelTwoOn <= s_ChannelTwoOn;
    ChannelTwoDot <= s_ChannelTwoDot;

    Trigger_ch1 <= s_Trigger_ch1;
    Trigger_on_rising <= s_Trigger_on_rising;



end architecture;