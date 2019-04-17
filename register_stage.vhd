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
entity register_stage is port(PIPE_REG_DECODE : in 	STD_LOGIC_VECTOR(PIPE_REG_DECODE_SIZE -1 downto 0);
			WB_RD :in STD_LOGIC_VECTOR (2 downto 0);
			WB_RESULT : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
			WB_CTL_WRITE_REG : in STD_LOGIC;
			WB_PC_INX : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
			clk : in STD_LOGIC;
			PIPE_REG_OP_FETCH : out STD_LOGIC_VECTOR (PIPE_REG_OP_FETCH_SIZE - 1 downto 0));
end entity register_stage;

architecture rtl of register_stage is	


-------------------- ALIAS declarations start------------------------------
	-------CTL_WORD has previous CONTROL_WORD 
	alias CTL_WORD :STD_LOGIC_VECTOR(CONTROL_WORD_WIDTH -1 downto 0) is PIPE_REG_DECODE(PIPE_REG_DECODE_SIZE-1 downto PIPE_REG_FETCH_SIZE);
	alias INSTRUCTION :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is PIPE_REG_DECODE (GLOBAL_WIDTH -1 downto 0);
	alias PC_INX :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is PIPE_REG_DECODE (PIPE_REG_FETCH_SIZE -1 downto GLOBAL_WIDTH);


	alias RS1 : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(2 downto 0);
	alias RS2 : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(5 downto 3);
	alias RD  : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(8 downto 6);
	alias ADDRESS : STD_LOGIC_VECTOR(15 downto 0) is CTL_WORD(24 downto 9);
--	alias IMMEDIATE_16 : STD_LOGIC_VECTOR(15 downto 0) is CTL_WORD(40 downto 25);
	alias CTL_MODIFY_FLAGS : STD_LOGIC_VECTOR(1 downto 0) is CTL_WORD(26 downto 25); -- modify the flags or not "CZ"
	alias CTL_BEQ : STD_LOGIC is CTL_WORD(27);
	alias CTL_JLR : STD_LOGIC is CTL_WORD(28);
	alias CTL_JAL : STD_LOGIC is CTL_WORD(29);
	
	alias CTL_OPERATION_SEL : STD_LOGIC is CTL_WORD(30);
	alias CTL_WRITE_REG : STD_LOGIC is CTL_WORD(31);
	alias CTL_MEMW : STD_LOGIC is CTL_WORD(32);
	alias CTL_MEMR : STD_LOGIC is CTL_WORD(33);
	alias CTL_SEL_IMMEDIATE : STD_LOGIC is CTL_WORD(34);
	
	alias CTL_ADI : STD_LOGIC is CTL_WORD(35);
	alias CTL_LH : STD_LOGIC is CTL_WORD(36);
	alias CTL_SIGNALS : STD_LOGIC_VECTOR(11 downto 0) is CTL_WORD(36 downto 25);


	alias IMMEDIATE_16 : STD_LOGIC_VECTOR(GLOBAL_WIDTH-1 downto 0) is CTL_WORD(52 downto 37);


----------------alias declarations for next stage ---------------------------------
	alias OPERAND_1 : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is PIPE_REG_OP_FETCH(84 downto 69); 
	alias OPERAND_2 : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is PIPE_REG_OP_FETCH(100 downto 85); 
----------------signal declarations -------------------------------------------------
	signal register_out2 :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0); --
                                                                          --
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
		data_out1 => OPERAND_1,
		data_out2 => register_out2,
		data_in => WB_RESULT,
		PC_in => WB_PC_INX);
	
	OPERAND_2 <= IMMEDIATE_16 when CTL_SEL_IMMEDIATE = '1' else 
		     register_out2;

	PIPE_REG_OP_FETCH(68 downto 0) <= PIPE_REG_DECODE(68 downto 0);

end architecture rtl;
