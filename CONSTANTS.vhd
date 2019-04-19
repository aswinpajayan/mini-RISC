package CONSTANTS is 
	constant GLOBAL_SIZE  : POSITIVE := 8;
	constant GLOBAL_WIDTH : POSITIVE := 16;
	constant I_MEM_SIZE   : POSITIVE := 64;
	constant DATA_MEM_SIZE : POSITIVE := 64;
	constant CONTROL_WORD_WIDTH : POSITIVE := 53;
	constant IMM_IN_6 :POSITIVE := 6;
	constant PIPE_REG_FETCH_SIZE : POSITIVE := 32;
	constant PIPE_REG_DECODE_SIZE : POSITIVE := 85;
	constant PIPE_REG_OP_FETCH_SIZE :POSITIVE := 79; 
	--removing RS1 and RS2 replacing Address, IMM 16 by operand1, operand2 
	constant PIPE_REG_EXECUTE_SIZE :POSITIVE := 85 ;
	constant CONTROL_WORD_WIDTH_OP_FETCH : POSITIVE := 69;
end package CONSTANTS;
