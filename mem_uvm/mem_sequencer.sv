//-------------------------------------------------------------------------
//						mem_sequencer - www.verificationguide.com
//-------------------------------------------------------------------------

class mem_sequencer extends uvm_sequencer#(mem_seq_item);

  `uvm_component_utils(mem_sequencer) 
  int count;
  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::get(null,"uvm_my_top","cnt",count); 
    $display (" from sequnecer count %0d",count);
  endfunction 
endclass