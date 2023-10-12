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

#warning "This test does not check for untouched memory"

int main(void) {
    // Vector configuration parameters and variables
    // uint64_t avl = RVV_TEST_AVL(64);
    uint64_t avl = 16;
    uint64_t vl;
    vcsr_dump_t vcsr_state = {0};

    // Helper variables and arrays
    uint64_t array_load [RVV_TEST_AVL(64)] ;
    uint64_t array_store[RVV_TEST_AVL(64)];
    uint64_t* address_load = array_load;
    uint64_t* address_store = array_store;
    uint64_t store_val, preload_val, prestart_val;

    // Simplification: EEW-wide indexes
    uint64_t array_index [RVV_TEST_AVL(64)] ;
    uint64_t* address_index = array_index;

    // Enalbe RVV
    enable_rvv();
    vcsr_dump ( vcsr_state );

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    // START OF TESTS
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////
    // TEST: Zero and non-zero vstart indexed load
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    // Loop over vstart values
    for ( uint64_t vstart_val = 0; vstart_val < vl; vstart_val++ ) {
        RVV_TEST_INIT( vl, avl );
        
        preload_val = -1;
        prestart_val = -2;
        
        // Init whole memory 
        for ( uint64_t i = 0; i < RVV_TEST_AVL(64); i++ ) {
            address_load[i] = preload_val;
        }
        // Init index memory
        for ( uint64_t i = 0; i < vl; i++ ) {
            // Constrain the target memory space to +/- (2^16)*sizeof(uint64_t) bytes
            // NOTE:to ease testing, indexes should not overlap
            address_index[ i ] = 0xffff & ( vstart_val + vl + i );
        }
        // Init indexed memory
        for ( uint64_t i = 0; i < vl; i++ ) {
            address_load [ address_index[ i ] ] = vstart_val + vl + i;
        }

        // Load index array
        asm volatile ("vle64.v	v0   , (%0)" : "+&r"(address_index));
        
        // Load prestart
        asm volatile ("vmv.v.x	v24   , %0" :: "r"(prestart_val));

        // Set vstart
        asm volatile ("csrs     vstart, %0"   :: "r"(vstart_val) );
        // Test target: load vr group body
        asm volatile ("vluxei64.v	v24   , (%0), v0" : "+&r"(address_load));
        // Store whole vr group back to memory
        asm volatile ("vse64.v	v24   , (%0)" : "+&r"(address_store));

        // Check pre-start
        for ( uint64_t i = 0; i < vstart_val; i++ ) {
            RVV_TEST_ASSERT ( address_store[i] == prestart_val );
        }
        // Check body
        for ( uint64_t i = vstart_val; i < vl; i++ ) {
            RVV_TEST_ASSERT ( address_store[i] == address_load [ address_index[ i ] ] );
        }
        // TODO: Check untouched memory
        for ( uint64_t i = 0; i < RVV_TEST_AVL(64); i++ ) {
            // TBD
        }

        RVV_TEST_CLEANUP();
    }


    //////////////////////////////////////////////////////////////////
    // TEST: Non-zero stride, zero and non-zero vstart indexed stores
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    // Loop over vstart values
    for ( uint64_t vstart_val = 0; vstart_val < vl; vstart_val++ ) {
      RVV_TEST_INIT( vl, avl );
        
      preload_val = -1;
      prestart_val = -2;
      
      // Init whole memory 
      for ( uint64_t i = 0; i < RVV_TEST_AVL(64); i++ ) {
          address_load[i] = preload_val + i;
      }
      // Init index memory
      for ( uint64_t i = 0; i < vl; i++ ) {
          // Constrain the target memory space to +/- (2^16)*sizeof(uint64_t) bytes
          // NOTE:to ease testing, indexes should not overlap
          address_index[ i ] = 0xffff & ( vstart_val + vl + i );
      }
      // Init indexed memory
      for ( uint64_t i = 0; i < vl; i++ ) {
          address_load [ address_index[ i ] ] = vstart_val + vl + i;
      }

      // Load index array
      asm volatile ("vle64.v	v0   , (%0)" : "+&r"(address_index));

      // Load data        
      asm volatile ("vle64.v	v24   , (%0)" : "+&r"(address_load));
      // Set vstart
      asm volatile ("csrs       vstart, %0"   :: "r"(vstart_val) );
      // Test target: store to indexed memory
      asm volatile ("vsuxei64.v	v24   , (%0), v0" : "+&r"(address_store));

      // Check pre-start
      for ( uint64_t i = 0; i < vstart_val; i++ ) {
        RVV_TEST_ASSERT ( address_store[i] == preload_val + i );
      }
      // Check body
      for ( uint64_t i = vstart_val; i < vl; i++ ) {
        RVV_TEST_ASSERT ( address_store [ address_index[ i ] ] == address_load[i] );
      }
      // TODO: Check untouched memory
      for ( uint64_t i = 0; i < RVV_TEST_AVL(64); i++ ) {
          // TBD
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
