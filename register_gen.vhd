library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity register_gen is generic(N : POSITIVE :=16);
			port(data_in : in STD_LOGIC_VECTOR( N-1 DOWNTO 0);
				clk  : in STD_LOGIC;
			     data_out : out STD_LOGIC_VECTOR( N-1 DOWNTO 0));
end entity register_gen;

architecture behav of register_gen is
begin 
process (clk) begin
	if(rising_edge(clk)) then 
		data_out <= data_in ;
	end if;
end process;
end behav;

