library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
use work.CONSTANTS.all;
--we need an additional port to write back PC to R7
entity register_file is generic(SIZE : POSITIVE :=8;
				WIDTH: POSITIVE :=16);
			port(read_address1,read_address2,write_address : in STD_LOGIC_VECTOR(integer(log2(real(SIZE)))-1 downto 0);
				clk,write_en : in STD_LOGIC;
				data_out1,data_out2,R7_out : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
				data_in,PC_in : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
				RESET_IN : in STD_LOGIC);

--PC +1 should be always kept in last register in the register file  ,
--R7 for a register file of size 8
--no instruction should contain R7 as destination as it will be over-written
end entity register_file;

architecture rtl of register_file is


-- this data structure implements a basic register block 
type rblock_t is array (INTEGER range <>) of STD_LOGIC_VECTOR(WIDTH -1 downto 0);
signal rblock : rblock_t(SIZE-1 downto 0) := (others =>(others =>'0'));
begin 
	 data_out1 <= rblock(to_integer(unsigned(read_address1)));
	 data_out2 <= rblock(to_integer(unsigned(read_address2)));
	 write_process: process(clk,RESET_IN) begin
		 if rising_edge(clk) then
			 if(write_en = '1') and RESET_IN = '0' then
				rblock(to_integer(unsigned('0' & write_address)))<= data_in;
				if(to_integer(unsigned ('0' & write_address))) = 7 then	
					R7_out <= data_in;
				end if;
		 end if;
		end if;
		 rblock(SIZE-1) <= PC_in;
		 if(RESET_IN = '1') then 
		    rblock <= (others =>(others=>'0')); 
		 end if;
	end process write_process;
end architecture rtl;































