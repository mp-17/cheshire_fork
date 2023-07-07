# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

PROJECT     ?= cheshire

##########
# Bender #
##########

BENDER      	?= bender
BENDER_DEFS 	?= 
BENDER_TARGETS 	:= -t cva6

#######
# ARA #
#######

# Ara-capable CVA6
BENDER_TARGETS += -t cv64a6_imafdcv_sv39 

# Ara-required CVA6 configs
ARA ?= 1
ARA_NR_LANES ?= 0
ifeq ($(ARA),1)
	ifneq ( $(ARA), 0 ) 
		ARA_NR_LANES ?= 2
		VLEN ?= $$(($(ARA_NR_LANES) * 1024))
		BENDER_DEFS += --define ARA
		BENDER_DEFS += --define ARIANE_ACCELERATOR_PORT=1
		BENDER_DEFS += --define WT_CACHE=1
		BENDER_DEFS += --define ARA_NR_LANES=$(ARA_NR_LANES)  
		BENDER_DEFS += --define VLEN=$(VLEN)
#		BENDER_DEFS += --define ARA_INTEGRATION_v0_1=1
		BENDER_DEFS += --define ARA_INTEGRATION_v0_2=1
		PROJECT := $(PROJECT)_ara_$(ARA_NR_LANES)_lanes
	endif
else
	PROJECT := $(PROJECT)_no_ara
endif

# Board in      {vcu128, genesys2, zcu102(not working)}
BOARD        ?= vcu128
XILINX_HOST  ?= bordcomputer

# Select board specific variables
ifeq ($(BOARD),vcu128)
    # The bordcomputer only has hw-server 2020.2 for now
	VIVADO       ?= vitis-2020.2 vivado
	XILINX_PART  ?= xcvu37p-fsvh2892-2L-e
	XILINX_BOARD ?= xilinx.com:vcu128:part0:1.0
	# VCU128-01
    XILINX_PORT	 ?= 3231 
	# VCU128-02
    # XILINX_PORT	 ?= 3232
    FPGA_PATH	 ?= xilinx_tcf/Xilinx/091847100576A 
	FPGA_DEVICE	 ?= xcvu37p_0
	IPS_NAMES    := xlnx_vio xlnx_mig_ddr4 xlnx_qspi
	BENDER_TARGETS := $(BENDER_TARGETS) -t bscane
endif
ifeq ($(BOARD),genesys2)
	XILINX_PART  ?= xc7k325tffg900-2
	XILINX_BOARD ?= digilentinc.com:genesys2:part0:1.1
	XILINX_PORT  ?= 3332
	FPGA_PATH    ?= xilinx_tcf/Digilent/200300A8C60DB
	FPGA_DEVICE	 ?= xc7k325t_0
	IPS_NAMES    := xlnx_mig_7_ddr3
endif
# ifeq ($(BOARD),zcu102)
# 	VIVADO ?= vitis-2020.2 vivado
# 	XILINX_PART    ?= xczu9eg-ffvb1156-2-e
# 	XILINX_BOARD   ?= xilinx.com:zcu102:part0:3.4
# 	XILINX_PORT  ?= 
# 	FPGA_PATH    ?= 
# 	FPGA_DEVICE	 ?= 
# 	IPS_NAMES      := xlnx_mig_ddr4
# endif


out := $(PROJECT)
bit := $(out)/cheshire_top_xilinx.bit
mcs := $(out)/cheshire_top_xilinx.mcs
BIT ?= $(bit)

##########
# Vivado #
##########

# Define TARGET_<ip> macro with bender
IPS := $(addsuffix .xci ,$(basename $(IPS_NAMES)))
BENDER_TARGETS += $(addprefix -t ,$(basename $(IPS)))
IP_DIR := xilinx

DEBUG_RUN ?= 1
VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \
              PORT=$(XILINX_PORT)           \
              HOST=$(XILINX_HOST)           \
              FPGA_PATH=$(FPGA_PATH)        \
              BIT=$(BIT) 					\
			  DEBUG_RUN=$(DEBUG_RUN)
MODE        ?= batch
VIVADOFLAGS ?= -nojournal -mode $(MODE)
# Define TARGET_$(BOARD) macro with bender
BENDER_TARGETS += -t $(BOARD) -t fpga

all: $(bit)

# Include Xilinx IPs simulation makefile
include sim/simulate.mk

# Generate mcs from bitstream
$(mcs): $(bit)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/write_cfgmem.tcl -tclargs $@ $^

$(bit): $(IPS) scripts/add_sources.tcl
	mkdir -p $(out)
	mkdir -p $(PROJECT)
	cd $(PROJECT); $(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source ../scripts/run.tcl 
	cp $(PROJECT)/$(PROJECT).runs/impl_1/$(PROJECT)* ./$(out)
	cd $(PROJECT); $(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) $(PROJECT).xpr -source ../scripts/get_run_info.tcl > reports/report.tmp
	grep " cheshire_top_xilinx " $(PROJECT)/reports/$(PROJECT).utilization.rpt | sed -E "s/.+top\) //g" >> reports/report.tmp

# Build all the IPS
ips: $(IPS)

%.xci:
	@echo "Generating IP $(basename $@)"
	cd $(IP_DIR)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO="$(VIVADO)" $(MAKE)
	cp $(IP_DIR)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@

gui:
	@echo "Starting $(vivado) GUI"
	$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT)/$(PROJECT).xpr &

program: #$(bit)
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
# hw_server in IIS bordcomputer is v2020.2
	$(VIVADOENV) vitis-2020.2 vivado $(VIVADOFLAGS) -source scripts/program.tcl

# Spare IPS from clean
clean:
	rm -rf scripts/add_sources.tcl 
	rm -rf vivado* probes.ltx \
		*.log *.jou *.str *.mif .Xil/ \
		$(out) $(PROJECT)

clean_IPS:
	rm -rf *.xci
	cd xilinx; $(foreach ip, $(IPS_NAMES), make -C $(ip) clean;)

# Clean only top and copy back the IPS output here
rebuild_top:
	${MAKE} clean
	rm -f scripts/add_sources.tcl
	find xilinx -wholename "**/*.srcs/**/*.xci" | xargs -n 1 -I {} cp {} .
	${MAKE} $(bit)

# Bender
# TODO: this needs to be redirected to the top makefile to align with questa script generation
scripts/add_sources.tcl: ../../Bender.yml
	$(BENDER) script vivado $(BENDER_TARGETS) $(BENDER_DEFS) > $@ 

.PHONY: clean sim scripts/add_sources.tcl
