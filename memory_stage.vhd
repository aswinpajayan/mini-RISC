library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.log2;
use work.CONSTANTS.all;
use work.all;
--this will implement the register stage of the pipeline(operand fetch and write back)
--LEGEND 
--	CONTROL_WORD  = a standard logic vector which has all the control signals
--      alias alias_name : alias_type is object_name; 
entity memory_stage is port(PIPE_REG_MEM : in 	STD_LOGIC_VECTOR(PIPE_REG_MEM_SIZE -1 downto (GLOBAL_WIDTH));
		 clk : in STD_LOGIC;
		 PIPE_REG_WB : out STD_LOGIC_VECTOR (PIPE_REG_WB_SIZE - 1 downto (GLOBAL_WIDTH*2)));

end entity memory_stage;

architecture rtl of memory_stage is	




-------------------- ALIAS declarations start------------------------------
	-------CTL_SIGNALS has previous CONTROL_WORD 

	alias CTL_SIGNALS :STD_LOGIC_VECTOR(CONTROL_SIGNALS_WIDTH -1 downto 0) is
		PIPE_REG_MEM((GLOBAL_WIDTH *2) + 12 -1  downto (GLOBAL_WIDTH *2));



	alias CTL_MODIFY_FLAGS : STD_LOGIC_VECTOR(1 downto 0) is CTL_SIGNALS(1  downto 0); -- modify the flags or not "CZ"
	alias CTL_BEQ : STD_LOGIC is CTL_SIGNALS(2);
	alias CTL_JLR : STD_LOGIC is CTL_SIGNALS(3);
	alias CTL_JAL : STD_LOGIC is CTL_SIGNALS(4);
	alias CTL_OPERATION_SEL : STD_LOGIC is CTL_SIGNALS(5);
	alias CTL_WRITE_REG : STD_LOGIC is CTL_SIGNALS(6);
	alias CTL_MEMW : STD_LOGIC is CTL_SIGNALS(7);
	alias CTL_MEMR : STD_LOGIC is CTL_SIGNALS(8);
	alias CTL_SEL_IMMEDIATE : STD_LOGIC is CTL_SIGNALS(9);
	alias CTL_VALIDATE_FLAGS : STD_LOGIC is CTL_SIGNALS(10);
	alias CTL_LHI : STD_LOGIC is CTL_SIGNALS(11);


	--architecture is always add new things to one end of pipeline registers
	--the outer ones are the ones which are taken out sooner
	--writing in this cryptic way to avoid errors
	

----------------aliases for previous stage-----------------------------------------------

	alias RD  : STD_LOGIC_VECTOR(2  downto 0) is 
		   PIPE_REG_MEM((GLOBAL_WIDTH *2)+CONTROL_SIGNALS_WIDTH + 3 - 1 downto (GLOBAL_WIDTH *2)+ CONTROL_SIGNALS_WIDTH);

	------OPERAND_1 and OPERAND_2 will be thrown out , RESULT will be stored
	------in place of OPERAND_1 , also two flags will be saved 
	
	alias DATA_IN : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is 
		PIPE_REG_MEM(PIPE_REG_MEM_SIZE -(GLOBAL_WIDTH) -2 -1 
		downto PIPE_REG_MEM_SIZE - 2 - GLOBAL_WIDTH*2); 
	
	alias ADDRESS : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is 
		PIPE_REG_MEM(PIPE_REG_MEM_SIZE -2 -1 
		downto PIPE_REG_MEM_SIZE - 2 - GLOBAL_WIDTH); 
	alias PC_INX : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0 ) is
		PIPE_REG_MEM( (GLOBAL_WIDTH*2) -1 downto GLOBAL_WIDTH);
	

-----------------alias declarations for output port ---------------------------------


	alias DATA_OUT : STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0) is
		PIPE_REG_WB(PIPE_REG_WB_SIZE - 1 downto PIPE_REG_WB_SIZE - GLOBAL_WIDTH);

	
----------------signal declarations -------------------------------------------------
	signal memory_out :STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0); 
----------------component declarations-----------------------------------------------

	-- DATA_MEM_SIZE is in number of words 
	component data_memory is generic(  SIZE : POSITIVE :=64;
					WIDTH: POSITIVE :=16);
				port(address : in STD_LOGIC_VECTOR(WIDTH -1 downto 0);
				   clk,write_en : in STD_LOGIC;
				    data_out : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
				      data_in: in STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end component  data_memory;
begin


	D_MEM : data_memory generic map (D_MEM_SIZE,GLOBAL_WIDTH)
			    port map(address =>ADDRESS,
				     clk =>clk,
				     write_en =>CTL_MEMW,
				     data_out =>memory_out,
				     data_in =>DATA_IN);






--connecting remaining input and output ports 

	DATA_OUT  <= memory_out when CTL_MEMR='1' else
		     PC_INX when (CTL_JLR='1' or CTL_JAL='1') else
		     DATA_IN;

	PIPE_REG_WB(PIPE_REG_WB_SIZE - (GLOBAL_WIDTH ) -1 downto (GLOBAL_WIDTH *2)) 
	<= PIPE_REG_MEM(PIPE_REG_MEM_SIZE - (GLOBAL_WIDTH *2) -2 -1 downto (GLOBAL_WIDTH *2));


end architecture rtl;
