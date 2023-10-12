// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Matheus Cavalcante <matheusd@iis.ee.ethz.ch>
// Description:
// This is Ara's vector load/store unit. It is used exclusively for vector
// loads and vector stores. There are no guarantees regarding concurrency
// and coherence with Ariane's own load/store unit.

import ariane_pkg::exception_t;

module vlsu_dfx_wrapper import ara_pkg::*; import rvv_pkg::*; import cheshire_pkg::*; (
    input  logic                    clk_i,
    input  logic                    rst_ni,
    // AXI Memory Interface
    output axi_ara_wide_req_t                axi_req_o,
    input  axi_ara_wide_resp_t               axi_resp_i,
    // Interface with the dispatcher
    input  logic                    core_st_pending_i,
    output logic                    load_complete_o,
    output logic                    store_complete_o,
    output logic                    store_pending_o,
    // Interface with the sequencer
    input  pe_req_t                 pe_req_i,
    input  logic                    pe_req_valid_i,
    input  logic      [NrVInsn-1:0] pe_vinsn_running_i,
    output logic      [1:0]         pe_req_ready_o,         // Load  units
    output pe_resp_t  [1:0]         pe_resp_o,              // Load  units
    output logic                    addrgen_ack_o,
    output logic                    addrgen_error_o,
    output vlen_t                   addrgen_error_vl_o,
    // Interface with the lanes
    // Store unit operands
    input  elen_t     [`ARA_NR_LANES-1:0] stu_operand_i,
    input  logic      [`ARA_NR_LANES-1:0] stu_operand_valid_i,
    output logic      [`ARA_NR_LANES-1:0] stu_operand_ready_o,
    // Address generation operands
    input  elen_t     [`ARA_NR_LANES-1:0] addrgen_operand_i,
    input  target_fu_e[`ARA_NR_LANES-1:0] addrgen_operand_target_fu_i,
    input  logic      [`ARA_NR_LANES-1:0] addrgen_operand_valid_i,
    output logic                    addrgen_operand_ready_o,
    // Interface with the Mask unit
    input  logic [$bits(elen_t)/8-1:0]     [`ARA_NR_LANES-1:0] mask_i,
    input  logic      [`ARA_NR_LANES-1:0] mask_valid_i,
    output logic                    vldu_mask_ready_o,
    output logic                    vstu_mask_ready_o,
    
    // Interface with CVA6's sv39 MMU
    // This is everything the MMU can provide, it might be overcomplete for Ara and some signals be useless
    output  exception_t                    mmu_misaligned_ex_o,
    output  logic                          mmu_req_o,        // request address translation
    output  logic [riscv::VLEN-1:0]        mmu_vaddr_o,      // virtual address out
    output  logic                          mmu_is_store_o,   // the translation is requested by a store
    // if we need to walk the page table we can't grant in the same cycle
    // Cycle 0
    input logic                            mmu_dtlb_hit_i,   // sent in the same cycle as the request if translation hits in the DTLB
    input logic [riscv::PPNW-1:0]          mmu_dtlb_ppn_i,   // ppn 
    // Cycle 1
    input logic                            mmu_valid_i,      // translation is valid
    input logic [riscv::PLEN-1:0]          mmu_paddr_i,      // translated address
    input exception_t                      mmu_exception_i,  // address translation threw an exception

    // Results
    output logic      [`ARA_NR_LANES-1:0] ldu_result_req_o,
    output vid_t      [`ARA_NR_LANES-1:0] ldu_result_id_o,
    output vaddr_t    [`ARA_NR_LANES-1:0] ldu_result_addr_o,
    output elen_t     [`ARA_NR_LANES-1:0] ldu_result_wdata_o,
    output logic [$bits(elen_t)/8-1:0]     [`ARA_NR_LANES-1:0] ldu_result_be_o,
    input  logic      [`ARA_NR_LANES-1:0] ldu_result_gnt_i,
    input  logic      [`ARA_NR_LANES-1:0] ldu_result_final_gnt_i
  );

    // For DFX
    `include "axi/typedef.svh"

    `include "cheshire/typedef.svh"

    // Declare interface types internally
    // For addr_t and axi_user_t
   `CHESHIRE_TYPEDEF_ALL(, cheshire_pkg::DefaultCfg)

    // Configure Ara with the right AXI id width
    typedef logic [cheshire_pkg::Cfg.AxiMstIdWidth-1:0] ara_id_t; // set it cheshire_pkg.sv
    // Default Ara AXI data width
    localparam int unsigned AraDataWideWidth = 32 * `ARA_NR_LANES;
    typedef logic [AraDataWideWidth   -1 : 0] axi_ara_wide_data_t;
    typedef logic [AraDataWideWidth/8 -1 : 0] axi_ara_wide_strb_t;
    `AXI_TYPEDEF_ALL(axi_ara_wide, addr_t, ara_id_t, axi_ara_wide_data_t, axi_ara_wide_strb_t, axi_user_t)



  vlsu #(
    .NrLanes      ( `ARA_NR_LANES                  ),
    .AxiDataWidth ( cheshire_pkg::Cfg.AxiDataWidth ),
    .AxiAddrWidth ( cheshire_pkg::Cfg.AddrWidth    ),
    .axi_ar_t     ( axi_ara_wide_ar_chan_t         ),
    .axi_r_t      ( axi_ara_wide_r_chan_t          ),
    .axi_aw_t     ( axi_ara_wide_aw_chan_t         ),
    .axi_w_t      ( axi_ara_wide_w_chan_t          ),
    .axi_b_t      ( axi_ara_wide_b_chan_t          ),
    .axi_req_t    ( axi_ara_wide_req_t             ),
    .axi_resp_t   ( axi_ara_wide_resp_t            ),
    .vaddr_t     
  ) i_vlsu (
    .clk_i                      ,
    .rst_ni                     ,
    // AXI memory interface
    .axi_req_o                  ,
    .axi_resp_i                 ,
    // Interface with the dispatcher
    .core_st_pending_i          ,
    .load_complete_o            ,
    .store_complete_o           ,
    .store_pending_o            ,
    // Interface with the sequencer
    .pe_req_i                   ,
    .pe_req_valid_i             ,
    .pe_vinsn_running_i         ,
    .pe_req_ready_o             ,
    .pe_resp_o                  ,
    .addrgen_ack_o              ,
    .addrgen_error_o            ,
    .addrgen_error_vl_o         ,
    // Interface with the Mask unit
    .mask_i                     ,
    .mask_valid_i               ,
    .vldu_mask_ready_o          ,
    .vstu_mask_ready_o          ,
    // Interface with the lanes
    // Store unit
    .stu_operand_i              ,
    .stu_operand_valid_i        ,
    .stu_operand_ready_o        ,
    // Address Generation
    .addrgen_operand_i          ,
    .addrgen_operand_target_fu_i,
    .addrgen_operand_valid_i    ,
    .addrgen_operand_ready_o    ,
    // Interface with CVA6's sv39 MMU
    .mmu_misaligned_ex_o,
    .mmu_req_o,
    .mmu_vaddr_o,
    .mmu_is_store_o,
    .mmu_dtlb_hit_i,
    .mmu_dtlb_ppn_i,
    .mmu_valid_i,
    .mmu_paddr_i,
    .mmu_exception_i,
    // Load unit
    .ldu_result_req_o           ,
    .ldu_result_addr_o          ,
    .ldu_result_id_o            ,
    .ldu_result_wdata_o         ,
    .ldu_result_be_o            ,
    .ldu_result_gnt_i           ,
    .ldu_result_final_gnt_i     
  );

endmodule : vlsu_dfx_wrapper
