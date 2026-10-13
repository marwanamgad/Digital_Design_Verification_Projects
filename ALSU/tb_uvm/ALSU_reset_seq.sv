package ALSU_reset_seq_pkg;

    import ALSU_seq_item_pkg::*;
    import ALSU_pkg::*;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

class ALSU_reset_seq extends uvm_sequence #(ALSU_seq_item);
    `uvm_object_utils(ALSU_reset_seq);
    ALSU_seq_item seq_item;

    function new (string name = "ALSU_reset_seq");
        super.new(name);
    endfunction

    task body;
        seq_item = ALSU_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.rst       = 1;
        seq_item.A         = 0;
        seq_item.B         = 0;
        seq_item.cin       = 0;
        seq_item.serial_in = 0;
        seq_item.red_op_A  = 0;
        seq_item.red_op_B  = 0;
        seq_item.opcode    = OR;
        seq_item.bypass_A  = 0;
        seq_item.bypass_B  = 0;
        seq_item.direction = 0;
        finish_item(seq_item);
    endtask
endclass

endpackage