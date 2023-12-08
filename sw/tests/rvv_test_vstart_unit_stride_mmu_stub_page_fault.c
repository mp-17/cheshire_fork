// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Matteo Perotti  <mperotti@iis.ee.ethz.ch>

// Every request generates an exception after 1 cycle
#define param_stub_ex          1
#define param_stub_req_rsp_lat 1
#define param_stub_req_rsp_rnd 0

// Test body
#include "rvv_test_vstart_unit_stride_mmu_stub_page_fault.c.body"
