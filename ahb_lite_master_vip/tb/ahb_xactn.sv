import ahb_pkg::*;
class ahb_xactn; 


  rand logic [ DATA_WIDTH - 1 : 0 ] hwdata;
  rand logic [ ADDR_WIDTH - 1 : 0 ] haddr;
  rand burst_type burst;
  rand slv_op kind;
  rand size_type size;
  trans_type htrans;
  
  static int xactn_id;
  
  logic [3:0]hprot;
  //logic hmastlock;
  
  /*constraint burst_const{
                         burst inside
{SINGLE,INCR,INCR4,WRAP4,INCR8,INCR16};}*/
  constraint size_const{
                        size inside{BYTE,HALF_WORD,WORD};}
  constraint addr_const{
    haddr <= 'd128 && haddr%'d2 == 0 ;}
  constraint kind_const{
			kind inside {WRITE,READ};}

  extern virtual function ahb_xactn copy(ahb_xactn to = null);
  extern virtual function string psdisplay (string prefix = "");
 
endclass : ahb_xactn

  function ahb_xactn ahb_xactn::copy(ahb_xactn to = null);
    ahb_xactn local_xactn;
    if (to == null)
      local_xactn = new();
    else if (!$cast(local_xactn,to))
    begin
      $display("Attempting to copy a non apb_slv_xactn instance");
      copy  = null;
      return copy;
    end
    local_xactn.hwdata     = this.hwdata;  
    local_xactn.haddr      = this.haddr;  
    local_xactn.burst      = this.burst;  
    local_xactn.kind       = this.kind; 
    local_xactn.size       = this.size; 
    local_xactn.hprot      = this.hprot;
    //local_xactn.hmastlock  = this.hmastlock;
    return (local_xactn);
  endfunction : copy
 
  function string ahb_xactn::psdisplay(string prefix = "");
    psdisplay  = $psprintf("%0t %0s: ",$time, prefix);
    psdisplay  = $psprintf("%s %s", psdisplay, this.kind.name());
    if(this.kind == WRITE)
      psdisplay = $psprintf ("%s addr: %0d data: %0d burst:%s size:%s",
                             psdisplay,this.haddr,this.hwdata,this.burst.name(),
                             this.size.name());
    if(this.kind == READ)
      psdisplay = $psprintf ("%s addr: %0d burst:%s size:%s",
                             psdisplay,this.haddr,this.burst.name(),
                             this.size.name());
  endfunction : psdisplay
