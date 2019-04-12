library IEEE;
use ieee.std_logic_1164.all;

entity d_ff is port(d,clk   : in std_logic;
		     q	    : out std_logic);
end entity d_ff;

architecture behav of d_ff is begin

process(clk) begin
	if (rising_edge(clk)) then	
	q <= d;
end if;
	end process;
	
end behav;


