// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Matteo Perotti  <mperotti@iis.ee.ethz.ch>
// Vincenzo Maisto <vincenzo.maisto2@unina.it>

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "encoding.h"
#include "rvv_test.h"

// Tunable parameters
// param_stub_ex_ctrl. 0: no exceptions, 1: always exceptions, 2: random exceptions
#define param_stub_ex_ctrl 0
// param_stub_req_rsp_lat_ctrl. 0: fixed latency (== param_stub_req_rsp_lat), 1: random latency (max == param_stub_req_rsp_lat)
#define param_stub_req_rsp_lat_ctrl 0
#define param_stub_req_rsp_lat 1

// Derived parameters
#define param_stub_ex { param_stub_ex_ctrl ? 1 : 0; }

uint64_t stub_req_rsp_lat = param_stub_req_rsp_lat;

#define COND_PRINT 1

int main(void) {
  PRINT_INIT;

    // This initialization is controlled through "defines" in the various
    // derived tests.
    INIT_RVV_TEST_SOC_REGFILE;
    VIRTUAL_MEMORY_ON;
    STUB_EX_ON;

    // Vector configuration parameters and variables
    uint64_t avl_original = RVV_TEST_AVL(64);
    uint64_t vl, vstart_read;
    vcsr_dump_t vcsr_state = {0};

    // Helper variables and arrays
    uint64_t array_load [VLMAX];
    uint64_t array_store [VLMAX];
    uint64_t* address_load = array_load;
    uint64_t* address_store = array_store;

    // Enalbe RVV
    enable_rvv();
    vcsr_dump ( vcsr_state );

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    // START OF TESTS
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////
    // TEST: Exception generation and non-zero vstart: vector store
    //////////////////////////////////////////////////////////////////

    // Loop through different avl, from 0 to avlmax
    for (uint64_t avl = 1; avl <= 2*VLMAX; avl++) {
      // Reset vl, vstart, reset exceptions.
      RVV_TEST_INIT(vl, avl);
      // Loop over vstart values. Also test vstart > vl.
      for (uint64_t vstart_val = 0; vstart_val < vl; vstart_val++) {
        PRINT_CHAR('A');
        // Reset vl, vstart, reset exceptions.
        RVV_TEST_INIT(vl, avl);
        // Turn off exceptions
        STUB_EX_OFF;

        // Decide latency for next STUB req-rsp
        switch (param_stub_req_rsp_lat_ctrl) {
          // Fixed STUB req-rsp latency
          case 0:
            STUB_REQ_RSP_LAT(stub_req_rsp_lat);
          break;
          // Random STUB req-rsp latency (minimum value should be 1)
          case 1:
            STUB_REQ_RSP_LAT((stub_req_rsp_lat++ % MAX_LAT_P2) + 1);
          break;
          default:
            return RET_CODE_WRONG_CASE;
        }

        // Init memory
        for (uint64_t i = 0; i < vl; i++) {
          address_store[i] = INIT_NONZERO_VAL_ST;
        }
        for (uint64_t i = 0; i < vl; i++) {
          address_load[i]  = vl + vstart_val + i + MAGIC_NUM;
        }

        // Get information about the next axi transfer
        axi_burst_log_t axi_log =
          get_unit_stride_bursts_wrap(address_store, vl, EW64, MEM_BUS_BYTE, vstart_val);

        // Load the whole register
        asm volatile("vle64.v v0, (%0)" : "+&r"(address_load));
        // Setup vstart
        asm volatile("csrs vstart, %0" :: "r"(vstart_val));

        // Setup STUB behavior
        uint64_t ex_lat;
        switch (param_stub_ex_ctrl) {
          // No exceptions
          case 0:
            ex_lat = 0;
            STUB_EX_OFF;
          break;
          // Always exceptions at every request
          case 1:
            ex_lat = 0;
            STUB_EX_ON;
            STUB_NO_EX_LAT(ex_lat);
          break;
          // Random exceptions
          case 2:
            // If ex_lat == axi_log.bursts, no exception for this transaction!
            ex_lat = pseudo_rand(axi_log.bursts);
            STUB_EX_ON;
            STUB_NO_EX_LAT(ex_lat);
          break;
          default:
            return RET_CODE_WRONG_CASE;
        }

        // Get information about the next vstart
        uint64_t body_elm_pre_exception = get_body_elm_pre_exception(axi_log, ex_lat, vstart_val);
        uint64_t vstart_post_ex = vstart_val + body_elm_pre_exception;

        PRINT_CHAR('B');

        // Check for illegal new vstart values
        RVV_TEST_ASSERT(vstart_post_ex >= vstart_val && vstart_post_ex < vl)

        // Store back the values
        asm volatile("vse64.v v0, (%0)" : "+&r"(address_store));

        PRINT_CHAR('C');

        // Check pre-start values
        for (uint64_t i = 0; i < vstart_val; i++) {
          ASSERT_EQ(address_store[i], INIT_NONZERO_VAL_ST)
        }

//        // Check if we had an exception on this transaction
//        if (param_stub_ex_ctrl == 1 || (param_stub_ex_ctrl == 2 && ex_lat < axi_log.bursts)) {
//            // Check that the body, up to the exception, has the correct value
//            for (uint64_t i = vstart_val; i < vstart_post_ex; i++) {
//              ASSERT_EQ(address_store[i], address_load[i])
//            }
//            // Check that the body, after the exception, was untouched in memory
//            for (uint64_t i = vstart_post_ex; i < vl; i++) {
//              ASSERT_EQ(address_store[i], INIT_NONZERO_VAL_ST)
//            }
//            // Check that the new vstart is correct
//            vstart_read = -1;
//            asm volatile("csrr %0, vstart" : "=r"(vstart_read));
//            ASSERT_EQ(vstart_read, vstart_post_ex)
//            // Check the exception
//            RVV_TEST_ASSERT_EXCEPTION_EXTENDED(1, axi_log.burst_start_addr[ex_lat], CAUSE_STORE_PAGE_FAULT)
//            RVV_TEST_CLEAN_EXCEPTION()
//
//            // Recover the instruction
//            // The following instructions resets the STUB counter for the exceptions, too!
//            STUB_EX_OFF;
//            asm volatile("vse64.v v0, (%0)" : "+&r"(address_store));
//            STUB_EX_ON;
//            // Check pre-start values again
//            for (uint64_t i = 0; i < vstart_val; i++) {
//              ASSERT_EQ(address_store[i], INIT_NONZERO_VAL_ST)
//            }
//        }

        PRINT_CHAR('D');

        // No exception (or just-recovered-from-an-exception) area
        // Check that the body was correctly stored
        for (uint64_t i = vstart_val; i < vl; i++) {
          ASSERT_EQ(address_store[i], address_load[i])
        }
        // Check that vstart was reset at zero
        vstart_read = -1;

        PRINT_CHAR('E');

        asm volatile("csrr %0, vstart" : "=r"(vstart_read));
        ASSERT_EQ(vstart_read, 0)
        // Check that there was no exception
        RVV_TEST_ASSERT_EXCEPTION(0)
        RVV_TEST_CLEAN_EXCEPTION()

        // Clean-up
        RVV_TEST_CLEANUP();
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
