library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
use work.CONSTANTS.all;
use work.all;
--this will implement the decode stage of the pipeline
--LEGEND 
--	CONTROL_WORD  = a standard logic vector which has all the control signals
--	JUMP_ADD -- jump address
--      alias alias_name : alias_type is object_name; 
entity decode_stage is port(PIPE_REG_FETCH : in 	STD_LOGIC_VECTOR(PIPE_REG_FETCH_SIZE -1 downto 0);
			PIPE_REG_DECODE : out STD_LOGIC_VECTOR (PIPE_REG_DECODE_SIZE - 1 downto 0));
end entity decode_stage;

architecture rtl of decode_stage is	


-------------------- ALIAS declarations start------------------------------
	alias CTL_WORD :STD_LOGIC_VECTOR(CONTROL_WORD_WIDTH -1 downto 0) is PIPE_REG_DECODE(PIPE_REG_DECODE_SIZE-1 downto PIPE_REG_FETCH_SIZE);
	alias INSTRUCTION :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is PIPE_REG_FETCH (GLOBAL_WIDTH -1 downto 0);
	alias PC_INX :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is PIPE_REG_FETCH (PIPE_REG_FETCH_SIZE -1 downto GLOBAL_WIDTH);


	alias CTL_MODIFY_FLAGS : STD_LOGIC_VECTOR(1 downto 0) is CTL_WORD(1  downto 0); -- modify the flags or not "CZ"
	alias CTL_BEQ : STD_LOGIC is CTL_WORD(2);
	alias CTL_JLR : STD_LOGIC is CTL_WORD(3);
	alias CTL_JAL : STD_LOGIC is CTL_WORD(4);
	
	alias CTL_OPERATION_SEL : STD_LOGIC is CTL_WORD(5);
	alias CTL_WRITE_REG : STD_LOGIC is CTL_WORD(6);
	alias CTL_MEMW : STD_LOGIC is CTL_WORD(7);
	alias CTL_MEMR : STD_LOGIC is CTL_WORD(8);
	alias CTL_SEL_IMMEDIATE : STD_LOGIC is CTL_WORD(9);
	
	alias CTL_ADI : STD_LOGIC is CTL_WORD(10);
	alias CTL_LH : STD_LOGIC is CTL_WORD(11);
	alias CTL_SIGNALS : STD_LOGIC_VECTOR(11 downto 0) is CTL_WORD(11 downto 0);

        
	alias RD  : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(14 downto 12);
	alias RS1 : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(17 downto 15);
	alias RS2 : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(20 downto 18);
	
	alias IMMEDIATE_16 : STD_LOGIC_VECTOR(GLOBAL_WIDTH-1 downto 0) is CTL_WORD(36 downto 21);
	
	
	alias ADDRESS : STD_LOGIC_VECTOR(15 downto 0) is CTL_WORD(52 downto 37);


	alias OPCODE : STD_LOGIC_VECTOR (3 downto 0 ) is INSTRUCTION(15 downto 12);

-------------------aliases for opcodes -----------------------------------------------
	constant ADD : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	constant ADC : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	constant ADZ : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	constant ADI : STD_LOGIC_VECTOR (3 downto 0) := "0001";
	constant NDU : STD_LOGIC_VECTOR (3 downto 0) := "0010";
	constant NDC : STD_LOGIC_VECTOR (3 downto 0) := "0010";
	constant NDZ : STD_LOGIC_VECTOR (3 downto 0) := "0010";
	constant LHI : STD_LOGIC_VECTOR (3 downto 0) := "0011";
	constant LW  : STD_LOGIC_VECTOR (3 downto 0) := "0100";
	constant SW  : STD_LOGIC_VECTOR (3 downto 0) := "0101";
	constant LM  : STD_LOGIC_VECTOR (3 downto 0) := "0110";
	constant SM  : STD_LOGIC_VECTOR (3 downto 0) := "0111";
	constant BEQ : STD_LOGIC_VECTOR (3 downto 0) := "1100";
	constant JAL : STD_LOGIC_VECTOR (3 downto 0) := "1000";
	constant JLR : STD_LOGIC_VECTOR (3 downto 0) := "1001";


	constant ALL_NAND : STD_LOGIC_VECTOR (3 downto 0) := "0010";
	constant ALL_ADD  : STD_LOGIC_VECTOR (3 downto 0) := "0000";


------------------------signal declarations ------------------------------------------
	

	signal mux_out,instn_address,pc_inc,immediate: STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);

-------------------------components---------------------------------------------------
	component sign_extender is generic(IN_WIDTH :POSITIVE:=6;
				       WIDTH     :POSITIVE:=16);
				port(immediate_in : in STD_LOGIC_VECTOR(IN_WIDTH -1 downto 0);
				     sign_extended_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end component sign_extender;
	
begin
	SE6 : sign_extender  generic map(IMM_IN_6,GLOBAL_WIDTH)
				port map( immediate_in => INSTRUCTION (5 downto 0),
				sign_extended_out => immediate);

	RS1 <= INSTRUCTION(8 downto 6) when OPCODE = LW else  --LW
	       INSTRUCTION(8 downto 6) when OPCODE = SW else  --SW
	       INSTRUCTION(11 downto 9) ;  --for all other instructions
			 
	RS2 <= INSTRUCTION(11 downto 9) when OPCODE = SW else  --SW
	       INSTRUCTION(8 downto 6) ;   --for all other instructions

	RD <=  INSTRUCTION(8 downto 6) when OPCODE = ADI else   --ADI
	       INSTRUCTION(11 downto 9) when OPCODE = LHI else  --LHI
	       INSTRUCTION(11 downto 9) when OPCODE = LW else  --LW
	       INSTRUCTION(11 downto 9) when OPCODE = JAL else  --JAL
	       INSTRUCTION(11 downto 9) when OPCODE = JLR else  --JLR
	       INSTRUCTION(5 downto 3);  --for all other instructions
		
	ADDRESS <= std_logic_vector(unsigned(PC_INX) + unsigned(immediate));
	--zero flag control 
	CTL_MODIFY_FLAGS(0) <= '1' when( (OPCODE = ALL_ADD) or (OPCODE = ADI) or (OPCODE = ALL_NAND )) else '0';
	--carry flag control 
	CTL_MODIFY_FLAGS(1) <= '1' when( (OPCODE = ALL_ADD) or (OPCODE = ADI)) else '0';
	--for branch instructions
	CTL_BEQ <= '1' when (OPCODE = BEQ) else '0';
	CTL_JLR <= '1' when (OPCODE = JLR) else '0';
	CTL_JAL <= '1' when (OPCODE = JAL) else '0';
			        
 	--do add(0) or nand(1)
	CTL_OPERATION_SEL <= '1' when (OPCODE = ALL_NAND) else '0';

	--write back to register file (dont write in these cases 
	CTL_WRITE_REG <= '0' when( (OPCODE = SW) or (OPCODE = SM ) or (OPCODE = BEQ)) else '1';

	-- mem read write CTL
	CTL_MEMW <= '1' when( (OPCODE = SW) or (OPCODE = SM)) else '0';
	CTL_MEMR <= '1' when( (OPCODE = LW) or (OPCODE = LM)) else '0';
	
	-- select immediate as operand 2
	CTL_SEL_IMMEDIATE <= '1' when( (OPCODE = ADI) or (OPCODE = LW) or (OPCODE = SW)
			     		or (OPCODE = LM) or (OPCODE = SM))else '0';

	CTL_ADI <= '1' when (OPCODE = ADI) else '0';
	CTL_LH  <= '1' when (OPCODE = LHI) else '0' ;
      
	-- branch target addresses are not calculated in ALU 
	
	--storing either Sign extended six bits (immediate) or shifted 9 bits)
	IMMEDIATE_16 <= (INSTRUCTION(8 downto 0) & "0000000") when OPCODE = LHI else	
			immediate;
	

	--passing on input pipeline(32) bits to output
	PIPE_REG_DECODE(PIPE_REG_FETCH_SIZE -1 downto 0) <= PIPE_REG_FETCH;
end architecture rtl;


