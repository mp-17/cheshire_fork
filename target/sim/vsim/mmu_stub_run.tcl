
add wave sim:/tb_cheshire_soc/fix/dut/xvio_mmu_exception_i
add wave sim:/tb_cheshire_soc/fix/dut/xvio_en_ld_st_translation_i

if { $::env(MMU_STUB) eq "1"} {
    add wave -group mmu_stub sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_mmu_stub/*
}
run 100
if {[string first "mmu_stub" $BINARY] != -1} {
    force -deposit sim:/tb_cheshire_soc/fix/dut/xvio_mmu_exception_i 1'h1 0
    if {[string first "page_fault" $BINARY] != -1} {
        force -deposit sim:/tb_cheshire_soc/fix/dut/xvio_en_ld_st_translation_i 1'h1 0
    }
}
run -a
