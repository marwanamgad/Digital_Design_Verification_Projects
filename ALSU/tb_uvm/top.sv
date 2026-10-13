import ALSU_test_pkg::*;

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

  ALSU_interface alsu_if (clk);

  ALSU dut (.A(alsu_if.A), .B(alsu_if.B), .cin(alsu_if.cin), .serial_in(alsu_if.serial_in), .red_op_A(alsu_if.red_op_A), .red_op_B(alsu_if.red_op_B), .opcode(alsu_if.opcode), .bypass_A(alsu_if.bypass_A), .bypass_B(alsu_if.bypass_B),
  .clk(clk), .rst(alsu_if.rst), .direction(alsu_if.direction), .leds(alsu_if.leds), .out(alsu_if.out));


  bind ALSU ALSU_sva #(.INPUT_PRIORITY(INPUT_PRIORITY), .FULL_ADDER(FULL_ADDER)) ALSU_sva_inst (.*);



  initial begin
    uvm_config_db #(virtual ALSU_interface)::set(null,"uvm_test_top", "ALSU_Interface", alsu_if);
    run_test ("ALSU_test");
  end
endmodule