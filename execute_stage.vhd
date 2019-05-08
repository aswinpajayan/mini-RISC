library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
use work.CONSTANTS.all;
use work.all;
--this will implement the register stage of the pipeline(operand fetch and write back)
--LEGEND 
--	CONTROL_WORD  = a standard logic vector which has all the control signals
--      alias alias_name : alias_type is object_name; 
entity execute_stage is port(PIPE_REG_EX : in 	STD_LOGIC_VECTOR(PIPE_REG_EX_SIZE -1 downto (GLOBAL_WIDTH*2));
			PREV_FLAGS : in STD_LOGIC_VECTOR(1 downto 0);  --previous intruction op / Forward pipeline
			RF_CONDITION_CODE : in STD_LOGIC_VECTOR(1 downto 0);  --should be mapped to instn(1 downt 0)
			PIPE_REG_MEM : out STD_LOGIC_VECTOR (PIPE_REG_MEM_SIZE - 1 downto (GLOBAL_WIDTH*2)));

end entity execute_stage;

architecture rtl of execute_stage is	




-------------------- ALIAS declarations start------------------------------
	-------CTL_SIGNALS has previous CONTROL_WORD 

	alias CTL_SIGNALS :STD_LOGIC_VECTOR(CONTROL_SIGNALS_WIDTH -1 downto 0) is
		PIPE_REG_EX(PIPE_REG_EX_SIZE - (GLOBAL_WIDTH *3)- REG_ADD_WIDTH - 1
				  downto GLOBAL_WIDTH *2);

	alias CTL_MODIFY_FLAGS : STD_LOGIC_VECTOR(1 downto 0) is CTL_SIGNALS(1  downto 0); -- modify the flags or not "CZ"
	alias CTL_BEQ : STD_LOGIC is CTL_SIGNALS(2);
	alias CTL_JLR : STD_LOGIC is CTL_SIGNALS(3);
	alias CTL_JAL : STD_LOGIC is CTL_SIGNALS(4);
	alias CTL_OPERATION_SEL : STD_LOGIC is CTL_SIGNALS(5);
	alias CTL_WRITE_REG : STD_LOGIC is CTL_SIGNALS(6);
	alias CTL_MEMW : STD_LOGIC is CTL_SIGNALS(7);
	alias CTL_MEMR : STD_LOGIC is CTL_SIGNALS(8);
	alias CTL_SEL_IMMEDIATE : STD_LOGIC is CTL_SIGNALS(9);
	alias CTL_VALIDATE_FLAGS : STD_LOGIC is CTL_SIGNALS(10);
	alias CTL_LHI : STD_LOGIC is CTL_SIGNALS(11);


	--architecture is always add new things to one end of pipeline registers
	--the outer ones are the ones which are taken out sooner
	--writing in this cryptic way to avoid errors
	alias RD  : STD_LOGIC_VECTOR(2  downto 0) is 
		   PIPE_REG_EX(PIPE_REG_EX_SIZE - (GLOBAL_WIDTH *2) - 1
		   			downto 
					PIPE_REG_EX_SIZE - (GLOBAL_WIDTH *2)- REG_ADD_WIDTH);
	
	
	

	alias OPERAND_2 : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is 
		PIPE_REG_EX(PIPE_REG_EX_SIZE -1 
		downto PIPE_REG_EX_SIZE - GLOBAL_WIDTH); 
		
	alias OPERAND_1 : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is 
		PIPE_REG_EX(PIPE_REG_EX_SIZE - GLOBAL_WIDTH -1   
		downto PIPE_REG_EX_SIZE - (GLOBAL_WIDTH*2));   
	-- operand1 to the pipelie register this can be either imm16 or register
	
	alias IMMEDIATE_16 : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is 
		PIPE_REG_EX(PIPE_REG_EX_SIZE - (GLOBAL_WIDTH *2) - 1
		downto PIPE_REG_EX_SIZE - (GLOBAL_WIDTH * 3));

----------------aliases for next stage-----------------------------------------------
	------OPERAND_1 and OPERAND_2 will be thrown out , RESULT will be stored
	------in place of OPERAND_1 , also two flags will be saved 
	alias C : STD_LOGIC is 
	       PIPE_REG_MEM(PIPE_REG_MEM_SIZE - 1);

	alias Z : STD_LOGIC is 
	       PIPE_REG_MEM(PIPE_REG_MEM_SIZE - 2);
	
	alias ADDRESS : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is 
		PIPE_REG_MEM(PIPE_REG_MEM_SIZE -2 -1 
		downto PIPE_REG_MEM_SIZE - 2 - GLOBAL_WIDTH); 
	
	alias RESULT : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is 
		PIPE_REG_MEM(PIPE_REG_MEM_SIZE -(GLOBAL_WIDTH) -2 -1 
		downto PIPE_REG_MEM_SIZE - 2 - GLOBAL_WIDTH*2); 
----------------signal declarations -------------------------------------------------
	signal alu_out,operand_2_in:STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0); 
	signal carry_out,zero_out :STD_LOGIC ; 	--should be updated based on condition flags 
----------------component declarations-----------------------------------------------

	component alu is generic(WIDTH: Natural :=16);
		port(operand_1 : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		     operand_2 : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		     operation_sel : in STD_LOGIC; -- 0 for addition 1 for nand
		     result :out STD_LOGIC_VECTOR (WIDTH -1 downto 0);
			C,Z :out STD_LOGIC);
	end component alu;
begin
	operand_2_in <= IMMEDIATE_16 when (CTL_SEL_IMMEDIATE = '1') else
			OPERAND_2;


	COMP_ALU : alu generic map(GLOBAL_WIDTH)
		  port map(operand_1 => OPERAND_1,
		  operand_2 => operand_2_in,
		  operation_sel => CTL_OPERATION_SEL,
		  result => alu_out,
		  C => carry_out,
		  Z => zero_out);


	RESULT <= OPERAND_2 when CTL_JLR = '1' or CTL_MEMW = '1' else 
		  IMMEDIATE_16 when CTL_LHI ='1' else
		  alu_out;

	ADDRESS <= alu_out;


--connecting remaining input and output ports 
	PIPE_REG_MEM(PIPE_REG_MEM_SIZE - (GLOBAL_WIDTH *2) -2 -1 downto (GLOBAL_WIDTH *2) +7) 
	<= PIPE_REG_EX(PIPE_REG_MEM_SIZE - (GLOBAL_WIDTH *2) -2 -1 downto (GLOBAL_WIDTH *2) +7);


	----we are calculating the output even for conditional add and conditional nand . 
	----we have to invalidate the CTL_WRITE_REG when conditions (C,Z) are not set
	
	PIPE_REG_MEM((GLOBAL_WIDTH *2 ) + 6) <= CTL_WRITE_REG when CTL_VALIDATE_FLAGS = '0' else 
	'1' when ((RF_CONDITION_CODE(1) and PREV_FLAGS(1)  ) = '1') or ((RF_CONDITION_CODE (0) and PREV_FLAGS(0)) = '1') else '0';



	PIPE_REG_MEM((GLOBAL_WIDTH *2) + 5 downto (GLOBAL_WIDTH *2)) <= PIPE_REG_EX((GLOBAL_WIDTH *2) + 5 downto (GLOBAL_WIDTH *2)) ;

	C <= PREV_FLAGS(1) when CTL_MODIFY_FLAGS(1) = '0' else
	     carry_out when ((not(CTL_VALIDATE_FLAGS)) or (CTL_VALIDATE_FLAGS and RF_CONDITION_CODE(1))) ='1' else
		PREV_FLAGS(1);

	Z <= PREV_FLAGS(0) when CTL_MODIFY_FLAGS(0) = '0' else
	     zero_out when ((not(CTL_VALIDATE_FLAGS)) or (CTL_VALIDATE_FLAGS and RF_CONDITION_CODE(0))) ='1' else
		PREV_FLAGS(1);


end architecture rtl;
