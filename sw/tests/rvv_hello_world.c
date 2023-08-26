// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test vector instructions

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "encoding.h"

int main(void) {
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, 115200);

    // Set MSTATUS.VS
    asm volatile (" li      t0, %0       " :: "i"(MSTATUS_FS | MSTATUS_XS | MSTATUS_VS));
    asm volatile (" csrs    mstatus, t0" );

    // Run some vector instructions here
    // Vector configuration
    #define AVL 4
    uint64_t vl;
    asm volatile("li        t0 ,  %0" :: "i"(AVL));
    asm volatile("vsetvli   %0, t0, e64, m8, ta, ma" : "=r"(vl));

    // Vector permutation/arithmetic
    asm volatile("vmv.v.i   v0 ,  1");
    asm volatile("vadd.vv   v16, v0, v0");

    // // Allocate array in memory
    // uint64_t array [AVL];
    // // initialize with deadbeef
    // for ( unsigned int i = 0; i < AVL; i++ ) {
    //     array[i] = 0xdeadbeefdeadbeef;
    // }

    // uint64_t* address = array;
    // // Vector load
    // asm volatile("vle64.v	v24, (%0)": "+&r"(address));

    // // Vector store
    // asm volatile("vse64.v	v16, (%0)": "+&r"(address));

    // // Vector load
    // asm volatile("vle64.v	v8 , (%0)": "+&r"(address));

    char str2[] = "Enough vectors for today...\r\n";
    uart_write_str(&__base_uart, str2, sizeof(str2));
    uart_write_flush(&__base_uart);

    return 0;
}
