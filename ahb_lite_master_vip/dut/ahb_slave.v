

module ahb_slave (
                   input hclk,           
                   input hreset_n,       
                   input hsel,
                   input [31:0]haddr,
                   input [1:0]htrans,     // IDLE,BUSY,NON_SEQ,SEQ
                   input hwrite,
                   input [2:0]hburst,     // SINGLE,INC,WRAP4,INC4,WRAP8,INC8,WRAP16,INC16
                   input [2:0]hsize,      // BYTE,H_W,W,2W,4W,8W,16W,32W
                   input [3:0]hprot,      //OPCODE FETCH,DATA ACCESS,USER,PRIVILEGED,NON_BUF,BUF,NON_CACHE,CACHEABLE
                   input [31:0]hwdata,
                   output [31:0]hrdata,
                   output hresp,
                   output hready,
                   input hready_i
                  );
reg [31:0] hrdata_out;
reg hresp_out;
reg hready_out;

`include "ahb_defines.v"  

assign hrdata = hrdata_out;
assign hresp  = hresp_out;
assign hready = hready_out;

reg [7:0] slave_mem[SLAVE_BUF_DEPTH-1:0];  // AHB SLAVE-MEMORY

reg [1:0]slave_state;
parameter SLAVE_IDLE=2'b00,SLAVE_RETRY=2'b01,SLAVE_ERROR=2'b10;  // AHB SLAVE OPERATION

//DATA SHOULD BE STABLE DURING WAITED STATES TO EXTEND THE TRANSFER 
reg waited;             //THIS REGISTER TELLS WHETHER WAIT TRANSFERS OCCURING OR NOT
reg [2:0]hsize_save;    //TRANSFER SIZE SHOULD BE STABLE WHILE EXTENDING THE TRANSFER  
reg hwrite_save;        //THIS SIGNAL IS USED TO WRITE DATA INTO SLAVE-MEMORY DURING WAITED TRANSFERS   
reg [SLAVE_BUF_ADDR_SIZE-1:0] haddr_os_save; 

reg capture_wdata;      // CAPTURES WRITE DATA
wire [3:0] be;          // INDICATES THE BYTE LANES ON A 32 BIT BUS    

integer cur_dphase;     // INDICATES CURRENT DATA PHASE OF THE TRANSFER
//DELAY BUFFER IS USED TO HOLD THE NUMBER OF WAIT STATES OF EACH DATA PHASE
reg [MAXWS-1:0]delaybuffer[SLAVE_RESP_BUF_DEPTH-1:0]; 
//RESPONSE BUFFER HOLDS THE RESPONSE OF EACH DATA PHASE
reg[1:0]respbuffer[SLAVE_RESP_BUF_DEPTH-1:0];
//RESPONSE LIMIT BUFFER IS USED TO HOLD THE NUMBER OF TIMES RESPONSE SHOULD BE APPLIED AFTER LIMIT IS REACHED
reg [MAXWS-1:0]resplimitbuffer[SLAVE_RESP_BUF_DEPTH-1:0];
//RESPONSE TIME BUFFER COUNTS THE NUMBER OF TIMES RESPONSE BUFFER RESPONSE HAS BEEN APPLIED
reg [MAXWS-1:0]resptimebuffer[SLAVE_RESP_BUF_DEPTH-1:0];

assign be[0] = ((hsize_save==3'b000 && haddr_os_save[1:0]==2'b00)) || ((hsize_save==3'b001 && haddr_os_save[1:0]==2'b00)) || (hsize_save==3'b010 && haddr_os_save[1:0]==2'b00 );

assign be[1] = ((hsize_save==3'b000 && haddr_os_save[1:0]==2'b01)) || ((hsize_save==3'b001 && haddr_os_save[1:0]==2'b00)) || (hsize_save==3'b010 && haddr_os_save[1:0]==2'b00);

assign be[2] = ((hsize_save==3'b000 && haddr_os_save[1:0]==2'b10)) || ((hsize_save==3'b001 && haddr_os_save[1:0]==2'b10)) || (hsize_save==3'b010 && haddr_os_save[1:0]==2'b00);

assign be[3] = ((hsize_save==3'b000 && haddr_os_save[1:0]==2'b11)) || ((hsize_save==3'b001 && haddr_os_save[1:0]==2'b10)) || (hsize_save==3'b010 && haddr_os_save[1:0]==2'b00);


always@(posedge hclk)
begin
  if(capture_wdata)
  begin
    if(be[0])
    slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b00}] <= hwdata[7:0];
    if(be[1])
    slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b01}] <= hwdata[15:8];
    if(be[2])
    slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b10}] <= hwdata[23:16];
    if(be[3])
    slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b11}] <= hwdata[31:24];
  end
end
always@(posedge hclk or negedge hreset_n)
begin
  if(!hreset_n)
  begin
    slave_state   <= SLAVE_IDLE;
    hready_out    <= 1;
    hresp_out     <= OKAY;
    hrdata_out    <= DEFAULT_RDATA;
    haddr_os_save <= 0;
    hsize_save    <= 0;
    hwrite_save   <= 0;
    waited        <= 0;
    capture_wdata <= 0;
    cur_dphase    <= 0;
  end
  else   
  begin
    capture_wdata <= 0;
    waited        <= 0;
    case(slave_state)
    SLAVE_IDLE:        
    begin
      if(hsel && hburst && hprot && hready_i)
      begin
        if(htrans == NON_SEQ)
        begin
          haddr_os_save <= haddr;
          hwrite_save   <= hwrite;
          hsize_save    <= hsize;
          hready_out    <= 1;
          hresp_out     <= OKAY;
          hrdata_out    <= DEFAULT_RDATA;
          cur_dphase    <= 0;
          if(delaybuffer[0])
          begin
            hready_out  <= 0;
            waited      <= 1;
            repeat (delaybuffer[0]) @(posedge hclk);
          end
          if((respbuffer[0] == RETRY) && ((resplimitbuffer[0] == 0) || (resptimebuffer[0] < resplimitbuffer[0]))) 
          begin
            slave_state <= SLAVE_RETRY;
            hready_out  <= 0;
            hresp_out   <= RETRY;
            if(resplimitbuffer[0])
            begin
              resptimebuffer[0] <= resptimebuffer[0] + 1;
            end
          end
          else if(respbuffer[0] == ERROR)
          begin
            slave_state <= SLAVE_ERROR;
            hready_out  <= 0;
            hresp_out   <= ERROR;
          end
          else           // respbuffer[0] == OKAY
          begin
            hready_out  <= 1;
            hresp_out   <= OKAY;
            cur_dphase  <= 1;
            if(waited ? hwrite_save : hwrite) 
            begin
              capture_wdata <= 1;
            end
            else
            begin
              hrdata_out <= waited ?
                                    {
                                     slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b11}],
                                     slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b10}],
                                     slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b01}],
                                     slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b00}]
                                    }
                                   :
                                    {
                                     slave_mem[{haddr[SLAVE_BUF_ADDR_SIZE-1:2],2'b11}],
                                     slave_mem[{haddr[SLAVE_BUF_ADDR_SIZE-1:2],2'b10}],
                                     slave_mem[{haddr[SLAVE_BUF_ADDR_SIZE-1:2],2'b01}],
                                     slave_mem[{haddr[SLAVE_BUF_ADDR_SIZE-1:2],2'b00}]
                                    };
            end
          end
        end
        else if(htrans == SEQ && cur_dphase != 0)
        begin
          haddr_os_save <= haddr;
          hwrite_save   <= hwrite;
          hsize_save    <= hsize;
          hready_out    <= 1;
          hresp_out     <= OKAY;
          hrdata_out    <= DEFAULT_RDATA;
          if(delaybuffer[cur_dphase])
          begin
            hready_out  <= 0;
            waited      <= 1;
            repeat (delaybuffer[cur_dphase]) @(posedge hclk);
          end
          if((respbuffer[cur_dphase] == RETRY) && ((resplimitbuffer[cur_dphase] == 0) || (resptimebuffer[cur_dphase] < resplimitbuffer[cur_dphase])))
          begin
            slave_state <= SLAVE_RETRY;
            hready_out  <= 0;
            hresp_out   <= RETRY;
            if(resplimitbuffer[cur_dphase])
            begin
              resptimebuffer[cur_dphase] <= resptimebuffer[cur_dphase] + 1;
            end
          end
          else if(respbuffer[cur_dphase] == ERROR)
          begin
            slave_state <= SLAVE_ERROR;
            hready_out  <= 0;
            hresp_out   <= ERROR;
          end
          else          // respbuffer[cur_dphase] == OKAY
          begin
            hready_out  <= 1;
            hresp_out   <= OKAY;
            cur_dphase  <= cur_dphase + 1;
            if(waited ? hwrite_save : hwrite)
            begin
              capture_wdata <= 1;
            end
            else
            begin
              hrdata_out <= waited ?
                                    {
                                     slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b11}],
                                     slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b10}],
                                     slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b01}],
                                     slave_mem[{haddr_os_save[SLAVE_BUF_ADDR_SIZE-1:2],2'b00}]
                                    }
                                   :
                                    {
                                     slave_mem[{haddr[SLAVE_BUF_ADDR_SIZE-1:2],2'b11}],
                                     slave_mem[{haddr[SLAVE_BUF_ADDR_SIZE-1:2],2'b10}],
                                     slave_mem[{haddr[SLAVE_BUF_ADDR_SIZE-1:2],2'b01}],
                                     slave_mem[{haddr[SLAVE_BUF_ADDR_SIZE-1:2],2'b00}]
                                    };
            end
          end
        end
        else if(htrans == BUSY && cur_dphase != 0)
        begin
          hready_out    <= 1;
          hresp_out     <= OKAY;
          hrdata_out    <= DEFAULT_RDATA;
        end
        else if(htrans == IDLE && cur_dphase != 0)
        begin
          hready_out    <= 1;
          hresp_out     <= OKAY;
          hrdata_out    <= DEFAULT_RDATA;
        end
        else   //DEFAULT          
        begin
          hready_out    <= 1;
          hresp_out     <= OKAY;
          hrdata_out    <= DEFAULT_RDATA;
          cur_dphase    <= 0;
        end  //else
      end
    end
    SLAVE_RETRY:       
    begin
      hready_out        <= 1'b1;
      hresp_out         <= RETRY;
      hrdata_out        <= DEFAULT_RDATA;
      slave_state       <= SLAVE_IDLE;
      cur_dphase        <= 0;
    end
    SLAVE_ERROR:     
    begin
      hready_out        <= 1'b1;
      hresp_out         <= ERROR;
      hrdata_out        <= DEFAULT_RDATA;
      slave_state       <= SLAVE_IDLE;
      cur_dphase        <= 0;
    end
    endcase
  end
end

endmodule



