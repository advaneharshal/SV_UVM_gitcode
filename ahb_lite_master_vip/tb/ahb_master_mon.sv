import ahb_pkg::*;
class ahb_master_mon;
  mailbox #(ahb_xactn) out_box;
  ahb_xactn tr;

  virtual ahb_if.master_mp if_0;

  function new (virtual ahb_if.master_mp if_0,
                mailbox #(ahb_xactn) m_box);
    this.if_0     = if_0;
    this.out_box  = m_box;
    tr            = new();
  endfunction // new

  extern virtual task main();
  
endclass // ahb_master_mon

task ahb_master_mon::main ();
  int i = 0;
  $display("%0t: START OF MONITOR",$time);
  forever
    
    begin:mon_loop
      @ (this.if_0.ahb_cb);
      if (this.if_0.ahb_cb.htrans != 2'd0)
      begin:if_1
        if (this.if_0.ahb_cb.hwrite == 1 && if_0.ahb_cb.hsel == 1)
        begin:if_2
	  case (if_0.ahb_cb.hburst)
	  SINGLE:
	    begin:case_loop_1
	      repeat(1)
		begin:rep_loop_1
                  this.tr.kind   = WRITE;
                  this.tr.haddr  = if_0.ahb_cb.haddr;
                  this.tr.burst = burst_type'(if_0.ahb_cb.hburst);
                  this.tr.size  = size_type'(if_0.ahb_cb.hsize);
          	  @ (this.if_0.ahb_cb);
          	  this.tr.hwdata = if_0.ahb_cb.hwdata;
	          this.out_box.put(tr.copy());
      		  $display ("%0s",this.tr.psdisplay("MON"));
                end:rep_loop_1
            end:case_loop_1
	  INCR, WRAP8, INCR8:
	    begin:case_loop_2	
	      repeat(8)
		begin:rep_loop_2
		  i++;
                  this.tr.kind   = WRITE;
                  this.tr.haddr  = if_0.ahb_cb.haddr;
                  this.tr.burst = burst_type'(if_0.ahb_cb.hburst);
                  this.tr.size  = size_type'(if_0.ahb_cb.hsize);
          	  @ (this.if_0.ahb_cb);
		  if (i != 8)
          	    this.tr.hwdata = if_0.ahb_cb.hwdata;
		  else
		  begin
		    if (if_0.ahb_cb.hsize == 0)
          	      this.tr.hwdata = if_0.ahb_cb.hwdata[7:0];
		    else if (if_0.ahb_cb.hsize == 1)
          	      this.tr.hwdata = if_0.ahb_cb.hwdata[15:0];
		    else
          	    this.tr.hwdata = if_0.ahb_cb.hwdata;
		  end
	          this.out_box.put(tr.copy());
      		  $display ("%0s",this.tr.psdisplay("MON"));
                end:rep_loop_2
            end:case_loop_2
	  INCR4, WRAP4:
	    begin:case_loop_3	
	      repeat(4)
		begin:rep_loop_3
		  i++;
                  this.tr.kind   = WRITE;
                  this.tr.haddr  = if_0.ahb_cb.haddr;
                  this.tr.burst = burst_type'(if_0.ahb_cb.hburst);
                  this.tr.size  = size_type'(if_0.ahb_cb.hsize);
          	  @ (this.if_0.ahb_cb);
		  if (i != 4)
          	    this.tr.hwdata = if_0.ahb_cb.hwdata;
		  else
		  begin
		    if (if_0.ahb_cb.hsize == 0)
          	      this.tr.hwdata = if_0.ahb_cb.hwdata[7:0];
		    else if (if_0.ahb_cb.hsize == 1)
          	      this.tr.hwdata = if_0.ahb_cb.hwdata[15:0];
		    else
          	    this.tr.hwdata = if_0.ahb_cb.hwdata;
		  end
	          this.out_box.put(tr.copy());
      		  $display ("%0s",this.tr.psdisplay("MON"));
                end:rep_loop_3
            end:case_loop_3
	  INCR16, WRAP16:
	    begin:case_loop_4	
	      repeat(16)
		begin:rep_loop_4
		  i++;
                  this.tr.kind   = WRITE;
                  this.tr.haddr  = if_0.ahb_cb.haddr;
                  this.tr.burst = burst_type'(if_0.ahb_cb.hburst);
                  this.tr.size  = size_type'(if_0.ahb_cb.hsize);
          	  @ (this.if_0.ahb_cb);
		  if (i != 16)
          	    this.tr.hwdata = if_0.ahb_cb.hwdata;
		  else
		  begin
		    if (if_0.ahb_cb.hsize == 0)
          	      this.tr.hwdata = if_0.ahb_cb.hwdata[7:0];
		    else if (if_0.ahb_cb.hsize == 1)
          	      this.tr.hwdata = if_0.ahb_cb.hwdata[15:0];
		    else
          	    this.tr.hwdata = if_0.ahb_cb.hwdata;
		  end
	          this.out_box.put(tr.copy());
      		  $display ("%0s",this.tr.psdisplay("MON"));
                end:rep_loop_4
            end:case_loop_4
	  endcase
 	  i = 0;
        end:if_2
        else 
        begin:rd_part
          if (this.if_0.ahb_cb.hwrite == 0 && if_0.ahb_cb.hsel == 1)         
          begin:if_3
	    case (if_0.ahb_cb.hburst)
	  SINGLE:
	    begin:case_loop_5
	      repeat(1)
		begin:rep_loop_5
                  this.tr.kind   = READ;
                  this.tr.haddr  = if_0.ahb_cb.haddr;
                  this.tr.burst = burst_type'(if_0.ahb_cb.hburst);
                  this.tr.size  = size_type'(if_0.ahb_cb.hsize);
          	  @ (this.if_0.ahb_cb);
		  this.tr.hwdata = if_0.ahb_cb.hrdata;
	          this.out_box.put(tr.copy());
      		  $display ("%0s : DUT_Data: %0d",
                    this.tr.psdisplay("MON"),
                    this.if_0.ahb_cb.hrdata);
                end:rep_loop_5
            end:case_loop_5
	  INCR, WRAP8, INCR8:
	    begin:case_loop_6	
	      repeat(8)
		begin:rep_loop_6
                  this.tr.kind   = READ;
                  this.tr.haddr  = if_0.ahb_cb.haddr;
                  this.tr.burst = burst_type'(if_0.ahb_cb.hburst);
                  this.tr.size  = size_type'(if_0.ahb_cb.hsize);
          	  @ (this.if_0.ahb_cb);
		  this.tr.hwdata = if_0.ahb_cb.hrdata;
	          this.out_box.put(tr.copy());
      		  $display ("%0s",this.tr.psdisplay("MON"));
                end:rep_loop_6
            end:case_loop_6
	  INCR4, WRAP4:
	    begin:case_loop_7	
	      repeat(4)
		begin:rep_loop_7
                  this.tr.kind   = READ;
                  this.tr.haddr  = if_0.ahb_cb.haddr;
                  this.tr.burst = burst_type'(if_0.ahb_cb.hburst);
                  this.tr.size  = size_type'(if_0.ahb_cb.hsize);
          	  @ (this.if_0.ahb_cb);
		  this.tr.hwdata = if_0.ahb_cb.hrdata;
	          this.out_box.put(tr.copy());
      		  $display ("%0s",this.tr.psdisplay("MON"));
                end:rep_loop_7
            end:case_loop_7
	  INCR16, WRAP16:
	    begin:case_loop_8	
	      repeat(16)
		begin:rep_loop_8
                  this.tr.kind   = READ;
                  this.tr.haddr  = if_0.ahb_cb.haddr;
                  this.tr.burst = burst_type'(if_0.ahb_cb.hburst);
                  this.tr.size  = size_type'(if_0.ahb_cb.hsize);
          	  @ (this.if_0.ahb_cb);
		  this.tr.hwdata = if_0.ahb_cb.hrdata;
	          this.out_box.put(tr.copy());
      		  $display ("%0s",this.tr.psdisplay("MON"));
                end:rep_loop_8
            end:case_loop_8
	  endcase
        end:if_3 
      end:rd_part 
      /*this.out_box.put(tr.copy());
      $display ("%0s",this.tr.psdisplay("MON"));*/
      end:if_1 
    end:mon_loop
endtask:main
