package shift_reg_seq_item_pkg;

    import shared_pkg::*;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    


   class shift_reg_seq_item extends uvm_sequence_item;
        `uvm_object_utils(shift_reg_seq_item)

        rand bit reset, serial_in;
        rand direction_e direction;
        rand mode_e mode;
        rand bit [5:0] datain;
        logic [5:0] dataout;

        function new(string name="shift_reg_seq_item");
                super.new(name);
        endfunction


        
        function string convert2string();
            return $sformatf("%s reset=%0b serial_in=%0b direction=%0s mode=%0s datain=%0h dataout=%0h",
                            super.convert2string(),  reset, serial_in, direction.name(), mode.name(), datain, dataout);
        endfunction

        
        function string convert2string_stimulus();
            return $sformatf("reset=%0b serial_in=%0b direction=%0s mode=%0s datain=%0h",
                            reset, serial_in, direction.name(), mode.name(), datain);
                            endfunction


        constraint rst_con {
            reset dist {1:= 2, 0:= 98};
        }


        
    endclass

endpackage