# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

CHS_ROOT ?= .

include cheshire.mk

# Inside the repo, forward (prefixed) all and nonfree targets
all: patches
	@$(MAKE) chs-all

%-all:
	@$(MAKE) chs-$*-all

nonfree-%:
	@$(MAKE) chs-nonfree-$*

# This is a temporary solution to avoid a mess with bender
.PHONY: patches
patches: 
	patch patches/bender_git_checkouts_ara-*_Bender.yml.patch 	.bender/git/checkouts/ara-*/Bender.yml
	patch patches/bender_git_checkouts_cva6-*_Bender.yml.patch  .bender/git/checkouts/cva6-*/Bender.yml