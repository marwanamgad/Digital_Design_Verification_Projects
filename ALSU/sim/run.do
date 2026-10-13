vlib work
vlog -f src_files.list +cover=bcesft -covercells
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all -coverage
add wave /top/alsu_if/*
add wave /top/dut/ALSU_sva_inst/*
coverage save ALSU.ucdb -onexit
run 0 
add wave -position insertpoint  \
sim:/uvm_root/uvm_test_top/env/sb/seq_item_sb
run -all