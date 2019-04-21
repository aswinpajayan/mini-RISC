library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;
use work.CONSTANTS.all;
entity hazard_detection is port(RF_RS1,RF_RS2: in STD_LOGIC_VECTOR(2 downto 0);
	EX_RD,MEM_RD,WB_RD : in STD_LOGIC_VECTOR(2 downto 0);
	EX_RESULT,MEM_RESULT,WB_RESULT : in STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0);
	EX_CTL_WRITE_REG,MEM_CTL_WRITE_REG,WB_CTL_WRITE_REG,RF_CTL_BEQ : in STD_LOGIC;
	DEC_CTL_JAL,DEC_CTL_JLR,RF_CTL_JLR,SIG_BEQ_EQ : in STD_LOGIC;
	EX_CTL_MEMR : STD_LOGIC; --lookout for load dependncy
	RESET_IN ,clk: in STD_LOGIC;
	SIG_FLUSH,SIG_STALL : out STD_LOGIC_VECTOR(5 downto 0);
	SIG_FWD1,SIG_FWD2 : out STD_LOGIC;
	FWD_DATA1,FWD_DATA2 : out STD_LOGIC_VECTOR(GLOBAL_WIDTH -1 downto 0));
end entity hazard_detection;

architecture rtl of hazard_detection is


	
	component generic_register is generic(N : POSITIVE :=16);
				port(data_in : in STD_LOGIC_VECTOR( N-1 DOWNTO 0);
				    clk,clear: in STD_LOGIC;
				     data_out: out STD_LOGIC_VECTOR( N-1 DOWNTO 0));
	end component generic_register;

signal SIG_FLUSH_d : STD_LOGIC_VECTOR(5 downto 0);
signal sig_SIG_FWD1,sig_SIG_FWD2 ,sig_NOT_RESET_IN,sig_LOAD_DEP :STD_LOGIC;



alias 	SIG_FLUSH_FETCH :STD_LOGIC is SIG_FLUSH_d(0);
alias	SIG_FLUSH_DEC   :STD_LOGIC is SIG_FLUSH_d(1);
alias	SIG_FLUSH_RF    :STD_LOGIC is SIG_FLUSH_d(2);
alias	SIG_FLUSH_EX    :STD_LOGIC is SIG_FLUSH_d(3);
alias	SIG_FLUSH_MEM   :STD_LOGIC is SIG_FLUSH_d(4);
alias	SIG_FLUSH_WB    :STD_LOGIC is SIG_FLUSH_d(5);


alias	SIG_STALL_FETCH :STD_LOGIC is SIG_STALL(0);   
alias	SIG_STALL_DEC   :STD_LOGIC is SIG_STALL(1); 
alias	SIG_STALL_RF    :STD_LOGIC is SIG_STALL(2); 
alias	SIG_STALL_EX    :STD_LOGIC is SIG_STALL(3); 
alias	SIG_STALL_MEM   :STD_LOGIC is SIG_STALL(4); 
alias	SIG_STALL_WB    :STD_LOGIC is SIG_STALL(5); 


begin
	DELAY_FLUSH : generic_register generic map(6)
			port map(data_in => SIG_FLUSH_d,
			clk => clk,
			clear => sig_NOT_RESET_IN ,
			data_out => SIG_FLUSH);

--	SIG_FLUSH_FETCH <='1' when (DEC_CTL_JAL or DEC_CTL_JLR) = '1' else
--			'1' when   (RF_CTL_JLR  and SIG_BEQ_EQ )=  '1' else '0';
	SIG_FLUSH_DEC   <='1' when  (DEC_CTL_JAL  or DEC_CTL_JLR )=  '1' else
			  '1' when (RF_CTL_JLR  = '1')  else 
			  '1' when  (RF_CTL_BEQ  and SIG_BEQ_EQ) = '1' else '0';
	SIG_FLUSH_FETCH    <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_RF    <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_EX    <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_MEM   <='1' when RESET_IN = '1' else '0';
	SIG_FLUSH_WB    <='1' when RESET_IN = '1' else '0';
	
	SIG_STALL_EX   <= '0' when RESET_IN = '1' else '1'; 
	SIG_STALL_MEM  <= '0' when RESET_IN = '1' else '1'; 
	SIG_STALL_WB   <= '0' when RESET_IN = '1' else '1'; 
	
	sig_NOT_RESET_IN <= not(RESET_IN);

	sig_LOAD_DEP <=  '1' when ((RF_RS1 = EX_RD) or (RF_RS2 = EX_RD)) else '0';

	SIG_STALL_RF    <= not(sig_LOAD_DEP) when EX_CTL_MEMR = '1' else '1';
	SIG_STALL_DEC    <= not(sig_LOAD_DEP) when EX_CTL_MEMR = '1' else '1';
	SIG_STALL_FETCH   <= not(sig_LOAD_DEP) when EX_CTL_MEMR = '1' else '1';

	
	sig_SIG_FWD1 <= '1' when (((RF_RS1 = EX_RD) and (EX_CTL_WRITE_REG = '1') ) or 
		    	((RF_RS1 = MEM_RD) and (MEM_CTL_WRITE_REG = '1')) or 
			((RF_RS1 = WB_RD) and (WB_CTL_WRITE_REG = '1')))  else
		     '0';
		
	sig_SIG_FWD2 <= '1' when (((RF_RS2 = EX_RD) and (EX_CTL_WRITE_REG = '1') ) or 
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
