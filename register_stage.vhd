library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
use work.CONSTANTS.all;
use work.all;
--this will implement the register stage of the pipeline(operand fetch and write back)
--LEGEND 
--	CONTROL_WORD  = a standard logic vector which has all the control signals
--	JUMP_ADD -- jump address
--      alias alias_name : alias_type is object_name; 
entity register_stage is port(PIPE_REG_DECODE : in 	STD_LOGIC_VECTOR(PIPE_REG_DECODE_SIZE -1 downto (GLOBAL_WIDTH*2));
			WB_RD :in STD_LOGIC_VECTOR (2 downto 0);
			WB_RESULT : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
			WB_CTL_WRITE_REG : in STD_LOGIC;
			WB_PC_INX : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
			clk : in STD_LOGIC;
			PIPE_REG_RF : out STD_LOGIC_VECTOR (PIPE_REG_RF_SIZE - 1 downto (GLOBAL_WIDTH*2));
			RF_JUMP_ADD : out STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
			SIG_BEG_EQ : out STD_LOGIC);

end entity register_stage;

architecture rtl of register_stage is	




-------------------- ALIAS declarations start------------------------------
	-------CTL_WORD has previous CONTROL_WORD 

	alias CTL_WORD :STD_LOGIC_VECTOR(CONTROL_WORD_WIDTH -1 downto 0) is PIPE_REG_DECODE(PIPE_REG_DECODE_SIZE-1 downto PIPE_REG_FETCH_SIZE);

	alias CTL_MODIFY_FLAGS : STD_LOGIC_VECTOR(1 downto 0) is CTL_WORD(1  downto 0); -- modify the flags or not "CZ"
	alias CTL_BEQ : STD_LOGIC is CTL_WORD(2);
	alias CTL_JLR : STD_LOGIC is CTL_WORD(3);
	alias CTL_JAL : STD_LOGIC is CTL_WORD(4);
	alias CTL_OPERATION_SEL : STD_LOGIC is CTL_WORD(5);
	alias CTL_WRITE_REG : STD_LOGIC is CTL_WORD(6);
	alias CTL_MEMW : STD_LOGIC is CTL_WORD(7);
	alias CTL_MEMR : STD_LOGIC is CTL_WORD(8);
	alias CTL_SEL_IMMEDIATE : STD_LOGIC is CTL_WORD(9);
	alias CTL_VALIDATE_FLAGS : STD_LOGIC is CTL_WORD(10);
	alias CTL_LHI : STD_LOGIC is CTL_WORD(11);
	alias CTL_SIGNALS : STD_LOGIC_VECTOR(11 downto 0) is CTL_WORD(11 downto 0);

	alias RD  : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(14 downto 12);
	
	
	alias RS1 : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(17 downto 15);
	alias RS2 : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(20 downto 18);
	
	alias IMMEDIATE_16 : STD_LOGIC_VECTOR(GLOBAL_WIDTH-1 downto 0) is CTL_WORD(36 downto 21);

	alias ADDRESS : STD_LOGIC_VECTOR(15 downto 0) is CTL_WORD(52 downto 37);


----------------alias declarations for next stage ---------------------------------

	

	alias OPERAND_2 : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is 
		PIPE_REG_RF(PIPE_REG_RF_SIZE -1
		downto PIPE_REG_RF_SIZE - GLOBAL_WIDTH); 
	--adding operand2 to the pipeline register

	alias OPERAND_1 : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is 
		PIPE_REG_RF(PIPE_REG_RF_SIZE - GLOBAL_WIDTH -1   
		downto PIPE_REG_RF_SIZE - (GLOBAL_WIDTH*2));   


	-- adding operand1 to the pipelie register this can be either imm16 or register
	alias IMMEDIATE_16_OUT : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is 
		PIPE_REG_RF(PIPE_REG_RF_SIZE - (GLOBAL_WIDTH *2) - 1
		downto PIPE_REG_RF_SIZE - (GLOBAL_WIDTH * 3));
			
----------------signal declarations -------------------------------------------------
	signal register_out1,register_out2 :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0); --
----------------component declarations-----------------------------------------------

	component register_file is generic(SIZE : POSITIVE :=8;
			WIDTH: POSITIVE :=16);
			port(read_address1,read_address2,write_address : in STD_LOGIC_VECTOR(integer(log2(real(SIZE)))-1 downto 0);
			clk,write_en : in STD_LOGIC;
			data_out1,data_out2 : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			data_in,PC_in : in STD_LOGIC_VECTOR (WIDTH-1 downto 0));

	--PC +1 should be always kept in last register in the register file  ,
	--R7 for a register file of size 8
	--no instruction should contain R7 as destination as it will be over-written
	end component register_file;
begin
	RF : register_file generic map(GLOBAL_SIZE,GLOBAL_WIDTH)
		port map(read_address1 => RS1,
		read_address2 => RS2,
		write_address => WB_RD,
		clk => clk,
		write_en => WB_CTL_WRITE_REG,
		data_out1 => register_out1,
		data_out2 => register_out2,
		data_in => WB_RESULT,
		PC_in => WB_PC_INX);

	PIPE_REG_RF((GLOBAL_WIDTH *2) + 11 downto GLOBAL_WIDTH *2) <= CTL_SIGNALS; 
	PIPE_REG_RF((GLOBAL_WIDTH *2) +12 + 2 downto (GLOBAL_WIDTH *2)+ 12) <= RD;
	
	--adding operand 1 and operand2 to pipeline(47 downto 78)
	OPERAND_1 <= register_out1;
	OPERAND_2 <= register_out2;
	
	--adding IMMEDIATE_16 to pipeline later used for address calculation
	IMMEDIATE_16_OUT <= IMMEDIATE_16 ;

	--checking wether to branch on BEQ
	--SIG_BEG_EQ <= '1' when (unsigned(register_out1 xor register_out2) = 0) else '0';
	SIG_BEG_EQ <= '1' when (unsigned(register_out1) = unsigned(register_out2)) else '0';
        
	--calculating jump address and sending to output port
	RF_JUMP_ADD <= register_out2 when CTL_JLR = '1' else	
		       ADDRESS ;


end architecture rtl;
