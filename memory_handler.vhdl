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

        -- trigger
        Trigger_ref         : in std_logic_vector(5 downto 0);        -- trigger level signal (from 1 to 44 - middle at 22) [step 16]
        Trigger_pos         : in std_logic_vector(5 downto 0);        -- trigger position (from 1 to 39 - middle at 20)     [step 32]
        Trigger_ch1         : in std_logic;                           -- trigger channel signal
        Trigger_on_rising   : in std_logic;                           -- trigger on rising edge
        TimeBase            : in unsigned(2 downto 0);                -- time base signal (1 to 6 samples per pixel)

        -- ADC
        sample_in_ch1       : in std_logic_vector(8 downto 0);        -- sample signal channel 1
        sample_in_ch2       : in std_logic_vector(8 downto 0);        -- sample signal channel 2
        valid_in            : in std_logic;                           -- valid sample 

        -- display
        RequestSample       : in std_logic;                           -- request sample signal from display
        NextLine            : in std_logic;                           -- next line signal from display
        NextScreen          : in std_logic;                           -- next screen signal from display

        Offset_ch1          : in std_logic_vector(5 downto 0);        -- offset channel 1 signal [step: 16]
        Offset_ch2          : in std_logic_vector(5 downto 0);        -- offset channel 2 signal [step: 16]
        Sig_amplitude_ch1   : in std_logic_vector(2 downto 0);        -- define amplitude of visualization signal
        Sig_amplitude_ch2   : in std_logic_vector(2 downto 0);        -- define amplitude of visualization signal
        
        ChannelOneSample    : out std_logic_vector(9 downto 0);       -- channel 1 sample signal
        ChannelTwoSample    : out std_logic_vector(9 downto 0)        -- channel 2 sample signal
        
        );
end entity memory_handler;

architecture platform_indipendent of memory_handler is

    constant c_sample_number : integer := 8192; -- number of samples to fill memory
    constant c_pixels_number : integer := 1280; -- number of sample to display

    type state_type is (WAIT_PRE_TRIGGER,PRE_TRIGGER, POST_TRIGGER, END_FILL, SWAP);
    signal state      : state_type := WAIT_PRE_TRIGGER;
    signal state_next : state_type := WAIT_PRE_TRIGGER;

    signal s_event_valid      : std_logic := '0';     -- allow trigger detection event 
    signal s_event_trigger    : std_logic := '0';     -- trigger event
    signal s_event_end        : std_logic := '0';     -- end of samples store event
    signal s_event_swap        : std_logic := '0';    -- swap memory event

    signal s_write_counter   : unsigned(12 downto 0) := (others => '0');
    signal s_read_counter    : unsigned(12 downto 0) := (others => '0');
    signal s_trigger_address : unsigned(12 downto 0) := (others => '0');
    signal s_trigger_address_memory_1 : unsigned(12 downto 0) := (others => '0');
    signal s_trigger_address_memory_2 : unsigned(12 downto 0) := (others => '0');

    signal s_sample_in_ch1_pre : std_logic_vector(8 downto 0) := (others => '0');
    signal s_sample_in_ch2_pre : std_logic_vector(8 downto 0) := (others => '0');

    signal s_sample_ch1_out_1  : std_logic_vector(8 downto 0);
    signal s_sample_ch1_out_2  : std_logic_vector(8 downto 0);
    signal s_sample_ch1_out    : std_logic_vector(8 downto 0);
    signal s_sample_ch2_out_1  : std_logic_vector(8 downto 0);
    signal s_sample_ch2_out_2  : std_logic_vector(8 downto 0);
    signal s_sample_ch2_out    : std_logic_vector(8 downto 0);
    signal s_ChannelOneSample : unsigned(9 downto 0);
    signal s_ChannelTwoSample : unsigned(9 downto 0);
    signal s_write_address   : unsigned(12 downto 0);
    signal s_read_address    : unsigned(12 downto 0);

    signal s_ram_select : std_logic := '0';
    signal s_write_ram0 : std_logic := '0';
    signal s_read_ram0  : std_logic := '0';
    signal s_write_ram1 : std_logic := '0';
    signal s_read_ram1  : std_logic := '0';
    signal s_write_ram2 : std_logic := '0';
    signal s_read_ram2  : std_logic := '0';
    signal s_write_ram3 : std_logic := '0';
    signal s_read_ram3  : std_logic := '0';
    signal s_ram0_address : std_logic_vector(12 downto 0) := (others => '0');
    signal s_ram1_address : std_logic_vector(12 downto 0) := (others => '0');
    signal s_ram2_address : std_logic_vector(12 downto 0) := (others => '0');
    signal s_ram3_address : std_logic_vector(12 downto 0) := (others => '0');

begin

    -----------------------------------------------------------------------------------------------
    -- FSM
    -----------------------------------------------------------------------------------------------

    -- compute the state of the state machine
    REG: process(clk, rst) is
    begin
        if rst = '1' then
            state <= WAIT_PRE_TRIGGER;
        elsif rising_edge(clk) or state /= state_next then
            state <= state_next;
        end if;
    end process REG;

    -- compute the next state of the state machine
    NSL : process(s_event_valid,s_event_trigger,s_event_end,s_event_swap,state) is
    begin
        state_next <= state;
        case(state) is
            when WAIT_PRE_TRIGGER =>
                if s_event_valid = '1' then
                    state_next <= PRE_TRIGGER;
                end if;
            when PRE_TRIGGER =>
                if s_event_trigger = '1' then
                    state_next <= POST_TRIGGER;
                end if;
            when POST_TRIGGER =>
                if s_event_end = '1' then
                    state_next <= END_FILL;
                end if;
            when END_FILL =>
                if s_event_swap = '1' then
                    state_next <= SWAP;
                end if;
            when SWAP =>
                state_next <= WAIT_PRE_TRIGGER;
        end case;
    end process NSL;   

    -----------------------------------------------------------------------------------------------
    -- FSM EVENTS GENERATION
    -----------------------------------------------------------------------------------------------

    -- generate the valid event for the state machine
    -- wait half memory to be filled before generating the valid event
    VALID : process(s_write_counter) is
    begin
        if state = WAIT_PRE_TRIGGER then
            if s_write_counter = c_sample_number/2 then
                s_event_valid <= '1';
            else
                s_event_valid <= '0';
            end if;
        else 
            s_event_valid <= '0';
        end if;
    end process VALID;

    -- generate the trigger event for the state machine
    TRIGGER : process(valid_in) is  
    begin
        if state = PRE_TRIGGER then                     -- detect trigger event only in the pre-trigger state
            if valid_in = '1' then
                if Trigger_ch1 = '1' then               -- trigger on channel 1
                    if Trigger_on_rising = '1' then     -- trigger on rising edge
                        if unsigned(s_sample_in_ch1_pre) < (unsigned(Trigger_ref)*16) and unsigned(sample_in_ch1) >= (unsigned(Trigger_ref)*16) then
                            s_event_trigger <= '1';
                        else 
                            s_event_trigger <= '0';
                        end if;
                    else                                -- trigger on falling edge  
                        if unsigned(s_sample_in_ch1_pre) > (unsigned(Trigger_ref)*16) and unsigned(sample_in_ch1) <= (unsigned(Trigger_ref)*16) then
                            s_event_trigger <= '1';
                        else 
                            s_event_trigger <= '0';
                        end if;
                    end if;
                else                                    -- trigger on channel 2
                    if Trigger_on_rising = '1' then     -- trigger on rising edge
                        if unsigned(s_sample_in_ch2_pre) < (unsigned(Trigger_ref)*16) and unsigned(sample_in_ch2) >= (unsigned(Trigger_ref)*16) then
                            s_event_trigger <= '1';
                        else 
                            s_event_trigger <= '0';
                        end if;
                    else                                -- trigger on falling edge  
                        if unsigned(s_sample_in_ch2_pre) > (unsigned(Trigger_ref)*16) and unsigned(sample_in_ch2) <= (unsigned(Trigger_ref)*16) then
                            s_event_trigger <= '1';
                        else 
                            s_event_trigger <= '0';
                        end if;
                    end if;
                end if;
                s_sample_in_ch1_pre <= sample_in_ch1;             -- store the previous sample ch1
                s_sample_in_ch2_pre <= sample_in_ch2;             -- store the previous sample ch2
            end if;
        else
            s_event_trigger <= '0';
        end if;
    end process TRIGGER;

    -- store the trigger address
    TRIGGER_ADDRESS : process(s_event_trigger,s_write_counter) is 
    begin
        s_trigger_address <= s_trigger_address;
        if s_event_trigger = '1' then
            s_trigger_address <= s_write_counter;                 -- store the trigger address
        end if;
    end process TRIGGER_ADDRESS;    

    -- generate the end event for the state machine
    FILL_END : process(s_write_counter) is
    begin
        if state = POST_TRIGGER then
            if s_trigger_address < c_sample_number/2 then   -- trigger event is in first half of samples
                if s_write_counter = (s_trigger_address + c_sample_number/2) then
                    s_event_end <= '1';
                else
                    s_event_end <= '0';
                end if;
            else                                        -- trigger event is in second half of samples
                if s_write_counter = (s_trigger_address - c_sample_number/2) then
                    s_event_end <= '1';
                else
                    s_event_end <= '0';
                end if;
            end if;
        else
            s_event_end <= '0';
        end if;
    end process FILL_END;

    -- generate the swap event for the state machine
    MEMORY_SWAP : process(NextScreen) is
    begin
        if state = END_FILL and NextScreen = '1' then -- swap memory when the memory is full and the display request a new screen   
            s_event_swap <= '1';
        else
            s_event_swap <= '0';
        end if;
    end process MEMORY_SWAP;

    -----------------------------------------------------------------------------------------------
    -- COUNTERS FOR ADDRESS GENERATION
    -----------------------------------------------------------------------------------------------

    -- counter for the write in RAM adrress generation 
    WRITE_COUNTER : process(valid_in,rst,state) is
    begin
        if rst = '1' then
            s_write_counter <= (others => '0');
        elsif valid_in = '1' then
            if state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER then
                s_write_counter <= s_write_counter + 1;
            else 
                s_write_counter <= (others => '0');
            end if;
        end if;
    end process WRITE_COUNTER; 

    -- counter for the read from RAM adrress generation
    READ_COUNTER : process(RequestSample,NextLine,rst,state) is
    begin
        if rst = '1' or NextLine = '1' or state = SWAP then 
            s_read_counter <= (others => '0');
        elsif RequestSample = '1' and state /= SWAP then
            s_read_counter <= s_read_counter + 1;
        end if;
    end process READ_COUNTER;
    
    -----------------------------------------------------------------------------------------------
    -- RAM
    -----------------------------------------------------------------------------------------------
    RAM_SELECT : process(state) is
    begin
        if state = SWAP then
            s_ram_select <= not s_ram_select;
        end if;
    end process RAM_SELECT;

    -- READ ENABLE --------------------------------------------------------------------------------

    -- ram0 read enable
    s_read_ram0 <= '1' when state /= SWAP and RequestSample = '1' and s_ram_select = '0' else 
                   '0';
    -- ram1 read enable
    s_read_ram1 <= '1' when state /= SWAP and RequestSample = '1' and s_ram_select = '1' else 
                   '0';
    -- ram2 read enable
    s_read_ram2 <= '1' when state /= SWAP and RequestSample = '1' and s_ram_select = '0' else 
                   '0';
    -- ram3 read enable
    s_read_ram3 <= '1' when state /= SWAP and RequestSample = '1' and s_ram_select = '1' else 
                   '0';

    -- WRITE ENABLE --------------------------------------------------------------------------------

    -- ram0 write enable
    s_write_ram0 <= '1' when (state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER) and valid_in = '1' and s_ram_select = '1' else 
                    '0';
    -- ram1 write enable
    s_write_ram1 <= '1' when (state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER) and valid_in = '1' and s_ram_select = '0' else 
                    '0';
    -- ram2 write enable
    s_write_ram2 <= '1' when (state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER) and valid_in = '1' and s_ram_select = '1' else 
                    '0';
    -- ram3 write enable
    s_write_ram3 <= '1' when (state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER) and valid_in = '1' and s_ram_select = '0' else 
                    '0';


    -- ADDRESSES COMPUTATION ------------------------------------------------------------------------

    s_write_address <= s_write_counter;

    -- distinguish the trigger address in the two memory
    TRIGGER_ADDRESS_MEMORY : process(s_trigger_address) is
    begin
        if s_ram_select = '0' then
            s_trigger_address_memory_1 <= s_trigger_address;
        else
            s_trigger_address_memory_2 <= s_trigger_address;
        end if;
    end process TRIGGER_ADDRESS_MEMORY;

    s_read_address <= resize(( s_trigger_address_memory_1 - (to_integer(TimeBase) * (c_pixels_number/2)) + (to_integer(s_read_counter) * to_integer(TimeBase)) - (c_pixels_number/2) + (to_integer(unsigned(Trigger_pos)*32))) ,13) when s_ram_select = '1' else
                      resize(( s_trigger_address_memory_2 - (to_integer(TimeBase) * (c_pixels_number/2)) + (to_integer(s_read_counter) * to_integer(TimeBase)) - (c_pixels_number/2) + (to_integer(unsigned(Trigger_pos)*32))) ,13);


    -- ram0 address
    s_ram0_address <= std_logic_vector(s_write_address) when (state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER) and s_ram_select = '1' else                  
                      std_logic_vector(s_read_address)  when state /= SWAP and s_ram_select = '0' else
                      (others => '0');

    -- ram1 address
    s_ram1_address <= std_logic_vector(s_write_address) when (state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER) and s_ram_select = '0' else                  
                      std_logic_vector(s_read_address)  when state /= SWAP and s_ram_select = '1' else
                      (others => '0');

    -- ram2 address
    s_ram2_address <= std_logic_vector(s_write_address) when (state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER) and s_ram_select = '1' else                  
                      std_logic_vector(s_read_address)  when state /= SWAP and s_ram_select = '0' else
                      (others => '0');

    -- ram3 address
    s_ram3_address <= std_logic_vector(s_write_address) when (state = WAIT_PRE_TRIGGER or state = PRE_TRIGGER or state = POST_TRIGGER) and s_ram_select = '0' else                  
                      std_logic_vector(s_read_address)  when state /= SWAP and s_ram_select = '1' else
                      (others => '0');

    -- OUTPUT SAMPLE COMPUTATION ---------------------------------------------------------------------

    -- Sig_amplitude: 000: 1/4, 001: 1/2, 010: 1, 011: 2, 100: 4

    s_sample_ch1_out <= s_sample_ch1_out_1 when s_ram_select = '0' else
                        s_sample_ch1_out_2;

    s_sample_ch2_out <= s_sample_ch2_out_1 when s_ram_select = '0' else
                        s_sample_ch2_out_2;

    s_ChannelOneSample <= resize(unsigned(s_sample_ch1_out srl 2) + (unsigned(Offset_ch1)*16),10) when Sig_amplitude_ch1 = "000" and state /= SWAP else
                          resize(unsigned(s_sample_ch1_out srl 1) + (unsigned(Offset_ch1)*16),10) when Sig_amplitude_ch1 = "001" and state /= SWAP else
                          resize(unsigned(s_sample_ch1_out sll 1) + (unsigned(Offset_ch1)*16),10) when Sig_amplitude_ch1 = "011" and state /= SWAP else
                          resize(unsigned(s_sample_ch1_out sll 2) + (unsigned(Offset_ch1)*16),10) when Sig_amplitude_ch1 = "100" and state /= SWAP else
                          resize(unsigned(s_sample_ch1_out) + (unsigned(Offset_ch1)*16),10) when Sig_amplitude_ch1 = "010" and state /= SWAP else
                          (others => '0');

    s_ChannelTwoSample <= resize(unsigned(s_sample_ch2_out srl 2) + (unsigned(Offset_ch2)*16),10) when Sig_amplitude_ch2 = "000" and state /= SWAP else
                          resize(unsigned(s_sample_ch2_out srl 1) + (unsigned(Offset_ch2)*16),10) when Sig_amplitude_ch2 = "001" and state /= SWAP else
                          resize(unsigned(s_sample_ch2_out sll 1) + (unsigned(Offset_ch2)*16),10) when Sig_amplitude_ch2 = "011" and state /= SWAP else
                          resize(unsigned(s_sample_ch2_out sll 2) + (unsigned(Offset_ch2)*16),10) when Sig_amplitude_ch2 = "100" and state /= SWAP else
                          resize(unsigned(s_sample_ch2_out) + (unsigned(Offset_ch2)*16),10) when Sig_amplitude_ch2 = "010" and state /= SWAP else
                          (others => '0');

    ChannelOneSample <= std_logic_vector(s_ChannelOneSample);
    ChannelTwoSample <= std_logic_vector(s_ChannelTwoSample);

    -- RAM INSTANTIATION -----------------------------------------------------------------------------

    -- samples ch1 first buffer
    RAM0 : entity work.memory_stock(dual_port) 
        port map (
            clk => clk,
            we => s_write_ram0,
            re => s_read_ram0,
            addr => s_ram0_address,
            din => sample_in_ch1,
            dout => s_sample_ch1_out_1
        );

    -- samples ch1 second buffer
    RAM1 : entity work.memory_stock(dual_port) 
        port map (
            clk => clk,
            we => s_write_ram1,
            re => s_read_ram1,
            addr => s_ram1_address,
            din => sample_in_ch1,
            dout => s_sample_ch1_out_2
        );

    -- samples ch2 first buffer
    RAM2 : entity work.memory_stock(dual_port) 
        port map (
            clk => clk,
            we => s_write_ram2,
            re => s_read_ram2,
            addr => s_ram2_address,
            din => sample_in_ch2,
            dout => s_sample_ch2_out_1
        );

    -- samples ch2 second buffer
    RAM3 : entity work.memory_stock(dual_port) 
        port map (
            clk => clk,
            we => s_write_ram3,
            re => s_read_ram3,
            addr => s_ram3_address,
            din => sample_in_ch2,
            dout => s_sample_ch2_out_2
        );
   
end architecture platform_indipendent;

