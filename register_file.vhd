library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
use work.CONSTANTS.all;

entity register_file is generic(SIZE : POSITIVE :=8;
				WIDTH: POSITIVE :=16);
			port(read_address1,read_address2,write_address : in STD_LOGIC_VECTOR(integer(log2(real(SIZE)))-1 downto 0);
				clk,write_en : in STD_LOGIC;
				data_out1,data_out2 : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
				data_in : in STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end entity register_file;

architecture rtl of register_file is
	component register_gen is generic(N : POSITIVE :=16);
				port(data_in : in STD_LOGIC_VECTOR( N-1 DOWNTO 0);
					clk  : in STD_LOGIC;
				     data_out : out STD_LOGIC_VECTOR( N-1 DOWNTO 0));
	end component register_gen;


-- this data structure binds all the inputs / outputs of all registers 
type rblock_t is array (NATURAL range <>) of STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
signal rblock_in,rblock_out : rblock_t(GLOBAL_SIZE-1 downto 0) := (others =>(others =>'0'));
signal gated_clk : std_logic; -- this is used to disable the clock when write_enable signal is low 
begin
	generate_rfile: for i in 0 to SIZE -1 generate
		register_inst : register_gen generic map( GLOBAL_WIDTH)
						port map(data_in => rblock_in(i),
							 clk => gated_clk,
							 data_out => rblock_out(i));
	end generate;	
	 data_out1 <= rblock_in(to_integer(unsigned(read_address1)));
	 data_out2 <= rblock_in(to_integer(unsigned(read_address2)));
	 rblock_in(to_integer(unsigned(write_address))) <= data_in;  
	--though the data is placed as input , gated clk ensures that write operation happens only when write_enable is high			
	gated_clk <= clk and write_en; --clock gating 
end architecture rtl;


