# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Program bitstream

# First check if the probe file exists
exec ls $::env(LTX) 

# Connect to hw server
open_hw_manager
set url $::env(HOST):$::env(PORT)
if {[catch {connect_hw_server -url $url} 0]} {
    puts stderr "WARNING: Another connection is already up, proceeding using the existing connection instead"
}
set target $::env(HOST):$::env(PORT)/$::env(FPGA_PATH)
open_hw_target $target
set_property PARAM.FREQUENCY 15000000 [get_hw_targets $target]
puts "Using probe file $::env(LTX)"
set_property PROBES.FILE      $::env(LTX) [get_hw_devices $::env(FPGA_DEVICE)]
set_property FULL_PROBES.FILE $::env(LTX) [get_hw_devices $::env(FPGA_DEVICE)]
current_hw_device   [get_hw_devices $::env(FPGA_DEVICE)]

puts "Query the design"
# Debug
report_property -all [get_hw_targets]
# Search for hw probes
refresh_hw_device [lindex [get_hw_devices $::env(FPGA_DEVICE)] 0]

#######################
## ILA configuration ##
#######################
# Set triggers
# Ara req/resp valid
set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_ara/acc_req_i[req_valid]} -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"u_ila_0"}]]
set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_ara/acc_resp_o[resp_valid]} -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"u_ila_0"}]]
# CVA6 exception valid
# set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/commit_stage_i/exception_o[valid]} -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"u_ila_0"}]]

# Debug, PC hang
set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/commit_stage_i/commit_instr_i[0][valid]} -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"u_ila_0"}]]
set_property TRIGGER_COMPARE_VALUE eq64'hFFFF_FFFF_8000_331X [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/pc_commit} -of_objects [get_hw_ilas -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"u_ila_0"}]]


# Set trigger control
set_property CONTROL.TRIGGER_CONDITION OR [get_hw_ilas -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"u_ila_0"}]
set_property CONTROL.TRIGGER_POSITION 4096 [get_hw_ilas -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"u_ila_0"}]

# Arm ILA
run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"u_ila_0"}]

