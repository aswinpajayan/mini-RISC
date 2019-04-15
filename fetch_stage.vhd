library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.CONSTANTS.all;
--this will implement the fetch stage of the pipeline
--LEGEND 
--	PC_INC = PC + 1 next instruction
--	JUMP_ADD -- jump address is calculated in Execute stage, stored in REG_PIPE_EX_MEM
--	EPC	 -- Exception PC value , Value captured just before a pipeline stall 
entity fetch_stage is port(PC_INC,JUMP_ADD,EPC : in 	STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);

