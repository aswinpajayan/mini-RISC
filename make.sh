#!/bin/bash
# this make file will take the name of vhd file (without extension) and analyse and elaborate them . 
# use this in the run configuration (if you are using eclipse ) and give the file names as the command line arguments


for module in "$@"
do
	echo "analysing $module"
	ghdl -a --ieee=synopsys "$module.vhd"
	echo "elaborating $module"
	ghdl -e "$module"

	echo "done analysing and elaborating"

done


#checking for test benches and running the result
for module in "$@"
do
	if [[ "${module}" == *"_tb" ]]
	then
		echo "running the test bench files"
		ghdl -r $module --vcd=$module.vcd
		echo "created $module.vcd"
	fi
done
