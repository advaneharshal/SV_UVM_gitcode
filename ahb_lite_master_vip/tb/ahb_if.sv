interface ahb_if(input logic hclock); 
  
  import ahb_pkg::*;
  
  logic hresetn;
  logic hsel;
  logic [ ADDR_WIDTH - 1 : 0 ] haddr;
  logic hwrite;
  logic [ SIZE_WIDTH - 1 : 0 ] hsize;
  logic [ BURST_WIDTH - 1 : 0 ] hburst;
  logic [ PROT_WIDTH - 1 : 0 ] hprot;
  logic [ TRANS_WIDTH - 1 : 0 ] htrans;
  logic hmastlock;
  logic hready;
  logic [ DATA_WIDTH - 1 : 0 ] hwdata;
  logic [ DATA_WIDTH - 1 : 0 ] hrdata;
  logic hreadyout;
  logic hresp;

  clocking ahb_cb @( posedge hclock);
    inout hsel;
    inout hresetn;
    inout haddr;
    inout hwrite;
    inout hsize;
    inout hburst;
    inout htrans;
    inout hprot;
    //inout hmastlock;
    inout hready;
    inout hwdata;
    input hrdata;
    input hreadyout;
    input hresp;
  endclocking:ahb_cb

  modport master_mp(clocking ahb_cb);

  modport slave_mp(input hresetn,hsel,haddr,hwrite,
                   hsize,hburst,hprot,htrans, hready,
		   hwdata,
                   output hrdata,hreadyout,hresp);
    

  endinterface : ahb_if
