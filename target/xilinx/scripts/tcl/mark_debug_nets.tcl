# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>

# Mark target debug nets
# NOTE: these nets must have been preserved during synthesis
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/axi_req_o*                ]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/axi_resp_i*               ]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/fetch_entry_if_id*        ]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/pc_commit*                ]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/commit_stage_i/exception_o*]
set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/commit_stage_i/commit_instr_i*]
set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/mepc_q*/Q   ]]
set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/mcause_q*/Q ]]
set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/mtval_q*/Q  ]]
set_property MARK_DEBUG 1 [get_nets -of [get_pins i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/csr_regfile_i/cycle_q*/Q  ]]
if { $::env(ARA) eq "1" } {
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/acc_req_i* ]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/acc_resp_o*]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/axi_req_o* ]
  set_property MARK_DEBUG 1 [get_nets i_cheshire_soc/gen_cva6_cores[0].i_ara/axi_resp_i*]
}

