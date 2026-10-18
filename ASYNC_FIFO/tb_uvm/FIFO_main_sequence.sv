class FIFO_main_sequence extends uvm_sequence #(FIFO_seq_item);

`uvm_object_utils(FIFO_main_sequence)

FIFO_seq_item seq_item;

function new (string name = "FIFO_main_sequence");
    super.new(name);
endfunction

task body ();
    // Write Sequence: fill the FIFO, then keep writing while full
    repeat(TESTS/2) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.write_only.constraint_mode(1);
        start_item(seq_item);
        if (!seq_item.randomize())
            `uvm_error("body", "Write sequence - randomization failed")
        finish_item(seq_item);
    end

    // Read Sequence: drain the FIFO, then keep reading while empty
    repeat(TESTS/4) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.read_only.constraint_mode(1);
        seq_item.i_wdata.rand_mode(0);   // data_in is not needed in read mode
        seq_item.i_wdata = 0;
        start_item(seq_item);
        if (!seq_item.randomize())
            `uvm_error("body", "Read sequence - randomization failed")
        finish_item(seq_item);
    end

    // Read & Write Sequence: random mix (write_only / read_only are off by default)
    repeat(TESTS/4) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        if (!seq_item.randomize())
            `uvm_error("body", "Read & Write sequence - randomization failed")
        finish_item(seq_item);
    end
endtask

endclass