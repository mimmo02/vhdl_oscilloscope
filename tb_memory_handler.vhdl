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
    signal s_NextScreen : std_logic := '0';

    signal s_Offset_ch1 : std_logic_vector(5 downto 0) := "000000";
    signal s_Offset_ch2 : std_logic_vector(5 downto 0) := "000000";
    signal s_Sig_amplitude_ch1 : std_logic_vector(2 downto 0) := "010"; -- normal amplitude
    signal s_Sig_amplitude_ch2 : std_logic_vector(2 downto 0) := "010"; -- normal amplitude

    signal s_out_ChannelOneSample : std_logic_vector(9 downto 0);
    signal s_out_ChannelTwoSample : std_logic_vector(9 downto 0);

    type TEST_FSM is (TRIGGER_TEST,MEMORY_STORAGE,STOP);

    signal s_state : TEST_FSM := STOP;
    signal s_next_state : TEST_FSM := STOP;

    signal s_begin_test_trigger : std_logic := '0';
    signal s_begin_tast_memory_storage : std_logic := '0';
    signal s_stop_test : std_logic := '0';

    signal counter : integer := 0;
    signal test_num : std_logic_vector(1 downto 0) := "00";

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

    VALID_IN_GEN: process(s_clk)
    begin
        if falling_edge(s_clk) then
            s_valid_in <= not s_valid_in;
        end if;
    end process VALID_IN_GEN;

    REG: process(s_clk) is
    begin
        if rising_edge(s_clk) then
            s_state <= s_next_state;
        end if;
    end process REG;

    NSL: process(s_state,s_begin_tast_memory_storage,s_begin_test_trigger,s_stop_test) is
    begin
        case s_state is
            when TRIGGER_TEST =>
                if s_begin_tast_memory_storage = '1' then
                    s_next_state <= MEMORY_STORAGE;
                else
                    s_next_state <= TRIGGER_TEST;
                end if;
            when MEMORY_STORAGE =>
                if s_stop_test = '1' then
                    s_next_state <= STOP;
                else
                    s_next_state <= MEMORY_STORAGE;
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

        ---- Test memory read
        -- assert s_dout = samples(2) 
        --    report "Error reading data from memory: expected " & to_string(unsigned(samples(2))) & " got " & to_string(unsigned(s_dout))
        --    severity error;

        wait;
    end process RESET;



    TEST_TRIGGER: process(s_clk) is
    begin
        if s_state = TRIGGER_TEST then 
            s_NextScreen <= '0';
            if rising_edge(s_clk) and s_valid_in = '1' then
                counter <= counter + 1;

                -- first trigger test - - - - - - - - - - - - - - - - - - - - -
                -- trigger in the second half of the buffer on ch1 rising edge
                if test_num = "00" then
                    s_TriggerLevel <= "010110"; -- 22 in the middle
                    s_TriggerPos <= "010000";    -- 20 in the middle
                    s_Trigger_ch1 <= '1';
                    s_Trigger_on_rising <= '1';
                    s_TimeBase <= "000"; --1 sample per pixel 
                end if;

                if counter < 101 and test_num = "00" then                    -- check that trigger is not taken in the first half of the buffer
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                elsif counter < 111 and test_num = "00" then
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "000000000"; -- 0
                elsif counter < 5000 and test_num = "00" then
                    s_SampleOne <= "000000000"; -- 0
                    s_SampleTwo <= "000000000"; -- 0
                elsif test_num = "00" then
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "000000000"; -- 0
                end if;

                -- second trigger test - - - - - - - - - - - - - - - - - - - - -
                -- trigger in the first half of the buffer on ch2 falling edge
                if test_num = "01" then
                    s_TriggerLevel <= "010110"; -- 22 in the middle
                    s_TriggerPos <= "010000";    -- 20 in the middle
                    s_Trigger_ch1 <= '0';
                    s_Trigger_on_rising <= '0';
                    s_TimeBase <= "000"; --1 sample per pixel 
                end if;

                if counter < 101 and test_num = "01" then                    -- check that trigger is not taken in the first half of the buffer
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "110010000"; -- 400
                elsif counter < 111 and test_num = "01" then
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "000000000"; -- 0
                elsif counter < 9200 and test_num = "01" then               -- first half of the buffer: 8192 samples (whole buffer) + 1000
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "110010000"; -- 400
                elsif test_num = "01" then
                    s_SampleOne <= "110010000"; -- 400
                    s_SampleTwo <= "000000000"; -- 0
                end if;




            end if;

            if counter = 10000 and test_num = "00" then 
                counter <= 0;
                test_num <= "01";
                s_NextScreen <= '1';
            end if;
        end if;
    end process TEST_TRIGGER;



end architecture test_bench;