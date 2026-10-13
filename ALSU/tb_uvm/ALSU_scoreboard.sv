package ALSU_scoreboard_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ALSU_seq_item_pkg::*;
    import ALSU_pkg::*;

    class ALSU_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(ALSU_scoreboard)

        uvm_analysis_export #(ALSU_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(ALSU_seq_item) sb_fifo;
        ALSU_seq_item seq_item_sb;

        // Reference outputs
        logic signed [5:0] out_ref;
        logic [15:0]       leds_ref;

        // Internals to register the stimulus for the reference model
        bit red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg;
        bit signed [1:0] cin_reg;
        opcode_e opcode_reg;
        bit signed [2:0] A_reg, B_reg;

        int error_count = 0;
        int correct_count = 0;

        function new(string name = "ALSU_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);
                ref_model(seq_item_sb);
                if ((seq_item_sb.out !== out_ref) || (seq_item_sb.leds !== leds_ref)) begin
                    `uvm_error("run_phase", $sformatf("Comparison failed, Transaction received by the DUT:%s  While the reference out=%0d leds=%0h", seq_item_sb.convert2string(), out_ref, leds_ref))
                    error_count++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("Correct ALSU out: %s ", seq_item_sb.convert2string()), UVM_HIGH);
                    correct_count++;
                end
            end
        endtask

        // is_invalid function
        function bit is_invalid();
            // invalid case 1
            if (opcode_reg == INVALID_6 || opcode_reg == INVALID_7)
                return 1;
            // invalid case 2
            else if ((opcode_reg > 3'b001) && (red_op_A_reg || red_op_B_reg))
                return 1;
            else
                return 0;
        endfunction

        task ref_model(ALSU_seq_item seq_item_chk);
            if (seq_item_chk.rst) begin
                out_ref  = 0;
                leds_ref = 0;
                reset_internals();
            end
            else begin
                // Handle leds_ref
                if (is_invalid())
                    leds_ref = ~leds_ref;
                else
                    leds_ref = 0;

                // Check bypass (INPUT_PRIORITY = "A")
                if (bypass_A_reg)
                    out_ref = A_reg;
                else if (bypass_B_reg)
                    out_ref = B_reg;
                // Check invalid
                else if (is_invalid())
                    out_ref = 0;
                // Valid opcodes
                else begin
                    case (opcode_reg)
                        OR: begin
                            if (red_op_A_reg)
                                out_ref = |A_reg;
                            else if (red_op_B_reg)
                                out_ref = |B_reg;
                            else
                                out_ref = A_reg | B_reg;
                        end
                        XOR: begin
                            if (red_op_A_reg)
                                out_ref = ^A_reg;
                            else if (red_op_B_reg)
                                out_ref = ^B_reg;
                            else
                                out_ref = A_reg ^ B_reg;
                        end
                        ADD:  out_ref = A_reg + B_reg + cin_reg;   // FULL_ADDER = "ON"
                        MULT: out_ref = A_reg * B_reg;
                        SHIFT: begin
                            if (direction_reg)
                                out_ref = {out_ref[4:0], serial_in_reg};
                            else
                                out_ref = {serial_in_reg, out_ref[5:1]};
                        end
                        ROTATE: begin
                            if (direction_reg)
                                out_ref = {out_ref[4:0], out_ref[5]};
                            else
                                out_ref = {out_ref[0], out_ref[5:1]};
                        end
                    endcase
                end
                update_internals(seq_item_chk);
            end
        endtask

        task reset_internals();
            red_op_A_reg  = 0;
            red_op_B_reg  = 0;
            bypass_A_reg  = 0;
            bypass_B_reg  = 0;
            direction_reg = 0;
            serial_in_reg = 0;
            cin_reg       = 0;
            opcode_reg    = OR;
            A_reg         = 0;
            B_reg         = 0;
        endtask

        task update_internals(ALSU_seq_item seq_item_chk);
            cin_reg       = seq_item_chk.cin;
            red_op_A_reg  = seq_item_chk.red_op_A;
            red_op_B_reg  = seq_item_chk.red_op_B;
            bypass_A_reg  = seq_item_chk.bypass_A;
            bypass_B_reg  = seq_item_chk.bypass_B;
            direction_reg = seq_item_chk.direction;
            serial_in_reg = seq_item_chk.serial_in;
            opcode_reg    = seq_item_chk.opcode;
            A_reg         = seq_item_chk.A;
            B_reg         = seq_item_chk.B;
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d",correct_count), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d",error_count), UVM_MEDIUM);
        endfunction

    endclass

endpackage