# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

# Contraints files selection
switch $::env(BOARD) {
  "genesys2" - "kc705" - "vc707" - "vcu128" - "zcu102" {
    import_files -fileset constrs_1 -norecurse ../constraints/cheshire.xdc
    import_files -fileset constrs_1 -norecurse ../constraints/$::env(BOARD).xdc
  }
  default {
      exit 1
  }
}

# Ips selection
set ips $::env(IP_PATHS)
read_ip $ips

source ../scripts/add_sources.tcl
# add_files -norecurse -fileset sources_1 ../../../hw/cva6_dfx_wrapper.sv
# add_files -norecurse -fileset sources_1 ../../../hw/vlsu_dfx_wrapper.sv

set_property top cheshire_top_xilinx [current_fileset]

update_compile_order -fileset sources_1

#############################
# DFX: partition definition #
#############################

# set_property -name "pr_flow" -value "1" -objects [current_project]

# # CVA6
# create_partition_def -name partition_cva6 -module cva6_dfx_wrapper
# create_reconfig_module -name cva6_dfx_wrapper -partition_def [get_partition_defs partition_cva6 ]  -define_from cva6_dfx_wrapper
# update_compile_order -fileset cva6_dfx_wrapper
# update_compile_order -fileset sources_1


# # Ara VLSU
# create_partition_def -name partition_vlsu -module vlsu_dfx_wrapper
# create_reconfig_module -name vlsu_dfx_wrapper -partition_def [get_partition_defs partition_vlsu ]  -define_from vlsu_dfx_wrapper
# update_compile_order -fileset vlsu_dfx_wrapper
# update_compile_order -fileset sources_1

# start_gui

set_property XPM_LIBRARIES XPM_MEMORY [current_project]

synth_design -rtl -name rtl_1
# start_gui

# Preserve the net names and hierarchy for debug
if { ($::env(DEBUG_RUN) eq "1") || ($::env(DEBUG_NETS) eq "1") } {
  set_property STRATEGY                                           Flow_RuntimeOptimized    [get_runs synth_1]
  set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY          none                     [get_runs synth_1]
  set_property STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS  true                     [get_runs synth_1]
} else {
  set_property STRATEGY                                           $::env(SYNTH_STRATEGY)   [get_runs synth_1]
  set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING                   true                     [get_runs synth_1]
}  

# Synthesis
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1


##################
# DFX: floorplan #
##################
# startgroup
# create_pblock pblock_cva6
# resize_pblock pblock_cva6 -add CLOCKREGION_X4Y6:CLOCKREGION_X7Y7
# add_cells_to_pblock pblock_cva6 [get_cells [list {i_cheshire_soc/gen_cva6_cores[0].i_core_cva6}]] -clear_locs
# endgroup

# startgroup
# create_pblock pblock_i_vlsu
# resize_pblock pblock_i_vlsu -add CLOCKREGION_X4Y4:CLOCKREGION_X7Y5
# add_cells_to_pblock pblock_i_vlsu [get_cells [list {i_cheshire_soc/gen_cva6_cores[0].i_ara/i_vlsu}]] -clear_locs
# endgroup


exec mkdir -p reports/
exec rm -rf reports/*

check_timing -verbose                                                   -file reports/$project.check_timing.rpt
# report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack -file reports/$project.timing_WORST_100.rpt
# report_timing -nworst 1 -delay_type max -sort_by group                  -file reports/$project.timing.rpt
report_utilization -hierarchical -hierarchical_percentage               -file reports/$project.utilization.rpt
report_cdc                                                              -file reports/$project.cdc.rpt
report_clock_interaction                                                -file reports/$project.clock_interaction.rpt

# Remove black-boxed unreads (only necessary for common_cells < v1.31.1)
remove_cell [get_cells -hier -filter {ORIG_REF_NAME == "unread" || REF_NAME == "unread"}]

# Add further debug nets
if { $::env(DEBUG_NETS) eq "1" } {
  source ../scripts/tcl/mark_debug_nets.tcl
}

# Instantiate ILA
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
    write_debug_probes -force probes.ltx
}

# Incremental implementation
if {[info exists $::env(ROUTED_DCP)] && [file exists  $::env(ROUTED_DCP)]} {
  set_property incremental_checkpoint $ $::env(ROUTED_DCP) [get_runs impl_1]
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

# launch_runs impl_1
# wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Check timing constraints
set timingrep [report_timing_summary -no_header -no_detailed_paths -return_string]
if {[info exists ::env(CHECK_TIMING)] && $::env(CHECK_TIMING)==1} {
  if {! [string match -nocase {*timing constraints are met*} $timingrep]} {
    send_msg_id {USER 1-1} ERROR {Timing constraints were not met.}
    return -code error
  }
}

# Output Verilog netlist + SDC for timing simulation
if {[info exists ::env(EXPORT_SDF)] && $::env(EXPORT_SDF)==1} {
  write_verilog -force -mode funcsim out/${project}_funcsim.v
  write_verilog -force -mode timesim out/${project}_timesim.v
  write_sdf     -force out/${project}_timesim.sdf
}

# Reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                              -file reports/${project}.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/${project}.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/${project}.timing.rpt
report_utilization -hierarchical -hierarchical_percentage                 -file reports/${project}.utilization.rpt
