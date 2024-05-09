---------------------------------------------------------------------------------------------------------------
-- File: bcd_to_7seg.vhdl
-- Author: Domenico Aquilino <aquid1@bfh.ch>
-- Date: 2024-05-07
-- Version: 1.0

-- description: Converts a three-digit BCD number into a 8 binary number.
--              The conversion is done by accessing a predefined table of 
--              segment values associated with each BCD digit from 0 to 9.
---------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_to_7seg is
    generic (
        NBITS : positive := 4        -- data input width
    );
    port (
        din      : in std_logic_vector(NBITS-1 downto 0); --data input (4 bits)
        segments : out std_logic_vector(6 downto 0) --Display7Segments (7 bits)
    );
end entity;

architecture dfl of bcd_to_7seg is
    --MSB segment g -  LSB segment a
    -- To understand the seven segments read the Leguan documentation 
    type table is array (natural range 0 to 11) of std_logic_vector(6 downto 0);
    signal segments_table : table := (
        "0111111", -- 0
        "0000110", -- 1
        "1011011", -- 2
        "1001111", -- 3
        "1100110", -- 4
        "1101101", -- 5
        "1111101", -- 6
        "0000111", -- 7
        "1111111", -- 8
        "1101111", -- 9
        "0111001", -- C
        "1110011" -- P
    );

begin
   --Convert data input to integer
   segments <= segments_table(to_integer(unsigned(din)));
end architecture;