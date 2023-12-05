// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package cheshire_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 7;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic [1:0]  d;
  } cheshire_hw2reg_boot_mode_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_hw2reg_rtc_freq_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_hw2reg_platform_rom_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
    } bootrom;
    struct packed {
      logic        d;
    } llc;
    struct packed {
      logic        d;
    } uart;
    struct packed {
      logic        d;
    } spi_host;
    struct packed {
      logic        d;
    } i2c;
    struct packed {
      logic        d;
    } gpio;
    struct packed {
      logic        d;
    } dma;
    struct packed {
      logic        d;
    } serial_link;
    struct packed {
      logic        d;
    } vga;
    struct packed {
      logic        d;
    } axirt;
    struct packed {
      logic        d;
    } clic;
    struct packed {
      logic        d;
    } irq_router;
  } cheshire_hw2reg_hw_features_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_hw2reg_llc_size_reg_t;

  typedef struct packed {
    struct packed {
      logic [7:0]  d;
    } red_width;
    struct packed {
      logic [7:0]  d;
    } green_width;
    struct packed {
      logic [7:0]  d;
    } blue_width;
  } cheshire_hw2reg_vga_params_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_hw2reg_num_harts_reg_t;

  // HW -> register type
  typedef struct packed {
    cheshire_hw2reg_boot_mode_reg_t boot_mode; // [165:164]
    cheshire_hw2reg_rtc_freq_reg_t rtc_freq; // [163:132]
    cheshire_hw2reg_platform_rom_reg_t platform_rom; // [131:100]
    cheshire_hw2reg_hw_features_reg_t hw_features; // [99:88]
    cheshire_hw2reg_llc_size_reg_t llc_size; // [87:56]
    cheshire_hw2reg_vga_params_reg_t vga_params; // [55:32]
    cheshire_hw2reg_num_harts_reg_t num_harts; // [31:0]
  } cheshire_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_0_OFFSET = 7'h 0;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_1_OFFSET = 7'h 4;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_2_OFFSET = 7'h 8;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_3_OFFSET = 7'h c;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_4_OFFSET = 7'h 10;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_5_OFFSET = 7'h 14;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_6_OFFSET = 7'h 18;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_7_OFFSET = 7'h 1c;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_8_OFFSET = 7'h 20;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_9_OFFSET = 7'h 24;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_10_OFFSET = 7'h 28;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_11_OFFSET = 7'h 2c;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_12_OFFSET = 7'h 30;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_13_OFFSET = 7'h 34;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_14_OFFSET = 7'h 38;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_15_OFFSET = 7'h 3c;
  parameter logic [BlockAw-1:0] CHESHIRE_BOOT_MODE_OFFSET = 7'h 40;
  parameter logic [BlockAw-1:0] CHESHIRE_RTC_FREQ_OFFSET = 7'h 44;
  parameter logic [BlockAw-1:0] CHESHIRE_PLATFORM_ROM_OFFSET = 7'h 48;
  parameter logic [BlockAw-1:0] CHESHIRE_HW_FEATURES_OFFSET = 7'h 4c;
  parameter logic [BlockAw-1:0] CHESHIRE_LLC_SIZE_OFFSET = 7'h 50;
  parameter logic [BlockAw-1:0] CHESHIRE_VGA_PARAMS_OFFSET = 7'h 54;
  parameter logic [BlockAw-1:0] CHESHIRE_NUM_HARTS_OFFSET = 7'h 58;
  parameter logic [BlockAw-1:0] CHESHIRE_STUB_EX_EN_OFFSET = 7'h 5c;
  parameter logic [BlockAw-1:0] CHESHIRE_STUB_EX_RATE_OFFSET = 7'h 60;
  parameter logic [BlockAw-1:0] CHESHIRE_STUB_REQ_RSP_LAT_OFFSET = 7'h 64;
  parameter logic [BlockAw-1:0] CHESHIRE_STUB_REQ_RSP_RND_OFFSET = 7'h 68;
  parameter logic [BlockAw-1:0] CHESHIRE_GOLD_EXCEPTION_OFFSET = 7'h 6c;

  // Reset values for hwext registers and their fields
  parameter logic [1:0] CHESHIRE_BOOT_MODE_RESVAL = 2'h 0;
  parameter logic [31:0] CHESHIRE_RTC_FREQ_RESVAL = 32'h 0;
  parameter logic [31:0] CHESHIRE_PLATFORM_ROM_RESVAL = 32'h 0;
  parameter logic [11:0] CHESHIRE_HW_FEATURES_RESVAL = 12'h 0;
  parameter logic [31:0] CHESHIRE_LLC_SIZE_RESVAL = 32'h 0;
  parameter logic [23:0] CHESHIRE_VGA_PARAMS_RESVAL = 24'h 0;
  parameter logic [31:0] CHESHIRE_NUM_HARTS_RESVAL = 32'h 0;

  // Register index
  typedef enum int {
    CHESHIRE_SCRATCH_0,
    CHESHIRE_SCRATCH_1,
    CHESHIRE_SCRATCH_2,
    CHESHIRE_SCRATCH_3,
    CHESHIRE_SCRATCH_4,
    CHESHIRE_SCRATCH_5,
    CHESHIRE_SCRATCH_6,
    CHESHIRE_SCRATCH_7,
    CHESHIRE_SCRATCH_8,
    CHESHIRE_SCRATCH_9,
    CHESHIRE_SCRATCH_10,
    CHESHIRE_SCRATCH_11,
    CHESHIRE_SCRATCH_12,
    CHESHIRE_SCRATCH_13,
    CHESHIRE_SCRATCH_14,
    CHESHIRE_SCRATCH_15,
    CHESHIRE_BOOT_MODE,
    CHESHIRE_RTC_FREQ,
    CHESHIRE_PLATFORM_ROM,
    CHESHIRE_HW_FEATURES,
    CHESHIRE_LLC_SIZE,
    CHESHIRE_VGA_PARAMS,
    CHESHIRE_NUM_HARTS,
    CHESHIRE_STUB_EX_EN,
    CHESHIRE_STUB_EX_RATE,
    CHESHIRE_STUB_REQ_RSP_LAT,
    CHESHIRE_STUB_REQ_RSP_RND,
    CHESHIRE_GOLD_EXCEPTION
  } cheshire_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] CHESHIRE_PERMIT [28] = '{
    4'b 1111, // index[ 0] CHESHIRE_SCRATCH_0
    4'b 1111, // index[ 1] CHESHIRE_SCRATCH_1
    4'b 1111, // index[ 2] CHESHIRE_SCRATCH_2
    4'b 1111, // index[ 3] CHESHIRE_SCRATCH_3
    4'b 1111, // index[ 4] CHESHIRE_SCRATCH_4
    4'b 1111, // index[ 5] CHESHIRE_SCRATCH_5
    4'b 1111, // index[ 6] CHESHIRE_SCRATCH_6
    4'b 1111, // index[ 7] CHESHIRE_SCRATCH_7
    4'b 1111, // index[ 8] CHESHIRE_SCRATCH_8
    4'b 1111, // index[ 9] CHESHIRE_SCRATCH_9
    4'b 1111, // index[10] CHESHIRE_SCRATCH_10
    4'b 1111, // index[11] CHESHIRE_SCRATCH_11
    4'b 1111, // index[12] CHESHIRE_SCRATCH_12
    4'b 1111, // index[13] CHESHIRE_SCRATCH_13
    4'b 1111, // index[14] CHESHIRE_SCRATCH_14
    4'b 1111, // index[15] CHESHIRE_SCRATCH_15
    4'b 0001, // index[16] CHESHIRE_BOOT_MODE
    4'b 1111, // index[17] CHESHIRE_RTC_FREQ
    4'b 1111, // index[18] CHESHIRE_PLATFORM_ROM
    4'b 0011, // index[19] CHESHIRE_HW_FEATURES
    4'b 1111, // index[20] CHESHIRE_LLC_SIZE
    4'b 0111, // index[21] CHESHIRE_VGA_PARAMS
    4'b 1111, // index[22] CHESHIRE_NUM_HARTS
    4'b 1111, // index[23] CHESHIRE_STUB_EX_EN
    4'b 1111, // index[24] CHESHIRE_STUB_EX_RATE
    4'b 1111, // index[25] CHESHIRE_STUB_REQ_RSP_LAT
    4'b 1111, // index[26] CHESHIRE_STUB_REQ_RSP_RND
    4'b 1111  // index[27] CHESHIRE_GOLD_EXCEPTION
  };

endpackage

