# NOTE: Run this script to reboot kernel in memory

# Load OpenSBI + Linux ELF
file /scratch/vmaisto/cheshire_fork/sw/boot/install64/in_memory_fw_payload.elf
load
printf "OpenSBI + Linux loaded\n"

# Attach to a running kernel
# source scripts/gdb/running_kernel.gdb
# break sbi_hart_hang

continue
