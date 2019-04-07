library ieee;
use IEEE.std_logic_1164.all;

entity alu is 
	generic(width: Natural :=16);
	port(a : in std_logic_vector(width-1 downto 0);
	    b : in std_logic_vector(width-1 downto 0);
    	c :out std_logic_vector (width -1 downto 0));
end entity alu;
