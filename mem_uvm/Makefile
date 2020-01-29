clean:
	rm -rf work  *.svp *.vstf  
all:	
	qverilog -work work +incdir+C:/questasim64_10.4e/verilog_src/uvm-1.1d/src +incdir+/home/Lenovo/uvm_example/mem_uvm -timescale "1ns/1ns" -mfcu +acc=rmb design.sv testbench.sv +define+UVM_NO_DPI +define+UVM_NO_DPI +define+UVM_REGEX_NO_DPI -R +UVM_TESTNAME="mem_wr_rd_test"

%:      # thanks to chakrit
@:    # thanks to William Pursell
