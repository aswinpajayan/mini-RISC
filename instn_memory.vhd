library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
use work.CONSTANTS.all;
-- I_MEM_SIZE is in number of instructions
entity instn_memory is generic(SIZE : POSITIVE :=64;
				WIDTH: POSITIVE :=16);
			port(instn_address : in STD_LOGIC_VECTOR(WIDTH -1 downto 0);
				     instn : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end entity instn_memory;
--Notice that size of instructon memory in bytes is I_MEM_SIZE * WIDTH /8 
--but for easiness of implementation, lets assume :the memory is word addressable
--adress bus width should be log2(I_MEM_SIZE)

architecture rtl of instn_memory is
-- this data structure implements a basic register block 
type rblock_t is array (INTEGER range <>) of STD_LOGIC_VECTOR(WIDTH -1 downto 0);
signal rblock : rblock_t(I_MEM_SIZE-1 downto 0) := (others =>(others =>'0'));
begin
	 instn <= rblock(to_integer(unsigned(instn_address)));

end architecture rtl;

