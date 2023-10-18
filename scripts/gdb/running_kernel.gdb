# NOTE: Run this script on a running kernel

# Loading symbol file, offset must be the same as OpenSBI FW_PAYLOAD_OFFSET
symbol-file /scratch/vmaisto/cheshire_fork/sw/boot/install64V/vmlinux -o 0x200000


# Adding RVV-related breakpoints
source scripts/gdb/add_rvv_breakpoints.gdb

break payload_bin