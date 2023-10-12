// CVA6's wrapper for Xilinx' Dynamic Function eXchange (DFX), a.k.a. Dynamic Partial Reconfiguration (DPR)


module cva6_dfx_wrapper import ariane_pkg::*; import cheshire_pkg::*;(
  input  logic                         clk_i,
  input  logic                         rst_ni,
  // Core ID, Cluster ID and boot address are considered more or less static
  input  logic [riscv::VLEN-1:0]       boot_addr_i,  // reset boot address
  input  logic [riscv::XLEN-1:0]       hart_id_i,    // hart id in a multicore environment (reflected in a CSR)

  // Interrupt inputs
  input  logic [1:0]                   irq_i,        // level sensitive IR lines, mip & sip (async)
  input  logic                         ipi_i,        // inter-processor interrupts (async)
  // Timer facilities
  input  logic                         time_irq_i,   // timer interrupt in (async)
  input  logic                         debug_req_i,  // debug request (async)
`ifdef ARIANE_ACCELERATOR_PORT
  // Invalidation requests
  output logic                         acc_cons_en_o,
  input  logic [63:0]                  inval_addr_i,
  input  logic                         inval_valid_i,
  output logic                         inval_ready_o,    

  // MMU interface with accelerator
  input  exception_t                      acc_mmu_misaligned_ex_i,
  input  logic                            acc_mmu_req_i,        // request address translation
  input  logic [riscv::VLEN-1:0]          acc_mmu_vaddr_i,      // virtual address in
  input  logic                            acc_mmu_is_store_i,   // the translation is requested by a store
  // if we need to walk the page table we can't grant in the same cycle
  // Cycle 0
  output logic                            acc_mmu_dtlb_hit_o,   // sent in the same cycle as the request if translation hits in the DTLB
  output logic [riscv::PPNW-1:0]          acc_mmu_dtlb_ppn_o,   // ppn (send same cycle as hit)
  // Cycle 1
  output logic                            acc_mmu_valid_o,      // translation is valid
  output logic [riscv::PLEN-1:0]          acc_mmu_paddr_o,      // translated address
  output exception_t                      acc_mmu_exception_o,  // address translation threw an exception
`endif
  // RISC-V formal interface port (`rvfi`):
  // Can be left open when formal tracing is not needed.
  output ariane_pkg::rvfi_port_t          rvfi_o,
  output acc_pkg::accelerator_req_t       cvxif_req_o,
  input  acc_pkg::accelerator_resp_t      cvxif_resp_i,
  // L15 (memory side)
  output wt_cache_pkg::l15_req_t          l15_req_o,
  input  wt_cache_pkg::l15_rtrn_t         l15_rtrn_i,
  // memory side, AXI Master
  output cheshire_pkg::axi_cva6_axi_req_t               axi_req_o,
  input  cheshire_pkg::axi_cva6_axi_rsp_t               axi_res
  );

  localparam ariane_pkg::ariane_cfg_t Cva6Cfg = gen_cva6_cfg(cheshire_pkg::DefaultCfg);

  cva6 #(
    .ArianeCfg     ( Cva6Cfg                        ),
    .AxiAddrWidth  ( cheshire_pkg::DefaultCfg.AddrWidth    ),
    .AxiDataWidth  ( cheshire_pkg::DefaultCfg.AxiDataWidth ),
    .AxiIdWidth    ( cheshire_pkg::Cva6IdWidth      ),
    .cvxif_req_t   ( acc_pkg::accelerator_req_t ),
    .cvxif_resp_t  ( acc_pkg::accelerator_resp_t ),
    .axi_ar_chan_t ( cheshire_pkg::axi_cva6_ar_chan_t ),
    .axi_aw_chan_t ( cheshire_pkg::axi_cva6_aw_chan_t ),
    .axi_w_chan_t  ( cheshire_pkg::axi_cva6_w_chan_t  ),
    .axi_req_t     ( cheshire_pkg::axi_cva6_req_t     ),
    .axi_rsp_t     ( cheshire_pkg::axi_cva6_rsp_t     )
  ) i_core_cva6 (
    .clk_i,
    .rst_ni,
    .boot_addr_i,
    .hart_id_i,
    .irq_i,
    .ipi_i,
    .time_irq_i,
    .debug_req_i,
    .rvfi_o,
    .l15_req_o,
    .l15_rtrn_i,
    // Accelerator ports
    .cvxif_req_o,
    .cvxif_resp_i,
`ifdef ARIANE_ACCELERATOR_PORT
    // Invalidation requests
    .acc_cons_en_o,
    .inval_addr_i,
    .inval_valid_i,
    .inval_ready_o,
    // MMU interface with accelerator
    .acc_mmu_misaligned_ex_i,
    .acc_mmu_req_i,
    .acc_mmu_vaddr_i,
    .acc_mmu_is_store_i,
    .acc_mmu_dtlb_hit_o,
    .acc_mmu_dtlb_ppn_o,
    .acc_mmu_valid_o,
    .acc_mmu_paddr_o,
    .acc_mmu_exception_o,
`endif // ARIANE_ACCELERATOR_PORT
    // AXI interface
    .axi_req_o,
    .axi_resp_i
  );

endmodule : cva6_dfx_wrapper
