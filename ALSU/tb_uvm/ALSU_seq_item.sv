package ALSU_seq_item_pkg;


    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import ALSU_pkg::*;


   class ALSU_seq_item extends uvm_sequence_item;
        `uvm_object_utils(ALSU_seq_item)

        rand logic  rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
        rand logic [2:0] A, B;          
        rand opcode_e opcode;
        rand opcode_e opcode_valid[VALID_OP];
        rand reg_e enum_ext_A, enum_ext_B;
        rand logic [2:0] A_rem_values, B_rem_values;
        bit [2:0] walking_ones[] = '{3'b001, 3'b010, 3'b100};
        rand bit [2:0] walking_ones_t, walking_ones_f;

        logic signed [5:0] out;
        logic [15:0]       leds;

       

        function new(string name="ALSU_seq_item");
                super.new(name);
            endfunction


        
        function string convert2string();
        return $sformatf("%s rst=%0b A=%0d B=%0d cin=%0b serial_in=%0b red_op_A=%0b red_op_B=%0b opcode=%s bypass_A=%0b bypass_B=%0b direction=%0b | out=%0d leds=%0h",
                        super.convert2string(), rst, A, B, cin, serial_in, red_op_A, red_op_B,
                        opcode, bypass_A, bypass_B, direction, out, leds);
        endfunction

        function string convert2string_stimulus();
        return $sformatf("rst=%0b A=%0d B=%0d cin=%0b serial_in=%0b red_op_A=%0b red_op_B=%0b opcode=%s bypass_A=%0b bypass_B=%0b direction=%0b",
                        rst, A, B, cin, serial_in, red_op_A, red_op_B,
                        opcode, bypass_A, bypass_B, direction);
        endfunction


        // ALSU_1 (Point 1)
        constraint rst_con {
            rst dist {0:=98, 1:=2};
        }

        constraint A_B_con {
            !(A_rem_values inside {MAXPOS, ZERO, MAXNEG});
            !(B_rem_values inside {MAXPOS, ZERO, MAXNEG});
            walking_ones_t inside {walking_ones};
            !(walking_ones_f inside {walking_ones});

            // ALSU_5, ALSU_7
            if (opcode == OR || opcode == XOR) {  
                if (red_op_A == 1) {
                    B == 0;
                    A dist {walking_ones_t:= 80, walking_ones_f:= 20};
                } else if (red_op_B == 1) {
                    A == 0;
                    B dist {walking_ones_t:= 80, walking_ones_f:= 20};
                }
            } else {                               
                // ALSU_4, ALSU_6
                red_op_A dist {1:= 20, 0:= 80};
                red_op_B dist {1:= 20, 0:= 80};
                // ALSU_2, ALSU_3
                if (opcode == ADD || opcode == MULT) {
                    A dist {enum_ext_A:= 80, A_rem_values:= 20};
                    B dist {enum_ext_B:= 80, B_rem_values:= 20};
                }
            }
        }

        // ALSU_10 (Point 5)
        constraint opcode_con {
            opcode dist {[OR:ROTATE]:= 80, [INVALID_6:INVALID_7]:= 20};
        }

        // ALSU_11 (Point 6)
        constraint bypass_con {
            bypass_A dist {1:= 2, 0:= 98};
            bypass_B dist {1:= 2, 0:= 98};  
        }

        constraint opcode_seq_cont {
            unique {opcode_valid};
        }


        
    endclass

endpackage