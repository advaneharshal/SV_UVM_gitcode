parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;

parameter TRANS_WIDTH = 2;
parameter BURST_WIDTH = 3;
parameter SIZE_WIDTH = 3;
parameter PROT_WIDTH = 3;

// TRANSFER TYPE
parameter 
         IDLE     = 2'b00,
         BUSY     = 2'b01,
         NON_SEQ  = 2'b10,
         SEQ      = 2'b11;

//BURST TRANSFER
parameter
         SINGLE   = 3'b000,
         INCR     = 3'b001,
         WRAP4    = 3'b010,
         INCR4    = 3'b011,
         WRAP8    = 3'b100,
         INCR8    = 3'b101,
         WRAP16   = 3'b110,
         INCR16   = 3'b111;

//TRANSFER SIZE 
parameter 
         BYTE         = 3'b000,
         HALF_WORD    = 3'b001,
         WORD         = 3'b010,
         WORD2        = 3'b011,
         WORD4        = 3'b100,
         WORD8        = 3'b101,
         WORD16       = 3'b110,
         WORD32       = 3'b111;

//SLAVE_RESPONSE
parameter 
        OKAY   = 2'b00,
        RETRY  = 2'b01,
        ERROR  = 2'b10;


// DEFAULT READ DATA DRIVEN BY THE SLAVE
parameter DEFAULT_RDATA = 32'habcd_abcd;

// SLAVE BUFFER
parameter SLAVE_BUF_DEPTH     = 2**16;         
parameter SLAVE_BUF_ADDR_SIZE = 16;

parameter SLAVE_RESP_BUF_DEPTH =32'h1000;
parameter MAXWS = 5;

  
         
