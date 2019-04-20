package CONSTANTS is 
	constant GLOBAL_SIZE  : POSITIVE := 8;
	constant GLOBAL_WIDTH : POSITIVE := 16;
	constant I_MEM_SIZE   : POSITIVE := 64;
	constant DATA_MEM_SIZE : POSITIVE := 64;
	constant CONTROL_WORD_WIDTH : POSITIVE := 53;
	constant IMM_IN_6 :POSITIVE := 6;
	constant IMM_IN_9 :POSITIVE := 9;
	constant PIPE_REG_DEC_SIZE : POSITIVE := 32;
	constant PIPE_REG_RF_SIZE : POSITIVE := 85;
	constant PIPE_REG_EX_SIZE :POSITIVE := 95; 
	--removing RS1 and RS2 replacing Address, IMM 16 by operand1, operand2 
	constant PIPE_REG_MEM_SIZE :POSITIVE := 81 ;
	constant CONTROL_SIGNALS_WIDTH : POSITIVE := 12;
	constant REG_ADD_WIDTH : POSITIVE := 3;
	constant PIPE_REG_WB_SIZE : POSITIVE := 63;
	constant D_MEM_SIZE :POSITIVE := 64;
end package CONSTANTS;
