# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Reset from VIO probe

# Connect to hw server
# open_hw_manager
# set url $::env(HOST):$::env(PORT)
# if {[catch {connect_hw_server -url $url} 0]} {
#     puts stderr "WARNING: Another connection is already up, proceeding using the existing connection instead"
# }

set_property OUTPUT_VALUE 1 [get_hw_probes vio_reset_1 -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"i_xlnx_vio"}]]
commit_hw_vio [get_hw_probes {vio_reset_1} -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"i_xlnx_vio"}]]
after 100
set_property OUTPUT_VALUE 0 [get_hw_probes vio_reset_1 -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"i_xlnx_vio"}]]
commit_hw_vio [get_hw_probes {vio_reset_1} -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu37p_0] -filter {CELL_NAME=~"i_xlnx_vio"}]]
