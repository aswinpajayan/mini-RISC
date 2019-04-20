library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS.all;
entity pipeline is port(clk : in STD_LOGIC;
			PC_value :out STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0));
end entity pipeline;

architecture rtl of pipeline is 





-----------------component declarations--------------------


	component generic_register is generic(N : POSITIVE :=16);
				port(data_in : in STD_LOGIC_VECTOR( N-1 DOWNTO 0);
				    clk,clear: in STD_LOGIC;
				     data_out: out STD_LOGIC_VECTOR( N-1 DOWNTO 0));
	end component generic_register;



	component fetch_stage is port(RF_JUMP_ADDRESS,DEC_JUMP_ADDRESS,EPC : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
				clk,reset : in 	STD_LOGIC;
				PC_inX,INSTN : out STD_LOGIC_VECTOR (GLOBAL_WIDTH -1 downto 0);
				SIG_BEQ_EQ : in STD_LOGIC;
				RS_CTL_JLR,RS_CTL_BEQ,DEC_CTL_JAL : in STD_LOGIC);
	end component fetch_stage;


	
	component decode_stage is port(PIPE_REG_FETCH : in 	STD_LOGIC_VECTOR(PIPE_REG_FETCH_SIZE -1 downto 0);
				PIPE_REG_DECODE : out STD_LOGIC_VECTOR (PIPE_REG_DECODE_SIZE - 1 downto 0));
	end component decode_stage;



	component register_stage is port(PIPE_REG_DECODE : in 	STD_LOGIC_VECTOR(PIPE_REG_DECODE_SIZE -1 downto (GLOBAL_WIDTH*2));
				WB_RD :in STD_LOGIC_VECTOR (2 downto 0);
				WB_RESULT : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
				WB_CTL_WRITE_REG : in STD_LOGIC;
				WB_PC_inX : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
				clk : in STD_LOGIC;
				PIPE_REG_RF : out STD_LOGIC_VECTOR (PIPE_REG_RF_SIZE - 1 downto (GLOBAL_WIDTH*2));
				RF_JUMP_ADD : out STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
				SIG_BEG_EQ : out STD_LOGIC);

	end component register_stage;



	component execute_stage is port(PIPE_REG_RF : in 	STD_LOGIC_VECTOR(PIPE_REG_RF_SIZE -1 downto (GLOBAL_WIDTH*2));
				EX_FLAGS : in STD_LOGIC_VECTOR(1 downto 0);  --previous intruction op / Forward pipeline
				RF_CONDITION_CODE : in STD_LOGIC_VECTOR(1 downto 0);  --should be mapped to instn(1 downt 0)
				PIPE_REG_EX : out STD_LOGIC_VECTOR (PIPE_REG_EX_SIZE - 1 downto (GLOBAL_WIDTH*2)));

	end component execute_stage;



	component memory_stage is port(PIPE_REG_EX : in 	STD_LOGIC_VECTOR(PIPE_REG_EX_SIZE -1 downto (GLOBAL_WIDTH));
			 clk : in STD_LOGIC;
			 PIPE_REG_MEM : out STD_LOGIC_VECTOR (PIPE_REG_MEM_SIZE - 1 downto (GLOBAL_WIDTH*2)));

	end component memory_stage;


-----------------signal declarations ----------------------
signal sig_pipe_reg_fetch_in	: STD_LOGIC_VECTOR(PIPE_REG_FETCH_SIZE -1 downto 0);
signal sig_pipe_reg_decode_in   : STD_LOGIC_VECTOR(PIPE_REG_DECODE_SIZE -1 downto 0);
signal sig_pipe_reg_ex_in 	: STD_LOGIC_VECTOR(PIPE_REG_EX_SIZE -1 downto 0);
signal sig_pipe_reg_mem_in 	: STD_LOGIC_VECTOR(PIPE_REG_MEM_SIZE -1 downto 0);


signal sig_pipe_reg_fetch_out	: STD_LOGIC_VECTOR(PIPE_REG_FETCH_SIZE -1 downto 0);
signal sig_pipe_reg_decode_out   : STD_LOGIC_VECTOR(PIPE_REG_DECODE_SIZE -1 downto 0);
signal sig_pipe_reg_ex_out 	: STD_LOGIC_VECTOR(PIPE_REG_EX_SIZE -1 downto 0);
signal sig_pipe_reg_mem_out 	: STD_LOGIC_VECTOR(PIPE_REG_MEM_SIZE -1 downto 0);

signal GATED_CLK 	: STD_LOGIC;
signal SIG_FLUSH_FETCH 	: STD_LOGIC;
signal SIG_FLUSH_DECODE : STD_LOGIC;
signal SIG_FLUSH_EX	: STD_LOGIC;
signal SIG_FLUSH_MEM 	: STD_LOGIC;


----------------------alias declarations-------------------

----------------------from PIPE_REG_DECODE----------------
	
	alias DEC_CTL_WORD :STD_LOGIC_VECTOR(CONTROL_WORD_WIDTH -1 downto 0) is sig_pipe_reg_decode_out(PIPE_REG_DECODE_SIZE-1 downto PIPE_REG_FETCH_SIZE);
	alias DEC_INSTRUCTION :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is sig_pipe_reg_decode_out (GLOBAL_WIDTH -1 downto 0);


	alias DEC_CTL_MODIFY_FLAGS : STD_LOGIC_VECTOR(1 downto 0) is DEC_CTL_WORD(1  downto 0); -- modify the flags or not "CZ"
	alias DEC_CTL_BEQ : STD_LOGIC is DEC_CTL_WORD(2);
	alias DEC_CTL_JLR : STD_LOGIC is DEC_CTL_WORD(3);
	alias DEC_CTL_JAL : STD_LOGIC is DEC_CTL_WORD(4);
	
	alias DEC_CTL_OPERATION_SEL : STD_LOGIC is DEC_CTL_WORD(5);
	alias DEC_CTL_WRITE_REG : STD_LOGIC is DEC_CTL_WORD(6);
	alias DEC_CTL_MEMW : STD_LOGIC is DEC_CTL_WORD(7);
	alias DEC_CTL_MEMR : STD_LOGIC is DEC_CTL_WORD(8);
	alias DEC_CTL_SEL_IMMEDIATE : STD_LOGIC is DEC_CTL_WORD(9);
	
	alias DEC_CTL_VALIDATE_FLAG : STD_LOGIC is DEC_CTL_WORD(10);
	alias DEC_CTL_LHI : STD_LOGIC is DEC_CTL_WORD(11);
	alias DEC_CTL_SIGNALS : STD_LOGIC_VECTOR(11 downto 0) is DEC_CTL_WORD(11 downto 0);

	
	alias DEC_RD  : STD_LOGIC_VECTOR(2  downto 0) is DEC_CTL_WORD(14 downto 12);
	alias DEC_RS1 : STD_LOGIC_VECTOR(2  downto 0) is DEC_CTL_WORD(17 downto 15);
	alias DEC_RS2 : STD_LOGIC_VECTOR(2  downto 0) is DEC_CTL_WORD(20 downto 18);
	
	alias DEC_IMMEDIATE_16 : STD_LOGIC_VECTOR(GLOBAL_WIDTH-1 downto 0) is DEC_CTL_WORD(36 downto 21);
	
	
	alias DEC_ADDRESS : STD_LOGIC_VECTOR(15 downto 0) is DEC_CTL_WORD(52 downto 37);



begin

	PIPE_REG_FETCH : generic_register generic map(PIPE_REG_FETCH_SIZE)
				port map(data_in =>sig_pipe_reg_fetch_in,
				clk => GATED_CLK,
				clear => SIG_FLUSH_FETCH,
				data_out => sig_pipe_reg_fetch_out); 



	PIPE_REG_DEC : generic_register generic map(PIPE_REG_DECODE_SIZE)
				port map(data_in =>sig_pipe_reg_decode_in,
				clk => GATED_CLK,
				clear => SIG_FLUSH_FETCH,
				data_out => sig_pipe_reg_decode_out); 


	PIPE_REG_EX : generic_register generic map(PIPE_REG_EX_SIZE)
				port map(data_in =>sig_pipe_reg_ex_in,
				clk => GATED_CLK,
				clear => SIG_FLUSH_FETCH,
				data_out => sig_pipe_reg_ex_out); 


	PIPE_REG_MEM : generic_register generic map(PIPE_REG_FETCH_SIZE)
				port map(data_in =>sig_pipe_reg_fetch_in,
				clk => GATED_CLK,
				clear => SIG_FLUSH_FETCH,
				data_out => sig_pipe_reg_fetch_out); 


end architecture rtl;

