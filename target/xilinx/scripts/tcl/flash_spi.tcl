
# Adapted from occamy_vcu128_procs.tcl:occ_flash_spi
# Only tested on VCU128

# Parse arguments
if {$argc < 1} {
    error "usage: flash_spi.tcl MCS_FILE"
}
set MCS_FILE       [lindex $argv 0]

# Connect to hw_server
open_hw_manager
connect_hw_server -url $::env(HOST):$::env(PORT)
open_hw_target $::env(HOST):$::env(PORT)/$::env(FPGA_PATH)

# Add the SPI flash as configuration memory
set hw_device [get_hw_devices $::env(FPGA_DEVICE)]
create_hw_cfgmem -hw_device [get_hw_devices $::env(FPGA_DEVICE)] [lindex [get_cfgmem_parts {mt25qu02g-spi-x1_x2_x4}] 0]
set hw_cfgmem [get_property PROGRAM.HW_CFGMEM [get_hw_devices $::env(FPGA_DEVICE)]]
set_property PROGRAM.ADDRESS_RANGE          {use_file}          $hw_cfgmem
set_property PROGRAM.FILES                  [list $MCS_FILE]    $hw_cfgmem
set_property PROGRAM.PRM_FILE               {}                  $hw_cfgmem
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none}         $hw_cfgmem
set_property PROGRAM.BLANK_CHECK            0                   $hw_cfgmem
set_property PROGRAM.ERASE                  1                   $hw_cfgmem
set_property PROGRAM.CFG_PROGRAM            1                   $hw_cfgmem
set_property PROGRAM.VERIFY                 1                   $hw_cfgmem
set_property PROGRAM.CHECKSUM               0                   $hw_cfgmem
# Create bitstream to access SPI flash
puts "Creating bitstream to access SPI flash"
create_hw_bitstream -hw_device [get_hw_devices $::env(FPGA_DEVICE)] [get_property PROGRAM.HW_CFGMEM_BITFILE [get_hw_devices $::env(FPGA_DEVICE)] ] 
program_hw_devices  [get_hw_devices $::env(FPGA_DEVICE)] 
refresh_hw_device   [get_hw_devices $::env(FPGA_DEVICE)] 
# Program SPI flash
puts "Programing SPI flash"
program_hw_cfgmem -hw_cfgmem $hw_cfgmem



