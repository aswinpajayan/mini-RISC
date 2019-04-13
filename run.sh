
#run with the name of top level test bench module to analyse the wave forms
./make.sh `find *.vhd | cut -d'.' -f1`
gtkwave "$1.vcd"
rm -f `find *.vcd | grep --invert "$1.vcd" `
