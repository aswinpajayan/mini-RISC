library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
use work.CONSTANTS.all;
use work.all;
--this will implement the fetch stage of the pipeline
--LEGEND 
--	PC_INC = PC + 1 next instruction
--	JUMP_ADD -- jump address is calculated in Execute stage, stored in REG_PIPE_EX_MEM
--	EPC	 -- Exception PC value , Value captured just before a pipeline stall 
---------TODO ______ decide how to get CTL_BRANCH
entity fetch_stage is port(JUMP_ADD_JL,JUMP_ADD_JLR,BRANCH_ADD,EPC : in 	STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
			clk,reset : in 	STD_LOGIC;
			PC_INX,INSTN : out STD_LOGIC_VECTOR (GLOBAL_WIDTH -1 downto 0);
			CTL_PC_IN : in STD_LOGIC_VECTOR(1 downto 0);
			CTL_BRANCH : in STD_LOGIC);
end entity fetch_stage;

architecture rtl of fetch_stage is	

	component instn_memory is generic(SIZE : POSITIVE :=64;
			WIDTH: POSITIVE :=16);
			port(instn_address : in STD_LOGIC_VECTOR(integer(log2(real(SIZE))) -1 downto 0);
			instn : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));

	end component instn_memory;

	
	component generic_register is generic(N : POSITIVE :=16);
			port(data_in : in STD_LOGIC_VECTOR( N-1 DOWNTO 0);
			clk,clear: in STD_LOGIC;
			data_out: out STD_LOGIC_VECTOR( N-1 DOWNTO 0));
	end component generic_register;
signal mux_out,instn_address,pc_inc: STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
begin
     PC : generic_register generic map(GLOBAL_WIDTH)
     			   port map(data_in => mux_out,
			   clk => clk,
			   clear => reset,
			   data_out => instn_address);

     I_MEMORY : instn_memory  generic map(I_MEM_SIZE,GLOBAL_WIDTH)
     			          port map(instn_address => instn_address,
				  instn => INSTN);

     PC_INX <= std_logic_vector(unsigned(instn_address) + 1);
	
     mux_out <= pc_inc when not(CTL_BRANCH = '1') else  
	       JUMP_ADD_JL when CTL_PC_IN = "00" else
		JUMP_ADD_JLR when CTL_PC_IN = "01" else 
		BRANCH_ADD when CTL_PC_IN = "10" else 
		EPC when CTL_PC_IN = "11" ;

     PC_INX <= pc_inc;

end architecture rtl;

