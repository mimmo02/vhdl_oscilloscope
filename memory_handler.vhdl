---------------------------------------------------------------------------------------------------------------
-- File: memory_handler.vhdl
-- Author: Domenico Aquilino <aquid1@bfh.ch>
-- Date: 2024-04-19
-- Version: 1.0

-- description: This file contains the VHDL code for the memory handler module. The module is responsible for
--              handling the memory of the system. It receives the samples from the ADC and stores them in the
--              memory in a strategic way. The module is also responsible for the trigger event generation. 
--              The trigger event is generated when the sample value is greater than the trigger level.              
---------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_handler is
    port (  
        clk                 : in std_logic;                           -- clock signal
        rst                 : in std_logic;                           -- reset signal

        start               : in std_logic;                           -- start signal

        trigger_ref         : in std_logic_vector(8 downto 0);        -- trigger level signal
        trigger_ch1         : in std_logic;                           -- trigger channel signal
        trigger_on_rising   : in std_logic;                          -- trigger on rising edge

        sample_in_ch1       : in std_logic_vector(8 downto 0);        -- sample signal channel 1
        sample_in_ch2       : in std_logic_vector(8 downto 0);        -- sample signal channel 2
        valid_in            : in std_logic;                           -- valid sample 

        write_cmd           : out std_logic;                          -- write command signal
        address_cmd         : out std_logic_vector(12 downto 0);      -- address command signal
        sample_out_ch1      : out std_logic_vector(8 downto 0);       -- sample signal channel 1
        sample_out_ch2      : out std_logic_vector(8 downto 0);       -- sample signal channel 2

        filled              : out std_logic                           -- memory filled signal
        );
end entity memory_handler;

architecture platform_indipendent of memory_handler is

    constant sample_number : integer := 8192; -- number of samples

    type state_type is (STOP, WAIT_PRE_TRIGGER,PRE_TRIGGER, POST_TRIGGER, END_FILL);
    signal state      : state_type := STOP;
    signal state_next : state_type := STOP;

    signal start_event      : std_logic := '0';
    signal valid_event      : std_logic := '0';
    signal trigger_event    : std_logic := '0';
    signal end_event        : std_logic := '0';

    signal counter : unsigned(12 downto 0) := (others => '0');
    signal trigger_address  : unsigned(12 downto 0) := (others => '0');

    signal sample_in_ch1_pre : std_logic_vector(8 downto 0) := (others => '0');
    signal sample_in_ch2_pre : std_logic_vector(8 downto 0) := (others => '0');

begin

    -- generate the start event for the state machine
    start_event <= '1' when start = '1' else 
                   '0';

    -- compute the state of the state machine
    REG: process(clk, rst) is
    begin
        if rst = '1' then
            state <= STOP;
        elsif rising_edge(clk) then
            state <= state_next;
        end if;
    end process REG;

    -- compute the next state of the state machine
    NSL : process(start_event,valid_event,trigger_event,end_event,state,clk) is
    begin
        state_next <= state;
        switch(state) is
            when STOP =>
                if start_event = '1' then
                    state_next <= WAIT_PRE_TRIGGER;
                end if;
            when WAIT_PRE_TRIGGER =>
                if valid_event = '1' then
                    state_next <= PRE_TRIGGER;
                end if;
            when PRE_TRIGGER =>
                if trigger_event = '1' then
                    state_next <= POST_TRIGGER;
                end if;
            when POST_TRIGGER =>
                if end_event = '1' then
                    state_next <= END_FILL;
                end if;
            when END_FILL =>
                next_state <= STOP; 
        end switch;
    end process NSL;

    filled <= '1' when state = END_FILL else
              '0';

    -- counter for the adrress generation
    COUNTER : process(valid_in,rst,state) is
    begin
        if rst = '1' then
            counter <= (others => '0');
        elsif valid_in = '1' then
            if state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER then
                if counter < sample_number then
                    counter <= counter + 1;
                else
                    counter <= (others => '0');
                end if;
            else 
                counter <= (others => '0');
            end if;
        end if;
    end process COUNTER;    

    -- generate the valid event for the state machine
    -- wait half memory to be filled before generating the valid event
    VALID : process(counter) is
    begin
        if state = WAIT_PRE_TRIGGER then
            if counter = sample_number/2 then
                valid_event <= '1';
            else
                valid_event <= '0';
            end if;
        else 
            valid_event <= '0';
        end if;
    end process VALID;

    -- generate the trigger event for the state machine
    TRIGGER : process(valid_in) is  
    begin
        if state = PRE_TRIGGER then                         -- detect trigger event only in the pre-trigger state
            if valid_in = '1' then
                if address > sample_number/2 then           -- consider trigger event only if it appens im the secon half of samples
                    if trigger_ch1 = '1' then               -- trigger on channel 1
                        if trigger_on_rising = '1' then     -- trigger on rising edge
                            if sample_in_ch1_pre < trigger_ref and sample_in_ch1 >= trigger_ref then
                                trigger_event <= '1';
                            else 
                                trigger_event <= '0';
                            end if;
                        else                                -- trigger on falling edge  
                            if sample_in_ch1_pre > trigger_ref and sample_in_ch1 <= trigger_ref then
                                trigger_event <= '1';
                            else 
                                trigger_event <= '0';
                            end if;
                        end if;
                    else                                    -- trigger on channel 2
                        if trigger_on_rising = '1' then     -- trigger on rising edge
                            if sample_in_ch2_pre < trigger_ref and sample_in_ch2 >= trigger_ref then
                                trigger_event <= '1';
                            else 
                                trigger_event <= '0';
                            end if;
                        else                                -- trigger on falling edge  
                            if sample_in_ch2_pre > trigger_ref and sample_in_ch2 <= trigger_ref then
                                trigger_event <= '1';
                            else 
                                trigger_event <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        else
            trigger_event <= '0';
        end if;
        sample_in_ch1_pre <= sample_in_ch1;             -- store the previous sample ch1
        sample_in_ch2_pre <= sample_in_ch2;             -- store the previous sample ch2
    end process TRIGGER;

    trigger_address <= counter when trigger_event = '1';  -- store the trigger address

    -- generate the end event for the state machine
    END_EVENT : process(counter) is
    begin
        if state = POST_TRIGGER then
            if trigger_address < sample_number/2 then   -- trigger event is in first half of samples
                if counter = (trigger_address + sample_number/2) then
                    end_event <= '1';
                else
                    end_event <= '0';
                end if;
            else                                        -- trigger event is in second half of samples
                if counter = (trigger_address - sample_number/2) then
                    end_event <= '1';
                else
                    end_event <= '0';
            end if;
        else
            end_event <= '0';
        end if;
    end process END_EVENT;

   -- memory filler
   MEMORY_FILLER : process(valid_in) is
   begin
       if valid_in = '0' then
           if state = PRE_TRIGGER or state = POST_TRIGGER then
               write_cmd <= '1';
               address_cmd <= std_logic_vector(counter);
               sample_out_ch1 <= sample_in_ch1;
               sample_out_ch2 <= sample_in_ch2;
           else
               write_cmd <= '0';
               address_cmd <= (others => '0');
               sample_out_ch1 <= (others => '0');
               sample_out_ch2 <= (others => '0');
           end if;
       end if;        
   end process MEMORY_FILLER;

end architecture platform_indipendent;

