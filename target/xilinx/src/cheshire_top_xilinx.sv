// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>

`include "cheshire/typedef.svh"
`include "phy_definitions.svh"

module cheshire_top_xilinx
  import cheshire_pkg::*;
(
`ifdef USE_RESET
  input logic         cpu_reset,
`endif
`ifdef USE_RESETN
  input logic         cpu_resetn,
`endif

`ifdef USE_SWITCHES
  input logic         testmode_i,
  input logic [1:0]   boot_mode_i,
`endif

`ifdef USE_JTAG
  input logic         jtag_tck_i,
  input logic         jtag_tms_i,
  input logic         jtag_tdi_i,
  output logic        jtag_tdo_o,
`ifdef USE_JTAG_TRSTN
  input logic         jtag_trst_ni,
`endif
`ifdef USE_JTAG_VDDGND
  output logic        jtag_vdd_o,
  output logic        jtag_gnd_o,
`endif
`endif

`ifdef USE_I2C
  inout wire          i2c_scl_io,
  inout wire          i2c_sda_io,
`endif

`ifdef USE_SD
  input logic         sd_cd_i,
  output logic        sd_cmd_o,
  inout wire  [3:0]   sd_d_io,
  output logic        sd_reset_o,
  output logic        sd_sclk_o,
`endif

`ifdef USE_FAN
  input logic [3:0]   fan_sw,
  output logic        fan_pwm,
`endif

`ifdef USE_QSPI
  output logic        qspi_clk,
  input  logic        qspi_dq0,
  input  logic        qspi_dq1,
  input  logic        qspi_dq2,
  input  logic        qspi_dq3,
  output logic        qspi_cs_b,
`endif

`ifdef USE_VGA
  // VGA Colour signals
  output logic [4:0]  vga_b,
  output logic [5:0]  vga_g,
  output logic [4:0]  vga_r,
  // VGA Sync signals
  output logic        vga_hs,
  output logic        vga_vs,
`endif

`ifdef USE_SERIAL
  // DDR Link
  output logic [4:0]  ddr_link_o,
  output logic        ddr_link_clk_o,
`endif

  // Phy interface for DDR4
`ifdef USE_DDR4
  `DDR4_INTF
`endif

`ifdef USE_DDR3
  `DDR3_INTF
`endif

  output logic        uart_tx_o,
  input logic         uart_rx_i

);

  // Declare interrupt array
  logic [iomsb(NumExtIntrs):0] intr_ext_chs;

  // Add an external slave for the QSPI
  localparam int unsigned AxiNumExtMst = 0;
  localparam int unsigned AxiNumExtSlv = 1;

  // Declare QSPI memory map
  // TODO: this must be tuned
  localparam byte_bt QSPIExtSlvIdx       = 8'd7;
  localparam doub_bt QSPIExtRegionStart  = 64'h0000_0000_5000_0000;
  localparam doub_bt QSPIExtRegionSize   = 64'h0000_0000_0080_0000;
  localparam doub_bt QSPIExtRegionEnd    = QSPIExtRegionStart + QSPIExtRegionSize;

  // Configure cheshire for FPGA mapping
  localparam cheshire_cfg_t FPGACfg = '{
    // External AXI ports (at most 8 ports and rules)
    AxiExtNumMst      : AxiNumExtMst, // bit     [2:0]  AxiExtNumMst;
    AxiExtNumSlv      : AxiNumExtSlv, // bit     [3:0]  AxiExtNumSlv;
    AxiExtNumRules    : AxiNumExtSlv, // bit     [3:0]  AxiExtNumRules;
    // External AXI region map
    AxiExtRegionIdx   : '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QSPIExtSlvIdx      }, // byte_bt [15:0] 
    AxiExtRegionStart : '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QSPIExtRegionStart }, // doub_bt [15:0] 
    AxiExtRegionEnd   : '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QSPIExtRegionEnd   }, // doub_bt [15:0] 
    // CVA6 parameters
    Cva6RASDepth      : ariane_pkg::ArianeDefaultConfig.RASDepth,
    Cva6BTBEntries    : ariane_pkg::ArianeDefaultConfig.BTBEntries,
    Cva6BHTEntries    : ariane_pkg::ArianeDefaultConfig.BHTEntries,
    Cva6NrPMPEntries  : 0,
    Cva6ExtCieLength  : 'h2000_0000,
    // Harts
    DualCore          : 0,  // Only one core, but rest of config allows for two
    CoreMaxTxns       : 8,
    CoreMaxTxnsPerId  : 4,
    // Interconnect
    // AddrWidth         : 48,
    AddrWidth         : 64, // Needed by CVA6 and ARA
    AxiDataWidth      : 64,
    // AxiUserWidth      : 2,  // Convention: bit 0 for core(s), bit 1 for serial link
    AxiUserWidth      : ariane_pkg::DCACHE_USER_WIDTH,  // WT cache only supports this    
    AxiMstIdWidth     : 2,
    AxiMaxMstTrans    : 8,
    AxiMaxSlvTrans    : 8,
    AxiUserAmoMsb     : 1,
    AxiUserAmoLsb     : 0,
    RegMaxReadTxns    : 8,
    RegMaxWriteTxns   : 8,
    RegAmoNumCuts     : 1,
    RegAmoPostCut     : 1,
    // RTC
    RtcFreq           : 1000000,
    // Features
    Bootrom           : 1,
    Uart              : 1,
    // I2c               : 1, // Disable
    // SpiHost           : 1, // Disable OpenTitan SPI core
    // Gpio              : 1, // Disable 
    // Dma               : 1, // Disable
    SerialLink        : 0,
    // Vga               : 1, // Disable
    // Debug
`ifdef TARGET_BSCANE
    DbgIdCode         : '0, // Unused wih BSCANE
`else
    DbgIdCode         : CheshireIdCode, 
`endif // TARGET_VCU128 
    DbgMaxReqs        : 4,
    DbgMaxReadTxns    : 4,
    DbgMaxWriteTxns   : 4,
    DbgAmoNumCuts     : 1,
    DbgAmoPostCut     : 1,
    // LLC: 128 KiB, up to 2 GiB DRAM
    LlcNotBypass      : 1,
    LlcSetAssoc       : 8,
    LlcNumLines       : 256,
    LlcNumBlocks      : 8,
    LlcMaxReadTxns    : 8,
    LlcMaxWriteTxns   : 8,
    LlcAmoNumCuts     : 1,
    LlcAmoPostCut     : 1,
    LlcOutConnect     : 1,
    LlcOutRegionStart : 'h8000_0000,
    LlcOutRegionEnd   : 'h1_0000_0000,
    // VGA: RGB332
    VgaRedWidth       : 5,
    VgaGreenWidth     : 6,
    VgaBlueWidth      : 5,
    VgaHCountWidth    : 24, // TODO: Default is 32; is this needed?
    VgaVCountWidth    : 24, // TODO: See above
    // Serial Link: map other chip's lower 32bit to 'h1_000_0000
    SlinkMaxTxnsPerId : 4,
    SlinkMaxUniqIds   : 4,
    SlinkMaxClkDiv    : 1024,
    SlinkRegionStart  : 'h1_0000_0000,
    SlinkRegionEnd    : 'h2_0000_0000,
    SlinkTxAddrMask   : 'hFFFF_FFFF,
    SlinkTxAddrDomain : 'h0000_0000,
    SlinkUserAmoBit   : 1,  // Upper atomics bit for serial link
    // DMA config
    DmaConfMaxReadTxns  : 4,
    DmaConfMaxWriteTxns : 4,
    DmaConfAmoNumCuts   : 1,
    DmaConfAmoPostCut   : 1,
    // GPIOs
    GpioInputSyncs    : 1,
    // All non-set values should be zero
    default: '0
  };

  localparam cheshire_cfg_t CheshireFPGACfg = FPGACfg;
  `CHESHIRE_TYPEDEF_ALL(, CheshireFPGACfg)

  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  `ifdef USE_RESET
  logic cpu_resetn;
  assign cpu_resetn = ~cpu_reset;
  `elsif USE_RESETN
  logic cpu_reset;
  assign cpu_reset  = ~cpu_resetn;
  `endif
  logic sys_rst;

  (* dont_touch = "yes" *) wire dram_clock_out; // 200 MHz
  (* dont_touch = "yes" *) wire dram_sync_reset;
  (* dont_touch = "yes" *) wire soc_clk;
  (* dont_touch = "yes" *) wire rst_n;

  ///////////////////////
  //  Xilinx AXI QSPI  //
  ///////////////////////

`ifdef TARGET_XLNX_QSPI

`ifdef QSPI_AXI_LITE
  // UNTESTED
  
  // // AXI types
  // // Define types needed
  // // `CHESHIRE_TYPEDEF_AXI_CT(axi_lite_qspi, addr_t, axi_slv_id_t, logic [31:0], logic [3:0], axi_user_t) 
  // // AXI-lite
  //   `AXI_LITE_TYPEDEF_ALL ( axi_lite_qspi, logic [6:0], logic [31:0], logic [3:0] )
  //   axi_lite_qspi_req_t  axi_lite_qspi_req;
  //   axi_lite_qspi_resp_t axi_lite_qspi_resp;
  // // AXI-full 32bit
  //   `AXI_TYPEDEF_ALL      ( axi_qspi_d32 , addr_t, axi_slv_id_t, logic [31:0], logic [3:0], axi_user_t )
  //   axi_qspi_d32_req_t axi_qspi_d32_req;
  //   axi_qspi_d32_resp_t axi_qspi_d32_rsp;
  // // AXI-full full width
  //   axi_slv_req_t axi_qspi_req;
  //   axi_slv_rsp_t axi_qspi_resp;

  // AXI-Lite
  // // Connects as a 32-bit slave on either AXI4-Lite (or AXI4 interface)
  //   xlnx_qspi i_axi_lite_quad_spi(
  //     .ext_spi_clk   ( clk_i             ), // in Occamy BD: 100MHz
  //     .s_axi4_aclk    ( clk_i             ), // in Occamy BD: 25MHz
  //     .s_axi4_aresetn ( rst_ni            ), // in Occamy BD: peripheral reset 
  //     .s_axi4_awaddr  ( axi_lite_qspi_req .aw.addr  ), // ( spi_lite.aw_addr  ),
  //     .s_axi4_awvalid ( axi_lite_qspi_req .aw_valid ), // ( spi_lite.aw_valid ),
  //     .s_axi4_awready ( axi_lite_qspi_resp.aw_ready ), // ( spi_lite.aw_ready ),
  //     .s_axi4_wdata   ( axi_lite_qspi_req .w.data   ), // ( spi_lite.w_data   ),
  //     .s_axi4_wstrb   ( axi_lite_qspi_req .w.strb   ), // ( spi_lite.w_strb   ),
  //     .s_axi4_wvalid  ( axi_lite_qspi_req .w_valid  ), // ( spi_lite.w_valid  ),
  //     .s_axi4_wready  ( axi_lite_qspi_resp.w_ready  ), // ( spi_lite.w_ready  ),
  //     .s_axi4_bresp   ( axi_lite_qspi_resp.b.axi_qspi_resp  ), // ( spi_lite.b_resp   ),
  //     .s_axi4_bvalid  ( axi_lite_qspi_resp.b_valid  ), // ( spi_lite.b_valid  ),
  //     .s_axi4_bready  ( axi_lite_qspi_req .b_ready  ), // ( spi_lite.b_ready  ),
  //     .s_axi4_araddr  ( axi_lite_qspi_req .ar.addr  ), // ( spi_lite.ar_addr  ),
  //     .s_axi4_arvalid ( axi_lite_qspi_req .ar_valid ), // ( spi_lite.ar_valid ),
  //     .s_axi4_arready ( axi_lite_qspi_resp.ar_ready ), // ( spi_lite.ar_ready ),
  //     .s_axi4_rdata   ( axi_lite_qspi_resp.r.data   ), // ( spi_lite.r_data   ),
  //     .s_axi4_rresp   ( axi_lite_qspi_resp.r.axi_qspi_resp  ), // ( spi_lite.r_resp   ),
  //     .s_axi4_rvalid  ( axi_lite_qspi_resp.r_valid  ), // ( spi_lite.r_valid  ),
  //     .s_axi4_rready  ( axi_lite_qspi_req .r_ready  ), // ( spi_lite.r_ready  ),
  //     .cfgclk        (                   ),
  //     .cfgmclk       (                   ),
  //     .eos           (                   ),
  //     .preq          (                   ),
  //     .gsr           ( 1'b0              ), 
  //     .gts           ( 1'b1              ), in Occamy BD: 1'b0
  //     .keyclearb     ( 1'b1              ), 
  //     .usrcclkts     ( 1'b0              ), 
  //     .usrdoneo      ( 1'b1              ), 
  //     .usrdonets     ( 1'b1              ), 
  // // .ip2intc_irpt  ( irq_sources[0]    ) //TODO: connect this to plic
  //     .ip2intc_irpt  (                   ) //TODO: connect this to plic
  //   );
      
  // // Convert AXI Lite to AXI
  //   axi_to_axi_lite #(
  //     .AxiAddrWidth    ( Cfg.AddrWidth        ),
  //     .AxiDataWidth    ( 32                   ),
  //     .AxiIdWidth      ( AxiSlvIdWidth        ),
  //     .AxiUserWidth    ( Cfg.AxiUserWidth     ),
  //     .AxiMaxReadTxns  ( 1                    ),       
  //     .AxiMaxWriteTxns ( 1                    ),
  //     .FallThrough     ( 1'b0                 ),
  //     .full_req_t      ( axi_slv_req_t        ),
  //     .full_resp_t     ( axi_slv_rsp_t        ),
  //     .lite_req_t      ( axi_lite_qspi_req_t  ),
  //     .lite_resp_t     ( axi_lite_qspi_resp_t )
  //   ) i_axi_to_axi_lite (
  //     .clk_i      ( clk_i              ),
  //     .rst_ni     ( rst_ni             ),
  //     .test_i     ( 1'b0               ),
  //     .slv_req_i  ( axi_qspi_req       ),
  //     .slv_resp_o ( axi_qspi_resp      ),
  //     .mst_req_o  ( axi_lite_qspi_req  ),
  //     .mst_resp_i ( axi_lite_qspi_resp )
  //   ); 

  // // Convert AXI full 32-bit to full width
  //   axi_dw_converter #(
  //     .AxiSlvPortDataWidth ( Cfg.AxiDataWidth         ),
  //     .AxiMstPortDataWidth ( 32                       ),
  //     .AxiAddrWidth        ( Cfg.AddrWidth            ),
  //     .AxiIdWidth          ( AxiSlvIdWidth        ),
  //     .AxiMaxReads         ( 4                        ),
  //     .ar_chan_t           ( axi_qspi_d32_ar_chan_t   ),
  //     .mst_r_chan_t        ( axi_qspi_d32_r_chan_t    ),
  //     .slv_r_chan_t        ( axi_slv_r_chan_t         ),
  //     .aw_chan_t           ( axi_qspi_d32_aw_chan_t   ),
  //     .b_chan_t            ( axi_qspi_d32_b_chan_t    ),
  //     .mst_w_chan_t        ( axi_qspi_d32_w_chan_t    ),
  //     .slv_w_chan_t        ( axi_slv_w_chan_t         ),
  //     .axi_mst_req_t       ( axi_qspi_d32_req_t       ),
  //     .axi_mst_resp_t      ( axi_qspi_d32_resp_t      ),
  //     .axi_slv_req_t       ( axi_slv_req_t            ),
  //     .axi_slv_resp_t      ( axi_slv_rsp_t            )
  //   ) i_ariane_axi_dwc (
  //     .clk_i      ( clk_i            ),
  //     .rst_ni     ( rst_ni           ),
  //     .slv_req_i  ( axi_qspi_req     ),
  //     .slv_resp_o ( axi_qspi_resp    ),
  //     .mst_req_o  ( axi_qspi_d32_req ),
  //     .mst_resp_i ( axi_qspi_d32_rsp )
  //   );

`endif // QSPI_AXI_LITE

`ifdef QSPI_AXI4

  axi_slv_req_t axi_qspi_req;
  axi_slv_rsp_t axi_qspi_resp;
  logic         qspi_intr;

  // AXI4 Full
  localparam C_S_AXI4_ID_WIDTH = 5;
  if ( C_S_AXI4_ID_WIDTH != $bits(axi_slv_id_t) ) {
    $error("xlnx_qspi AXI ID width connection (%d) not matched by axi_slv_id_t (%d):"
            "see property CONFIG.C_S_AXI4_ID_WIDTH", C_S_AXI4_ID_WIDTH, $bits(axi_slv_id_t) );
  }  
  xlnx_qspi i_axi_full_quad_spi (
    .ext_spi_clk     ( clk_i                   ), // input wire ext_spi_clk
    .s_axi4_aclk     ( clk_i                   ), // input wire s_axi4_aclk
    .s_axi4_aresetn  ( rst_ni                  ), // input wire s_axi4_aresetn
    .s_axi4_awid     ( axi_qspi_req .aw.id     ), // input wire [4 : 0]
    .s_axi4_awaddr   ( axi_qspi_req .aw.addr   ), // input wire [23 : 0]
    .s_axi4_awlen    ( axi_qspi_req .aw.len    ), // input wire [7 : 0]
    .s_axi4_awsize   ( axi_qspi_req .aw.size   ), // input wire [2 : 0]
    .s_axi4_awburst  ( axi_qspi_req .aw.burst  ), // input wire [1 : 0]
    .s_axi4_awlock   ( axi_qspi_req .aw.lock   ), // input wire s_axi4_awlock
    .s_axi4_awcache  ( axi_qspi_req .aw.cache  ), // input wire [3 : 0]
    .s_axi4_awprot   ( axi_qspi_req .aw.prot   ), // input wire [2 : 0]
    .s_axi4_awvalid  ( axi_qspi_req .aw_valid  ), // input wire s_axi4_awvalid
    .s_axi4_awready  ( axi_qspi_resp.aw_ready  ), // output wire s_axi4_awready
    .s_axi4_wdata    ( axi_qspi_req .w.data    ), // input wire [31 : 0]
    .s_axi4_wstrb    ( axi_qspi_req .w.strb    ), // input wire [3 : 0]
    .s_axi4_wlast    ( axi_qspi_req .w.last    ), // input wire s_axi4_wlast
    .s_axi4_wvalid   ( axi_qspi_req .w_valid   ), // input wire s_axi4_wvalid
    .s_axi4_wready   ( axi_qspi_resp.w_ready   ), // output wire s_axi4_wready
    .s_axi4_bid      ( axi_qspi_resp.b.id      ), // output wire [3 : 0]
    .s_axi4_bresp    ( axi_qspi_resp.b.resp    ), // output wire [1 : 0]
    .s_axi4_bvalid   ( axi_qspi_resp.b_valid   ), // output wire s_axi4_bvalid
    .s_axi4_bready   ( axi_qspi_req .b_ready   ), // input wire s_axi4_bready
    .s_axi4_arid     ( axi_qspi_req .ar.id     ), // input wire [4 : 0]
    .s_axi4_araddr   ( axi_qspi_req .ar.addr   ), // input wire [23 : 0]
    .s_axi4_arlen    ( axi_qspi_req .ar.len    ), // input wire [7 : 0]
    .s_axi4_arsize   ( axi_qspi_req .ar.size   ), // input wire [2 : 0]
    .s_axi4_arburst  ( axi_qspi_req .ar.burst  ), // input wire [1 : 0]
    .s_axi4_arlock   ( axi_qspi_req .ar.lock   ), // input wire s_axi4_arlock
    .s_axi4_arcache  ( axi_qspi_req .ar.cache  ), // input wire [3 : 0]
    .s_axi4_arprot   ( axi_qspi_req .ar.prot   ), // input wire [2 : 0]
    .s_axi4_arvalid  ( axi_qspi_req .ar_valid  ), // input wire s_axi4_arvalid
    .s_axi4_arready  ( axi_qspi_resp.ar_ready  ), // output wire s_axi4_arready
    .s_axi4_rid      ( axi_qspi_resp.r.id      ), // output wire [3 : 0]
    .s_axi4_rdata    ( axi_qspi_resp.r.data    ), // output wire [31 : 0]
    .s_axi4_rresp    ( axi_qspi_resp.r.resp    ), // output wire [1 : 0]
    .s_axi4_rlast    ( axi_qspi_resp.r.last    ), // output wire s_axi4_rlast
    .s_axi4_rvalid   ( axi_qspi_resp.r_valid   ), // output wire s_axi4_rvalid
    .s_axi4_rready   ( axi_qspi_req .r_ready   ), // input wire s_axi4_rready
    .cfgclk          (                         ), // output wire cfgclk
    .cfgmclk         (                         ), // output wire cfgmclk
    .eos             (                         ), // output wire eos
    .preq            (                         ), // output wire preq
    .gsr             ( 1'b0                    ), // input wire gsr
    .gts             ( 1'b0                    ), // input wire gts // in Occamy BD: 1'b0 
    // .gts             ( 1'b1                    ), // input wire gts // in AlSaqr: 1'b1 (but axi lite)
    .keyclearb       ( 1'b1                    ), // input wire keyclearb
    .usrcclkts       ( 1'b0                    ), // input wire usrcclkts
    .usrdoneo        ( 1'b1                    ), // input wire usrdoneo
    .usrdonets       ( 1'b1                    ), // input wire usrdonets
    .ip2intc_irpt    ( qspi_intr               ) // output wire ip2intc_irpt
  );
  
`endif // QSPI_AXI

`endif // TARGET_XLNX_QSPI

  ///////////////////
  // VIOs          // 
  ///////////////////
  
`ifdef USE_VIO
  logic vio_reset;
  xlnx_vio (
    .clk(soc_clk),
    .probe_out0(vio_reset)
  );
  assign sys_rst = cpu_reset | vio_reset;
`else
  assign sys_rst = cpu_reset;
`endif

  ///////////////////
  // GPIOs         // 
  ///////////////////

  // Tie off signals if no switches on the board
`ifndef USE_SWITCHES
  logic         testmode_i;
  logic [1:0]   boot_mode_i;
  assign testmode_i  = '0;
  assign boot_mode_i = 2'b00; // Passive boot (see cheshire_regs.json)
`endif

  // Give VDD and GND to JTAG
`ifdef USE_JTAG_VDDGND
  assign jtag_vdd_o  = '1;
  assign jtag_gnd_o  = '0;
`endif
`ifndef USE_JTAG_TRSTN
  logic jtag_trst_ni;
  assign jtag_trst_ni = '1;
`endif

  ///////////////////
  // Clock Divider // 
  ///////////////////

  clk_int_div #(
    .DIV_VALUE_WIDTH       ( 4                ),
    .DEFAULT_DIV_VALUE     ( `DDR_CLK_DIVIDER ),
    .ENABLE_CLOCK_IN_RESET ( 1'b0             )
  ) i_sys_clk_div (
    .clk_i                 ( dram_clock_out ),
    .rst_ni                ( ~dram_sync_reset  ),
    .en_i                  ( 1'b1              ),
    .test_mode_en_i        ( testmode_i        ),
    .div_i                 ( `DDR_CLK_DIVIDER  ),
    .div_valid_i           ( 1'b0              ),
    .div_ready_o           (                   ),
    .clk_o                 ( soc_clk           ),
    .cycl_count_o          (                   )
  );

  /////////////////////
  // Reset Generator //
  /////////////////////

  rstgen i_rstgen_main (
    .clk_i        ( soc_clk                  ),
    .rst_ni       ( ~dram_sync_reset         ),
    .test_mode_i  ( testmode_i               ),
    .rst_no       ( rst_n                    ),
    .init_no      (                          ) // keep open
  );

  //////////////
  // DRAM MIG //
  //////////////

  dram_wrapper #(
    .axi_soc_aw_chan_t ( axi_llc_aw_chan_t ),
    .axi_soc_w_chan_t  ( axi_llc_w_chan_t ),
    .axi_soc_b_chan_t  ( axi_llc_b_chan_t ),
    .axi_soc_ar_chan_t ( axi_llc_ar_chan_t ),
    .axi_soc_r_chan_t  ( axi_llc_r_chan_t ),
    .axi_soc_req_t     (axi_llc_req_t),
    .axi_soc_resp_t    (axi_llc_rsp_t)
  ) i_dram_wrapper (
    // Rst
    .sys_rst_i                  ( sys_rst     ),
    .soc_resetn_i               ( rst_n       ),
    .soc_clk_i                  ( soc_clk     ),
    // Clk rst out
    .dram_clk_o                 ( dram_clock_out     ),
    .dram_rst_o                 ( dram_sync_reset    ),
    // Axi
    .soc_req_i                  ( axi_llc_mst_req  ),
    .soc_rsp_o                  ( axi_llc_mst_rsp  ),
    // Phy
    .*
  );

  //////////////////
  // I2C Adaption //
  //////////////////

  logic i2c_sda_soc_out;
  logic i2c_sda_soc_in;
  logic i2c_scl_soc_out;
  logic i2c_scl_soc_in;
  logic i2c_sda_en;
  logic i2c_scl_en;

`ifdef USE_I2C
  // Three state buffer for SCL
  IOBUF #(
    .DRIVE        ( 12        ),
    .IBUF_LOW_PWR ( "FALSE"   ),
    .IOSTANDARD   ( "DEFAULT" ),
    .SLEW         ( "FAST"    )
  ) i_scl_iobuf (
    .O  ( i2c_scl_soc_in      ),
    .IO ( i2c_scl_io          ),
    .I  ( i2c_scl_soc_out     ),
    .T  ( ~i2c_scl_en         )
  );

  // Three state buffer for SDA
  IOBUF #(
    .DRIVE        ( 12        ),
    .IBUF_LOW_PWR ( "FALSE"   ),
    .IOSTANDARD   ( "DEFAULT" ),
    .SLEW         ( "FAST"    )
  ) i_sda_iobuf (
    .O  ( i2c_sda_soc_in      ),
    .IO ( i2c_sda_io          ),
    .I  ( i2c_sda_soc_out     ),
    .T  ( ~i2c_sda_en         )
  );
`endif


  //////////////////
  // SPI Adaption //
  //////////////////

  logic spi_sck_soc;
  logic [1:0] spi_cs_soc;
  logic [3:0] spi_sd_soc_out;
  logic [3:0] spi_sd_soc_in;

  logic spi_sck_en;
  logic [1:0] spi_cs_en;
  logic [3:0] spi_sd_en;

`ifdef USE_SD
  // Assert reset low => Apply power to the SD Card
  assign sd_reset_o       = 1'b0;
  // SCK  - SD CLK signal
  assign sd_sclk_o        = spi_sck_en    ? spi_sck_soc       : 1'b1;
  // CS   - SD DAT3 signal
  assign sd_d_io[3]       = spi_cs_en[0]  ? spi_cs_soc[0]     : 1'b1;
  // MOSI - SD CMD signal
  assign sd_cmd_o         = spi_sd_en[0]  ? spi_sd_soc_out[0] : 1'b1;
  // MISO - SD DAT0 signal
  assign spi_sd_soc_in[1] = sd_d_io[0];
  // SD DAT1 and DAT2 signal tie-off - Not used for SPI mode
  assign sd_d_io[2:1]     = 2'b11;
  // Bind input side of SoC low for output signals
  assign spi_sd_soc_in[0] = 1'b0;
  assign spi_sd_soc_in[2] = 1'b0;
  assign spi_sd_soc_in[3] = 1'b0;
`endif

`ifdef USE_QSPI
  assign qspi_clk  = spi_sck_en    ? spi_sck_soc       : 1'b1;
  assign qspi_cs_b = spi_cs_soc[0];
  assign spi_sd_soc_in[1] = qspi_dq0;
`endif

  /////////////////////////
  // "RTC" Clock Divider //
  /////////////////////////

  logic rtc_clk_d, rtc_clk_q;
  logic [4:0] counter_d, counter_q;

  // Divide soc_clk (50 MHz) by 50 => 1 MHz RTC Clock
  always_comb begin
    counter_d = counter_q + 1;
    rtc_clk_d = rtc_clk_q;

    if(counter_q == 24) begin
      counter_d = 5'b0;
      rtc_clk_d = ~rtc_clk_q;
    end
  end

  always_ff @(posedge soc_clk, negedge rst_n) begin
    if(~rst_n) begin
      counter_q <= 5'b0;
      rtc_clk_q <= 0;
    end else begin
      counter_q <= counter_d;
      rtc_clk_q <= rtc_clk_d;
    end
  end


  /////////////////
  // Fan Control //
  /////////////////

`ifdef USE_FAN
  fan_ctrl i_fan_ctrl (
    .clk_i         ( soc_clk    ),
    .rst_ni        ( rst_n      ),
    .pwm_setting_i ( fan_sw     ),
    .fan_pwm_o     ( fan_pwm    )
  );
`endif

  ////////////////////////
  // Regbus Error Slave //
  ////////////////////////

  reg_req_t ext_req;
  reg_rsp_t ext_rsp;

  reg_err_slv #(
    .DW       ( 32                 ),
    .ERR_VAL  ( 32'hBADCAB1E       ),
    .req_t    ( reg_req_t  ),
    .rsp_t    ( reg_rsp_t  )
  ) i_reg_err_slv_ext (
    .req_i ( ext_req  ),
    .rsp_o ( ext_rsp  )
  );


  //////////////////
  // Cheshire SoC //
  //////////////////
  axi_slv_req_t [iomsb(FPGACfg.AxiExtNumSlv):0] axi_ext_req;
  axi_slv_rsp_t [iomsb(FPGACfg.AxiExtNumSlv):0] axi_ext_resp;

  assign intr_ext_chs = {'0, qspi_intr    };
  assign axi_qspi_req = axi_ext_req[0];
  assign axi_ext_resp = {'0, axi_qspi_resp};
  
  // TODO: connect to xlxn_qspi as external slave
  cheshire_soc #(
    .Cfg               ( FPGACfg ),
    .ExtHartinfo       ( '0 ),
    .axi_ext_llc_req_t ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t ( axi_mst_rsp_t ),
    .axi_ext_slv_req_t ( axi_slv_req_t ),
    .axi_ext_slv_rsp_t ( axi_slv_rsp_t ),
    .reg_ext_req_t     ( reg_req_t ),
    .reg_ext_rsp_t     ( reg_req_t )
  ) i_cheshire_soc (
    .clk_i              ( soc_clk ),
    .rst_ni             ( rst_n   ),
    .test_mode_i        ( testmode_i ),
    .boot_mode_i,
    .rtc_i              ( rtc_clk_q       ),
    .axi_llc_mst_req_o  ( axi_llc_mst_req ),
    .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp ),
    .axi_ext_mst_req_i  ( '0 ),
    .axi_ext_mst_rsp_o  ( ),
    .axi_ext_slv_req_o  ( axi_ext_req    ),
    .axi_ext_slv_rsp_i  ( axi_ext_resp   ),
    .reg_ext_slv_req_o  ( ),
    .reg_ext_slv_rsp_i  ( '0 ),
    .intr_ext_i         ( intr_ext_chs   ),
    .meip_ext_o         ( ),
    .seip_ext_o         ( ),
    .mtip_ext_o         ( ),
    .msip_ext_o         ( ),
    .dbg_active_o       ( ),
    .dbg_ext_req_o      ( ),
    .dbg_ext_unavail_i  ( '0 ),
// Serial Link may be disabled
`ifdef USE_SERIAL
    .ddr_link_i           ( '0                    ),
    .ddr_link_o,
    .ddr_link_clk_i       ( 1'b1                  ),
    .ddr_link_clk_o,
`endif
// External JTAG may be disabled
`ifdef USE_JTAG
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
`endif
// I2C Uses internal signals that are always defined
    .i2c_sda_o            ( i2c_sda_soc_out       ),
    .i2c_sda_i            ( i2c_sda_soc_in        ),
    .i2c_sda_en_o         ( i2c_sda_en            ),
    .i2c_scl_o            ( i2c_scl_soc_out       ),
    .i2c_scl_i            ( i2c_scl_soc_in        ),
    .i2c_scl_en_o         ( i2c_scl_en            ),
// SPI Uses internal signals that are always defined
    .spih_sck_o           ( spi_sck_soc           ),
    .spih_sck_en_o        ( spi_sck_en            ),
    .spih_csb_o           ( spi_cs_soc            ),
    .spih_csb_en_o        ( spi_cs_en             ),
    .spih_sd_o            ( spi_sd_soc_out        ),
    .spih_sd_en_o         ( spi_sd_en             ),
    .spih_sd_i            ( spi_sd_soc_in         ),
`ifdef USE_VGA
    .vga_hsync_o          ( vga_hs                ),
    .vga_vsync_o          ( vga_vs                ),
    .vga_red_o            ( vga_r                 ),
    .vga_green_o          ( vga_g                 ),
    .vga_blue_o           ( vga_b                 ),
`endif
    .uart_tx_o,
    .uart_rx_i
  );

endmodule
