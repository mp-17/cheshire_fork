# Select and load elf
# file ../../sw/tests/rvv_hello_world.spm.elf 
# file ../../sw/tests/rvv_hello_world.dram.elf 
# file ../../sw/tests/helloworld.dram.elf 
file ../../sw/tests/helloworld.spm.elf 
load
printf "File loaded\n"

# # Set useful breakpoints
# break _start
# break main
# break _exit
# break trap_vector
# printf "Breakpoints set\n"


# # Set application-specific breakpoints
# # break clint_get_core_freq
# # break uart_init
# # break uart_write_str
# # break uart_write_flush
# break flag_function_1

# # # From clint.c
# # break get_mcycle
# # break clint_get_mtime

