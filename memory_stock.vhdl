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
            NDATA : integer := 9     -- number of data bits
            NADDR : integer := 13    -- number of address bits (8192 memory cells)
    );
    port (  clk             : in std_logic;
            we              : in std_logic;
            re              : in std_logic;
            addr            : in std_logic_vector(NADDR-1 downto 0);
            din             : in std_logic_vector(NDATA-1 downto 0);
            dout            : out std_logic_vector(NDATA-1 downto 0);
            );
end entity memory_stock;

architecture dual_port of memory_stock is

    type ram_type is array (0 to 2**NADDR-1) 
        of std_logic_vector(NDATA-1 downto 0);

    signal ram : ram_type;
    signal data_buf : std_logic_vector(NDATA-1 downto 0);

begin

    process(clk)
    begin
        
        if rising_edge(clk) then
            data_buf <= (others => '0');
            if we = '1' then                -- write operation
                ram(to_integer(unsigned(addr))) <= din;
            end if;
            if re = '1' then                -- read operation
                data_buf <= ram(to_integer(unsigned(addr)));
            end if;
            dout <= data_buf;
        end if;

    end process;

end architecture dual_port;