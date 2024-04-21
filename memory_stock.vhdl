---------------------------------------------------------------------------------------------------------------
-- File: memory_stock.vhd
-- Author: Domenico Aquilino <aquid1@bfh.ch>
-- Date: 2024-04-19
-- Version: 1.0

-- description: This file contains the VHDL code for a dual port memory. The memory has a read and a write port.
-- The memory is implemented as a RAM with 2^NADDR cells, each cell has NDATA bits. The memory is synchronous,
-- the read and write operations are performed on the rising edge of the clock signal.
---------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_stock is
    generic (
            NDATA : integer := 9;    -- number of data bits
            NADDR : integer := 13    -- number of address bits (8192 memory cells)
            );
    port (  
        clk             : in std_logic;                             -- clock signal
        we              : in std_logic;                             -- write enable signal (active high)
        re              : in std_logic;                             -- read enable signal (active high)
        addr            : in std_logic_vector(NADDR-1 downto 0);    -- address bus  
        din             : in std_logic_vector(NDATA-1 downto 0);    -- data input
        dout            : out std_logic_vector(NDATA-1 downto 0)    -- data output
        );
end entity memory_stock;

architecture dual_port of memory_stock is

    type ram_type is array (0 to 2**NADDR-1) 
        of std_logic_vector(NDATA-1 downto 0);

    signal ram : ram_type;

begin

    process(clk)
    begin
        
        if rising_edge(clk) then
            if we = '1' then                -- write operation
                ram(to_integer(unsigned(addr))) <= din;
            end if;
            if re = '1' then                -- read operation
                dout <= ram(to_integer(unsigned(addr)));
            end if;
        end if;

    end process;

end architecture dual_port;