// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Vincenzo Maisto <vincenzo.maisto2@unina.it>

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "encoding.h"
#include "rvv_test.h"

int main(void) {

    // Vector configuration parameters and variables
    uint64_t avl = RVV_TEST_AVL(64);
    uint64_t vl;
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
    // TEST: Zero and non-zero  vstart for arithmetic instructions
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    // Loop over vstart values
    for ( uint64_t vstart_val = 0; vstart_val < vl; vstart_val++ ) {
      RVV_TEST_INIT( vl, avl );

      // Init memory
      for ( uint64_t i = 0; i < vl; i++ ) {
        address_load[i] = i;
      }

      asm volatile ("vle64.v	v0   , (%0)" : "+&r"(address_load));
      asm volatile ("csrs     vstart, %0"   :: "r"(vstart_val) );
      asm volatile ("vadd.vv  v0, v0, v0");
      asm volatile ("vse64.v	v0   , (%0)" : "+&r"(address_store));

      // Check pre-start
      for ( uint64_t i = 0; i < vstart_val; i++ ) {
        RVV_TEST_ASSERT ( address_store[i] == i );
      }
      // Check body
      for ( uint64_t i = vstart_val; i < vl; i++ ) {
        RVV_TEST_ASSERT ( address_store[i] == 2*i );
      }

      RVV_TEST_CLEANUP();
    }

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    // END OF TESTS
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

RVV_TEST_pass:
    RVV_TEST_PASSED() 

RVV_TEST_error:
    RVV_TEST_FAILED()
  
  return 0;
}
