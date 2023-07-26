# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Program bitstream

# First check if the bitstream file exists
exec ls $::env(BIT) 

# Connect to hw server
open_hw_manager
set url $::env(HOST):$::env(PORT)
if {[catch {connect_hw_server -url $url} 0]} {
    puts stderr "WARNING: Another connection is already up, proceeding using the existing connection instead"
}
set target $::env(HOST):$::env(PORT)/$::env(FPGA_PATH)
open_hw_target $target
set_property PARAM.FREQUENCY 15000000 [get_hw_targets $target]
# Programming bitstream
puts "Programming $::env(BIT)"
set_property PROGRAM.FILE     $::env(BIT) [get_hw_devices $::env(FPGA_DEVICE)]
# For bitstream programming, we don't need a probe file
# set_property PROBES.FILE      $::env(LTX) [get_hw_devices $::env(FPGA_DEVICE)]
# set_property FULL_PROBES.FILE $::env(LTX) [get_hw_devices $::env(FPGA_DEVICE)]
current_hw_device   [get_hw_devices $::env(FPGA_DEVICE)]
program_hw_devices  [get_hw_devices $::env(FPGA_DEVICE)]

puts "Query the design"
# Debug
report_property -all [get_hw_targets]
# Search for hw probes
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $::env(FPGA_DEVICE)] 0]

# puts "--------------------"
# set vios [get_hw_vios -of_objects [get_hw_devices $::env(FPGA_DEVICE)]]
# puts "Done programming device, found [llength $vios] VIOS: "
# foreach vio $vios {
#     puts "- $vio : [get_hw_probes * -of_objects $vio]"
# }
# puts "--------------------"

# proc occ_write_vio {regexp_vio regexp_probe val} {
#     global occ_hw_device
#     puts "\[occ_write_vio $regexp_vio $regexp_probe\]"
#     set vio_sys [get_hw_vios -of_objects [get_hw_devices $::env(FPGA_DEVICE)] -regexp $regexp_vio]
#     set_property OUTPUT_VALUE $val [get_hw_probes -of_objects $vio_sys -regexp $regexp_probe]
#     commit_hw_vio [get_hw_probes -of_objects $vio_sys -regexp $regexp_probe]
# }

puts "(not implemented yet) Reset peripherals and CPU"
# occ_write_vio "hw_vio_1" ".*rst.*" 1

# Set boot mode
puts "(not implemented yet) Setting boot mode"
# TBD


close_hw_manager