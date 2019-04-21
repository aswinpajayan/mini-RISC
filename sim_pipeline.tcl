
#deposited instructions for 
#	--LHI R1,0x2000
#	--LHI R0,0x4000
#	--ADD R1,R0,R4
#	--SW  R4,R5,0x10
#	--LW  R2,R0,0x10
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
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(0)  0011001001000000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(1)  0011000010000000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(2)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(3)  0101100101010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(4)  0100110101010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(5)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(6)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(7)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(8)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(9)  0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(10) 0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(11) 0000001000010000 0	
force -freeze sim:/pipeline/FETCH_BLOCK/I_MEMORY/rblock(12) 0000001000010000 0	
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

