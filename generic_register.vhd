library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity generic_register is generic(N : POSITIVE :=16);
			port(data_in : in STD_LOGIC_VECTOR( N-1 DOWNTO 0);
			    clk,clear: in STD_LOGIC;
			     data_out: out STD_LOGIC_VECTOR( N-1 DOWNTO 0));
end entity generic_register;

architecture behav of generic_register is
signal single_reg : STD_LOGIC_VECTOR (N-1 downto 0):= (others => '0');
begin 
	--concurrent assignments, asynchronous processes
	data_out <= single_reg;
process (clk,clear) begin
	if(rising_edge(clk)) then
		if clear = '0' then
			single_reg <= data_in ;

		end if;
	end if;
	if(clear = '1') then 
		single_reg <= (others => '0'); --asynchronous clear
	end if;
end process;
end behav;

