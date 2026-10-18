class FIFO_sequencer extends uvm_sequencer #(FIFO_seq_item);

`uvm_component_utils(FIFO_sequencer)

function new (string name = "FIFO_sequencer", uvm_component parent = null);
    super.new(name,parent);
endfunction

endclass