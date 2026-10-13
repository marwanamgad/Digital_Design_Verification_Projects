package ALSU_coverage_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ALSU_seq_item_pkg::*;
    import ALSU_pkg::*;

    class ALSU_coverage extends uvm_component;
        `uvm_component_utils(ALSU_coverage)

        uvm_analysis_export #(ALSU_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(ALSU_seq_item) cov_fifo;
        ALSU_seq_item seq_item_cov;

        covergroup cvr_grp;
            option.per_instance = 1;

            //-----------------------------------------------------------
            // Baseline opcode coverage. No explicit bins are declared,
            // so the tool auto-generates one bin per opcode_e value
            // (OR, XOR, ADD, MULT, SHIFT, ROTATE, INVALID_6, INVALID_7) -
            // this also gives every cross below per-opcode granularity.
            //-----------------------------------------------------------
            cp_opcode: coverpoint seq_item_cov.opcode;

            //-----------------------------------------------------------
            // Req 1: A and B must take all 3x3 permutations of
            // {ZERO, MAXPOS, MAXNEG} while opcode is ADD or MULT.
            //-----------------------------------------------------------
            // Note: Questa's vopt rejects binsof() references to a "default"
            // bin inside a cross's bin-select expression, so the non-extreme
            // values of A/B are dropped up front with an explicit ignore_bins
            // on each coverpoint (values outside {ZERO=0, MAXPOS=3, MAXNEG=4}
            // are 1, 2, 5, 6, 7). That leaves each coverpoint with exactly
            // 3 bins, so the cross is naturally just the 9 permutations.
            cp_A_extreme_arith: coverpoint seq_item_cov.A iff (seq_item_cov.opcode == ADD || seq_item_cov.opcode == MULT) {
                bins a_zero   = {ZERO};
                bins a_maxpos = {MAXPOS};
                bins a_maxneg = {MAXNEG};
                ignore_bins a_other = {[1:2], [5:7]};
            }

            cp_B_extreme_arith: coverpoint seq_item_cov.B iff (seq_item_cov.opcode == ADD || seq_item_cov.opcode == MULT) {
                bins b_zero   = {ZERO};
                bins b_maxpos = {MAXPOS};
                bins b_maxneg = {MAXNEG};
                ignore_bins b_other = {[1:2], [5:7]};
            }

            cx_AB_extreme_permutations: cross cp_A_extreme_arith, cp_B_extreme_arith;

            //-----------------------------------------------------------
            // Req 2: cin must take 0 and 1 while opcode is ADD.
            //-----------------------------------------------------------
            cp_cin_add: coverpoint seq_item_cov.cin iff (seq_item_cov.opcode == ADD) {
                bins cin_0 = {1'b0};
                bins cin_1 = {1'b1};
            }

            //-----------------------------------------------------------
            // Req 3: direction must take 0 and 1 while opcode is SHIFT or ROTATE.
            //-----------------------------------------------------------
            cp_direction_shift_rotate: coverpoint seq_item_cov.direction iff (seq_item_cov.opcode == SHIFT || seq_item_cov.opcode == ROTATE) {
                bins dir_0 = {1'b0};
                bins dir_1 = {1'b1};
            }

            //-----------------------------------------------------------
            // Req 4: serial_in must take 0 and 1 while opcode is SHIFT.
            //-----------------------------------------------------------
            cp_serial_in_shift: coverpoint seq_item_cov.serial_in iff (seq_item_cov.opcode == SHIFT) {
                bins sin_0 = {1'b0};
                bins sin_1 = {1'b1};
            }

            //-----------------------------------------------------------
            // Req 5: opcode OR/XOR, red_op_A asserted -> A walks the
            // one-hot patterns 001/010/100 while B == 0.
            //-----------------------------------------------------------
            cp_A_walking_ones_redA: coverpoint seq_item_cov.A iff ((seq_item_cov.opcode == OR || seq_item_cov.opcode == XOR) && seq_item_cov.red_op_A) {
                bins walk_001 = {3'b001};
                bins walk_010 = {3'b010};
                bins walk_100 = {3'b100};
            }

            cp_B_zero_redA: coverpoint seq_item_cov.B iff ((seq_item_cov.opcode == OR || seq_item_cov.opcode == XOR) && seq_item_cov.red_op_A) {
                bins b_zero = {3'b000};
            }

            cx_redA_walking_A_B_zero: cross cp_A_walking_ones_redA, cp_B_zero_redA;

            //-----------------------------------------------------------
            // Req 6: opcode OR/XOR, red_op_B asserted (and not red_op_A)
            // -> B walks 001/010/100 while A == 0.
            //-----------------------------------------------------------
            cp_B_walking_ones_redB: coverpoint seq_item_cov.B iff ((seq_item_cov.opcode == OR || seq_item_cov.opcode == XOR) && seq_item_cov.red_op_B && !seq_item_cov.red_op_A) {
                bins walk_001 = {3'b001};
                bins walk_010 = {3'b010};
                bins walk_100 = {3'b100};
            }

            cp_A_zero_redB: coverpoint seq_item_cov.A iff ((seq_item_cov.opcode == OR || seq_item_cov.opcode == XOR) && seq_item_cov.red_op_B && !seq_item_cov.red_op_A) {
                bins a_zero = {3'b000};
            }

            cx_redB_walking_B_A_zero: cross cp_B_walking_ones_redB, cp_A_zero_redB;

            //-----------------------------------------------------------
            // Req 7: invalid case - a reduction op is asserted while
            // opcode is NOT OR/XOR (mirrors invalid_red_op in the RTL).
            //-----------------------------------------------------------
            cp_invalid_reduction: coverpoint {seq_item_cov.red_op_A, seq_item_cov.red_op_B} iff (seq_item_cov.opcode != OR && seq_item_cov.opcode != XOR) {
                bins red_A_only = {2'b10};
                bins red_B_only = {2'b01};
                bins red_both   = {2'b11};
            }

            // Confirms the illegal reduction is exercised against every
            // non-OR/XOR opcode individually. The OR/XOR cross bins can
            // never be hit because of the guard above, so they're dropped.
            cx_invalid_reduction_per_opcode: cross cp_invalid_reduction, cp_opcode {
                ignore_bins unreachable_or_xor = binsof(cp_opcode) intersect {OR, XOR};
            }

            //=============================================================
            // Additional coverage, not explicitly requested.
            //=============================================================

            // Bypass tie-break: exercises the INPUT_PRIORITY mux on the bypass path.
            cp_bypass_priority: coverpoint {seq_item_cov.bypass_A, seq_item_cov.bypass_B} {
                bins none   = {2'b00};
                bins a_only = {2'b10};
                bins b_only = {2'b01};
                bins both   = {2'b11};
            }

            // Reduction tie-break: legal corner case while opcode is OR/XOR.
            cp_reduction_priority_or_xor: coverpoint {seq_item_cov.red_op_A, seq_item_cov.red_op_B} iff (seq_item_cov.opcode == OR || seq_item_cov.opcode == XOR) {
                bins both_asserted = {2'b11};
            }

            // Reset assertion / de-assertion.
            cp_rst: coverpoint seq_item_cov.rst {
                bins rst_deasserted = {1'b0};
                bins rst_asserted   = {1'b1};
            }
        endgroup

        function new(string name = "ALSU_coverage", uvm_component parent = null);
            super.new(name, parent);
            cvr_grp = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                cvr_grp.sample();
            end
        endtask

    endclass

endpackage