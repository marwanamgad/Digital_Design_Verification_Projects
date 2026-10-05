vlib work
vlog -f src_files.list +cover -covercells
vsim -voptargs=+acc work.top -cover -classdebug -uvmcontrol=all
add wave /top/shift_regif/*
add wave /top/DUT/sva_inst/a_reset /top/DUT/sva_inst/a_shift_left /top/DUT/sva_inst/a_shift_right /top/DUT/sva_inst/a_rotate_left /top/DUT/sva_inst/a_rotate_right
run 0
add wave -position insertpoint  \
sim:/uvm_root/uvm_test_top/env/sb/seq_item_sb \
sim:/uvm_root/uvm_test_top/env/sb/shift_reg_out_ref
coverage save shift_reg.ucdb -onexit
run -all
vcover report shift_reg.ucdb -details -annotate -all -output coverage_rpt.txt