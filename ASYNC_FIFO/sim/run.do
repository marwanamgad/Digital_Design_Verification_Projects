vlib work

# -sv: ASYNC_FIFO.v puts a localparam in its parameter list (SystemVerilog only)
vlog -sv -f src_files.list +cover -covercells

vsim -voptargs=+acc work.top -cover -classdebug -uvmcontrol=all +UVM_TESTNAME=FIFO_test

add wave /top/FIFO_vif/*
add wave /top/DUT/u_sva/*

coverage save -onexit FIFO_cov.ucdb
run -all

coverage report -detail -cvg -directive -comments -output FIFO_cov_report.txt /FIFO_pkg/FIFO_coverage
coverage report -detail -assert -directive -output FIFO_sva_report.txt
coverage report -detail -codeAll -output FIFO_code_cov_report.txt /top/DUT