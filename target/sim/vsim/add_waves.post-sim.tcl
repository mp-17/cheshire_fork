add wave -group SoC /tb_cheshire_soc/fix/dut/*
# Copyright 2021 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Matheus Cavalcante <matheusd@iis.ee.ethz.ch>

add wave -noupdate -group CVA6 -group core /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/*

add wave -noupdate -group CVA6 -group frontend /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/i_frontend/*
add wave -noupdate -group CVA6 -group frontend -group icache /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/genblk4/i_cache_subsystem/*
# add wave -noupdate -group CVA6 -group frontend -group ras /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/i_frontend/i_ras/*
# add wave -noupdate -group CVA6 -group frontend -group btb /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/i_frontend/i_btb/*
# add wave -noupdate -group CVA6 -group frontend -group bht /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/i_frontend/i_bht/*
# add wave -noupdate -group CVA6 -group frontend -group instr_scan /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/i_frontend/*/i_instr_scan/*
# add wave -noupdate -group CVA6 -group frontend -group fetch_fifo /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/i_frontend/i_fetch_fifo/*

add wave -noupdate -group CVA6 -group id_stage -group decoder /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/id_stage_i/decoder_i/*
add wave -noupdate -group CVA6 -group id_stage -group compressed_decoder /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/id_stage_i/genblk1/compressed_decoder_i/*
add wave -noupdate -group CVA6 -group id_stage /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/id_stage_i/*

add wave -noupdate -group CVA6 -group issue_stage -group scoreboard /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/issue_stage_i/i_scoreboard/*
add wave -noupdate -group CVA6 -group issue_stage -group issue_read_operands /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/issue_stage_i/i_issue_read_operands/*
add wave -noupdate -group CVA6 -group issue_stage -group rename /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/issue_stage_i/i_re_name/*
add wave -noupdate -group CVA6 -group issue_stage /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/issue_stage_i/*

add wave -noupdate -group CVA6 -group ex_stage -group alu /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/alu_i/*
add wave -noupdate -group CVA6 -group ex_stage -group mult /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/i_mult/*
add wave -noupdate -group CVA6 -group ex_stage -group mult -group mul /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/i_mult/i_multiplier/*
add wave -noupdate -group CVA6 -group ex_stage -group mult -group div /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/i_mult/i_div/*
add wave -noupdate -group CVA6 -group ex_stage -group fpu /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/fpu_gen/fpu_i/*
add wave -noupdate -group CVA6 -group ex_stage -group fpu -group fpnew /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/fpu_gen/fpu_i/fpu_gen/i_fpnew_bulk/*

add wave -noupdate -group CVA6 -group ex_stage -group lsu /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/*
add wave -noupdate -group CVA6 -group ex_stage -group lsu  -group lsu_bypass /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/lsu_bypass_i/*
add wave -noupdate -group CVA6 -group ex_stage -group lsu -group mmu /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39/i_cva6_mmu/*
add wave -noupdate -group CVA6 -group ex_stage -group lsu -group mmu -group itlb /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39/i_cva6_mmu/i_itlb/*
add wave -noupdate -group CVA6 -group ex_stage -group lsu -group mmu -group dtlb /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39/i_cva6_mmu/i_dtlb/*
add wave -noupdate -group CVA6 -group ex_stage -group lsu -group mmu -group ptw /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39/i_cva6_mmu/i_ptw/*

add wave -noupdate -group CVA6 -group ex_stage -group lsu -group store_unit /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/i_store_unit/*
add wave -noupdate -group CVA6 -group ex_stage -group lsu -group store_unit -group store_buffer /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/i_store_unit/store_buffer_i/*

add wave -noupdate -group CVA6 -group ex_stage -group lsu -group load_unit /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/i_load_unit/*

add wave -noupdate -group CVA6 -group ex_stage -group branch_unit /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/branch_unit_i/*

add wave -noupdate -group CVA6 -group ex_stage -group csr_buffer /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/csr_buffer_i/*

add wave -noupdate -group CVA6 -group ex_stage /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/ex_stage_i/*

add wave -noupdate -group CVA6 -group commit_stage /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/commit_stage_i/*

add wave -noupdate -group CVA6 -group csr_file /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/*

add wave -noupdate -group CVA6 -group controller /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/controller_i/*

add wave -noupdate -group CVA6 -group wt_dcache /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/genblk4/i_cache_subsystem/i_wt_dcache/*
add wave -noupdate -group CVA6 -group wt_dcache -group miss_handler /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/genblk4/i_cache_subsystem/i_wt_dcache/i_wt_dcache_missunit/*

add wave -noupdate -group CVA6 -group wt_dcache -group load {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/genblk4/i_cache_subsystem/i_wt_dcache/gen_rd_ports[0]/i_wt_dcache_ctrl/*}
add wave -noupdate -group CVA6 -group wt_dcache -group ptw {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/genblk4/i_cache_subsystem/i_wt_dcache/gen_rd_ports[1]/i_wt_dcache_ctrl/*}

add wave -noupdate -group CVA6 -group dispatcher /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/gen_accelerator/i_acc_dispatcher/*

add wave -noupdate -group CVA6 -group perf_counters /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_core_cva6/gen_perf_counter/perf_counters_i/*
# Copyright 2021 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Matheus Cavalcante <matheusd@iis.ee.ethz.ch>

add wave -noupdate -group Ara -group core /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/*

add wave -noupdate -group Ara -group dispatcher /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/i_dispatcher/*
add wave -noupdate -group Ara -group sequencer /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/i_sequencer/*

# Add waves from all the lanes
for {set lane 0}  {$lane < 2} {incr lane} {
    do wave_lane.post-sim.tcl $lane
}

add wave -noupdate -group Ara -group masku /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/i_masku/*

add wave -noupdate -group Ara -group sldu /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/i_sldu/*

add wave -noupdate -group Ara -group vlsu -group addrgen /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/i_vlsu/i_addrgen/*
add wave -noupdate -group Ara -group vlsu -group vldu /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/i_vlsu/i_vldu/*
add wave -noupdate -group Ara -group vlsu -group vstu /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/i_vlsu/i_vstu/*
add wave -noupdate -group Ara -group vlsu /tb_cheshire_soc/fix/dut/gen_cva6_cores[0].i_ara/i_vlsu/*
