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
    uint64_t array_load [RVV_TEST_AVL(64)];
    uint64_t array_store [RVV_TEST_AVL(64)] = {0};
    uint64_t* address_load = array_load;
    uint64_t* address_store = array_store;
    uint64_t* address_misaligned;
    uint8_t byte;
    uint64_t vstart_read;


    // Enalbe RVV
    enable_rvv();
    vcsr_dump ( vcsr_state );

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    // START OF TESTS
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////
    // TEST: Legal encoding
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    asm volatile("vmv.v.i   v0 ,  1");
    RVV_TEST_ASSERT_EXCEPTION(0)

    RVV_TEST_CLEANUP();
    
    //////////////////////////////////////////////////////////////////
    // TEST: Illegal encoding
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    asm volatile("vmv.v.i   v1 ,  1");
    RVV_TEST_ASSERT_EXCEPTION(1)
    RVV_TEST_CLEAN_EXCEPTION()

    RVV_TEST_CLEANUP();

    //////////////////////////////////////////////////////////////////
    // TEST: vstart update
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    vstart_read = -1;
    // CSR <-> vector instrucitons
    asm volatile ("csrs  vstart, 1");
    asm volatile ("csrr  %0, vstart" : "=r"(vstart_read));
    RVV_TEST_ASSERT ( vstart_read == (uint64_t)1 );


    //////////////////////////////////////////////////////////////////
    // TEST: vstart automatic reset
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    // NOTE: This relied on non-zero vstart support for arithmetic instructions, i.e., operand request
    asm volatile ("vmv.v.i  v24, -1");
    asm volatile ("csrs     vstart, 1");
    asm volatile ("vadd.vv  v0, v24, v24");
    asm volatile ("csrr     %0, vstart" : "=r"(vstart_read));
    RVV_TEST_ASSERT ( vstart_read == (uint64_t)0 );

    RVV_TEST_CLEANUP();

    //////////////////////////////////////////////////////////////////
    // TEST: These instructions should WB asap to ROB
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    // Vector permutation/arithmetic
    asm volatile("vmv.v.i   v0 ,  1");
    asm volatile("csrr      %0 , vl" : "=r"(vl));

    RVV_TEST_CLEANUP();

    //////////////////////////////////////////////////////////////////
    // TEST: These intructions should WB to CVA6 only after WB from PEs
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    address_load = array_load;
    // initialize
    for ( uint64_t i = 0; i < vl; i++ ) {
        array_load[i] = -i;
    }

    // Vector load
    asm volatile("vle64.v	v24, (%0)" : "+&r"(address_load));
    // Vector store
    asm volatile("vse64.v	v16, (%0)" : "+&r"(address_store));
    // Vector load
    asm volatile("vle64.v	v8 , (%0)" : "+&r"(address_load));

    RVV_TEST_CLEANUP();

    //////////////////////////////////////////////////////////////////
    // TEST: Legal non-zero vstart on vector instructions
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    asm volatile("csrs     vstart, 3");
    asm volatile("vadd.vv	 v24   , v16, v16");
    RVV_TEST_ASSERT_EXCEPTION(0)

    RVV_TEST_CLEANUP();

    //////////////////////////////////////////////////////////////////
    // TEST: Legal non-zero vstart on vector CSR
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    asm volatile("csrs     vstart, 3");
    asm volatile("vsetvli  x0    , x0, e64, m8, ta, ma" );
    RVV_TEST_ASSERT_EXCEPTION(0)

    asm volatile("csrs     vstart, 22");
    asm volatile("vle64.v	 v24   , (%0)" : "+&r"(address_load));
    RVV_TEST_ASSERT_EXCEPTION(0)
 
    RVV_TEST_CLEANUP();
 
    //////////////////////////////////////////////////////////////////
    // TEST: EEW misaligned loads
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    byte = 0xff;
    // Byte-alignment
    address_misaligned = (uint64_t*)(((uint64_t)(&byte) & 0xffffffffffffffe));
    // EEW=64
    asm volatile ("vle64.v	v16, (%0)" : "+&r"(address_misaligned));
    RVV_TEST_ASSERT_EXCEPTION(1)
    RVV_TEST_CLEAN_EXCEPTION() 

    RVV_TEST_CLEANUP();

    //////////////////////////////////////////////////////////////////
    // TEST: EEW misaligned stores
    //////////////////////////////////////////////////////////////////
    RVV_TEST_INIT( vl, avl );

    byte = 0xff;
    // Byte-alignment
    address_misaligned = (uint64_t*)(((uint64_t)(&byte) & 0xffffffffffffffe));
    // EEW=64
    asm volatile ("vse64.v	v24, (%0)" : "+&r"(address_misaligned));
    RVV_TEST_ASSERT_EXCEPTION(1)
    RVV_TEST_CLEAN_EXCEPTION() 

    RVV_TEST_CLEANUP();


    ////////////////////////////////////////////////////////////////////
    // Missing tests for unimplemented features:
    // TEST: Illegal non-zero vstart
    ////////////////////////////////////////////////////////////////////

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
