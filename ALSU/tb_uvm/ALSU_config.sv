package ALSU_config_pkg;

     import uvm_pkg::*;                 
    `include "uvm_macros.svh"          

class ALSU_config extends uvm_object;
    `uvm_object_utils(ALSU_config)

     virtual ALSU_interface alsu_vif;

     function new(string name="ALSU_config");
        super.new(name) ;
     endfunction
    
endclass


endpackage