package ALSU_test_pkg;

  import ALSU_config_pkg::*;
  import ALSU_main_seq_pkg::*;
  import ALSU_reset_seq_pkg::*;
  import ALSU_env_pkg::*;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  



class ALSU_test extends uvm_test;

  `uvm_component_utils(ALSU_test)

   ALSU_env env;
   ALSU_config alsu_cfg;
   ALSU_main_seq main_seq;
   ALSU_reset_seq reset_seq;



  function new(string name="ALSU_test", uvm_component parent);
   super.new(name,parent) ;
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    env = ALSU_env::type_id::create("env",this);
    alsu_cfg = ALSU_config::type_id::create("alsu_cfg");

    main_seq = ALSU_main_seq::type_id::create("alsu_main_seq");
    reset_seq = ALSU_reset_seq::type_id::create("alsu_reset_seq");

    if(!uvm_config_db #(virtual ALSU_interface)::get(this,"","ALSU_Interface",alsu_cfg.alsu_vif))
        `uvm_fatal("build phase","Test - Unable to get the Virtual Interface");

    uvm_config_db #(ALSU_config)::set(this,"*","CFG",alsu_cfg);

  endfunction



  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);


    //reset sequence 
    `uvm_info("run Phase", "Reset Asserted", UVM_LOW)
    reset_seq.start(env.agt.sqr);
    `uvm_info("run phase", "Reset De-Asserted", UVM_LOW)



     //main sequence 
    `uvm_info("run Phase", "Stimulus Generation Started", UVM_LOW)
    main_seq.start(env.agt.sqr);
    `uvm_info("run phase", "Stimulus Generation Ended", UVM_LOW)


     @(negedge alsu_cfg.alsu_vif.clk);
    phase.drop_objection(this);
  endtask 
  
endclass
endpackage