# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>

source ../scripts/prologue.tcl

# Contraints files selection
switch $::env(BOARD) {
  "genesys2" - "kc705" - "vc707" - "vcu128" - "zcu102" {
    import_files -fileset constrs_1 -norecurse ../constraints/cheshire.xdc
  }
  default {
      exit 1
  }
}

# Ips selection
switch $::env(BOARD) {
  "genesys2" - "kc705" - "vc707" {
    set ips { "../xilinx/xlnx_mig_7_ddr3/xlnx_mig_7_ddr3.srcs/sources_1/ip/xlnx_mig_7_ddr3/xlnx_mig_7_ddr3.xci" }
  }
  "vcu128" {
    set ips { "../xilinx/xlnx_mig_ddr4/xlnx_mig_ddr4.srcs/sources_1/ip/xlnx_mig_ddr4/xlnx_mig_ddr4.xci" \
              "../xilinx/xlnx_vio/xlnx_vio.srcs/sources_1/ip/xlnx_vio/xlnx_vio.xci" \
              "../xilinx/xlnx_qspi/xlnx_qspi.srcs/sources_1/ip/xlnx_qspi/xlnx_qspi.xci" \
            }
  }
  "zcu102" {
    set ips { "../xilinx/xlnx_mig_ddr4/xlnx_mig_ddr4.srcs/sources_1/ip/xlnx_mig_ddr4/xlnx_mig_ddr4.xci"}
  }
  default {
    set ips {}
  }
}

read_ip $ips

# Add sources
source ../scripts/add_sources.tcl
# Manually add the sources that submodules will not give bender
# Yes, this is a dirty solution and a fix should be applied in the interested submodules instead
set SyncSpRamBeNx64  [exec find ../../../ -name SyncSpRamBeNx64.sv  | grep cva6 | head -n 1]
set instr_tracer_pkg [exec find ../../../ -name instr_tracer_pkg.sv | grep cva6 | head -n 1]
add_files -norecurse -fileset [current_fileset] $SyncSpRamBeNx64
add_files -norecurse -fileset [current_fileset] $instr_tracer_pkg

set_property top cheshire_top_xilinx [current_fileset]

update_compile_order -fileset sources_1

# Add project configuration for Xilinx' memory
set_property XPM_LIBRARIES XPM_MEMORY [current_project]

# Add constraints
import_files -fileset constrs_1 -norecurse ../constraints/$::env(BOARD).xdc
set_property used_in_synthesis false [get_files cheshire.xdc]
set_property used_in_synthesis false [get_files $::env(BOARD).xdc]
# Import contraints for external JTAG connection
if { $::env(EXT_JTAG) } {
    import_files -fileset constrs_1 ../constraints/occamy_vcu128_impl_ext_jtag.xdc
    set_property used_in_synthesis false [get_files occamy_vcu128_impl_ext_jtag.xdc]
}

# Check rtl first
synth_design -rtl -name rtl_1

if { $::env(DEBUG_RUN) eq "1" } {
  # Check for combinatorial loops (axi_downsized has such an issue https://github.com/pulp-platform/axi/issues/195)
  report_drc -checks "LUTLP-1" -file timing.rtl.drc
  start_gui
  set_property STRATEGY                                           Flow_RuntimeOptimized    [get_runs synth_1]
  set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY          none                     [get_runs synth_1]
  set_property STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS  true                     [get_runs synth_1]
  # Instantiate ILAs
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/i_cva6/axi_req_o[*]]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/i_cva6/axi_resp_i[*]]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/i_cva6/pc_commit[*]]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/i_cva6/csr_regfile_i/mepc_q[*]]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/i_cva6/csr_regfile_i/mcause_q[*]]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/i_cva6/csr_regfile_i/mtval_q[*]]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/i_cva6/csr_regfile_i/cycle_q_reg[*]]
} else {
  set_property STRATEGY                                           $::env(SYNTH_STRATEGY)   [get_runs synth_1]
  set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING                   true                     [get_runs synth_1]
}  

launch_runs synth_1
wait_on_run synth_1
open_run synth_1

exec mkdir -p reports/
exec rm -rf reports/*

check_timing -verbose                                                   -file reports/$project.check_timing.rpt
# report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack -file reports/$project.timing_WORST_100.rpt
# report_timing -nworst 1 -delay_type max -sort_by group                  -file reports/$project.timing.rpt
report_utilization -hierarchical -hierarchical_percentage               -file reports/$project.utilization.rpt
# report_cdc                                                              -file reports/$project.cdc.rpt
# report_clock_interaction                                                -file reports/$project.clock_interaction.rpt

set DEBUG [llength [get_nets -hier -filter {MARK_DEBUG == 1}]]
if ($DEBUG) {
    # Create core
    puts "Creating debug core..."
    create_debug_core u_ila_0 ila
    set_property -dict "ALL_PROBE_SAME_MU true ALL_PROBE_SAME_MU_CNT 4 C_ADV_TRIGGER true C_DATA_DEPTH 16384 \
     C_EN_STRG_QUAL true C_INPUT_PIPE_STAGES 0 C_TRIGIN_EN false C_TRIGOUT_EN false" [get_debug_cores u_ila_0]
    ## Clock
    set_property port_width 1 [get_debug_ports u_ila_0/clk]
    connect_debug_port u_ila_0/clk [get_nets soc_clk]
    # Get nets to debug
    set debugNets [lsort -dictionary [get_nets -hier -filter {MARK_DEBUG == 1}]]
    set netNameLast ""
    set probe_i 0
    # Loop through all nets (add extra list element to ensure last net is processed)
    foreach net [concat $debugNets {""}] {
        # Remove trailing array index
        regsub {\[[0-9]*\]$} $net {} netName
        # Create probe after all signals with the same name have been collected
        if {$netNameLast != $netName} {
            if {$netNameLast != ""} {
                puts "Creating probe $probe_i with width [llength $sigList] for signal '$netNameLast'"
                # probe0 already exists, and does not need to be created
                if {$probe_i != 0} {
                    create_debug_port u_ila_0 probe
                }
                set_property port_width [llength $sigList] [get_debug_ports u_ila_0/probe$probe_i]
                set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe$probe_i]
                connect_debug_port u_ila_0/probe$probe_i [get_nets $sigList]
                incr probe_i
            }
            set sigList ""
        }
        lappend sigList $net
        set netNameLast $netName
    }
    # Need to save save constraints before implementing the core
    # set_property target_constrs_file cheshire.srcs/constrs_1/imports/constraints/$::env(BOARD).xdc [current_fileset -constrset]
    save_constraints -force
    implement_debug_core
    write_debug_probes -force $project.ltx
}

# Implementation
if { $::env(DEBUG_RUN) eq "1" } {
  set_property "steps.place_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
  set_property "steps.route_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
} else {
  set_property STRATEGY                                    $::env(IMPL_STRATEGY)    [get_runs impl_1]
  set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED 		       true                     [get_runs impl_1]
  set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true                     [get_runs impl_1]
}

launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Check timing constraints
open_run impl_1
# set timingrep [report_timing_summary -no_header -no_detailed_paths -return_string]
# if {! [string match -nocase {*timing constraints are met*} $timingrep]} {
#   send_msg_id {USER 1-1} ERROR {Timing constraints were not met.}
#   # return -code error
# }

# Output Verilog netlist + SDC for timing simulation
# write_verilog -force -mode funcsim out/${project}_funcsim.v
# write_verilog -force -mode timesim out/${project}_timesim.v
# write_sdf     -for -verbose

# Reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing -verbose                                                     -file reports/${project}.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/${project}.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/${project}.timing.rpt
report_utilization -hierarchical -hierarchical_percentage                 -file reports/${project}.utilization.rpt
