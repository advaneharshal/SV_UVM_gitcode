`include "ahb_env.sv"

program ahb_pgm(ahb_if.master_mp if_0);

  ahb_env env_0;

  initial
  begin:test_ahb
    env_0 = new(.if_0(if_0));
    env_0.main();
  end:test_ahb

endprogram : ahb_pgm 
