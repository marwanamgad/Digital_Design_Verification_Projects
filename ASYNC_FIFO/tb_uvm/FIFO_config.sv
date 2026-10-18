class FIFO_config extends uvm_object;

`uvm_object_utils(FIFO_config)

virtual FIFO_if FIFO_vif;
uvm_active_passive_enum sel_mode;

function new (string name = "FIFO_config");
    super.new(name);
endfunction

endclass