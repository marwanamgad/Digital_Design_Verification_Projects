////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
package shift_reg_test_pkg;

  import shift_reg_env_pkg::*;
  import shift_reg_config_pkg::*;
  import shift_reg_main_seq_pkg::*;
  import shift_reg_reset_seq_pkg::*;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

class shift_reg_test extends uvm_test;
  `uvm_component_utils(shift_reg_test)

   shift_reg_env env;
   shift_reg_config shift_reg_cfg;
   shift_reg_main_seq main_seq;
   shift_reg_reset_seq reset_seq;

  function new(string name="shift_reg_test", uvm_component parent = null);
   super.new(name,parent) ;
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    env = shift_reg_env::type_id::create("env",this);
    shift_reg_cfg = shift_reg_config::type_id::create("shift_reg_cfg",this);
    main_seq = shift_reg_main_seq::type_id::create("main_seq");
    reset_seq = shift_reg_reset_seq::type_id::create("reset_seq");


    if(!uvm_config_db #(virtual shift_reg_if) :: get (this, "", "SHIFT_REG_IF",shift_reg_cfg.shift_reg_vif) )
      `uvm_fatal("build_phase", "Test - Unable to get virtual interface");

    uvm_config_db #(shift_reg_config) :: set (this, "*", "CFG", shift_reg_cfg);

  endfunction



  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    
    `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
    reset_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Reset De-asserted", UVM_LOW)

     `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
    main_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

    phase.drop_objection(this);
  endtask 
  
endclass: shift_reg_test
endpackage