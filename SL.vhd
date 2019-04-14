library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity SL is generic(WIDTH: POSITIVE := 16);
		port( data_in : in STD_LOGIC_VECTOR(WIDTH -1 downto 0);
		     data_out : out STD_LOGIC_VECTOR(WIDTH -1 downto 0));
end entity SL;
--shift left by one bit 
--memory access is word aligned 
architecture rtl of SL is
begin
	data_out <= '0' & data_in(WIDTH-2 downto 0);
end rtl;

