
all:
	qverilog -work work +incdir+C:/questasim64_10.4e/verilog_src/uvm-1.1d/src $1 +define+UVM_NO_DPI +define+UVM_NO_DPI +define+UVM_REGEX_NO_DPI -v "C:/questasim64_10.4e/uvm-1.1d/win64/uvm_dpi.dll"
action:
	@echo action $(filter-out $@,$(MAKECMDGOALS))

%:      # thanks to chakrit
    @:    # thanks to William Pursell

