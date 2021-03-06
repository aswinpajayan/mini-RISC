library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS.all;
entity pipeline is port(clk ,RESET_IN: in STD_LOGIC;
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


	
	component decode_stage is port(PIPE_REG_DEC : in 	STD_LOGIC_VECTOR(PIPE_REG_DEC_SIZE -1 downto 0);
				PIPE_REG_RF : out STD_LOGIC_VECTOR (PIPE_REG_RF_SIZE - 1 downto GLOBAL_WIDTH *2));
	end component decode_stage;



	component register_stage is port(PIPE_REG_RF : in 	STD_LOGIC_VECTOR(PIPE_REG_RF_SIZE -1 downto (GLOBAL_WIDTH*2));
				WB_RD :in STD_LOGIC_VECTOR (2 downto 0);
				WB_RESULT : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
				WB_CTL_WRITE_REG : in STD_LOGIC;
				WB_PC_INX : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
				clk : in STD_LOGIC;
				SIG_FWD1,SIG_FWD2 : in STD_LOGIC;
				FWD_DATA1,FWD_DATA2 : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
				PIPE_REG_EX : out STD_LOGIC_VECTOR (PIPE_REG_EX_SIZE - 1 downto (GLOBAL_WIDTH*2));
				RF_JUMP_ADD : out STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
				SIG_BEQ_EQ : out STD_LOGIC);

	end component register_stage;



	component execute_stage is port(PIPE_REG_EX : in 	STD_LOGIC_VECTOR(PIPE_REG_EX_SIZE -1 downto (GLOBAL_WIDTH*2));
				PREV_FLAGS : in STD_LOGIC_VECTOR(1 downto 0);  --previous intruction op / Forward pipeline
				RF_CONDITION_CODE : in STD_LOGIC_VECTOR(1 downto 0);  --should be mapped to instn(1 downt 0)
				PIPE_REG_MEM : out STD_LOGIC_VECTOR (PIPE_REG_MEM_SIZE - 1 downto (GLOBAL_WIDTH*2)));

	end component execute_stage;



	component memory_stage is port(PIPE_REG_MEM : in 	STD_LOGIC_VECTOR(PIPE_REG_MEM_SIZE -1 downto (GLOBAL_WIDTH));
			 clk : in STD_LOGIC;
			 PIPE_REG_WB : out STD_LOGIC_VECTOR (PIPE_REG_WB_SIZE - 1 downto (GLOBAL_WIDTH*2)));

	end component memory_stage;
	

	component hazard_detection is port(RF_RS1,RF_RS2: in STD_LOGIC_VECTOR(2 downto 0);
		EX_RD,MEM_RD,WB_RD : in STD_LOGIC_VECTOR(2 downto 0);
		EX_RESULT,MEM_RESULT,WB_RESULT : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
		RESET_IN,clk : in STD_LOGIC;
		EX_CTL_WRITE_REG,MEM_CTL_WRITE_REG,WB_CTL_WRITE_REG : in STD_LOGIC;
		DEC_CTL_JAL,DEC_CTL_JLR,RF_CTL_JLR,SIG_BEQ_EQ,RF_CTL_BEQ : in STD_LOGIC;
		EX_CTL_MEMR : in STD_LOGIC;
		SIG_FLUSH,SIG_STALL : out STD_LOGIC_VECTOR(5 downto 0);
		SIG_FWD1,SIG_FWD2 : out STD_LOGIC;
		FWD_DATA1,FWD_DATA2 : out STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0));
	end component hazard_detection;



-----------------signal declarations ----------------------
--TODO signal sig_pipe_reg_fetch_in	: STD_LOGIC_VECTOR(PIPE_REG_FETCH_SIZE -1 downto 0); 
signal sig_pipe_reg_dec_in      : STD_LOGIC_VECTOR(PIPE_REG_DEC_SIZE -1 downto 0);
signal sig_pipe_reg_rf_in	: STD_LOGIC_VECTOR(PIPE_REG_RF_SIZE -1 downto 0);
signal sig_pipe_reg_ex_in 	: STD_LOGIC_VECTOR(PIPE_REG_EX_SIZE -1 downto 0);
signal sig_pipe_reg_mem_in 	: STD_LOGIC_VECTOR(PIPE_REG_MEM_SIZE -1 downto 0);
signal sig_pipe_reg_wb_in 	: STD_LOGIC_VECTOR(PIPE_REG_WB_SIZE -1 downto 0);


--TODO signal sig_pipe_reg_fetch_out	: STD_LOGIC_VECTOR(PIPE_REG_FETCH_SIZE -1 downto 0);
signal sig_pipe_reg_dec_out  : STD_LOGIC_VECTOR(PIPE_REG_DEC_SIZE -1 downto 0);
signal sig_pipe_reg_rf_out	: STD_LOGIC_VECTOR(PIPE_REG_RF_SIZE -1 downto 0);
signal sig_pipe_reg_ex_out 	: STD_LOGIC_VECTOR(PIPE_REG_EX_SIZE -1 downto 0);
signal sig_pipe_reg_mem_out 	: STD_LOGIC_VECTOR(PIPE_REG_MEM_SIZE -1 downto 0);
signal sig_pipe_reg_wb_out 	: STD_LOGIC_VECTOR(PIPE_REG_WB_SIZE -1 downto 0);

signal GATED_CLK_FETCH 	: STD_LOGIC :='0';
signal GATED_CLK_DEC 	: STD_LOGIC :='0';
signal GATED_CLK_RF 	: STD_LOGIC :='0';
signal GATED_CLK_EX 	: STD_LOGIC :='0';
signal GATED_CLK_MEM 	: STD_LOGIC :='0';
signal GATED_CLK_WB 	: STD_LOGIC :='0';

signal RF_JUMP_ADD  : STD_LOGIC_VECTOR (GLOBAL_WIDTH -1 downto 0); -- connect to op port of RF stage 
signal EPC 		: STD_LOGIC_VECTOR (GLOBAL_WIDTH -1 downto 0); --for exceptions, not used till now TODO
signal RF_SIG_BEQ_EQ    : STD_LOGIC :='0'; 	--for connecting out port of RF stage to in of fetch stage 	
--signal RS_CTL_BEQ,RS_CTL_JLR : STD_LOGIC; --connecint
signal SIG_STALL,SIG_FLUSH : STD_LOGIC_VECTOR (5 downto 0);
signal SIG_FWD1,SIG_FWD2 : STD_LOGIC ; -- to connect to forward logic out 
signal FWD_DATA1,FWD_DATA2 :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
----------------------alias declarations-------------------

----------------------from various stages ----------------
alias DEC_JUMP_ADDRESS : STD_LOGIC_VECTOR (GLOBAL_WIDTH - 1 downto 0) is sig_pipe_reg_rf_in(84 downto 69);
--alias WB_RD : STD_LOGIC_VECTOR(2 downto 0) is sig_pipe_reg_wb_out(PIPE_REG_WB_SIZE - GLOBAL_WIDTH -1 downto PIPE_REG_WB_SIZE - GLOBAL_WIDTH -3);
--alias WB_RESULT : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is sig_pipe_reg_wb_out(PIPE_REG_WB_SIZE - 1 downto PIPE_REG_WB_SIZE - GLOBAL_WIDTH);
alias WB_CTL_WRITE_REG : STD_LOGIC is sig_pipe_reg_wb_out((GLOBAL_WIDTH *2) + 6) ;
alias EX_CTL_WRITE_REG : STD_LOGIC is sig_pipe_reg_mem_in((GLOBAL_WIDTH *2) + 6) ; --calculated at end of execute stage
alias MEM_CTL_WRITE_REG : STD_LOGIC is sig_pipe_reg_mem_out((GLOBAL_WIDTH *2) + 6) ;
alias WB_PC_INX : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is sig_pipe_reg_wb_out(GLOBAL_WIDTH *2 -1 downto GLOBAL_WIDTH);
alias PREV_FLAGS : STD_LOGIC_VECTOR (1 downto 0) is sig_pipe_reg_mem_out(PIPE_REG_MEM_SIZE -1 downto PIPE_REG_MEM_SIZE -2);
alias RF_CONDITION_CODE : STD_LOGIC_VECTOR (1 downto 0) is sig_pipe_reg_rf_out(GLOBAL_WIDTH -1 downto GLOBAL_WIDTH - 2);
--last two bits of instruction (conditional execution )

-------------aliases for stall logic output----------------

alias 	SIG_FLUSH_FETCH :STD_LOGIC is SIG_FLUSH(0);
alias	SIG_FLUSH_DEC   :STD_LOGIC is SIG_FLUSH(1);
alias	SIG_FLUSH_RF    :STD_LOGIC is SIG_FLUSH(2);
alias	SIG_FLUSH_EX    :STD_LOGIC is SIG_FLUSH(3);
alias	SIG_FLUSH_MEM   :STD_LOGIC is SIG_FLUSH(4);
alias	SIG_FLUSH_WB    :STD_LOGIC is SIG_FLUSH(5);
alias	SIG_STALL_FETCH :STD_LOGIC is SIG_STALL(0);   
alias	SIG_STALL_DEC   :STD_LOGIC is SIG_STALL(1); 
alias	SIG_STALL_RF    :STD_LOGIC is SIG_STALL(2); 
alias	SIG_STALL_EX    :STD_LOGIC is SIG_STALL(3); 
alias	SIG_STALL_MEM   :STD_LOGIC is SIG_STALL(4); 
alias	SIG_STALL_WB    :STD_LOGIC is SIG_STALL(5); 

---------------aliases for hazard detection input---------------------
---------------check alias declaration section of register_stage.vhd for clarity
alias RF_RS1 	: STD_LOGIC_VECTOR(2 downto 0) is sig_pipe_reg_rf_out(GLOBAL_WIDTH *2 + 17 downto GLOBAL_WIDTH *2 + 15);
alias RF_RS2 	: STD_LOGIC_VECTOR(2 downto 0) is sig_pipe_reg_rf_out(GLOBAL_WIDTH *2 + 20 downto GLOBAL_WIDTH *2 + 18);
alias EX_RD 	: STD_LOGIC_VECTOR(2 downto 0) is sig_pipe_reg_ex_out(GLOBAL_WIDTH *2 + 14 downto GLOBAL_WIDTH *2 + 12);
alias MEM_RD 	: STD_LOGIC_VECTOR(2 downto 0) is sig_pipe_reg_mem_out(GLOBAL_WIDTH *2 + 14 downto GLOBAL_WIDTH *2 + 12);
alias WB_RD 	: STD_LOGIC_VECTOR(2 downto 0) is sig_pipe_reg_wb_out(GLOBAL_WIDTH *2 + 14 downto GLOBAL_WIDTH *2 + 12);
alias EX_RESULT	: STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is 
	sig_pipe_reg_mem_in(PIPE_REG_MEM_SIZE -(GLOBAL_WIDTH) -2 -1 
	downto PIPE_REG_MEM_SIZE - 2 - GLOBAL_WIDTH*2); 
-------notice that for ex stage, result is taken before the pipeline---------------


alias MEM_RESULT: STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is 
	sig_pipe_reg_mem_out(PIPE_REG_MEM_SIZE -(GLOBAL_WIDTH) -2 -1 
	downto PIPE_REG_MEM_SIZE - 2 - GLOBAL_WIDTH*2); 

alias WB_RESULT	: STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is 
	sig_pipe_reg_wb_out(PIPE_REG_WB_SIZE - 1 
	downto PIPE_REG_WB_SIZE - GLOBAL_WIDTH);

alias	DEC_CTL_JAL : STD_LOGIC is sig_pipe_reg_rf_in(GLOBAL_WIDTH *2 +  4);
alias	DEC_CTL_JLR : STD_LOGIC is sig_pipe_reg_rf_in(GLOBAL_WIDTH *2 +  3);
alias	RF_CTL_JLR  : STD_LOGIC is sig_pipe_reg_rf_out (GLOBAL_WIDTH *2 +  3);
alias 	RF_CTL_BEQ  : STD_LOGIC is sig_pipe_reg_rf_out (GLOBAL_WIDTH *2 + 2);
alias   EX_CTL_MEMR : STD_LOGIC is sig_pipe_reg_ex_out (GLOBAL_WIDTH *2 + 8);


begin

	PIPE_REG_DEC : generic_register generic map(GLOBAL_WIDTH *2)
				port map(data_in =>sig_pipe_reg_dec_in,
				clk => GATED_CLK_DEC,
				clear => SIG_FLUSH_DEC,
				data_out => sig_pipe_reg_dec_out); 


	PIPE_REG_RF : generic_register generic map(PIPE_REG_RF_SIZE)
				port map(data_in =>sig_pipe_reg_rf_in,
				clk => GATED_CLK_RF,
				clear => SIG_FLUSH_RF,
				data_out => sig_pipe_reg_rf_out); 



	PIPE_REG_EX : generic_register generic map(PIPE_REG_EX_SIZE)
				port map(data_in =>sig_pipe_reg_ex_in,
				clk => GATED_CLK_EX,
				clear => SIG_FLUSH_EX,
				data_out => sig_pipe_reg_ex_out); 


	PIPE_REG_MEM : generic_register generic map(PIPE_REG_MEM_SIZE)
				port map(data_in =>sig_pipe_reg_mem_in,
				clk => GATED_CLK_MEM,
				clear => SIG_FLUSH_MEM,
				data_out => sig_pipe_reg_mem_out); 


	PIPE_REG_WB : generic_register generic map(PIPE_REG_WB_SIZE)
				port map(data_in =>sig_pipe_reg_wb_in,
				clk => GATED_CLK_WB,
				clear => SIG_FLUSH_WB,
				data_out => sig_pipe_reg_wb_out); 


	FETCH_BLOCK : fetch_stage port map(RF_JUMP_ADDRESS => RF_JUMP_ADD,
			DEC_JUMP_ADDRESS => DEC_JUMP_ADDRESS,
			EPC => EPC,
			clk => GATED_CLK_FETCH,
		 	reset => RESET_IN,
			PC_INX => sig_pipe_reg_dec_in (GLOBAL_WIDTH*2 -1 downto GLOBAL_WIDTH),
			INSTN => sig_pipe_reg_dec_in(GLOBAL_WIDTH -1 downto 0),
			SIG_BEQ_EQ => RF_SIG_BEQ_EQ,
			RS_CTL_BEQ => RF_CTL_BEQ,
			RS_CTL_JLR => RF_CTL_JLR,
			DEC_CTL_JAL =>DEC_CTL_JAL
		);

	DECODE_BLOCK : decode_stage port map(PIPE_REG_DEC => sig_pipe_reg_dec_out(31 downto 0),
			PIPE_REG_RF => sig_pipe_reg_rf_in(PIPE_REG_RF_SIZE -1 downto GLOBAL_WIDTH *2));

	REGISTER_BLOCK : register_stage port  map(PIPE_REG_RF => sig_pipe_reg_rf_out(PIPE_REG_RF_SIZE - 1 downto (GLOBAL_WIDTH *2)),
			WB_RD => WB_RD, --RD from write back stage , see the aliases section 
			WB_RESULT => WB_RESULT,
			WB_CTL_WRITE_REG => WB_CTL_WRITE_REG,
			WB_PC_INX => WB_PC_INX,
			clk => clk,
			SIG_FWD1 => SIG_FWD1,
			SIG_FWD2 => SIG_FWD2,
			FWD_DATA1 => FWD_DATA1,
			FWD_DATA2 => FWD_DATA2,
			PIPE_REG_EX => sig_pipe_reg_ex_in(PIPE_REG_EX_SIZE - 1 downto GLOBAL_WIDTH *2 ),
			RF_JUMP_ADD => RF_JUMP_ADD,
			SIG_BEQ_EQ => rF_SIG_BEQ_EQ);

	EXECUTE_BLOCK : execute_stage port map(PIPE_REG_EX => sig_pipe_reg_ex_out(PIPE_REG_EX_SIZE - 1 downto GLOBAL_WIDTH *2),
			PREV_FLAGS => PREV_FLAGS,
			RF_CONDITION_CODE => RF_CONDITION_CODE,
			PIPE_REG_MEM => sig_pipe_reg_mem_in(PIPE_REG_MEM_SIZE - 1 downto GLOBAL_WIDTH*2));

	
			
	MEMORY_BLOCK : memory_stage port map(PIPE_REG_MEM => sig_pipe_reg_mem_out(PIPE_REG_MEM_SIZE -1 downto GLOBAL_WIDTH),
			clk => clk,
			PIPE_REG_WB => sig_pipe_reg_wb_in(PIPE_REG_WB_SIZE -1 downto GLOBAL_WIDTH *2 ));
	
	HAZARD_DETECT_BLOCK : hazard_detection port map(RF_RS1 => RF_RS1,
				RF_RS2 => RF_RS2,
				EX_RD  => EX_RD,
				MEM_RD => MEM_RD,
				WB_RD  => WB_RD,
				RESET_IN => RESET_IN,
				EX_RESULT => EX_RESULT,
				MEM_RESULT => MEM_RESULT,
				WB_RESULT => WB_RESULT,
				EX_CTL_WRITE_REG => EX_CTL_WRITE_REG,
				MEM_CTL_WRITE_REG => MEM_CTL_WRITE_REG,
				WB_CTL_WRITE_REG => WB_CTL_WRITE_REG,
				DEC_CTL_JAL => DEC_CTL_JAL,
				DEC_CTL_JLR => DEC_CTL_JLR,
				RF_CTL_JLR => RF_CTL_JLR,
				RF_CTL_BEQ => RF_CTL_BEQ,
				SIG_BEQ_EQ => RF_SIG_BEQ_EQ,
				EX_CTL_MEMR => EX_CTL_MEMR,
				clk => clk,
				SIG_FLUSH => SIG_FLUSH,
				SIG_STALL => SIG_STALL,
				SIG_FWD1   => SIG_FWD1,
				SIG_FWD2   => SIG_FWD2,
				FWD_DATA1  => FWD_DATA1,
				FWD_DATA2  => FWD_DATA2);

	GATED_CLK_FETCH	 <= clk and SIG_STALL_FETCH	; --TODO change to and with stall logic 
	GATED_CLK_DEC	 <= clk and SIG_STALL_DEC	; --TODO change to and with stall logic 
	GATED_CLK_RF	 <= clk and SIG_STALL_RF	; --TODO change to and with stall logic 
	GATED_CLK_EX 	 <= clk and SIG_STALL_EX	; --TODO change to and with stall logic 
	GATED_CLK_MEM 	 <= clk and SIG_STALL_MEM	; --TODO change to and with stall logic 
	GATED_CLK_WB 	 <= clk and SIG_STALL_WB	; --TODO change to and with stall logic 

----------------------------rippling instruction and pc+1 value through each stages -----------------------------
	sig_pipe_reg_rf_in (GLOBAL_WIDTH *2 - 1 downto 0) <= sig_pipe_reg_dec_out(GLOBAL_WIDTH *2 -1 downto 0);
	sig_pipe_reg_ex_in (GLOBAL_WIDTH *2 - 1 downto 0) <= sig_pipe_reg_rf_out(GLOBAL_WIDTH *2 -1 downto 0);
	sig_pipe_reg_mem_in(GLOBAL_WIDTH *2 - 1 downto 0) <= sig_pipe_reg_ex_out(GLOBAL_WIDTH *2 -1 downto 0);
	sig_pipe_reg_wb_in (GLOBAL_WIDTH *2 - 1 downto 0) <= sig_pipe_reg_mem_out(GLOBAL_WIDTH *2 -1 downto 0);

	PC_value <= sig_pipe_reg_wb_out(GLOBAL_WIDTH *2 -1 downto GLOBAL_WIDTH);

end architecture rtl; 

