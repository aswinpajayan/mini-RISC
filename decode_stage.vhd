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
	alias CTL_BRANCH : STD_LOGIC is CTL_WORD(9);
	alias CTL_BEQ : STD_LOGIC is CTL_WORD(10);
	alias CTL_JAL : STD_LOGIC is CTL_WORD(11);
	alias CTL_JLR : STD_LOGIC is CTL_WORD(12);
	alias CTL_WRITE_REG : STD_LOGIC is CTL_WORD(13);
	alias CTL_OPERATION_SEL : STD_LOGIC is CTL_WORD(14);
	alias CTL_SEL_IMMEDIATE : STD_LOGIC is CTL_WORD(15);
	alias CTL_MEMW : STD_LOGIC is CTL_WORD(16);
	alias CTL_ADI : STD_LOGIC is CTL_WORD(12);
	alias CTL_LH : STD_LOGIC is CTL_WORD(12);
	alias CTL_MEMR : STD_LOGIC is CTL_WORD(12);`
begin

end architecture rtl;


