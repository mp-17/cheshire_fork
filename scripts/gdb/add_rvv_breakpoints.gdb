# # Define utility command for breaking at raw addresses
# # Usage: 
#     # (gdb) setup_breakpoint_with_name *<address> "<breakpoint name>"
# define setup_breakpoint_with_name    
#     break $arg0
#     set $name = $arg1
#     commands
#         print $name
#     end
# end   

# Add breakpoints

# Functions using RVV instructions
# NOTE: before using any vector instruction, the kernel always uses vsetvl{i}
# Using vle8.v
break __restore_v_state
break riscv_v_first_use_handler

# Using vse8.v and reads vector CSRs
break save_v_state

# Using vse8.v and vle8.v
break __schedule

# Using also vmv.v.i
break do_trap_ecall_u

# Related functions, not using RVV instructions (hence, no vsetvl{i} either)
# Reads VLENB
break riscv_v_setup_vsize

# Control functions
break riscv_v_vstate_ctrl_user_allowed
break riscv_v_vstate_ctrl_init
break riscv_v_vstate_ctrl_get_current
break riscv_v_vstate_ctrl_set_current
break riscv_v_init


# Print info
printf "Breakpoints set\n"
info breakpoints
