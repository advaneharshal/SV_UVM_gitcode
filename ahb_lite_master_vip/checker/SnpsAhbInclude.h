/*===========================================================================
                    SYNOPSYS CONFIDENTIAL
This is an unpublished, proprietary work of Synopsys, Inc. and is
fully protected under copyright and trade secret laws.
You may not view, use, disclose, copy or distribute this file or any
information contained herein except pursuant to a valid written
license from Synopsys.Inc.
===========================================================================*/
// ----------------------------------------------------------------------------
// AIP Display task
// ----------------------------------------------------------------------------
//synopsys translate_off
task sva_aip_display;
    input string severity;
    input string spec_section;
    input string err_msg;
    int error_count;
    begin

        `ifdef ASSERT_MAX_REPORT_ERROR
            error_count = error_count + 1;
            if (error_count <= `ASSERT_MAX_REPORT_ERROR)
        `endif
        `ifndef SYNTHESIS
        `ifdef SVA_CHECKER_NO_MESSAGE
        `else
             `ifdef SVA_VMM_LOG_ON
                  case(severity)
                      "FATAL" :
                          `vmm_fatal(log,
                           $psprintf("[%0s]  %0s", spec_section, err_msg));
                      "ERROR" :
                          `vmm_error(log,
                           $psprintf("[%0s]  %0s", spec_section, err_msg));
                      "WARNING" :
                          `vmm_warning(log,
                           $psprintf("[%0s]  %0s", spec_section, err_msg));
                      "NORMAL" :
                          `vmm_note(log,
                           $psprintf("[%0s]  %0s", spec_section, err_msg));
                  endcase
             `else
                 case(severity)
                      "FATAL" :
                       begin
                          $display("!FATAL![FAILURE] on %s(%s) at %t\n[%0s]  %0s",design_name, instancename, $time, spec_section, err_msg);
                          $finish;
                       end
                     "ERROR" :
                          $display("!ERROR![FAILURE] on %s(%s) at %t\n[%0s]  %0s",design_name, instancename, $time, spec_section, err_msg);
                      "WARNING" :
                          $display("!WARNING![FAILURE] on %s(%s) at %t\n[%0s]  %0s",design_name, instancename, $time, spec_section, err_msg);
                      "NORMAL" :
                          $display("!Normal![NOTE] on %s(%s) at %t\n[%0s]  %0s",design_name, instancename, $time, spec_section, err_msg);
                  endcase
             `endif
        `endif
        `endif // SYNTHESIS
        `ifdef ASSERT_MAX_REPORT_ERROR
             end
         `endif
     end
endtask
//synopsys translate_on

`ifdef SNPS_AHB_INCLUDE_DONE
`else
`define SNPS_AHB_SPLIT           2'b11
`define SNPS_AHB_RETRY           2'b10
`define SNPS_AHB_OKAY            2'b00
`define SNPS_AHB_ERROR           2'b01

`define SNPS_AHB_BUSY			   2'b01
`define SNPS_AHB_IDLE			   2'b00
`define SNPS_AHB_NSEQ			   2'b10
`define SNPS_AHB_SEQ			   2'b11

`define SNPS_AHB_SINGLE            3'b000
`define SNPS_AHB_INCR              3'b001

`define SNPS_AHB_MASTER_NOT_SPLIT_OR_RETRIED          2'b00
`define SNPS_AHB_MASTER_IN_SPLIT                      2'b01
`define SNPS_AHB_MASTER_SPLIT_AND_HSPLIT_ASSERTED     2'b10
`define SNPS_AHB_MASTER_IN_RETRY                      2'b11

`define MASTER_INACTIVE           2'b00
`define MASTER_OWNS_ADDR_ONLY     2'b01
`define MASTER_OWNS_ADDR_AND_DATA 2'b10
`define MASTER_OWNS_DATA_ONLY    2'b11

`define HBURST_COVERAGE_BIN bins hburst[]= {[LOW_HBURST_ITERATION_LIMIT:HIGH_HBURST_ITERATION_LIMIT]};
//Abhishek ignore hburst_0 for single transfers
`define HBURST_COVERAGE_IGNORE_BIN ignore_bins hburst_ignore = {0};
`define HWRITE_COVERAGE_BIN bins hwrite[]= {[0:1]};
`define HSIZE_COVERAGE_BIN bins hsize[]= {[LOW_HSIZE_ITERATION_LIMIT:HIGH_HSIZE_ITERATION_LIMIT]};
`define HMASTER_COVERAGE_BIN bins hmaster[]= {[0:NUMBER_OF_MASTERS]};
`endif

