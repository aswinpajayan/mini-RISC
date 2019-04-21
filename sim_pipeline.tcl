
#deposited instructions for 
#	--LHI R1,0x2000
#	--LHI R0,0x01
#	--ADD R1,R0,R4
#	--SW  R4,R0,10
#	--LW  R2,R0,10
#	--LHI R1,0xC000
#	--LHI R2,0xE000
vsim work.pipeline
add wave -position insertpoint  \
sim:/pipeline/clk \
sim:/pipeline/RESET_IN \
sim:/pipeline/PC_value
add wave -position insertpoint  \
sim:/pipeline/REGISTER_BLOCK/RF/rblock

add list -hexadecimal *
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(0)  0011001100100000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(1)  0011000100000001 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(3)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(4)  0101100000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(5)  0100010000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(6)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(7)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(8)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(9)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(10) 0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(11) 0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(12) 0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(13) 0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(14) 0000001000010000 0	

force -freeze sim:/pipeline/RESET_IN 1 0
run
force -freeze sim:/pipeline/RESET_IN 0 1
force -freeze sim:/pipeline/clk 1 0, 0 {50 ps} -r 100  				
run 1200
run 100
force -freeze sim:/pipeline/RESET_IN 0 1
force -freeze sim:/pipeline/clk 1 0, 0 {50 ps} -r 100  				
run 1200

