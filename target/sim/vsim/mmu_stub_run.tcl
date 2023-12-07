if { $::env(MMU_STUB) eq "1"} {
    add wave -group mmu_stub sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_mmu_stub/*
}
run -a
