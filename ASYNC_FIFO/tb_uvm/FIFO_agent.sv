class FIFO_agent extends uvm_agent;

`uvm_component_utils(FIFO_agent)

FIFO_sequencer sqr;
FIFO_driver    drv;
FIFO_monitor   mon;
FIFO_config    FIFO_cfg;

uvm_analysis_port #(FIFO_seq_item) agt_ap;

function new (string name = "FIFO_agent", uvm_component parent = null);
    super.new(name,parent);
endfunction

function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(FIFO_config)::get(this,"","CFG",FIFO_cfg))
        `uvm_fatal("build_phase","Agent - Unable to get the configuration object from the uvm_config_db")

    if (FIFO_cfg.sel_mode == UVM_ACTIVE) begin
        sqr = FIFO_sequencer::type_id::create("sqr",this);
        drv = FIFO_driver::type_id::create("drv",this);
    end
    mon    = FIFO_monitor::type_id::create("mon",this);

    agt_ap = new("agt_ap",this);
endfunction

function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    mon.FIFO_vif = FIFO_cfg.FIFO_vif;
    mon.mon_ap.connect(agt_ap);

    if (FIFO_cfg.sel_mode == UVM_ACTIVE) begin

        drv.FIFO_vif = FIFO_cfg.FIFO_vif;
        drv.seq_item_port.connect(sqr.seq_item_export);
        
    end
endfunction

endclass