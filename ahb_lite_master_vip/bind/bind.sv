module bind_to_ahbslave;

  bind ahb_slave SnpsAhbSlaveChecker #(.NUMBER_OF_MASTERS(1),.AHB_LITE_EN(1)) AhbSlave_0 (
    .HCLK(hclk),
    .HRESETn(hreset_n),//ports are connected
    .HTRANS(htrans),
    .HRDATA(hrdata),
    .HREADY(hready_out),
    .HRESP(hresp),
    .HADDR(haddr),
    .HMASTLOCK('b0),
    .HREADY_IN(hready_out),
    .HSEL(hsel),
    .HSIZE(hsize),
    .HWDATA(hwdata),
    .HBURST(hburst),
    .HWRITE(hwrite) 
    );

endmodule 
