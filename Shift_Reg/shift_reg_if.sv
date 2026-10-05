interface shift_reg_if (clk);
import shared_pkg::*;

  input clk;
  logic reset;
  logic serial_in;
  direction_e direction;
  mode_e mode;
  logic [5:0] datain, dataout;
  
endinterface 