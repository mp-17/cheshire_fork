
add wave sim:/tb_cheshire_soc/fix/dut/xvio_mmu_exception_i
add wave sim:/tb_cheshire_soc/fix/dut/xvio_en_ld_st_translation_i
add wave -group mmu_stub sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_mmu_stub/*
run 100
force -deposit sim:/tb_cheshire_soc/fix/dut/xvio_mmu_exception_i        1'h1 0
force -deposit sim:/tb_cheshire_soc/fix/dut/xvio_en_ld_st_translation_i 1'h1 0
run -a
