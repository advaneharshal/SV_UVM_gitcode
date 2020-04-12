// Code your testbench here
// or browse Examples

class mailbox#(type T=int);
  
  T mq[$];
 

  function void put(int A);
    mq.push_back(A);
  endfunction
  
  function int get();
    return(mq.pop_front);
  endfunction 
endclass

class gen;
  mailbox mbox;
  
  function new(mailbox _mb);
    this.mbox = _mb;
  endfunction

  task run();
      mbox.put(2);
      
  endtask
endclass 

class drv;
  mailbox bbox;
  int xtrans;
  function new(mailbox _mb);
    this.bbox = _mb;
  endfunction 
  
  task run();
    xtrans = bbox.get();
    $display(" Get the val %0d",xtrans);
  endtask
endclass 


program top();
  gen a; 
  drv b;
  mailbox lbx; 
  initial 
    begin
      lbx =new();
      a= new(lbx);
      b=new(lbx);
      fork 
      a.run();
      b.run();
      join
    end
endprogram 
