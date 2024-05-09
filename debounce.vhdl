library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
    port ( 	clk_148_5_MHz		: in std_logic;
			in_btn 	: in std_logic;
			btn_out : out std_logic;
			out_btn 	: out std_logic);
end debounce;

architecture Behavioral of debounce is

	SIGNAL s_counter 			: unsigned(19 downto 0);
	SIGNAL s_btn, s_btn_last	: std_logic;

begin
	process (clk_148_5_MHz)
	begin
		if rising_edge(clk_148_5_MHz) then
			if in_btn = '0' then
				s_counter <= to_unsigned(-1, s_counter'length);
			elsif not(s_counter = 0) then
				s_counter <= s_counter - 1;
			end if;

			if s_counter = 0 then
				s_btn <= '1';
			else
				s_btn <= '0';
			end if;
			s_btn_last <= s_btn;
		end if;
	end process;
	
	btn_out <= s_btn;
	out_btn 	<= '1' when (s_btn = '1') and (s_btn_last = '0') else '0'; 

end Behavioral;

