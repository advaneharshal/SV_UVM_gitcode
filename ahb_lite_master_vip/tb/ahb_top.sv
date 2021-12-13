module ahb_top;

  import ahb_pkg::*;
  logic clk;

  // Interface Instantiation
  ahb_if if_0(.hclock(clk));

  // DUT Instantiation : Slave
  ahb_slave ahb_slave_0(
		    	.hclk(clk),
			.hreset_n(if_0.hresetn),
			.hsel(if_0.hsel),
			.haddr(if_0.haddr),
			.hwrite(if_0.hwrite),
			.hsize(if_0.hsize),
			.hburst(if_0.hburst),
			.hprot(if_0.hprot),
			.htrans(if_0.htrans),
			.hready_i(if_0.hready),
			.hwdata(if_0.hwdata),
			.hrdata(if_0.hrdata),
			.hresp(if_0.hresp),
			.hready(if_0.hreadyout)
			);

  ahb_pgm ahb_pgm_0(.if_0(if_0));

  initial
    begin
      clk <= 1'b0;
      forever #5 clk <= ~ clk;
    end

`ifdef VCS
  initial
    $vcdpluson();
`endif

endmodule : ahb_top
