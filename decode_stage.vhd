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
entity decode_stage is port(INSTRUCTION : in 	STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
			CTL_WORD : out STD_LOGIC_VECTOR (CONTROL_WORD_WIDTH - 1 downto 0));
end entity decode_stage;

architecture rtl of decode_stage is	


-------------------- ALIAS declarations start------------------------------
	alias RS1 : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(2 downto 0);
	alias RS2 : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(5 downto 3);
	alias RD  : STD_LOGIC_VECTOR(2  downto 0) is CTL_WORD(8 downto 6);
	alias JUMP_ADD : STD_LOGIC_VECTOR(15 downto 0) is CTL_WORD(24 downto 9);
--	alias IMM_VALUE : STD_LOGIC_VECTOR(15 downto 0) is CTL_WORD(40 downto 25);
	alias CTL_MODIFY_FLAG : STD_LOGIC_VECTOR(1 downto 0) is CTL_WORD(42 downto 41);
	alias CTL_BEQ : STD_LOGIC is CTL_WORD(43);
	alias CTL_JLR : STD_LOGIC is CTL_WORD(44);
	alias CTL_JAL : STD_LOGIC is CTL_WORD(45);
	
	alias CTL_OPERATION_SEL : STD_LOGIC is CTL_WORD(47);
	alias CTL_WRITE_REG : STD_LOGIC is CTL_WORD(48);
	alias CTL_MEMW : STD_LOGIC is CTL_WORD(49);
	alias CTL_MEMR : STD_LOGIC is CTL_WORD(46);
	alias CTL_SEL_IMMEDIATE : STD_LOGIC is CTL_WORD(50);
	
	alias CTL_ADI : STD_LOGIC is CTL_WORD(51);
	alias CTL_LH : STD_LOGIC is CTL_WORD(52);
	

	signal mux_out,instn_address,pc_inc: STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
	
begin

	RS1 <= INSTRUCTION(8 downto 6) when INSTRUCTION(15 downto 12) = "0100" else--LW
			 INSTRUCTION(8 downto 6) when INSTRUCTION(15 downto 12) = "0101" else--SW
			 INSTRUCTION(11 downto 9) when not(INSTRUCTION(15 downto 12)="0101");--for all other instructions
			 
	RS2 <= INSTRUCTION(11 downto 9) when INSTRUCTION(15 downto 12) = "0101" else--SW
			 INSTRUCTION(8 downto 6) when not(INSTRUCTION(15 downto 12)="0101");--for all other instructions

	RD <=  INSTRUCTION(8 downto 6) when INSTRUCTION(15 downto 12) = "0001" else--ADI
			 INSTRUCTION(11 downto 9) when INSTRUCTION(15 downto 12) = "0011" else--LHI
			 INSTRUCTION(11 downto 9) when INSTRUCTION(15 downto 12) = "0100" else--LW
			 INSTRUCTION(11 downto 9) when INSTRUCTION(15 downto 12) = "1000" else--JAL
			 INSTRUCTION(11 downto 9) when INSTRUCTION(15 downto 12) = "1001" else--JLR
			 INSTRUCTION(5 downto 3) when not(INSTRUCTION(15 downto 12)="1001");--for all other instructions
		
	CTL_BRANCH <= '1' when INSTRUCTION(15 downto 12) = "1000" else--JAL
					  '1' when INSTRUCTION(15 downto 12) = "1001" else--JLR
					  '0' when not(INSTRUCTION(15 downto 12) = "1001");
	
						
			 

end architecture rtl;


