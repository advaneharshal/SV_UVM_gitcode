
package ahb_pkg;

  parameter ADDR_WIDTH   = 32;
  parameter DATA_WIDTH   = 32;

  parameter SIZE_WIDTH   = 3;
	parameter BURST_WIDTH  = 3;
	parameter PROT_WIDTH   = 4;
	parameter TRANS_WIDTH  = 2;


  parameter CLOCK_PERIOD = 10;
  
  // enum for operation
  typedef enum {WRITE, READ}slv_op;
  // enum for Transfer type
  typedef  enum logic [1:0]{IDLE,BUSY,NONSEQ,SEQ} trans_type;
  //enum for burst_type
  typedef enum logic[2:0] {SINGLE,INCR,WRAP4,INCR4, 
                           WRAP8,INCR8,WRAP16,INCR16} burst_type ;
  //enum for size_type
  typedef enum logic[2:0] {BYTE,HALF_WORD, WORD,DWORD,
                           QWORD,DQWORD,WORD16, WORD32} size_type;

endpackage : ahb_pkg  
  
