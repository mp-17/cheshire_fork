# Select and load elf
# file ../../../cva6-sdk_cheshire/install64/in_memory_fw_payload.elf
file sw/boot/install64/in_memory_fw_payload.elf 
# file ../../../cva6-sdk_fork_update_kernel/install64/in_memory_fw_payload.elf
# file ../../../cva6-sdk_fork_update_kernel_no_RVV/install64/in_memory_fw_payload.elf
load
printf "File loaded\n"

## Set useful breakpoints
## OpenSBI
# break _fw_start
# break payload_bin 
# break sbi_illegal_insn_handler
# break fw_platform_init 
# break _trap_handler
# break _trap_exit
# break _start_hang
# break _fdt_reloc_done
# break sbi_hart_hang
# break sbi_trap_handler 

# ## Linux 6.5-rc-6
# Define utility function
# define setup_breapoint_with_name    
#     # Setup breakpoint
#     break $arg0
#     # Show a name when it is hit
#     set $name = $arg1
#     commands
#         print $name
#     end
# end   
# # All the symbols using RVV from vmlinux.dump + FW_PAYLOAD_OFFSET (0x200000)
# # Once attached as payload to OpenSBI, Linux looses all symbols
# # NOTE: this could be automated processing vmlinux.dump
# setup_breapoint_with_name *0x802010d0 "_start_kernel"
# setup_breapoint_with_name *0x80203caa "riscv_vr_get"
# setup_breapoint_with_name *0x80204464 "__restore_v_state"
# setup_breapoint_with_name *0x8020465a "save_v_state"
# setup_breapoint_with_name *0x802064e2 "riscv_v_first_use_handler"
# setup_breapoint_with_name *0x80206478 "riscv_v_vstate_ctrl_user_allowed"
# setup_breapoint_with_name *0x80206494 "riscv_v_setup_vsize"
# setup_breapoint_with_name *0x8020649c "csrr_a5_vlenb"
# setup_breapoint_with_name *0x8020665a "riscv_v_vstate_ctrl_init"
# setup_breapoint_with_name *0x802066aa "riscv_v_vstate_ctrl_get_current"
# setup_breapoint_with_name *0x802066cc "riscv_v_vstate_ctrl_set_current"
# setup_breapoint_with_name *0x804d8f08 "riscv_v_init"
# setup_breapoint_with_name *0x804e18a4 "do_trap_ecall_u"
# setup_breapoint_with_name *0x804e2d82 "__schedule"


printf "Breakpoints set\n"
info breakpoints

printf "Continuing...\n"
continue

