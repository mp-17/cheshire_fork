# Parse arguments
if {$argc < 3} {
    error "usage: write_cfgmem.tcl MCS_FILE FLASH_OFFSET FLASH_FILE"
}
set MCS_FILE       [lindex $argv 0]
set FLASH_OFFSET   [lindex $argv 1]
set FLASH_FILE     [lindex $argv 2]

# From occamy_vcu128_program.tcl
set interface SPIx4 
puts "Creating config mem file $MCS_FILE from for ${interface} @$FLASH_OFFSET from $FLASH_FILE"
# Create flash configuration file
write_cfgmem -force -format mcs -size 256 -interface SPIx4 \
    -loaddata "up $FLASH_OFFSET $FLASH_FILE" \
    -checksum \
    -file $MCS_FILE
