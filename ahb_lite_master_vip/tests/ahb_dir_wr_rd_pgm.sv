`include "ahb_master_env.sv"
`include "ahb_dir_wr_rd_xactn.sv"

program ahb_pgm(ahb_if if_0);

  ahb_master_env env_0;
  ahb_dir_wr_rd_xactn  direct_xactn;
  
  initial 
  begin:test_ahb
    env_0       = new(if_0);
    direct_xactn  = new();
    
    env_0.build();
    env_0.gen_0.tr       = direct_xactn;
    env_0.gen_0.no_of_xactn     = 2;
    env_0.reset();
    env_0.start();
    
  end:test_ahb

endprogram:ahb_pgm
