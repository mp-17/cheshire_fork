# NOTE: Run this script on a running kernel

# Loading symbol file, offset must be the same as OpenSBI FW_PAYLOAD_OFFSET
symbol-file /usr/scratch/fenga3/vmaisto/cva6-sdk_fork_backup/install64/vmlinux -o 0x200000

# Adding RVV-related breakpoints
source scripts/gdb/add_rvv_breakpoints.gdb
