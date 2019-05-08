------------------------------this uses a simple hack 
------------------------------instead of  clearing the entire register
------------------------------i am just clearing WRITE_REG and CTL_MEMW
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.CONSTANTS.all;
entity gen_pipe_reg is generic(N : POSITIVE :=16);
			port(data_in : in STD_LOGIC_VECTOR( N-1 DOWNTO 0);
			    clk,clear: in STD_LOGIC;
			     data_out: out STD_LOGIC_VECTOR( N-1 DOWNTO 0));
end entity gen_pipe_reg;

architecture behav of gen_pipe_reg is
signal single_reg : STD_LOGIC_VECTOR (N-1 downto 0):= (others => '0');
begin 
	--concurrent assignments, asynchronous processes
	data_out <= single_reg;
process (clk,clear) begin
	if(rising_edge(clk)) then
		if clear = '0' then
			single_reg <= data_in ;

		end if;
		if(clear = '1') then 
		single_reg(N-1 downto GLOBAL_WIDTH ) <= (others => '0'); --disable CTL_WRITE_REG
		single_reg(N-1 downto GLOBAL_WIDTH ) <= (others => '0'); --disable CTL_MEMW
	end if;
	end if;
	
end process;
end behav;


