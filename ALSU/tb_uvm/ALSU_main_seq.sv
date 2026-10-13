package ALSU_main_seq_pkg;

    import ALSU_seq_item_pkg::*;
    import ALSU_pkg::*;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

class ALSU_main_seq extends uvm_sequence #(ALSU_seq_item);
    `uvm_object_utils(ALSU_main_seq);
    ALSU_seq_item seq_item;

    function new (string name = "ALSU_main_seq");
        super.new(name);
    endfunction

    task body;
       repeat(10000) begin
        seq_item = ALSU_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        assert(seq_item.randomize());
        finish_item(seq_item);
    end
    endtask
     
endclass

endpackage