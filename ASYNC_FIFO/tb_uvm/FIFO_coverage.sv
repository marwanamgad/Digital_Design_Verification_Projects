class FIFO_coverage extends uvm_component;

`uvm_component_utils(FIFO_coverage)

uvm_analysis_export   #(FIFO_seq_item) cov_export;
uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
FIFO_seq_item seq_item;

// Write domain (ignored while reset is active)
covergroup wr_cg;
    wen_cp      : coverpoint seq_item.i_wen  iff (seq_item.i_rst_n);
    full_cp     : coverpoint seq_item.o_full iff (seq_item.i_rst_n) {
                    bins not_full = {1'b0};
                    bins full     = {1'b1};
                  }
    full_tr_cp  : coverpoint seq_item.o_full iff (seq_item.i_rst_n) {
                    bins became_full = (1'b0 => 1'b1);
                    bins left_full   = (1'b1 => 1'b0);
                  }
    // every data value actually written into the FIFO
    wdata_cp    : coverpoint seq_item.i_wdata iff (seq_item.i_rst_n && seq_item.i_wen && !seq_item.o_full);
    // includes i_wen = 1 while o_full = 1 (write that must be blocked)
    wen_x_full  : cross wen_cp, full_cp iff (seq_item.i_rst_n);
endgroup

// Read domain (ignored while reset is active)
covergroup rd_cg;
    ren_cp      : coverpoint seq_item.i_ren   iff (seq_item.i_rst_n);
    empty_cp    : coverpoint seq_item.o_empty iff (seq_item.i_rst_n) {
                    bins not_empty = {1'b0};
                    bins empty     = {1'b1};
                  }
    empty_tr_cp : coverpoint seq_item.o_empty iff (seq_item.i_rst_n) {
                    bins became_empty = (1'b0 => 1'b1);
                    bins left_empty   = (1'b1 => 1'b0);
                  }
    // includes i_ren = 1 while o_empty = 1 (read that must be blocked)
    ren_x_empty : cross ren_cp, empty_cp iff (seq_item.i_rst_n);
endgroup

function new (string name = "FIFO_coverage", uvm_component parent = null);
    super.new(name,parent);
    wr_cg = new();
    rd_cg = new();
endfunction

function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    cov_export = new("cov_export",this);
    cov_fifo   = new("cov_fifo",this);
endfunction

function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    cov_export.connect(cov_fifo.analysis_export);
endfunction

task run_phase (uvm_phase phase);
    super.run_phase(phase);
    forever begin
        cov_fifo.get(seq_item);
        if (seq_item.side == FIFO_seq_item::WR_SIDE)
            wr_cg.sample();
        else
            rd_cg.sample();
    end
endtask

endclass