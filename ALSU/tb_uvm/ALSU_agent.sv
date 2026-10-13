package ALSU_agent_pkg;

    import ALSU_sequencer_pkg::*;
    import ALSU_driver_pkg::*;
    import ALSU_monitor_pkg::*;
    import ALSU_config_pkg::*;
    import ALSU_seq_item_pkg::*;   

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_agent extends uvm_agent;
        `uvm_component_utils(ALSU_agent)
        ALSU_sequencer sqr;
        ALSU_driver drv;
        ALSU_monitor mon;

        ALSU_config alsu_cfg;
        uvm_analysis_port #(ALSU_seq_item) agt_ap;

        function new (string name = "ALSU_agent", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!uvm_config_db #(ALSU_config)::get(this , "", "CFG", alsu_cfg))begin
                `uvm_fatal("build_phase" , "Unable to get configuration object")
            end

            sqr = ALSU_sequencer::type_id::create("sqr",this);
            drv = ALSU_driver::type_id::create("drv",this);
            mon = ALSU_monitor::type_id::create("mon",this);

            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            drv.ALSU_vif = alsu_cfg.alsu_vif;
            mon.ALSU_vif = alsu_cfg.alsu_vif;

            drv.seq_item_port.connect(sqr.seq_item_export);

            mon.mon_ap.connect(agt_ap);
        endfunction
    endclass

endpackage