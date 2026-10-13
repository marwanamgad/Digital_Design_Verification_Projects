import uvm_pkg::*;
`include "uvm_macros.svh"
import ALSU_pkg::*;

// ---------------------------------------------------------------------------
// ALSU assertions - bound to the ALSU module from top.sv
//
// Timing of the DUT (2-cycle latency):
//   posedge k   : inputs are registered (A_reg, B_reg, opcode_reg, ...)
//   posedge k+1 : out / leds are updated from the registered values
//   posedge k+2 : the new out / leds are visible to the assertion (sampled)
// So every property looks at the inputs at posedge k and checks
// out / leds ##2 cycles later, using $past(<input>, 2) for the values.
// ---------------------------------------------------------------------------
module ALSU_sva #(parameter INPUT_PRIORITY = "A", parameter FULL_ADDER = "ON")
  (input clk, rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in,
   input [2:0] opcode,
   input signed [2:0] A, B,
   input [15:0] leds,
   input signed [5:0] out);

  // Invalid rule from the spec, applied to the inputs before they are registered
  wire invalid_in = ((red_op_A | red_op_B) & (opcode[1] | opcode[2])) | (opcode[1] & opcode[2]);
  wire no_bypass  = !bypass_A && !bypass_B;
  wire valid_op   = no_bypass && !invalid_in;

  //==========================================================================
  // 1. Reset
  //==========================================================================
  property p_reset;
    @(posedge clk) rst |-> (out == 0 && leds == 0);
  endproperty

  //==========================================================================
  // 2. Bypass (has priority over everything, including invalid cases)
  //==========================================================================
  property p_bypass_both;
    @(posedge clk) disable iff (rst)
      (bypass_A && bypass_B) |-> ##2
        (out == ((INPUT_PRIORITY == "A") ? $past(A,2) : $past(B,2)));
  endproperty

  property p_bypass_A;
    @(posedge clk) disable iff (rst)
      (bypass_A && !bypass_B) |-> ##2 (out == $past(A,2));
  endproperty

  property p_bypass_B;
    @(posedge clk) disable iff (rst)
      (!bypass_A && bypass_B) |-> ##2 (out == $past(B,2));
  endproperty

  //==========================================================================
  // 3. Invalid cases (opcode 6/7, or reduction with opcode other than OR/XOR)
  //==========================================================================
  property p_invalid_out;
    @(posedge clk) disable iff (rst)
      (no_bypass && invalid_in) |-> ##2 (out == 0);
  endproperty

  //==========================================================================
  // 4. OR
  //==========================================================================
  property p_or_reduction;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == OR && (red_op_A || red_op_B)) |-> ##2
        (out == (($past(red_op_A,2) && $past(red_op_B,2)) ?
                    ((INPUT_PRIORITY == "A") ? |$past(A,2) : |$past(B,2)) :
                 $past(red_op_A,2) ? |$past(A,2) : |$past(B,2)));
  endproperty

  property p_or_bitwise;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == OR && !red_op_A && !red_op_B) |-> ##2
        (out == ($past(A,2) | $past(B,2)));
  endproperty

  //==========================================================================
  // 5. XOR
  //==========================================================================
  property p_xor_reduction;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == XOR && (red_op_A || red_op_B)) |-> ##2
        (out == (($past(red_op_A,2) && $past(red_op_B,2)) ?
                    ((INPUT_PRIORITY == "A") ? ^$past(A,2) : ^$past(B,2)) :
                 $past(red_op_A,2) ? ^$past(A,2) : ^$past(B,2)));
  endproperty

  property p_xor_bitwise;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == XOR && !red_op_A && !red_op_B) |-> ##2
        (out == ($past(A,2) ^ $past(B,2)));
  endproperty

  //==========================================================================
  // 6. ADD  (cin is zero-extended and kept signed, like cin_reg in the RTL)
  //==========================================================================
  property p_add;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == ADD) |-> ##2
        (out == ((FULL_ADDER == "ON") ?
                    ($past(A,2) + $past(B,2) + $signed({1'b0, $past(cin,2)})) :
                    ($past(A,2) + $past(B,2))));
  endproperty

  //==========================================================================
  // 7. MULT
  //==========================================================================
  property p_mult;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == MULT) |-> ##2 (out == $past(A,2) * $past(B,2));
  endproperty

  //==========================================================================
  // 8. SHIFT (uses the previous out value)
  //==========================================================================
  property p_shift_left;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == SHIFT && direction) |-> ##2
        (out == {$past(out[4:0]), $past(serial_in,2)});
  endproperty

  property p_shift_right;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == SHIFT && !direction) |-> ##2
        (out == {$past(serial_in,2), $past(out[5:1])});
  endproperty

  //==========================================================================
  // 9. ROTATE (uses the previous out value)
  //==========================================================================
  property p_rotate_left;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == ROTATE && direction) |-> ##2
        (out == {$past(out[4:0]), $past(out[5])});
  endproperty

  property p_rotate_right;
    @(posedge clk) disable iff (rst)
      (valid_op && opcode == ROTATE && !direction) |-> ##2
        (out == {$past(out[0]), $past(out[5:1])});
  endproperty

  //==========================================================================
  // 10. leds (depends only on invalid, NOT on bypass)
  //==========================================================================
  property p_leds_invalid;
    @(posedge clk) disable iff (rst)
      invalid_in |-> ##2 (leds == ~$past(leds));
  endproperty

  property p_leds_valid;
    @(posedge clk) disable iff (rst)
      !invalid_in |-> ##2 (leds == 0);
  endproperty

  //==========================================================================
  // Assert
  //==========================================================================
  a_reset          : assert property (p_reset)          else `uvm_error("ALSU_SVA", "Reset: out/leds are not zero")
  a_bypass_both    : assert property (p_bypass_both)    else `uvm_error("ALSU_SVA", "Bypass both: wrong priority output")
  a_bypass_A       : assert property (p_bypass_A)       else `uvm_error("ALSU_SVA", "Bypass A: out != A")
  a_bypass_B       : assert property (p_bypass_B)       else `uvm_error("ALSU_SVA", "Bypass B: out != B")
  a_invalid_out    : assert property (p_invalid_out)    else `uvm_error("ALSU_SVA", "Invalid case: out != 0")
  a_or_reduction   : assert property (p_or_reduction)   else `uvm_error("ALSU_SVA", "OR reduction wrong")
  a_or_bitwise     : assert property (p_or_bitwise)     else `uvm_error("ALSU_SVA", "OR bitwise wrong")
  a_xor_reduction  : assert property (p_xor_reduction)  else `uvm_error("ALSU_SVA", "XOR reduction wrong")
  a_xor_bitwise    : assert property (p_xor_bitwise)    else `uvm_error("ALSU_SVA", "XOR bitwise wrong")
  a_add            : assert property (p_add)            else `uvm_error("ALSU_SVA", "ADD wrong")
  a_mult           : assert property (p_mult)           else `uvm_error("ALSU_SVA", "MULT wrong")
  a_shift_left     : assert property (p_shift_left)     else `uvm_error("ALSU_SVA", "SHIFT left wrong")
  a_shift_right    : assert property (p_shift_right)    else `uvm_error("ALSU_SVA", "SHIFT right wrong")
  a_rotate_left    : assert property (p_rotate_left)    else `uvm_error("ALSU_SVA", "ROTATE left wrong")
  a_rotate_right   : assert property (p_rotate_right)   else `uvm_error("ALSU_SVA", "ROTATE right wrong")
  a_leds_invalid   : assert property (p_leds_invalid)   else `uvm_error("ALSU_SVA", "leds did not toggle on invalid")
  a_leds_valid     : assert property (p_leds_valid)     else `uvm_error("ALSU_SVA", "leds not zero on valid")

  //==========================================================================
  // Cover - proves each scenario was actually exercised (not just passed vacuously)
  //==========================================================================
  c_reset         : cover property (@(posedge clk) rst);
  c_bypass_both   : cover property (@(posedge clk) disable iff (rst) bypass_A && bypass_B);
  c_bypass_A      : cover property (@(posedge clk) disable iff (rst) bypass_A && !bypass_B);
  c_bypass_B      : cover property (@(posedge clk) disable iff (rst) !bypass_A && bypass_B);
  c_invalid       : cover property (@(posedge clk) disable iff (rst) no_bypass && invalid_in);
  c_or_reduction  : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == OR  && (red_op_A || red_op_B));
  c_or_bitwise    : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == OR  && !red_op_A && !red_op_B);
  c_xor_reduction : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == XOR && (red_op_A || red_op_B));
  c_xor_bitwise   : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == XOR && !red_op_A && !red_op_B);
  c_add           : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == ADD);
  c_mult          : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == MULT);
  c_shift_left    : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == SHIFT  && direction);
  c_shift_right   : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == SHIFT  && !direction);
  c_rotate_left   : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == ROTATE && direction);
  c_rotate_right  : cover property (@(posedge clk) disable iff (rst) valid_op && opcode == ROTATE && !direction);

endmodule