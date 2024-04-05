library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RGBArrayColumnScanning is
  generic ( singleColor         : std_logic := '0';
            -- for the color value:
            -- bit 2 = red
            -- bit 1 = green
            -- bit 0 = blue
            singleColorValueRGB : std_logic_vector( 2 downto 0 ) := "101");
  port ( clk_148_5_MHz     : in  std_logic;
         
         -- here you can connect your value for each of the
         -- 110 RGB-LEDs. The bit-index is calculated by:
         -- bit_index = column * 10 + row
         -- these vectors are active high, meaning a 1 will
         -- light up the LED
         internalRedLeds   : in  std_logic_vector( 109 downto 0 );
         internalBlueLeds  : in  std_logic_vector( 109 downto 0 );
         internalGreenLeds : in  std_logic_vector( 109 downto 0 );
  
         -- here the signals to the external array are defined
         columnAddress     : out std_logic_vector( 3 downto 0 );
         rowRedLeds_b      : out std_logic_vector( 9 downto 0 );
         rowGreenLeds_b    : out std_logic_vector( 9 downto 0 );
         rowBlueLeds_b     : out std_logic_vector( 9 downto 0 ));
end RGBArrayColumnScanning;

architecture leguan of RGBArrayColumnScanning is

  signal s_scanningCounterReg  : unsigned( 17 downto 0 );
  signal s_scanningCounterNext : unsigned( 17 downto 0 );
  signal s_tickNext            : std_logic;
  signal s_tickReg             : std_logic;
  signal s_columnCounterNext   : unsigned( 3 downto 0 );
  signal s_columnCounterReg    : unsigned( 3 downto 0 );
  signal s_correctRedColumn    : std_logic_vector( 9 downto 0 );
  signal s_correctGreenColumn  : std_logic_vector( 9 downto 0 );
  signal s_correctBlueColumn   : std_logic_vector( 9 downto 0 );

begin
  -- first we define the scanning frequency, for this purpose we
  -- introduce a counter that will activate so now and than a "tick"
  -- that than controls the rest of the circuit.
  
  s_scanningCounterNext <= (others => '0') when s_tickReg /= '0' and s_tickReg /= '1' else
                           -- the above line is for simulation only and has no influence
                           -- on the actual hardware
                           to_unsigned( 148499, 18 ) when s_tickNext = '1' else
                           s_scanningCounterReg - 1;
  s_tickNext <= '1' when s_scanningCounterReg = to_unsigned( 0 , 15 ) else '0';
  
  scanningFlipFlops : process ( clk_148_5_MHz ) is
  begin
    if (rising_edge(clk_148_5_MHz)) then
      s_scanningCounterReg <= s_scanningCounterNext;
      s_tickReg            <= s_tickNext;
    end if;
  end process scanningFlipFlops;
  
  -- here we define the column counter
  columnAddress       <= std_logic_vector( s_columnCounterReg );
  s_columnCounterNext <= (others => '0') when s_tickReg /= '0' and s_tickReg /= '1' else
                         -- the above line is for simulation only and has no influence
                         -- on the actual hardware
                         s_columnCounterReg when s_tickReg = '0' else
                         to_unsigned( 10 , 4 ) when s_columnCounterReg = to_unsigned( 0 , 4 ) else
                         s_columnCounterReg - 1;

  columnCounterFlipFlops : process ( clk_148_5_MHz ) is
  begin
    if (rising_edge(clk_148_5_MHz)) then
      s_columnCounterReg <= s_columnCounterNext;
    end if;
  end process columnCounterFlipFlops;
  
  -- finally we have to put the correct RGB values on the correct RGB outputs
  selectCorrectColumn : process ( s_columnCounterReg , internalRedLeds, internalBlueLeds ,
                                  internalGreenLeds ) is
  begin
    case ( s_columnCounterReg ) is
      when "0000" => s_correctRedColumn   <= internalRedLeds( 9 DOWNTO 0 );
                     s_correctGreenColumn <= internalGreenLeds( 9 DOWNTO 0 );
                     s_correctBlueColumn  <= internalBlueLeds( 9 DOWNTO 0 );
      when "0001" => s_correctRedColumn   <= internalRedLeds( 19 DOWNTO 10 );
                     s_correctGreenColumn <= internalGreenLeds( 19 DOWNTO 10 );
                     s_correctBlueColumn  <= internalBlueLeds( 19 DOWNTO 10 );
      when "0010" => s_correctRedColumn   <= internalRedLeds( 29 DOWNTO 20 );
                     s_correctGreenColumn <= internalGreenLeds( 29 DOWNTO 20 );
                     s_correctBlueColumn  <= internalBlueLeds( 29 DOWNTO 20 );
      when "0011" => s_correctRedColumn   <= internalRedLeds( 39 DOWNTO 30 );
                     s_correctGreenColumn <= internalGreenLeds( 39 DOWNTO 30 );
                     s_correctBlueColumn  <= internalBlueLeds( 39 DOWNTO 30 );
      when "0100" => s_correctRedColumn   <= internalRedLeds( 49 DOWNTO 40 );
                     s_correctGreenColumn <= internalGreenLeds( 49 DOWNTO 40 );
                     s_correctBlueColumn  <= internalBlueLeds( 49 DOWNTO 40 );
      when "0101" => s_correctRedColumn   <= internalRedLeds( 59 DOWNTO 50 );
                     s_correctGreenColumn <= internalGreenLeds( 59 DOWNTO 50 );
                     s_correctBlueColumn  <= internalBlueLeds( 59 DOWNTO 50 );
      when "0110" => s_correctRedColumn   <= internalRedLeds( 69 DOWNTO 60 );
                     s_correctGreenColumn <= internalGreenLeds( 69 DOWNTO 60 );
                     s_correctBlueColumn  <= internalBlueLeds( 69 DOWNTO 60 );
      when "0111" => s_correctRedColumn   <= internalRedLeds( 79 DOWNTO 70 );
                     s_correctGreenColumn <= internalGreenLeds( 79 DOWNTO 70 );
                     s_correctBlueColumn  <= internalBlueLeds( 79 DOWNTO 70 );
      when "1000" => s_correctRedColumn   <= internalRedLeds( 89 DOWNTO 80 );
                     s_correctGreenColumn <= internalGreenLeds( 89 DOWNTO 80 );
                     s_correctBlueColumn  <= internalBlueLeds( 89 DOWNTO 80 );
      when "1001" => s_correctRedColumn   <= internalRedLeds( 99 DOWNTO 90 );
                     s_correctGreenColumn <= internalGreenLeds( 99 DOWNTO 90 );
                     s_correctBlueColumn  <= internalBlueLeds( 99 DOWNTO 90 );
      when "1010" => s_correctRedColumn   <= internalRedLeds( 109 DOWNTO 100 );
                     s_correctGreenColumn <= internalGreenLeds( 109 DOWNTO 100 );
                     s_correctBlueColumn  <= internalBlueLeds( 109 DOWNTO 100 );
      when others => s_correctRedColumn   <= ( others => '-' );
                     s_correctGreenColumn <= ( others => '-' );
                     s_correctBlueColumn  <= ( others => '-' );
    end case;
  end process selectCorrectColumn;
  
  genBits : for n in 9 downto 0 generate
    rowRedLeds_b(n)   <= not(s_correctRedColumn(n)) when singleColor = '0' else
                         not(s_correctRedColumn(n) and singleColorValueRGB(2));
    rowGreenLeds_b(n) <= not(s_correctGreenColumn(n)) when singleColor = '0' else
                         not(s_correctGreenColumn(n) and singleColorValueRGB(1));
    rowBlueLeds_b(n)  <= not(s_correctBlueColumn(n)) when singleColor = '0' else
                         not(s_correctBlueColumn(n) and singleColorValueRGB(0));
  end generate genBits;
end leguan;
