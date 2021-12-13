import ahb_pkg::*;
class ahb_master_bfm;
  virtual ahb_if.master_mp  if_0;
  ahb_xactn tr;
  mailbox #(ahb_xactn) ahb_inbox;
  function new(virtual ahb_if.master_mp  if_0,
	       mailbox #(ahb_xactn) mbox);
    this.if_0      = if_0;
    this.ahb_inbox = mbox;
  endfunction : new

  extern virtual task write (input logic [DATA_WIDTH - 1 : 0 ] data,
             		     input logic [ADDR_WIDTH - 1 : 0 ] addr,
             		     input burst_type burst,
             		     input size_type size);
			     
  extern virtual task read  (input logic [ADDR_WIDTH - 1 : 0 ] addr,
             		     input burst_type burst,
             		     input size_type size);

  extern virtual task main();

endclass : ahb_master_bfm

  task ahb_master_bfm::main();
    $display("%0t Start of BFM",$time);
    forever
      begin:bfm_loop
	this.ahb_inbox.peek(tr);
        $display("%s ",tr.psdisplay("BFM"));
        case (tr.kind)
          WRITE:
            this.write (
			.data(tr.hwdata),
              		.addr(tr.haddr),
              		.burst(tr.burst),
              		.size(tr.size)
			);
      	  READ:
            this.read  (
             		.addr(tr.haddr),
             		.burst(tr.burst),
             		.size(tr.size)
             		);
        endcase
	this.ahb_inbox.get(tr);
      end:bfm_loop
  endtask : main

  task ahb_master_bfm::write (input logic [DATA_WIDTH - 1 : 0 ] data,
             	       input logic [ADDR_WIDTH - 1 : 0 ] addr,
             	       input burst_type burst,
             	       input size_type size);
    logic [4:0]addr_incr;
    logic [2:0]hsize;
    logic [2:0]hburst;
    logic [31:0]wrap_boundary;
    logic [7:0] no_of_bytes;
    logic [31:0] allinged_addr;
    logic [ADDR_WIDTH - 1 : 0 ] local_addr;
    logic [31:0] diff;
    int i= 1;
    int j= 1;
    local_addr  = addr;
    case(size)
      BYTE:
        begin
          addr_incr  = 'd1;
          hsize      = 3'd0;
        end
      HALF_WORD:
        begin
          addr_incr  = 'd2;
          hsize      = 3'd1;
        end
      WORD:
        begin
          addr_incr  = 'd4;
          hsize      = 3'd2;
        end   
      default:
        addr_incr  = 'd0;
    endcase // case (size)
    
    case(burst)
      SINGLE:hburst = 'b0;
      INCR:hburst   = 'b001;
      WRAP4:
        begin
          hburst  = 'b010;
          case(size)
            BYTE:
              begin
                no_of_bytes    = 'd4*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
              end
            HALF_WORD:
              begin
                no_of_bytes    = 'd4*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b1000;
                //no_of_bytes     = 'b100;
              end
            WORD:
              begin
                no_of_bytes    = 'd4*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b10000;
                //no_of_bytes     = 'b101;
              end
          endcase // case (size)
        end
      
      INCR4:hburst  = 'b011;
      WRAP8:
        begin
          hburst  = 'b100;
          case(size)
            BYTE:
              begin
                 no_of_bytes    = 'd8*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
               // wrap_boundary  = 'b1000;
               // no_of_bytes     = 'b100;
              end
            HALF_WORD:
              begin
                no_of_bytes    = 'd8*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b10000;
                //no_of_bytes     = 'b101;
              end
            WORD:
              begin
                 no_of_bytes    = 'd8*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b100000;
                //no_of_bytes     = 'b110;
              end
          endcase // case (size)
          
        end
      INCR8:hburst  = 'b101;
      WRAP16:
        begin
          hburst = 'b110;
          case(size)
            BYTE:
              begin
                no_of_bytes    = 'd16*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b10000;
                //no_of_bytes     = 'b101;
              end
            HALF_WORD:
              begin
                no_of_bytes    = 'd16*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b100000;
                //no_of_bytes     = 'b111;
              end
            WORD:
              begin
                no_of_bytes    = 'd4*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b1000000;
                //no_of_bytes     = 'b111;
              end
          endcase // case (size)
          
        end // case: WRAP16
      INCR16:hburst = 'b111;
      
    endcase // case (burst)
    
    //@(if_0.ahb_cb);
    //Address Phase
    if_0.ahb_cb.hsel     <= 'b1;
    if_0.ahb_cb.haddr     <= addr;
    if_0.ahb_cb.hwrite    <= 'b1;
    if_0.ahb_cb.hready    <= 'b1;
    // CVC TBD use htrans trans_type enum here..
    if_0.ahb_cb.htrans    <= 'b10;
    if_0.ahb_cb.hburst    <= hburst;
    //$display("size :%s %0d",size.name,size);
    if_0.ahb_cb.hsize     <=  hsize;
    if_0.ahb_cb.hprot     <= 'b0011;
    //if_0.ahb_cb.hmastlock <= 'b0;
    //@(if_0.ahb_cb);
    case (burst)
      SINGLE:
        begin:single_xfer
          @(if_0.ahb_cb);
          case (if_0.ahb_cb.hsize)
	    BYTE: // 8_bit_data
              if_0.ahb_cb.hwdata <= data[7:0];
      	    HALF_WORD: // 16_bit_data
              if_0.ahb_cb.hwdata <= data[15:0];
	    WORD: // 32_bit_data
              if_0.ahb_cb.hwdata <= data;
          endcase
          wait(if_0.ahb_cb.hreadyout);
          // $display (" WRITE TRANSACTION.......... SINGLE");
        end:single_xfer
      INCR:
        begin:incr_xfer
          $display ("BFM:%0t WRITE TRANSACTION FROM MASTER for INCR....",$time);
          for(int i = 1 ; i <= 8; i++)
          begin:loop
            @(if_0.ahb_cb);
            if(i != 1)
              data = data+i; 
	    case (if_0.ahb_cb.hsize)
	      BYTE: // 8_bit_data
                if_0.ahb_cb.hwdata <= data[7:0];
      	      HALF_WORD: // 16_bit_data
                if_0.ahb_cb.hwdata <= data[15:0];
	      WORD: // 32_bit_data
                if_0.ahb_cb.hwdata <= data;
            endcase
            wait(if_0.ahb_cb.hreadyout);
            if_0.ahb_cb.haddr    <= addr+(addr_incr*i);
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
          //@(if_0.ahb_cb); 
          //if_0.ahb_cb.hwdata <= data+'d20; 
        end:incr_xfer
      WRAP4:
        begin:wrap4
          $display ("BFM:%0t WRITE TRANSACTION FROM MASTER for WRAP4....",$time);
          //for(int i = 1 ; i <= 4; i++)
          repeat(4)
          begin:loop
            if_0.ahb_cb.haddr <= local_addr;
            local_addr         = local_addr+addr_incr;
            i                  = i+1;
            //{local_addr+(addr_incr*i)}
            if(local_addr >= wrap_boundary)
            begin:boundary_check
              local_addr  = addr - ( addr % no_of_bytes);
              i           = 0;
              $display(" BFM : %0t boundary crossed the new valueof addr: %0d",$time,local_addr);
            end:boundary_check
            
            if_0.ahb_cb.hburst   <= hburst;
            @(if_0.ahb_cb);
            if_0.ahb_cb.htrans   <= 'b11;
            if(j != 1)
              data = data+j; 
            case (if_0.ahb_cb.hsize)
	      BYTE: // 8_bit_data
                if_0.ahb_cb.hwdata <= data[7:0];
      	      HALF_WORD: // 16_bit_data
                if_0.ahb_cb.hwdata <= data[15:0];
	      WORD: // 32_bit_data
                if_0.ahb_cb.hwdata <= data;
            endcase
            wait(if_0.ahb_cb.hreadyout);
            j++;
            //@(if_0.ahb_cb);
          end:loop
          //@(if_0.ahb_cb); 
          //if_0.ahb_cb.hwdata <= data+'d4;
          i = 1;
          j = 1;
        end:wrap4
      INCR4:
        begin:incr4
          $display ("BFM:%0t  WRITE TRANSACTION FROM MASTER for INCR4....",$time);
          for(int i = 1 ; i <= 4; i++)
          begin:loop
            @(if_0.ahb_cb);
            if(i != 1)
              data = data+4; 
	    case (if_0.ahb_cb.hsize)
	      BYTE: // 8_bit_data
                if_0.ahb_cb.hwdata <= data[7:0];
      	      HALF_WORD: // 16_bit_data
                if_0.ahb_cb.hwdata <= data[15:0];
	      WORD: // 32_bit_data
                if_0.ahb_cb.hwdata <= data;
            endcase
            wait(if_0.ahb_cb.hreadyout);
            if_0.ahb_cb.haddr    <= addr+(addr_incr*i);
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
          //@(if_0.ahb_cb); 
          //if_0.ahb_cb.hwdata <= data+'d4;
        end:incr4
      WRAP8:
        begin:wrap8
          $display ("BFM:%0t WRITE TRANSACTION FROM MASTER for WRAP8....",$time);
          repeat(8)
          begin:loop
            if_0.ahb_cb.haddr <= local_addr;
            local_addr         = local_addr+addr_incr;
            i                  = i+1;
            if(local_addr >= wrap_boundary)
            begin:boundary_check
              local_addr  = addr - ( addr % no_of_bytes);
              i           = 0;
              $display(" BFM : %0t boundary crossed the new valueof addr: %0d",$time,local_addr);
            end:boundary_check
            
            if_0.ahb_cb.hburst   <= hburst;
            @(if_0.ahb_cb);
            if_0.ahb_cb.htrans   <= 'b11;
	    if(j != 1)
              data = data+j; 
            case (if_0.ahb_cb.hsize)
	      BYTE: // 8_bit_data
                if_0.ahb_cb.hwdata <= data[7:0];
      	      HALF_WORD: // 16_bit_data
                if_0.ahb_cb.hwdata <= data[15:0];
	      WORD: // 32_bit_data
                if_0.ahb_cb.hwdata <= data;
            endcase
            wait(if_0.ahb_cb.hreadyout);
            j++;
            //@(if_0.ahb_cb);
          end:loop
          //@(if_0.ahb_cb); 
          //if_0.ahb_cb.hwdata <= data+'d4;
          i = 1;
          j = 1;
        end:wrap8
      INCR8:
        begin:incr8
          $display (" WRITE TRANSACTION FROM MASTER for INCR8....");
          for(int i = 1 ; i <= 8; i++)
          begin:loop
            @(if_0.ahb_cb);
            if(i != 1)
              data = data+8; 
	    case (if_0.ahb_cb.hsize)
	      BYTE: // 8_bit_data
                if_0.ahb_cb.hwdata <= data[7:0];
      	      HALF_WORD: // 16_bit_data
                if_0.ahb_cb.hwdata <= data[15:0];
	      WORD: // 32_bit_data
                if_0.ahb_cb.hwdata <= data;
            endcase
            wait(if_0.ahb_cb.hreadyout);
            if_0.ahb_cb.haddr    <= addr+(addr_incr*i);
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
          //@(if_0.ahb_cb); 
          //if_0.ahb_cb.hwdata <= data+'d8;
        end:incr8
      WRAP16:
        begin:wrap16
          $display ("BFM : %0t WRITE TRANSACTION FROM MASTER for WRAP16....",$time);
          //for(int i = 1 ; i <= 4; i++)
          repeat(16)
          begin:loop
            if_0.ahb_cb.haddr <= local_addr;
            local_addr         = local_addr+addr_incr;
            i                  = i+1;
            //{local_addr+(addr_incr*i)}
            if(local_addr >= wrap_boundary)
            begin:boundary_check
              local_addr  = addr - ( addr % no_of_bytes);
              i           = 0;
              $display(" BFM : %0t boundary crossed the new valueof addr: %0d",$time,local_addr);
            end:boundary_check
            
            if_0.ahb_cb.hburst   <= hburst;
            @(if_0.ahb_cb);
            if_0.ahb_cb.htrans   <= 'b11;
	    if(j != 1)
              data = data+j; 
            case (if_0.ahb_cb.hsize)
	      BYTE: // 8_bit_data
                if_0.ahb_cb.hwdata <= data[7:0];
      	      HALF_WORD: // 16_bit_data
                if_0.ahb_cb.hwdata <= data[15:0];
	      WORD: // 32_bit_data
                if_0.ahb_cb.hwdata <= data;
            endcase
            wait(if_0.ahb_cb.hreadyout);
            j++;
            //@(if_0.ahb_cb);
          end:loop
          //@(if_0.ahb_cb); 
          //if_0.ahb_cb.hwdata <= data+'d4;
          i = 1;
          j = 1;
        end:wrap16
      INCR16:
        begin:incr16
          $display (" WRITE TRANSACTION FROM MASTER for INCR16....");
          for(int i = 1 ; i <= 16; i++)
          begin:loop
            @(if_0.ahb_cb);
	    if (i != 1)
	      data = data+16;
            case (if_0.ahb_cb.hsize)
	      BYTE: // 8_bit_data
                if_0.ahb_cb.hwdata <= data[7:0];
      	      HALF_WORD: // 16_bit_data
                if_0.ahb_cb.hwdata <= data[15:0];
	      WORD: // 32_bit_data
                if_0.ahb_cb.hwdata <= data;
            endcase
            wait(if_0.ahb_cb.hreadyout);
            if_0.ahb_cb.haddr    <= addr+(addr_incr*i);
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
          //@(if_0.ahb_cb); 
          //data = data+'d16;
        end:incr16
    endcase // case (burst) 
    if_0.ahb_cb.hsel  <= 'b0;
    if_0.ahb_cb.htrans <= 'b00;
    repeat(2)@(if_0.ahb_cb);
  endtask : write
  
  
  task ahb_master_bfm::read (input logic [ADDR_WIDTH - 1 : 0 ] addr,
             	      input burst_type burst,
             	      input size_type size);

    logic [4:0]addr_incr;
    logic [2:0]hsize;
    logic [2:0]hburst;
    logic [31:0]wrap_boundary;
    logic [7:0] no_of_bytes;
    logic [31:0] allinged_addr;
    logic [ADDR_WIDTH - 1 : 0 ] local_addr;
    logic [31:0] diff;
    int i       = 1;
    local_addr  = addr;
    
    case(size)
      BYTE:
        begin
          addr_incr  = 'd1;
          hsize      = 3'd0;
        end
      HALF_WORD:
        begin
          addr_incr  = 'd2;
          hsize      = 3'd1;
        end
      WORD:
        begin
          addr_incr  = 'd4;
          hsize      = 3'd2;
        end
      
      default:
        addr_incr  = 'd0;
    endcase // case (size)
    case(burst)
      SINGLE:hburst = 'b0;
      INCR:hburst   = 'b001;
      WRAP4:
        begin
          hburst  = 'b010;
          case(size)
            BYTE:
              begin
                no_of_bytes    = 'd4*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
              end
            HALF_WORD:
              begin
                no_of_bytes    = 'd4*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b1000;
                //no_of_bytes     = 'b100;
              end
            WORD:
              begin
                no_of_bytes    = 'd4*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b10000;
                //no_of_bytes     = 'b101;
              end
          endcase // case (size)
        end
      
      INCR4:hburst  = 'b011;
      WRAP8:
        begin
          hburst  = 'b100;
          case(size)
            BYTE:
              begin
                 no_of_bytes    = 'd8*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
               // wrap_boundary  = 'b1000;
               // no_of_bytes     = 'b100;
              end
            HALF_WORD:
              begin
                no_of_bytes    = 'd8*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b10000;
                //no_of_bytes     = 'b101;
              end
            WORD:
              begin
                 no_of_bytes    = 'd8*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b100000;
                //no_of_bytes     = 'b110;
              end
          endcase // case (size)
          
        end
      INCR8:hburst  = 'b101;
      WRAP16:
        begin
          hburst = 'b110;
          case(size)
            BYTE:
              begin
                no_of_bytes    = 'd16*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b10000;
                //no_of_bytes     = 'b101;
              end
            HALF_WORD:
              begin
                no_of_bytes    = 'd16*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b100000;
                //no_of_bytes     = 'b111;
              end
            WORD:
              begin
                no_of_bytes    = 'd4*addr_incr;
                diff           = addr % no_of_bytes;
                wrap_boundary  = addr+(no_of_bytes - diff);
                allinged_addr  = addr - addr % ('d4*addr_incr);
                //wrap_boundary  = 'b1000000;
                //no_of_bytes     = 'b111;
              end
          endcase // case (size)
          
        end // case: WRAP16
      INCR16:hburst = 'b111;
      
    endcase // case (burst)
    //@(if_0.ahb_cb);
    //Address Phase
    if_0.ahb_cb.hsel   <= 'b1;
    if_0.ahb_cb.haddr  <= addr;
    if_0.ahb_cb.hwrite <= 'b0;
    if_0.ahb_cb.htrans <= 'b10;
    if_0.ahb_cb.hburst <= hburst;
    if_0.ahb_cb.hsize  <= hsize;
    if_0.ahb_cb.hprot  <= 'b0011;
    if_0.ahb_cb.hready    <= 'b1;
    //if_0.ahb_cb.hmastlock <= 'b0;
    case (burst)
      SINGLE:
        begin:single_xfer
          @(if_0.ahb_cb);
          wait(if_0.ahb_cb.hreadyout);
          //$display (" READ TRANSACTION.......... SINGLE");
        end:single_xfer
      INCR:
        begin:incr_xfer
          $display (" READ TRANSACTION FROM MASTER for INCR....");
          for(int i = 1 ; i <= 8; i++)
          begin:loop
            @(if_0.ahb_cb);
            wait(if_0.ahb_cb.hreadyout);
            if_0.ahb_cb.haddr    <= addr+(addr_incr*i);
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
        end:incr_xfer
      WRAP4:
        begin:wrap4
          $display ("BFM : %0t READ TRANSACTION FROM MASTER for WRAP4....",$time);
          repeat(4)
          begin:loop
            if_0.ahb_cb.haddr <= local_addr;
            wait(if_0.ahb_cb.hreadyout);
            @(if_0.ahb_cb);
            local_addr         = local_addr+addr_incr;
            i                  = i+1;
            if(local_addr >= wrap_boundary)
            begin:boundary_check
              local_addr  = addr - ( addr % no_of_bytes);
              i           = 0;
              $display(" BFM : %0t boundary crossed the new value of addr: %0d wb: %0d",$time,local_addr,wrap_boundary);
            end:boundary_check
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
          i                   = 1;
        end:wrap4
      INCR4:
        begin:incr4
          $display (" READ TRANSACTION FROM MASTER for INCR4....");
          for(int i = 1 ; i <= 4; i++)
          begin:loop
            wait(if_0.ahb_cb.hreadyout);
            @(if_0.ahb_cb);
            if_0.ahb_cb.haddr  <= addr+(addr_incr*i);
            if_0.ahb_cb.htrans <= 'b11;
            if_0.ahb_cb.hburst <= hburst;
          end:loop
        end:incr4
      WRAP8:
        begin:wrap8
          $display ("BFM : %0t READ TRANSACTION FROM MASTER for WRAP8....",$time);
          repeat(7)
          begin:loop
            if_0.ahb_cb.haddr <= local_addr;
            wait(if_0.ahb_cb.hreadyout);
            @(if_0.ahb_cb);
            local_addr         = local_addr+addr_incr;
            i                  = i+1;
            if(local_addr >= wrap_boundary)
            begin:boundary_check
              local_addr  = addr - ( addr % no_of_bytes);
              i           = 0;
              $display(" BFM : %0t boundary crossed the new value of addr: %0d wb: %0d",$time,local_addr,wrap_boundary);
            end:boundary_check
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
          i                   = 1;
        end:wrap8
      INCR8:
        begin:incr8
          $display (" READ TRANSACTION FROM MASTER for INCR8...."); 
          for(int i = 1 ; i <= 8; i++)
          begin:loop
            wait(if_0.ahb_cb.hreadyout);
            @(if_0.ahb_cb);
            if_0.ahb_cb.haddr    <= addr+(addr_incr*i);
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
        end:incr8
      WRAP16:
        begin:wrap16
         $display ("BFM : %0t READ TRANSACTION FROM MASTER for WRAP16....",$time);
          repeat(15)
          begin:loop
            if_0.ahb_cb.haddr <= local_addr;
            wait(if_0.ahb_cb.hreadyout);
            @(if_0.ahb_cb);
            local_addr         = local_addr+addr_incr;
            i                  = i+1;
            //{local_addr+(addr_incr*i)}
            if(local_addr >= wrap_boundary)
            begin:boundary_check
              local_addr  = addr - ( addr % no_of_bytes);
              i           = 0;
              $display(" BFM : %0t boundary crossed the new value of addr: %0d wb: %0d",$time,local_addr,wrap_boundary);
            end:boundary_check
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
          //if_0.ahb_cb.hwdata <= data+'d4;
          i                   = 1; 
        end:wrap16
      INCR16:
        begin:incr16
          $display (" READ TRANSACTION FROM MASTER for INCR16....");
          for(int i = 1 ; i <= 16; i++)
          begin:loop
            wait(if_0.ahb_cb.hreadyout);
            @(if_0.ahb_cb);
            if_0.ahb_cb.haddr    <= addr+(addr_incr*i);
            if_0.ahb_cb.htrans   <= 'b11;
            if_0.ahb_cb.hburst   <= hburst;
          end:loop
        end:incr16
      
    endcase // case (burst)
    if_0.ahb_cb.hsel  <= 'b0;
    if_0.ahb_cb.htrans <= 'b00;
    repeat (2) @(if_0.ahb_cb);
    
  endtask : read
