// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
//
// Description: Simple stub emulating MMU behaviour

module mmu_stub (
    input  logic                          clk_i,
    input  logic                          rst_ni,
    input  logic                          en_ld_st_translation_i,  // Enable behaviour
    input  logic                          trigger_exception_i,     // Emulate exception generation on requests (load/store page faults)
    input  ariane_pkg::exception_t        misaligned_ex_i,         // Ignored
    input  logic                          req_i,
    input  logic [riscv::VLEN-1:0]        vaddr_i,
    input  logic                          is_store_i,              // Mux exception_o.tval
    // Cycle 0
    output logic                          dtlb_hit_o,
    output logic [riscv::PPNW-1:0]        dtlb_ppn_o,              // Constant '1
    // Cycle 1
    output logic                          valid_o,
    output logic [riscv::PLEN-1:0]        paddr_o,                 // Same as vaddr_i
    output ariane_pkg::exception_t        exception_o              // Valid on trigger_exception_i
);

  // Registers
  `include "common_cells/registers.svh"
  logic [riscv::PLEN-1:0] mock_paddr_d, mock_paddr_q;
  logic [riscv::VLEN-1:0] vaddr_d, vaddr_q;
  logic                   valid_d, valid_q;
  logic                   is_store_q, is_store_d;
  `FF(mock_paddr_q, mock_paddr_d, '0, clk_i, rst_ni)
  `FF(vaddr_q     , vaddr_d     , '0, clk_i, rst_ni)
  `FF(valid_q     , valid_d     , '0, clk_i, rst_ni)
  `FF(is_store_q  , is_store_d  , '0, clk_i, rst_ni)

  // Combinatorial logic
  always_comb begin : mmu_stub
    // Outputs (defaults)
    dtlb_hit_o  = '0;
    dtlb_ppn_o  = '0; // Never used
    valid_o     = '0;
    paddr_o     = '0;
    exception_o = '0;

    // Registers feedback
    mock_paddr_d = mock_paddr_q;
    valid_d      = valid_q;
    vaddr_d      = vaddr_q;
    is_store_d   = is_store_q;

    // If trasnlation is enabled
    if ( en_ld_st_translation_i ) begin : enable_translation
      // Cycle 0
      if ( req_i ) begin : req_valid
          // Sample inputs, for next cycle
          mock_paddr_d = vaddr_i; // Mock, just pass back the same vaddr
          vaddr_d      = vaddr_i;
          is_store_d   = is_store_i;

          // Pull up valid
          valid_d = 1'b1;

          // DTBL hit, assume 100%
          // NOTE: Ara does not use these
          dtlb_hit_o = 1'b1;
          dtlb_ppn_o = '1;
      end : req_valid

      // Cycle 1
      if ( valid_q ) begin : valid
        // Output to Ara
        valid_o = 1'b1;
        paddr_o = mock_paddr_q;
        // Pull down flag
        // NOTE: Assumes Ara consumes it 
        valid_d = 1'b0;
      end : valid

      // Mock exception logic
      if ( trigger_exception_i & valid_q ) begin : exception
        exception_o.valid = 1'b1;
        exception_o.cause = ( is_store_q ) ? riscv::STORE_PAGE_FAULT : riscv::LOAD_PAGE_FAULT;
        exception_o.tval  = {'0, vaddr_q};
      end : exception
    end : enable_translation
  end : mmu_stub
endmodule : mmu_stub