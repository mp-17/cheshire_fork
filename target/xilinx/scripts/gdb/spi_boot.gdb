# Select and load elf
file /usr/scratch/fenga3/vmaisto/cva6-sdk_fork/install64/fw_payload.elf
# file /usr/scratch/fenga3/vmaisto/cva6-sdk_cheshire/install64/fw_jump.elf
# load
# file /usr/scratch/fenga3/vmaisto/cva6-sdk_cheshire/install64/u-boot
load
printf "File loaded\n"

# Set useful breakpoints
## OpenSBI
# break _fw_start
# break payload_bin 
# break sbi_illegal_insn_handler
# break sbi_hart_hang
# break sbi_trap_handler 
printf "Breakpoints set\n"
info breakpoints

# Jump to FW_START
# printf "Jumping to FW_START (0x80000000)\n"
# j *0x80000000
continue

# # Set application-specific breakpoints
# # break clint_get_core_freq
# # break uart_init
# # break uart_write_str
# # break uart_write_flush
# break flag_function_1

# # # From clint.c
# # break get_mcycle
# # break clint_get_mtime

