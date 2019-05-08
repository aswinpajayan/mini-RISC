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
--	EPC	 -- Exception PC value , Value captured just before a pipeline stall --now used for jump on R7 
entity fetch_stage is port(RF_JUMP_ADDRESS,DEC_JUMP_ADDRESS,EPC : in 	STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
			clk,reset : in 	STD_LOGIC;
			PC_INX,INSTN : out STD_LOGIC_VECTOR (GLOBAL_WIDTH -1 downto 0);
			SIG_BEQ_EQ ,SIG_R7_JUMP: in STD_LOGIC;
			RS_CTL_JLR,RS_CTL_BEQ,DEC_CTL_JAL : in STD_LOGIC);
end entity fetch_stage;

architecture rtl of fetch_stage is	

	component instn_memory is generic(SIZE : POSITIVE :=64;
			WIDTH: POSITIVE :=16);
			port(instn_address : in STD_LOGIC_VECTOR(WIDTH -1 downto 0);
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

     pc_inc <= std_logic_vector(unsigned(instn_address) + 1);
	

     mux_out <= RF_JUMP_ADDRESS when ((RS_CTL_BEQ = '1'  and SIG_BEQ_EQ = '1') or RS_CTL_JLR = '1') else
		DEC_JUMP_ADDRESS when (DEC_CTL_JAL = '1' ) else
		EPC when (SIG_R7_JUMP = '1') else
		pc_inc;
     PC_INX <= pc_inc;

end architecture rtl;

