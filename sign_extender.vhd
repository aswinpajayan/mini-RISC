library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


entity sign_extender is generic(IN_WIDTH :POSITIVE:=6;
			       WIDTH     :POSITIVE:=16);
			port(immediate_in : in STD_LOGIC_VECTOR(IN_WIDTH -1 downto 0);
			     sign_extended_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end entity sign_extender;

architecture behavioural of sign_extender is 
signal ext_bits : STD_LOGIC_VECTOR((WIDTH - IN_WIDTH)-1 downto 0);
begin
	sign_extended_out(IN_WIDTH -1 downto 0) <= immediate_in;
	sign_extended_out(WIDTH-1 downto IN_WIDTH) <= (others=>'0') when immediate_in(IN_WIDTH -1) = '0' else
						      (others=>'1') when immediate_in(IN_WIDTH -1) = '1';
end architecture behavioural; 
