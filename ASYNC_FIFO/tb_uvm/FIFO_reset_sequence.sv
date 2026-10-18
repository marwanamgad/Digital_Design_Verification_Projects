class FIFO_reset_sequence extends uvm_sequence #(FIFO_seq_item);

`uvm_object_utils(FIFO_reset_sequence)

FIFO_seq_item seq_item;

function new (string name = "FIFO_reset_sequence");
    super.new(name);
endfunction

task body ();
    seq_item = FIFO_seq_item::type_id::create("seq_item");
    start_item(seq_item);
    seq_item.i_rst_n = 0;
    seq_item.i_wen   = 0;
    seq_item.i_ren   = 0;
    seq_item.i_wdata = 0;
    finish_item(seq_item);
endtask

endclass