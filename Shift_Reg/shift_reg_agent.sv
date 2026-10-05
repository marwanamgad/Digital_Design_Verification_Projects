package shift_reg_agent_pkg;

    import shift_reg_sequencer_pkg::*;
    import shift_reg_driver_pkg::*;
    import shift_reg_monitor_pkg::*;
    import shift_reg_config_pkg::*;
    import shift_reg_seq_item_pkg::*;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class shift_reg_agent extends uvm_agent;
        `uvm_component_utils(shift_reg_agent)

        shift_reg_sequencer sqr;
        shift_reg_driver drv;
        shift_reg_monitor mon;
        shift_reg_config shift_reg_cfg;

        uvm_analysis_port #(shift_reg_seq_item) agt_ap;

        function new (string name = "shift_reg_agent", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!uvm_config_db #(shift_reg_config)::get(this , "", "CFG", shift_reg_cfg))begin
                `uvm_fatal("build_phase" , "Unable to get configuration object")
            end

            sqr = shift_reg_sequencer::type_id::create("sqr",this);
            drv = shift_reg_driver::type_id::create("drv",this);
            mon = shift_reg_monitor::type_id::create("mon",this);

            agt_ap = new("agt_ap", this);

        endfunction

        function void connect_phase(uvm_phase phase);
            drv.shift_reg_vif = shift_reg_cfg.shift_reg_vif;
            mon.shift_reg_vif = shift_reg_cfg.shift_reg_vif;

            drv.seq_item_port.connect(sqr.seq_item_export);
            mon.mon_ap.connect(agt_ap);
            
        endfunction
    endclass

endpackage