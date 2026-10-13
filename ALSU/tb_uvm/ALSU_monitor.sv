package ALSU_monitor_pkg;
  
    import ALSU_seq_item_pkg::*;
    import ALSU_config_pkg::*;
    import ALSU_pkg::*;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_monitor extends uvm_monitor;
        `uvm_component_utils(ALSU_monitor)

        virtual ALSU_interface ALSU_vif;
        ALSU_seq_item rsp_seq_item;
        uvm_analysis_port #(ALSU_seq_item) mon_ap;

        function new(string name = "ALSU_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap", this);
        endfunction: build_phase

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                rsp_seq_item = ALSU_seq_item::type_id::create("rsp_seq_item");
                @(negedge ALSU_vif.clk);
                rsp_seq_item.rst       = ALSU_vif.rst;
                rsp_seq_item.A         = ALSU_vif.A;
                rsp_seq_item.B         = ALSU_vif.B;
                rsp_seq_item.cin       = ALSU_vif.cin;
                rsp_seq_item.serial_in = ALSU_vif.serial_in;
                rsp_seq_item.red_op_A  = ALSU_vif.red_op_A;
                rsp_seq_item.red_op_B  = ALSU_vif.red_op_B;
                rsp_seq_item.opcode    = opcode_e'(ALSU_vif.opcode);
                rsp_seq_item.bypass_A  = ALSU_vif.bypass_A;
                rsp_seq_item.bypass_B  = ALSU_vif.bypass_B;
                rsp_seq_item.direction = ALSU_vif.direction;
                rsp_seq_item.out       = ALSU_vif.out;
                rsp_seq_item.leds      = ALSU_vif.leds;
                mon_ap.write(rsp_seq_item);
                `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)
            end
        endtask
    endclass

endpackage