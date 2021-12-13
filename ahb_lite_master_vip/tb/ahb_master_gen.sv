class ahb_master_gen;
  int no_of_xactn;
  
  mailbox #(ahb_xactn) out_box;
  ahb_xactn tr;

  function new (mailbox #(ahb_xactn) new_mbx,
                int no_of_xactn);
    this.no_of_xactn  = no_of_xactn;
    this.out_box      = new_mbx;
    this.tr           = new();
  endfunction : new

  extern virtual task main();
 
endclass : ahb_master_gen

task ahb_master_gen::main();
  ahb_xactn obj;

  $display ("%0t Start of Generator", $time);
  
  for (int i = 0; i < no_of_xactn; i++)
  begin: gen_loop
    a_rand_check_xactn : assert(this.tr.randomize()) else
               $error ("RANDOMIZATION OF XACTN FAILED!!!");
    if (!$cast(obj, this.tr.copy())) begin:error_handling
      $display("GEN:ERROR, UNABLE TO COPY CURRENT XACTN");
      continue;
    end:error_handling

    this.out_box.put(obj);
    $display("%0s",tr.psdisplay("GEN"));
    #500;
  end : gen_loop

endtask : main
