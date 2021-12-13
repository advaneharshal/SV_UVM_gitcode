# Bind AIP
bind:clean	
	vcsi ../dut/ahb_slave.v +incdir+../dut ../checker/SnpsAhbSlaveChecker.sv ../bind/bind.sv -debug_all -sverilog -assert dve +incdir+../src +incdir+../checker +indir+../tests
	./simv -l bind.log

clean:
	rm -fr simv* csrc *.log *.key *.vpd DVE* *.vdb urg* work trans* *.wlf

