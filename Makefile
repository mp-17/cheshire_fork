# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

CHS_ROOT ?= .

include cheshire.mk

# Inside the repo, forward (prefixed) all, nonfree, and clean targets
all: patches
	@$(MAKE) chs-all

%-all:
	@$(MAKE) chs-$*-all

nonfree-%:
	@$(MAKE) chs-nonfree-$*

# This is a temporary solution to avoid a mess with bender
.PHONY: patches
patches: 
	-patch .bender/git/checkouts/cva6-*/Bender.yml patches/bender_git_checkouts_cva6_Bender.yml.patch
	-patch .bender/git/checkouts/cva6-*/common/local/util/instr_trace_item.svh patches/bender_git_checkouts_cva6_common_local_util_instr_trace_item.svh.patch
	-patch .bender/git/checkouts/ara-*/Bender.yml patches/bender_git_checkouts_ara_Bender.yml.patch 
	-patch .bender/git/checkouts/ara-*/hardware/src/vlsu/vlsu.sv patches/bender_git_checkouts_ara_hardware_src_vlsu_vlsu.sv.patch
	
# Quick workaround for cva6-sdk not finding the DTB/FDT in this repo
# Expose a target to update it (just touching would not work)
dtb:
	dtc -I dts -O dtb -i $(CHS_SW_DIR)/boot $(CHS_SW_DIR)/boot/cheshire_$(BOARD).dts -o $(CHS_SW_DIR)/boot/cheshire_$(BOARD).dtb 
