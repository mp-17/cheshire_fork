// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Matteo Perotti  <mperotti@iis.ee.ethz.ch>

#ifndef __RVV_RVV_TEST_H__
#define __RVV_RVV_TEST_H__

#include "regs/cheshire.h"

///////////////////////
// SoC-level regfile //
///////////////////////

#define INIT_RVV_TEST_SOC_REGFILE \
volatile uint32_t *rf_stub_ex_en  = reg32(&__base_regs, CHESHIRE_STUB_EX_EN_REG_OFFSET);       \
volatile uint32_t *rf_req_rsp_lat = reg32(&__base_regs, CHESHIRE_STUB_REQ_RSP_LAT_REG_OFFSET); \
volatile uint32_t *rf_req_rsp_rnd = reg32(&__base_regs, CHESHIRE_STUB_REQ_RSP_RND_REG_OFFSET); \
volatile uint32_t *rf_virt_mem_en = reg32(&__base_regs, CHESHIRE_ARA_VIRT_MEM_EN_REG_OFFSET);

//////////////////////
// Print facilities //
//////////////////////

#define PRINT_INIT                                                          \
  uint32_t rtc_freq   = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET); \
  uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);                \
  uart_init(&__base_uart, reset_freq, 115200);                              \
  char uart_print_str[] = {'0', '\r', '\n'};
#define PRINT_CHAR(byte)                          \
  uart_print_str[0] = (char) byte;                \
  PRINT(uart_print_str)
#define PRINT(str)                                \
  uart_write_str(&__base_uart, str, sizeof(str)); \
  uart_write_flush(&__base_uart);

/////////////////////
// Stub management //
/////////////////////

// Enable virtual memory Ara->STUB requests
#define VIRTUAL_MEMORY(val) *rf_virt_mem_en = val;
#define VIRTUAL_MEMORY_ON   *rf_virt_mem_en = 1;
#define VIRTUAL_MEMORY_OFF  *rf_virt_mem_en = 0;
// Enable/disable exceptions from the stub
#define STUB_EX(val) *rf_stub_ex_en = val;
#define STUB_EX_ON   *rf_stub_ex_en = 1;
#define STUB_EX_OFF  *rf_stub_ex_en = 0;
// Stub req-2-resp latency
#define STUB_REQ_RSP_LAT(lat) *rf_req_rsp_lat = lat;
// Stub req-2-resp latency random mode. If asserted,
// STUB_REQ_RSP_LAT becomes the maximum latency to expect.
// Minimum latency is 0.
#define STUB_REQ_RSP_RND(val) *rf_req_rsp_rnd = val;
#define STUB_REQ_RSP_RND_ON   *rf_req_rsp_rnd = 1;
#define STUB_REQ_RSP_RND_OFF  *rf_req_rsp_rnd = 0;

///////////////
// RVV Tests //
///////////////

#define FAIL { return -1; }
#define ASSERT_EQ(var, gold) if (var != gold) FAIL

// Helper test macros
#define RVV_TEST_INIT(vl, avl)            vl = reset_v_state ( avl ); exception = 0;
#define RVV_TEST_CLEANUP()                RVV_TEST_ASSERT_EXCEPTION(0); exception = 0;
// BUG: Can't return a non-zero value from here...
// #define RVV_TEST_ASSERT( expression ) if ( !expression ) { return -1; }
// Quick workaround:
#define RVV_TEST_ASSERT( expression )     if ( !(expression) ) FAIL
#define RVV_TEST_ASSERT_EXCEPTION( val )  RVV_TEST_ASSERT ( exception == (uint64_t)(val) );
#define RVV_TEST_ASSERT_EXCEPTION_EXTENDED( valid, tval, cause )  RVV_TEST_ASSERT ( ( exception == (uint64_t)(valid) )    \
                                                                            & ( mtval == (uint64_t)(tval) ) \
                                                                            & ( mcause == (uint64_t)(cause) ) \
                                                                            );
#define RVV_TEST_CLEAN_EXCEPTION()        exception = 0; mtval = 0; mcause = 0;

#define VLMAX (1024 * ARA_NR_LANES)
#ifndef RVV_TEST_AVL
  #define RVV_TEST_AVL(EEW) (VLMAX / (EEW))
#endif

// Helper test variables
typedef uint64_t vcsr_dump_t [5];
uint64_t exception;
uint64_t mtval;
uint64_t mcause;
uint64_t magic_out;

void enable_rvv() {
  // Enalbe RVV by seting MSTATUS.VS
  asm volatile (" li      t0, %0       " :: "i"(MSTATUS_VS));
  asm volatile (" csrs    mstatus, t0" );
}

uint64_t reset_v_state ( uint64_t avl ) {
    uint64_t vl_local = 0;

	asm volatile (
    "fence                                \n\t"
	  "vsetvli  %0    , %1, e64, m8, ta, ma \n\t"
	  "csrw	    vstart, 0                   \n\t"
	  "csrw	    vcsr  , 0                   \n\t"
    "fence                                \n\t"
	: "=r" (vl_local)  : "r" (avl) :
  );

    return vl_local;
}

void vcsr_dump ( vcsr_dump_t vcsr_state ) {
	asm volatile (
		"csrr  %0, vstart \n\t"
		"csrr  %1, vtype  \n\t"
		"csrr  %2, vl     \n\t"
		"csrr  %3, vcsr   \n\t"
		"csrr  %4, vlenb  \n\t"
		: "=r" (vcsr_state[0]),
		  "=r" (vcsr_state[1]),
		  "=r" (vcsr_state[2]),
		  "=r" (vcsr_state[3]),
		  "=r" (vcsr_state[4])
  );
}

// Override default weak trap vector
void trap_vector () {
    // Set exception flag
    exception = 1;

    // Save tval and mcause
    mtval = 0;
    mcause = 0;
    asm volatile ("csrr %0, mtval" : "=r"(mtval));
    asm volatile ("csrr %0, mcause" : "=r"(mcause));

    // Move PC ahead
    // NOTE: PC = PC + 4, valid only for non-compressed trapping instructions
    asm volatile (
        "nop;"
        "csrr	t6, mepc;"
        "addi	t6, t6, 4; # PC = PC + 4, valid only for non-compressed trapping instructions\n"
        "csrw	mepc, t6;"
        "nop;"
    );
}

#endif // __RVV_RVV_TEST_H__
