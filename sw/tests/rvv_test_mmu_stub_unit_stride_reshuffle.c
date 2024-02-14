// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Matteo Perotti  <mperotti@iis.ee.ethz.ch>

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "encoding.h"
#include "rvv_test.h"

#ifdef EXAHUSTIVE
#define VL_LIMIT_LOW      VLMAX
#define VSTART_LIMIT_LOW  vl + 1
#define VSTART_LIMIT_HIGH 0
#else
#define VL_LIMIT_LOW      3*ARA_NR_LANES + 1
#define VSTART_LIMIT_LOW  2*ARA_NR_LANES + 1
#define VSTART_LIMIT_HIGH vl - 2*ARA_NR_LANES - 1
#endif

#define INIT_NONZERO_VAL_V0 99
#define INIT_NONZERO_VAL_V8 84
#define INIT_NONZERO_VAL_ST_0 44
#define INIT_NONZERO_VAL_ST_1 65

// Derived parameters
uint64_t stub_req_rsp_lat = 10;

// If lanes == 8 and eew == 8, these vectors are too large to be instantiated in the stack.
// In all the other cases, the stack is the preferred choice since everything outside of the
// stack should be preloaded with the slow JTAG, and the simulation time increases
#if !((ARA_NR_LANES < 8) || (EEW > 8))
    // Helper variables and arrays
    _DTYPE array_load    [VLMAX/(EEW/8)];
    _DTYPE array_store_0 [VLMAX/(EEW/8)];
    _DTYPE array_store_1 [VLMAX/(EEW/8)];
#endif

int main(void) {

    // This initialization is controlled through "defines" in the various
    // derived tests.
    INIT_RVV_TEST_SOC_REGFILE;
    VIRTUAL_MEMORY_ON;
    STUB_EX_OFF;
    STUB_REQ_RSP_LAT((stub_req_rsp_lat++ % MAX_LAT_P2) + 1);

    // Vector configuration parameters and variables
    uint64_t avl_original = RVV_TEST_AVL(64);
    uint64_t vl, vstart_read;
    vcsr_dump_t vcsr_state = {0};

// See note above
#if (ARA_NR_LANES < 8) || (EEW > 8)
    // Helper variables and arrays
    _DTYPE array_load    [VLMAX/(EEW/8)];
    _DTYPE array_store_0 [VLMAX/(EEW/8)];
    _DTYPE array_store_1 [VLMAX/(EEW/8)];
#endif

    _DTYPE* address_load    = array_load;
    _DTYPE* address_store_0 = array_store_0;
    _DTYPE* address_store_1 = array_store_1;

    // Enalbe RVV
    enable_rvv();
    vcsr_dump ( vcsr_state );

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    // START OF TESTS
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    for (uint64_t ew = 0; ew < 4; ew++) {
      // Loop through different avl, from 0 to avlmax
      for (uint64_t avl = 0; avl <= VL_LIMIT_LOW; avl++) {
        // Reset vl, vstart, reset exceptions.
        RVV_TEST_INIT(vl, avl);
        for (uint64_t vstart_val = 0; (vstart_val <= VSTART_LIMIT_LOW || vstart_val >= VSTART_LIMIT_HIGH) && vstart_val < vl; vstart_val++) {
          // Reset vl, vstart, reset exceptions.
          RVV_TEST_INIT(vl, avl);
          // Random latency
          STUB_REQ_RSP_LAT((stub_req_rsp_lat++ % MAX_LAT_P2) + 1);

          // Write vals with target EEW
          asm volatile("vmv.v.x v0, %0" :: "r" (INIT_NONZERO_VAL_V0));
          asm volatile("vmv.v.x v8, %0" :: "r" (INIT_NONZERO_VAL_V8));
          switch(ew) {
            case 0:
              _VSETVLI_64(vl, avl)
              break;
            case 1:
              _VSETVLI_32(vl, avl)
              break;
            case 2:
              _VSETVLI_16(vl, avl)
              break;
            default:
              _VSETVLI_8(vl, avl)
          }
          // Force V8 reshuffle
          asm volatile("vadd.vv v24, v8, v8");

          // Init memory
          for (uint64_t i = 0; i < vl; i++) {
            address_store_0[i] = INIT_NONZERO_VAL_ST_0;
          }
          // Init memory
          for (uint64_t i = 0; i < vl; i++) {
            address_store_1[i] = INIT_NONZERO_VAL_ST_1;
          }
          for (uint64_t i = 0; i < vl; i++) {
            address_load[i]  = vl + vstart_val + i + MAGIC_NUM;
          }

          // Setup vstart
          asm volatile("csrs vstart, %0" :: "r"(vstart_val));

          // Load the whole register
          _VLD(v0, address_load)

          *rf_rvv_debug_reg = 0xF0000001;

          // Check that vstart was reset at zero
          vstart_read = -1;
          asm volatile("csrr %0, vstart" : "=r"(vstart_read));
          ASSERT_EQ(vstart_read, 0)

          *rf_rvv_debug_reg = 0xF0000002;

          // Check that there was no exception
          RVV_TEST_ASSERT_EXCEPTION(0)
          RVV_TEST_CLEAN_EXCEPTION()


          // Store
          _VST(v0, address_store_0)

          // Setup vstart
          asm volatile("csrs vstart, %0" :: "r"(vstart_val));

          _VST(v8, address_store_1)

          *rf_rvv_debug_reg = 0xF0000003;

          // Load test - prestart
          for (uint64_t i = 0; i < vstart_val; i++) {
            ASSERT_EQ(address_store_0[i], INIT_NONZERO_VAL_V0)
          }
          *rf_rvv_debug_reg = 0xF0000004;
          // Load test - body
          for (uint64_t i = vstart_val; i < vl; i++) {
            ASSERT_EQ(address_store_0[i], address_load[i])
          }
          *rf_rvv_debug_reg = 0xF0000005;

          // Store test - prestart
          for (uint64_t i = 0; i < vstart_val; i++) {
            ASSERT_EQ(address_store_1[i], INIT_NONZERO_VAL_ST_1)
          }
          *rf_rvv_debug_reg = 0xF0000006;
          // Store test - body
          for (uint64_t i = vstart_val; i < vl; i++) {
            ASSERT_EQ(address_store_1[i], INIT_NONZERO_VAL_V8)
          }
          *rf_rvv_debug_reg = 0xF0000007;

          // Clean-up
          RVV_TEST_CLEANUP();

#ifndef EXAUHSTIVE
        // Jump from limit low to limit high if limit high is higher than low
        if ((VSTART_LIMIT_LOW) < (VSTART_LIMIT_HIGH))
          if (vstart_val == VSTART_LIMIT_LOW)
            vstart_val = VSTART_LIMIT_HIGH;
#endif

          ret_cnt++;
        }
      }
    }

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    // END OF TESTS
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    // If we did not return before, the test passed
    return RET_CODE_SUCCESS;
}
