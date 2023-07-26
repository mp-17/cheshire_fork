# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

###################
# Global Settings #
###################

# Preserve the output mux of the clock divider
set_property DONT_TOUCH TRUE [get_cells i_sys_clk_div/i_clk_bypass_mux]

# The net of which we get the 200 MHz single ended clock from the MIG
set SOC_RST_SRC [get_pins -filter {DIRECTION == OUT} -leaf -of_objects [get_nets rst_n]]

#####################
# Timing Parameters #
#####################

# 50 MHz SoC clock
set SOC_TCK 20.0

# 10 MHz (max) JTAG clock
set JTAG_TCK 100.0

# I2C High-speed mode is 3.2 Mb/s
set I2C_IO_SPEED 312.5

# UART speed is at most 5 Mb/s
set UART_IO_SPEED 200.0

##########
# Clocks #
##########

# Clk_wiz clocks
create_clock -period 100 -name clk_10 [get_pins i_xlnx_clk_wiz/clk_10]
create_clock -period 50 -name clk_20 [get_pins i_xlnx_clk_wiz/clk_20]
create_clock -period 20 -name clk_50 [get_pins i_xlnx_clk_wiz/clk_50]
create_clock -period 10 -name clk_100 [get_pins i_xlnx_clk_wiz/clk_100]

# System Clock
# [see in board.xdc]

# JTAG Clock
create_clock -period $JTAG_TCK -name clk_jtag [get_ports jtag_tck_i]
set_input_jitter clk_jtag 1.000

##########
# BUFG   #
##########

# JTAG are on non clock capable GPIOs (if not using BSCANE)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports jtag_tck_i]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports jtag_tck_i]]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports cpu_reset]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports cpu_reset]]

set all_in_mux [get_nets -of [ get_pins -filter { DIRECTION == IN } -of [get_cells -hier -filter { ORIG_REF_NAME == tc_clk_mux2 || REF_NAME == tc_clk_mux2 }]]]
set_property CLOCK_DEDICATED_ROUTE FALSE $all_in_mux
set_property CLOCK_BUFFER_TYPE NONE $all_in_mux

################
# Clock Groups #
################

# JTAG Clock is asynchronous to all other clocks
set_clock_groups -name jtag_async -asynchronous -group {clk_jtag}

########
# JTAG #
########

set_input_delay  -min -clock clk_jtag [expr 0.10 * $JTAG_TCK] [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay  -max -clock clk_jtag [expr 0.20 * $JTAG_TCK] [get_ports {jtag_tdi_i jtag_tms_i}]

set_output_delay -min -clock clk_jtag [expr 0.10 * $JTAG_TCK] [get_ports jtag_tdo_o]
set_output_delay -max -clock clk_jtag [expr 0.20 * $JTAG_TCK] [get_ports jtag_tdo_o]

set_max_delay  -from [get_ports jtag_trst_ni] $JTAG_TCK
set_false_path -hold -from [get_ports jtag_trst_ni]

########
# UART #
########

set_max_delay [expr $UART_IO_SPEED * 0.35] -from [get_ports uart_rx_i]
set_false_path -hold -from [get_ports uart_rx_i]

set_max_delay [expr $UART_IO_SPEED * 0.35] -to [get_ports uart_tx_o]
set_false_path -hold -to [get_ports uart_tx_o]

########
# CDCs #
########

# cdc_fifo_gray: Disable hold checks, limit datapath delay and bus skew
set_property KEEP_HIERARCHY SOFT [get_cells i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync]
set_false_path -hold -through [get_pins -of_objects [get_cells i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*]] -through [get_pins -of_objects [get_cells i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*]]

set_false_path -hold -through [get_pins -of_objects [get_cells -hier -filter {ORIG_REF_NAME == axi_cdc_src || REF_NAME == axi_cdc_src}] -filter {NAME =~ *async*}]
set_false_path -hold -through [get_pins -of_objects [get_cells -hier -filter {ORIG_REF_NAME == axi_cdc_dst || REF_NAME == axi_cdc_dst}] -filter {NAME =~ *async*}]

###############
# Xilinx QSPI #
###############
# From https://github.com/AlSaqr-platform/he-soc/blob/master/hardware/fpga/alsaqr/tcl/constraints.xdc#L38
# tested on vivado-2018.2
# SPI-STARTUPE3 Ultrascale+
# Following are the SPI device parameters
set tco_max 7
set tco_min 1
set tsu 2
set th 3
set tdata_trace_delay_max 0.25
set tdata_trace_delay_min 0.25
set tclk_trace_delay_max 0.2
set tclk_trace_delay_min 0.2
create_generated_clock -name clk_sck -source [get_pins -hierarchical *i_axi_full_quad_spi/ext_spi_clk] [get_pins -hierarchical */CCLK] -edges {3 5 7}
set_input_delay -clock clk_sck -max [expr $tco_max + $tdata_trace_delay_max + $tclk_trace_delay_max] [get_pins -hierarchical *STARTUP*/DATA_IN[*]] -clock_fall;
set_input_delay -clock clk_sck -min [expr $tco_min + $tdata_trace_delay_min + $tclk_trace_delay_min] [get_pins -hierarchical *STARTUP*/DATA_IN[*]] -clock_fall;
set_multicycle_path 2 -setup -from clk_sck -to [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]]
set_multicycle_path 1 -hold -end -from clk_sck -to [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]]
set_output_delay -clock clk_sck -max [expr $tsu + $tdata_trace_delay_max -$tclk_trace_delay_min] [get_pins -hierarchical *STARTUP*/DATA_OUT[*]];
set_output_delay -clock clk_sck -min [expr $tdata_trace_delay_min -$th -$tclk_trace_delay_max] [get_pins -hierarchical *STARTUP*/DATA_OUT[*]];
set_multicycle_path 2 -setup -start -from [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]] -to clk_sck
set_multicycle_path 1 -hold -from [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]] -to clk_sck
# TODO: fix [Timing 38-316] Clock period '20.000' specified during out-of-context synthesis of instance 'i_axi_full_quad_spi' at clock pin 'ext_spi_clk' is different from the actual clock period '5.000', this can lead to different synthesis results.