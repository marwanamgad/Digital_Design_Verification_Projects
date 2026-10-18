module top ();

import FIFO_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

FIFO_if #(.FIFO_WIDTH(FIFO_WIDTH),.FIFO_DEPTH(FIFO_DEPTH)) FIFO_vif ();

ASYNC_FIFO #(.FIFO_WIDTH(FIFO_WIDTH),.FIFO_DEPTH(FIFO_DEPTH)) DUT (FIFO_vif.i_rst_n,FIFO_vif.i_wclk,FIFO_vif.i_wen,FIFO_vif.i_wdata,FIFO_vif.i_rclk,FIFO_vif.i_ren,FIFO_vif.o_full,FIFO_vif.o_empty,FIFO_vif.o_rdata);

ASYNC_FIFO_GOLD #(.DATA_WIDTH(FIFO_WIDTH),.FIFO_DEPTH(FIFO_DEPTH)) DUT_GOLD (FIFO_vif.i_rst_n,FIFO_vif.i_wclk,FIFO_vif.i_wen,FIFO_vif.i_wdata,FIFO_vif.i_rclk,FIFO_vif.i_ren,FIFO_vif.o_full_gold,FIFO_vif.o_empty_gold,FIFO_vif.o_rdata_gold);

bind ASYNC_FIFO ASYNCH_FIFO_sva #(
	.FIFO_WIDTH(FIFO_WIDTH),
	.FIFO_DEPTH(FIFO_DEPTH)
) u_sva (.*);

//Assertions here

initial begin
    uvm_config_db #(virtual FIFO_if)::set(null,"uvm_test_top","FIFO_IF",FIFO_vif);
    run_test();
end

initial begin
    $readmemb("mem.dat",DUT.MEM);
end

endmodule