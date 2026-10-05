import shift_reg_test_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"


module top();

  bit clk;

  initial begin
    clk = 0;
    forever begin
      #1 clk = ~clk;
    end
  end

  shift_reg_if shift_regif (clk);
  shift_reg DUT(clk, shift_regif.reset, shift_regif.serial_in, shift_regif.direction, shift_regif.mode, shift_regif.datain, shift_regif.dataout);
  bind shift_reg shift_reg_sva sva_inst (clk, reset, serial_in, direction, mode, datain, dataout);

  initial begin
    uvm_config_db #(virtual shift_reg_if) :: set (null, "uvm_test_top", "SHIFT_REG_IF", shift_regif);

    run_test ("shift_reg_test");
  end
endmodule