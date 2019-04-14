library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.all;

entity alu is 
	generic(WIDTH: Natural :=16);
	port(operand_1 : in std_logic_vector(WIDTH-1 downto 0);
	     operand_2 : in std_logic_vector(WIDTH-1 downto 0);
	 operation_sel : in STD_LOGIC_VECTOR(1 downto 0);
    	     result :out std_logic_vector (WIDTH -1 downto 0);
     		C,Z :out STD_LOGIC);
end entity alu;
architecture rtl of alu is
signal temp_result : STD_LOGIC_VECTOR(WIDTH downto 0);
begin
	temp_result <=  std_logic_vector(((unsigned('0' & operand_1)) +  (unsigned('0' & operand_2)))) when operation_sel = "00" else	        	     ('0' & operand_1) nand  ('0' & operand_2) when operation_sel = "01" else  --nand
			('0' & operand_1) xor   ('0' & operand_2) when operation_sel = "10" else -- compare BEQ
			(others => '0');
	result <= temp_result(WIDTH-1 downto 0) when not ((operation_sel = "11") or (operation_sel = "10"));
	--dont update result on compare
	C <= temp_result(WIDTH) when operation_sel = "00" else 
	     '0' ;
	Z <= '1' when ((unsigned(temp_result) =0) and not(operation_sel = "11"));

end rtl;

