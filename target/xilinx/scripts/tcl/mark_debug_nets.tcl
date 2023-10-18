# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>

# Mark target debug nets
# NOTE: these nets must have been preserved during synthesis
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/axi_req_o*                ]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/axi_resp_i*               ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/fetch_entry_if_id*        ]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/pc_commit*                ]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/commit_stage_i/exception_o*]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/commit_stage_i/commit_instr_i*]
# set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/mepc_q*/Q   ]]
# set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/mcause_q*/Q ]]
# set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/mtval_q*/Q  ]]
set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/cycle_q*/Q  ]]
if { $::env(ARA) eq "1" } {
  # TODO?: unpack these to probe only the necessary signals
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/acc_req_i* ]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/acc_resp_o*]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/axi_req_o* ]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/axi_resp_i*]
  # MMU-related ports
  # set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/en_ld_st_translation_i ] # uncomment when not tied to zero
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/mmu* ]
  # Internal ports
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/ara_idle]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/gen_accelerator.i_acc_dispatcher/*]
  set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_ara/i_vlsu/i_addrgen/state_q_reg*/Q]]
  set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_ara/i_vlsu/i_addrgen/axi_addrgen_state_q_reg*/Q]]  
}

# MMU, same as CVA6 mmu.sv for now
# NOTE: most of these are related to the PTW
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/req_port_i*           ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/req_port_o*           ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/ptw_error_o*    ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/update_vaddr_o* ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/itlb_update_o*  ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/dtlb_update_o*  ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/dtlb_access_i*  ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/dtlb_vaddr_i*   ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/dtlb_hit_i*     ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/itlb_access_i*  ]
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/itlb_vaddr_i*   ]  
# set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/ex_stage_i/lsu_i/gen_mmu_sv39.i_cva6_mmu/i_ptw/itlb_hit_i*     ]
