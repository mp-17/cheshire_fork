# NOTE: Run this script to reboot kernel in memory

# Load OpenSBI + Linux ELF
file /usr/scratch/fenga3/vmaisto/cva6-sdk_fork_backup/install64/in_memory_fw_payload.elf
load
printf "OpenSBI + Linux loaded\n"

# Attach to a running kernel
source scripts/gdb/running_kernel.gdb
 