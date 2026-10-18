package FIFO_pkg;

parameter  FIFO_WIDTH = 4;
parameter  FIFO_DEPTH = 8;
localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
localparam TESTS = 10000;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "FIFO_config.sv"
`include "FIFO_seq_item.sv"
`include "FIFO_reset_sequence.sv"
`include "FIFO_main_sequence.sv"
`include "FIFO_sequencer.sv"
`include "FIFO_driver.sv"
`include "FIFO_monitor.sv"
`include "FIFO_agent.sv"
`include "FIFO_scoreboard.sv"
`include "FIFO_coverage.sv"
`include "FIFO_env.sv"
`include "FIFO_test.sv"
endpackage