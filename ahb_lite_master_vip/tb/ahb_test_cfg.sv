class ahb_test_cfg;

  rand bit [15:0] no_of_xactn;
  constraint const_min_no_of_xactn
  {
    no_of_xactn > 15;
  }
  constraint const_max_no_of_xactn
  {
    no_of_xactn < 20;
  }

endclass:ahb_test_cfg
