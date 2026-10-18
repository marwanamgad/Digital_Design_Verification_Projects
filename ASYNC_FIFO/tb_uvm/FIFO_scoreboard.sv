class FIFO_scoreboard extends uvm_scoreboard;

`uvm_component_utils(FIFO_scoreboard)

uvm_analysis_export   #(FIFO_seq_item) sb_export;
uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
FIFO_seq_item seq_item;

int correct_count = 0;
int error_count   = 0;

function new (string name = "FIFO_scoreboard", uvm_component parent = null);
    super.new(name,parent);
endfunction

function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    sb_export = new("sb_export",this);
    sb_fifo   = new("sb_fifo",this);
endfunction

function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    sb_export.connect(sb_fifo.analysis_export);
endfunction

task run_phase (uvm_phase phase);
    super.run_phase(phase);
    forever begin
        sb_fifo.get(seq_item);
        check_data(seq_item);
    end
endtask

// Compare DUT vs golden model, each output only in the domain that produces it:
//   write side -> o_full
//   read side  -> o_empty, o_rdata
function void check_data (FIFO_seq_item seq_item);
    bit match;
    if (seq_item.side == FIFO_seq_item::WR_SIDE)
        match = (seq_item.o_full === seq_item.o_full_gold);
    else
        match = (seq_item.o_empty === seq_item.o_empty_gold) &&
                (seq_item.o_rdata === seq_item.o_rdata_gold);

    if (match)
        correct_count++;
    else begin
        error_count++;
        `uvm_error("check_data",$sformatf("Mismatch: %s",seq_item.convert2string()))
    end
endfunction

function void report_phase (uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("report_phase",$sformatf("Total successful checks: %0d",correct_count),UVM_MEDIUM)
    `uvm_info("report_phase",$sformatf("Total failed checks: %0d",error_count),UVM_MEDIUM)
endfunction

endclass