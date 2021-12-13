class ahb_dir_wr_rd_xactn extends ahb_xactn;
  extern  function void post_randomize();
endclass:ahb_dir_wr_rd_xactn

function void ahb_dir_wr_rd_xactn::post_randomize();
  case (this.xactn_id)
    0:
      begin
        this.kind  = WRITE;
        this.haddr  = 'd10;
        this.hwdata  = 'd30;
	this.size = BYTE;
	this.burst = SINGLE;
      end
    1:
      begin
        this.kind  = READ;
        this.haddr  = 'd10;
	this.size = BYTE;
	this.burst = SINGLE;
      end
  endcase // case (xactn_id)
  this.xactn_id++;
endfunction : post_randomize
