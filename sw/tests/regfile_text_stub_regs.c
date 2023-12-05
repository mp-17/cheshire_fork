// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Matteo Perotti <mperotti@iis.ee.ethz.ch>

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "encoding.h"
#include "rvv_test.h"

// 1 to print test information
#define COND_PRINT 0

/* Soc-Level regfile list (defined in rvv_test.h)
  rf_stub_ex_en
  rf_stub_ex_rate
  rf_req_rsp_lat
  rf_req_rsp_rate
  rf_gold_exception
*/

// Write the SoC-level regfile and verify the values
// We use lightweight char-only uart print
int main(void) {
  // Declare the SoC-level STUB registers
  INIT_RVV_TEST_SOC_REGFILE;

  // Write the register file (chars-only because it's easier to print)
  *rf_stub_ex_en     = '1';
  *rf_stub_ex_rate   = '2';
  *rf_req_rsp_lat    = '3';
  *rf_req_rsp_rnd    = '4';
  *rf_gold_exception = '5';

  // Read the register file again (check written values)
  ASSERT_EQ(*rf_stub_ex_en,     '1');
  ASSERT_EQ(*rf_stub_ex_rate,   '2');
  ASSERT_EQ(*rf_req_rsp_lat,    '3');
  ASSERT_EQ(*rf_req_rsp_rnd,    '4');
  ASSERT_EQ(*rf_gold_exception, '5');

#if (COND_PRINT == 1)
  // Initialize UART and print
  // Avoid printf to minimize program preload time
  PRINT_INIT;
  PRINT("SoC-level regfile values:\r\n");
  PRINT_CHAR(*rf_stub_ex_en);
  PRINT_CHAR(*rf_stub_ex_rate);
  PRINT_CHAR(*rf_req_rsp_lat);
  PRINT_CHAR(*rf_req_rsp_rnd);
  PRINT_CHAR(*rf_gold_exception);
#endif

  return 0;
}
