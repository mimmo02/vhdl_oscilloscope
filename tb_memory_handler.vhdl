---------------------------------------------------------------------------------------------------------------
-- File: tb_memory_handler.vhdl
-- Author: Domenico Aquilino <aquid1@bfh.ch>
-- Date: 2024-04-19
-- Version: 1.0

-- description: Test bench for the memory_handler module.
---------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memory_handler is
end entity tb_memory_handler;

architecture test_bench of tb_memory_handler is

    signal s_clk  : std_logic := '0';
    signal s_rst  : std_logic := '0';
    signal s_Trigger_ch1 : std_logic := '1';
    signal s_Trigger_on_rising : std_logic := '1';
    signal s_TimeBase : unsigned(2 downto 0) := "000"; --1 sample per pixel

    signal s_TriggerLevel : std_logic_vector(5 downto 0) := "010110" ; -- 22 in the middle
    signal s_TriggerPos : std_logic_vector(5 downto 0) := "010000";    -- 20 in the middle

    signal s_SampleOne : std_logic_vector(8 downto 0);
    signal s_SampleTwo : std_logic_vector(8 downto 0);
    signal s_valid_in : std_logic := '0';

    signal s_RequestSample : std_logic := '0';
    signal s_NextLine : std_logic := '0';
    signal s_NextScreen_async : std_logic := '0';
    signal s_NextScreen_sync : std_logic := '0';
    signal s_NextScreen : std_logic := '0';
    
    signal s_screen_counter : integer := 0;

    signal s_Offset_ch1 : std_logic_vector(5 downto 0) := "000000";
    signal s_Offset_ch2 : std_logic_vector(5 downto 0) := "000000";
    signal s_Sig_amplitude_ch1 : std_logic_vector(2 downto 0) := "010"; -- normal amplitude
    signal s_Sig_amplitude_ch2 : std_logic_vector(2 downto 0) := "010"; -- normal amplitude

    signal s_out_ChannelOneSample : std_logic_vector(9 downto 0);
    signal s_out_ChannelTwoSample : std_logic_vector(9 downto 0);

    type TEST_FSM is (TRIGGER_TEST,DISPLAY_TEST,STOP);

    signal s_state : TEST_FSM := STOP;
    signal s_next_state : TEST_FSM := STOP;

    signal s_begin_test_trigger : std_logic := '0';
    signal s_begin_test_display : std_logic := '0';
    signal s_stop_test : std_logic := '0';

    signal trigger_counter : integer := 0;
    signal trigger_test_num : std_logic_vector(1 downto 0) := "00";
    
    signal display_counter : integer := 0;
    signal display_test_num : std_logic_vector(1 downto 0) := "00";

begin

    DUT: entity work.memory_handler
        port map (
            clk => s_clk,   
            rst => s_rst,
            
            Trigger_ref => s_TriggerLevel,
            Trigger_pos => s_TriggerPos,
            Trigger_ch1 => s_Trigger_ch1,
            Trigger_on_rising => s_Trigger_on_rising,
            TimeBase => s_TimeBase,

            sample_in_ch1 => s_SampleOne,
            sample_in_ch2 => s_SampleTwo,
            valid_in => s_valid_in,

            RequestSample => s_RequestSample, 
            NextLine => s_NextLine,
            NextScreen => s_NextScreen,

            Offset_ch1 => s_Offset_ch1,
            Offset_ch2 => s_Offset_ch2,
            Sig_amplitude_ch1 => s_Sig_amplitude_ch1,
            Sig_amplitude_ch2 => s_Sig_amplitude_ch2,

            ChannelOneSample => s_out_ChannelOneSample,
            ChannelTwoSample => s_out_ChannelTwoSample
        );


    -- Clock generation
    CLOCK_GEN: process is 
    begin
        wait for 10 ns;
        s_clk <= not s_clk;
    end process CLOCK_GEN;

    -- Valid signal generation
    VALID_IN_GEN: process(s_clk)
    begin
        if falling_edge(s_clk) then
            s_valid_in <= not s_valid_in;
        end if;
    end process VALID_IN_GEN;

    -- Request sample generation
    SAMPLE_REQUEST_GEN: process(s_clk)
    begin
        if falling_edge(s_clk) and s_state = DISPLAY_TEST then
            s_RequestSample <= not s_RequestSample;
        end if;
    end process SAMPLE_REQUEST_GEN;

    -- Next line and next screen generation
    NEXT_LINE_SCREEN_GEN: process(s_clk)
        variable counter : integer := 0;
        variable line_counter : integer := 0;
    begin
        if falling_edge(s_clk) and s_state = DISPLAY_TEST and s_RequestSample = '1' then
            if counter = 1279 then
                s_NextLine <= '1';
                counter := 0;
                line_counter := line_counter + 1;
            else
                s_NextLine <= '0';
                counter := counter + 1;
            end if;
            if line_counter = 50 then        -- a whole screen signal is generated every 10 lines
                s_NextScreen_sync <= '1';
                line_counter := 0;
            else
                s_NextScreen_sync <= '0';
            end if;
        end if;
    end process NEXT_LINE_SCREEN_GEN;

    s_NextScreen <= s_NextScreen_async or s_NextScreen_sync;

    SCREEN_COUNTER: process(s_NextScreen_sync)
    begin
        if s_NextScreen_sync = '1' then
            s_screen_counter <= s_screen_counter + 1;
        end if;
    end process SCREEN_COUNTER;

    REG: process(s_clk) is
    begin
        if rising_edge(s_clk) then
            s_state <= s_next_state;
        end if;
    end process REG;

    NSL: process(s_state,s_begin_test_display,s_begin_test_trigger,s_stop_test) is
    begin
        case s_state is
            when TRIGGER_TEST =>
                if s_begin_test_display = '1' then
                    s_next_state <= DISPLAY_TEST;
                else
                    s_next_state <= TRIGGER_TEST;
                end if;
            when DISPLAY_TEST =>
                if s_stop_test = '1' then
                    s_next_state <= STOP;
                else
                    s_next_state <= DISPLAY_TEST;
                end if;
            when STOP =>
                if s_begin_test_trigger = '1' then
                    s_next_state <= TRIGGER_TEST;
                else
                    s_next_state <= STOP;
                end if;
            when others =>
                s_next_state <= STOP;
        end case;
    end process NSL;
    

    RESET: process is
    begin

        -- wait two clock cycles + 5 ns to center the operations in clock rising edge
        wait for 25 ns;

        -- Reset the DUT
        s_rst <= '1';
        wait for 10 ns;
        s_rst <= '0';

        s_begin_test_trigger <= '1';

        wait;
    end process RESET;



    TEST: process(s_clk, s_NextScreen_sync) is
    begin
        -- TRIGGER TEST
        if s_state = TRIGGER_TEST then 
            s_NextScreen_async <= '0';
            if rising_edge(s_clk) and s_valid_in = '1' then
                trigger_counter <= trigger_counter + 1;

                -- first trigger test - - - - - - - - - - - - - - - - - - - - -
                -- trigger in the second half of the buffer on ch1 rising edge
                if trigger_test_num = "00" then
                    s_TriggerLevel <= "010110"; -- 22 in the middle
                    s_TriggerPos <= "010100";    -- 20 in the middle
                    s_Trigger_ch1 <= '1';
                    s_Trigger_on_rising <= '1';
                    s_TimeBase <= "001"; --1 sample per pixel 
                end if;

                if trigger_counter < 1000 and trigger_test_num = "00" then                    -- check that trigger is not taken in the first half of the buffer
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                elsif trigger_counter < 1500 and trigger_test_num = "00" then
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "000000000"; -- 0
                elsif trigger_counter < 5000 and trigger_test_num = "00" then
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                elsif trigger_test_num = "00" then
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "000000000"; -- 0
                end if;

                -- second trigger test - - - - - - - - - - - - - - - - - - - - -
                -- trigger in the first half of the buffer on ch2 falling edge
                if trigger_test_num = "01" then
                    s_TriggerLevel <= "010110"; -- 22 in the middle
                    s_TriggerPos <= "010100";    -- 20 in the middle
                    s_Trigger_ch1 <= '0';
                    s_Trigger_on_rising <= '0';
                    s_TimeBase <= "001"; --1 sample per pixel 
                end if;

                if trigger_counter < 1000 and trigger_test_num = "01" then                    -- check that trigger is not taken in the first half of the buffer
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "110010000"; -- 400
                elsif trigger_counter < 1500 and trigger_test_num = "01" then
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "000000000"; -- 0
                elsif trigger_counter < 9200 and trigger_test_num = "01" then               -- first half of the buffer: 8192 samples (whole buffer) + 1000
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "110010000"; -- 400
                elsif trigger_test_num = "01" then
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "000000000"; -- 0
                end if;


            end if;

            if trigger_counter = 10000 and trigger_test_num = "00" then 
                trigger_counter <= 0;
                trigger_test_num <= "01";
                s_NextScreen_async <= '1';
            end if;

            if trigger_counter = 15000 and trigger_test_num = "01" then 
                trigger_counter <= 0;
                s_begin_test_display <= '1';
                s_NextScreen_async <= '1';
            end if;

        -- DISPLAY TEST
        elsif s_state = DISPLAY_TEST then
            s_NextScreen_async <= '0';


            -- first display test
            if display_test_num = "00" then
                s_TriggerLevel <= "000001";  -- 1 => level at 16
                s_TriggerPos <= "010100";    -- 20 in the middle
                s_Trigger_ch1 <= '1';
                s_Trigger_on_rising <= '1';
                s_TimeBase <= "001"; --1 sample per pixel 
                s_Offset_ch1 <= "000000"; -- 0
                s_Offset_ch2 <= "000000"; -- 0
                s_Sig_amplitude_ch1 <= "010"; -- normal amplitude
                s_Sig_amplitude_ch2 <= "010"; -- normal amplitude
            end if;

            -- second display test, same as first but with 3 samples per pixel
            if display_test_num = "01" then
                s_TriggerLevel <= "000001";  -- 1 => level at 16
                s_TriggerPos <= "010100";    -- 20 in the middle
                s_Trigger_ch1 <= '1';
                s_Trigger_on_rising <= '1';
                s_TimeBase <= "011";         --3 sample per pixel 
                s_Offset_ch1 <= "000000";    -- 0
                s_Offset_ch2 <= "000000";    -- 0
                s_Sig_amplitude_ch1 <= "010"; -- normal amplitude
                s_Sig_amplitude_ch2 <= "010"; -- normal amplitude
            end if;

            -- second display test, same as first but with 3 samples per pixel
            if display_test_num = "10" then
                s_TriggerLevel <= "000001";  -- 1 => level at 16
                s_TriggerPos <= "010100";    -- 20 in the middle
                s_Trigger_ch1 <= '1';
                s_Trigger_on_rising <= '1';
                s_TimeBase <= "011";         --3 sample per pixel 
                s_Offset_ch1 <= "001100";    -- 12 -> 192
                s_Offset_ch2 <= "001100";    -- 12 -> 192
                s_Sig_amplitude_ch1 <= "010"; -- normal amplitude
                s_Sig_amplitude_ch2 <= "010"; -- normal amplitude
            end if;

            -- second display test, same as first but with 3 samples per pixel
            if display_test_num = "11" then
                s_TriggerLevel <= "000001";  -- 1 => level at 16
                s_TriggerPos <= "010100";    -- 20 in the middle
                s_Trigger_ch1 <= '1';
                s_Trigger_on_rising <= '1';
                s_TimeBase <= "011";         --3 sample per pixel 
                s_Offset_ch1 <= "000000";    -- 0
                s_Offset_ch2 <= "000000";    -- 0
                s_Sig_amplitude_ch1 <= "100"; -- x4 amplitude
                s_Sig_amplitude_ch2 <= "100"; -- x4 amplitude
            end if;


            -- fill memory with samples
            if rising_edge(s_clk) and s_valid_in = '1' then
                trigger_counter <= trigger_counter + 1;
                if trigger_counter < 2000 then                      -- first half of the buffer: 0
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                elsif trigger_counter < 2100 then       
                    s_SampleOne <= "000110010"; -- 50
                    s_SampleTwo <= "000110010"; -- 50
                elsif trigger_counter < 3000 then       
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                elsif trigger_counter < 3100 then       
                    s_SampleOne <= "001100100"; -- 100
                    s_SampleTwo <= "001100100"; -- 100
                elsif trigger_counter < 5000 then       
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                elsif trigger_counter < 5100 then       
                    s_SampleOne <= "001100100"; -- 100
                    s_SampleTwo <= "001100100"; -- 100
                elsif trigger_counter < 6000 then       
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                elsif trigger_counter < 6100 then       
                    s_SampleOne <= "000110010"; -- 50
                    s_SampleTwo <= "000110010"; -- 50    
                else                                                -- second half of the buffer: 0 if not in time base step
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                end if;
            end if;

            if s_NextScreen_sync = '1' then 
                trigger_counter <= 0;
                if s_screen_counter = 4 then
                    display_test_num <= "01";
                elsif s_screen_counter = 8 then
                    display_test_num <= "10";
                elsif s_screen_counter = 12 then
                    display_test_num <= "11";
                elsif s_screen_counter = 16 then
                    s_stop_test <= '1';
                end if;
            end if;
                    
        end if;
    end process TEST;

end architecture test_bench;