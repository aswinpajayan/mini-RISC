library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;
use work.CONSTANTS.all;
entity hazard_detection is port(RF_RS1,RF_RS2: in STD_LOGIC_VECTOR(2 downto 0);
	EX_RD,MEM_RD,WB_RD : in STD_LOGIC_VECTOR(2 downto 0);
	EX_RESULT,MEM_RESULT,WB_RESULT : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
	EX_CTL_WRITE_REG,MEM_CTL_WRITE_REG,WB_CTL_WRITE_REG : in STD_LOGIC;
	RESET_IN : in STD_LOGIC;
	SIG_FLUSH,SIG_STALL : out STD_LOGIC_VECTOR(5 downto 0);
	SIG_FWD1,SIG_FWD2 : out STD_LOGIC;
	FWD_DATA1,FWD_DATA2 : out STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0));
end entity hazard_detection;

architecture rtl of hazard_detection is



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


begin

	SIG_FLUSH_FETCH <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_DEC   <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_RF    <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_EX    <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_MEM   <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_WB    <='1' when RESET_IN = '1' else '0';
	
	SIG_STALL_FETCH<= '0' when RESET_IN = '1' else '1';   
	SIG_STALL_DEC  <= '0' when RESET_IN = '1' else '1'; 
	SIG_STALL_RF   <= '0' when RESET_IN = '1' else '1'; 
	SIG_STALL_EX   <= '0' when RESET_IN = '1' else '1'; 
	SIG_STALL_MEM  <= '0' when RESET_IN = '1' else '1'; 
	SIG_STALL_WB   <= '0' when RESET_IN = '1' else '1'; 
	
	SIG_FWD1 <= '1' when (((RF_RS1 = EX_RD) and (EX_CTL_WRITE_REG = '1') ) or 
		    	((RF_RS1 = MEM_RD) and (MEM_CTL_WRITE_REG = '1')) or 
			((RF_RS1 = WB_RD) and (WB_CTL_WRITE_REG = '1')))  else
		     '0';
		
	SIG_FWD2 <= '1' when (((RF_RS2 = EX_RD) and (EX_CTL_WRITE_REG = '1') ) or 
			((RF_RS2 = MEM_RD) and (MEM_CTL_WRITE_REG = '1')) or 
			((RF_RS2 = WB_RD) and (WB_CTL_WRITE_REG = '1')))  else
		     '0';


	FWD_DATA1 <= EX_RESULT when RF_RS1 = EX_RD else
		    MEM_RESULT when RF_RS1 = MEM_RD else
		    WB_RESULT when RF_RS1 = WB_RD else
		    (others => '0');

	FWD_DATA2 <= EX_RESULT when RF_RS2 = EX_RD else
		    MEM_RESULT when RF_RS2 = MEM_RD else
		    WB_RESULT when RF_RS2 = WB_RD else
		    (others => '0');


end architecture rtl;