library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
-- DATA_MEM_SIZE is in number of words 
entity data_memory is generic(  SIZE : POSITIVE :=64;
				WIDTH: POSITIVE :=16);
			port(address : in STD_LOGIC_VECTOR(integer(log2(real(SIZE))) -1 downto 0);
		           clk,write_en : in STD_LOGIC;
			    data_out : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			      data_in: in STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end entity data_memory;
--Notice that size of instructon memory in bytes is DATA_MEM_SIZE * WIDTH / 8
--but for easiness of implementation, lets assume :the memory is word addressable
--adress bus width should be log2(DATA_MEM_SIZE)

architecture rtl of data_memory is
-- this data structure implements a basic register block 
type rblock_t is array (INTEGER range <>) of STD_LOGIC_VECTOR(WIDTH -1 downto 0);
signal rblock : rblock_t(SIZE-1 downto 0) := (others =>(others =>'0'));
begin
	data_out <= rblock(to_integer(unsigned(address)));
	process(clk) begin
		if (rising_edge(clk) and (write_en ='1')) then
			rblock(to_integer(unsigned('0' & address))) <= data_in ;
		end if;
	end process;
end architecture rtl;

