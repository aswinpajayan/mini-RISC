package CONSTANTS is 
	constant GLOBAL_SIZE  : POSITIVE := 8;
	constant GLOBAL_WIDTH : POSITIVE := 16;
	constant I_MEM_SIZE   : POSITIVE := 64;
	constant DATA_MEM_SIZE : POSITIVE := 64;
	constant CONTROL_WORD_WIDTH : POSITIVE := 53;
	constant IMM_IN_6 :POSITIVE := 6;
	constant PIPE_REG_FETCH_SIZE : POSITIVE := 32;
	constant PIPE_REG_DECODE_SIZE : POSITIVE := 85;
end package CONSTANTS;
