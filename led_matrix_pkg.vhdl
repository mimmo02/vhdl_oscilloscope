-------------------------------------------------------------------------------
-- Title      : constants and type definitions for the LED matrix
-------------------------------------------------------------------------------
-- File       : led_matrix_pkg.vhdl
-- Author     : Dominic Tamsel (tsd2@bfh.ch)
-- Company    : BFH-EIT
-- Created    : 2023-04-10
-- Last update: 2023-04-10
-- Platform   : Intel Quartus Prime 18.1
-- Standard   : VHDL'93/02, Math Packages
-------------------------------------------------------------------------------
-- Description:
--
-- This package contains some type and constants definitions specific for the
-- use of the LED matrix on the GECKO4-Education [1] or the LEGUAN FGPA board [2].
--
-- References:
--
-- [1] Theo Kluter, et al.: "GECKO4-Education: FPGA board based on an
--     Altera Cyclone IV FPGA", Wiki, BFH-TI, 2015-2019.
--     <https://gecko-wiki.ti.bfh.ch/gecko4education:start/>, last visited 2023-04-10
--
-- [2] Theo Kluter, et al.: "LEGUAN: An Intel Cyclone 10 based FPGA board
--     for use in the first two years of the bachelor studies at the BFH-TI.", Wiki, BFH-TI, 2022.
--     <https://leguan.ti.bfh.ch/>, last visited 2023-04-10
--
-------------------------------------------------------------------------------
-- Copyright (c) 2023 BFH-EIT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-04-10  1.0      tsd2  	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package led_matrix_pkg is

  constant LED_MATRIX_ROWS : positive := 10;
  constant LED_MATRIX_COLS : positive := 11;

  type led_array is array (0 to LED_MATRIX_ROWS-1) of std_logic_vector(0 to LED_MATRIX_COLS-1);

end package led_matrix_pkg;
