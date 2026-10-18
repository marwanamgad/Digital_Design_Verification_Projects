class FIFO_monitor extends uvm_monitor;

`uvm_component_utils(FIFO_monitor)

virtual FIFO_if FIFO_vif;
uvm_analysis_port #(FIFO_seq_item) mon_ap;

function new (string name = "FIFO_monitor", uvm_component parent = null);
    super.new(name,parent);
endfunction

function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    mon_ap = new("mon_ap",this);
endfunction

task run_phase (uvm_phase phase);
    super.run_phase(phase);
    // One thread per clock domain
    fork
        monitor_wr();
        monitor_rd();
    join
endtask

// Write domain: every posedge i_wclk
task monitor_wr ();
    FIFO_seq_item seq_item;
    forever begin
        @(FIFO_vif.cb_monitor_wr);
        seq_item = FIFO_seq_item::type_id::create("wr_seq_item");
        seq_item.side        = FIFO_seq_item::WR_SIDE;
        seq_item.i_rst_n     = FIFO_vif.cb_monitor_wr.i_rst_n;
        seq_item.i_wen       = FIFO_vif.cb_monitor_wr.i_wen;
        seq_item.i_wdata     = FIFO_vif.cb_monitor_wr.i_wdata;
        seq_item.o_full      = FIFO_vif.cb_monitor_wr.o_full;
        seq_item.o_full_gold = FIFO_vif.cb_monitor_wr.o_full_gold;
        mon_ap.write(seq_item);
        `uvm_info("monitor_wr",seq_item.convert2string(),UVM_FULL)
    end
endtask

// Read domain: every posedge i_rclk
task monitor_rd ();
    FIFO_seq_item seq_item;
    forever begin
        @(FIFO_vif.cb_monitor_rd);
        seq_item = FIFO_seq_item::type_id::create("rd_seq_item");
        seq_item.side         = FIFO_seq_item::RD_SIDE;
        seq_item.i_rst_n      = FIFO_vif.cb_monitor_rd.i_rst_n;
        seq_item.i_ren        = FIFO_vif.cb_monitor_rd.i_ren;
        seq_item.o_empty      = FIFO_vif.cb_monitor_rd.o_empty;
        seq_item.o_rdata      = FIFO_vif.cb_monitor_rd.o_rdata;
        seq_item.o_empty_gold = FIFO_vif.cb_monitor_rd.o_empty_gold;
        seq_item.o_rdata_gold = FIFO_vif.cb_monitor_rd.o_rdata_gold;
        mon_ap.write(seq_item);
        `uvm_info("monitor_rd",seq_item.convert2string(),UVM_FULL)
    end
endtask

endclass