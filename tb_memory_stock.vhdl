---------------------------------------------------------------------------------------------------------------
-- File: tb_memory_stock.vhd
-- Author: Domenico Aquilino <aquid1@bfh.ch>
-- Date: 2024-04-19
-- Version: 1.0

-- description: Test bench for the memory_stock module. The test bench writes and reads data from the memory
---------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memory_stock is
end entity tb_memory_stock;

architecture test_bench of tb_memory_stock is

   signal s_clk  : std_logic := '0';
   signal s_we   : std_logic := '0';
   signal s_re   : std_logic := '0';
   signal s_addr : std_logic_vector(12 downto 0); 
   signal s_din  : std_logic_vector(8 downto 0);
   signal s_dout : std_logic_vector(8 downto 0);

   type samples_type is array(0 to 2) of std_logic_vector(8 downto 0);
   type adrress_type is array(0 to 2) of std_logic_vector(12 downto 0);

   constant samples : samples_type := (
        "000000001",    -- 1
        "000000010",    -- 2
        "000000011"     -- 3
    );

    constant address : adrress_type := (
        "0000000000000", -- 0
        "0000000000001", -- 1
        "0000000000010"  -- 2
    );

begin

    CLOCK_GEN: process is 
    begin
        wait for 10 ns;
        s_clk <= not s_clk;
    end process CLOCK_GEN;

    DUT: entity work.memory_stock
        port map (
            clk => s_clk,
            we => s_we,
            re => s_re,
            addr => s_addr,
            din => s_din,
            dout => s_dout
        );

    TEST: process is
    begin

        -- wait two clock cycles + 5 ns to center the operations in clock rising edge
        wait for 25 ns;

        -- Write data to memory
        s_we <= '1';
        s_addr <= address(0);
        s_din <= samples(0);
        wait for 10 ns;
        s_we <= '0';
        wait for 10 ns;

        s_we <= '1';
        s_addr <= address(1);
        s_din <= samples(1);
        wait for 10 ns;
        s_we <= '0';
        wait for 10 ns;

        s_we <= '1';
        s_addr <= address(2);
        s_din <= samples(2);
        wait for 10 ns;
        s_we <= '0';
        wait for 10 ns;

        -- Read data from memory
        s_re <= '1';
        s_addr <= address(2);
        wait for 10 ns;
        assert s_dout = samples(2) 
            report "Error reading data from memory: expected " & to_string(unsigned(samples(2))) & " got " & to_string(unsigned(s_dout))
            severity error;
        s_re <= '0';
        wait for 10 ns;

        s_re <= '1';
        s_addr <= address(1);
        wait for 10 ns;
        assert s_dout = samples(1) 
            report "Error reading data from memory: expected " & to_string(unsigned(samples(1))) & " got " & to_string(unsigned(s_dout))
            severity error;
        s_re <= '0';
        wait for 10 ns;

        s_re <= '1';
        s_addr <= address(0);
        wait for 10 ns;
        assert s_dout = samples(0) 
            report "Error reading data from memory: expected " & to_string(unsigned(samples(0))) & " got " & to_string(unsigned(s_dout))
            severity error;
        s_re <= '0';
        wait for 10 ns;

        wait;
    end process TEST;

    

end architecture test_bench;