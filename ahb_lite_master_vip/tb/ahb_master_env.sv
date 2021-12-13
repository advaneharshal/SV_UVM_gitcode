`include "ahb_xactn.sv"
`include "ahb_master_gen.sv"
`include "ahb_master_bfm.sv"
`include "ahb_master_mon.sv"
`include "ahb_test_cfg.sv"

import ahb_pkg::*;
class ahb_master_env;

  ahb_master_gen gen_0;
  ahb_master_bfm bfm_0;
  ahb_master_mon mon_0;
  ahb_test_cfg test_cfg;
    
  virtual ahb_if.master_mp if_0;
   
  mailbox #(ahb_xactn) gen_mbx;
  mailbox #(ahb_xactn) mon_mbx;

  function new (virtual ahb_if.master_mp if_0); 
    this.if_0  = if_0;
  endfunction : new

  extern virtual function void build();
  extern virtual task reset();
  extern virtual task start();
  extern virtual task main();
  
endclass:ahb_master_env
     
function void ahb_master_env::build();
  this.gen_mbx  = new(1);
  this.mon_mbx  = new();
  this.test_cfg = new();

  a_rand_check_test_cfg:assert(this.test_cfg.randomize()) else
    $error("RANDOMIZATION OF TEST CONFIGURATION FAILED");
  this.gen_0     = new (.new_mbx(this.gen_mbx),
                        .no_of_xactn(this.test_cfg.no_of_xactn)
                        );
  this.bfm_0     = new (.if_0(this.if_0),
                        .mbox(this.gen_mbx)
                        );
  this.mon_0     = new (.if_0(this.if_0),
                        .m_box(this.mon_mbx)
                        );
endfunction : build

task ahb_master_env::reset();
  if_0.ahb_cb.hresetn   <= 1'b1;
  @ (if_0.ahb_cb);
  if_0.ahb_cb.hresetn   <= 1'b0;
  if_0.ahb_cb.hready    <= 1'b1;
  //if_0.ahb_cb.hresp     <= 1'b0;
  //if_0.ahb_cb.hrdata    <= 32'd0;
  if_0.ahb_cb.hsel      <= 1'b1;
  if_0.ahb_cb.haddr     <= 32'd0;
  if_0.ahb_cb.hsize     <= 3'd0;
  if_0.ahb_cb.hburst    <= 3'd0;
  if_0.ahb_cb.hprot     <= 4'd0;
  if_0.ahb_cb.htrans    <= 2'd0;
  //if_0.ahb_cb.hmastlock <= 1'd0;
  if_0.ahb_cb.hwdata    <= 32'd0;
  repeat (5) @ (if_0.ahb_cb);
  if_0.ahb_cb.hresetn <= 1'b1;
  repeat (4) @ (if_0.ahb_cb);
  $display ("%0t RESET TASK FINISHED", $time);
endtask // reset

task ahb_master_env::start();
  $display("%0t AHB_ENV: TOTAL NO. OF XACTNS = %0d",$time,this.gen_0.no_of_xactn);
  fork
    gen_0.main();
    bfm_0.main();
    mon_0.main();
  join_any
endtask:start

task ahb_master_env::main();
  $display("%0t AHB_ENV START OF OPERATION", $time);
  this.build();
  this.reset();
  this.start();
  #100;
  $display ("END OF TEST");
  $finish;
endtask:main
