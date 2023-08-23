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
current_hw_device   [get_hw_devices $::env(FPGA_DEVICE)]
program_hw_devices  [get_hw_devices $::env(FPGA_DEVICE)]

puts "Query the design"
# Debug
report_property -all [get_hw_targets]
# Search for hw probes
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $::env(FPGA_DEVICE)] 0]

close_hw_manager