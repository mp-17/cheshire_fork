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
BENDER_TARGETS 	?= 
EXT_JTAG    	?= 1

include ../common.mk

# Board in      {vcu128, genesys2, zcu102(not working)}
BOARD        ?= vcu128
XILINX_HOST  ?= bordcomputer
# IIS bordcomputer has a fixed vivado version for the hw_server 
VIVADO_BORDCOMPUTER ?= vitis-2020.2 vivado
VCU128 ?= 2

# Select board specific variables
ifeq ($(BOARD),vcu128)
	VIVADO       ?= vitis-2020.2 vivado
	XILINX_PART  ?= xcvu37p-fsvh2892-2L-e
	XILINX_BOARD ?= xilinx.com:vcu128:part0:1.0
# VCU128-01 (broken flash)
	ifeq ($(VCU128),1)
		XILINX_PORT	 ?= 3231 
		FPGA_PATH	 ?= xilinx_tcf/Xilinx/091847100576A 
		GDB_LOCAL_PORT  ?= 3337
		GDB_REMOTE_PORT ?= 3337
	endif
# 	VCU128-02
	ifeq ($(VCU128),2)
		XILINX_PORT	 ?= 3232
		FPGA_PATH	 ?= xilinx_tcf/Xilinx/091847100638A 
		GDB_LOCAL_PORT  ?= 3333
		GDB_REMOTE_PORT ?= 3334
	endif
	FPGA_DEVICE	 ?= xcvu37p_0
# IPS_NAMES    := xlnx_vio xlnx_mig_ddr4 xlnx_qspi xlnx_clk_wiz 
	IPS_NAMES    := xlnx_vio xlnx_mig_ddr4 xlnx_clk_wiz 
# Choose whether to use BSCANE2 or external scanchain for the debug module 
	ifeq ($(EXT_JTAG),0)
		BENDER_TARGETS += -t bscane
	endif
endif

##########
# Vivado #
##########

# Define TARGET_<ip> macro with bender
IPS := $(addsuffix .xci ,$(basename $(IPS_NAMES)))
BENDER_TARGETS += $(addprefix -t ,$(basename $(IPS)))
IP_DIR := xilinx

DEBUG_RUN ?= 1
IMPL_STRATEGY ?= Performance_ExtraTimingOpt
SYNTH_STRATEGY ?= Flow_PerfOptimized_high

ifeq ($(ARA),1)
	PROJECT := $(PROJECT)_ara_$(ARA_NR_LANES)_lanes
else
	PROJECT := $(PROJECT)_no_ara
endif
ifeq ($(EXT_JTAG),1)
	PROJECT := $(PROJECT)_EXT_JTAG
else
	PROJECT := $(PROJECT)_INT_JTAG
endif

TCL_DIR := $(PWD)/scripts/tcl
out := out
BIT ?= $(out)/$(PROJECT).bit
# MCS ?= $(out)/$(PROJECT).mcs
LTX ?= $(out)/$(PROJECT).ltx

VIVADOENV ?=  PROJECT="$(PROJECT)"          	\
              TCL_DIR=$(TCL_DIR)   		   		\
              BOARD=$(BOARD)                	\
              XILINX_PART=$(XILINX_PART)    	\
              XILINX_BOARD=$(XILINX_BOARD)  	\
              PORT=$(XILINX_PORT)           	\
              HOST=$(XILINX_HOST)           	\
              FPGA_PATH=$(FPGA_PATH)        	\
              FPGA_DEVICE=$(FPGA_DEVICE)    	\
              BIT="$(BIT)"                    	\
              IMPL_STRATEGY=$(IMPL_STRATEGY) 	\
              SYNTH_STRATEGY=$(SYNTH_STRATEGY) 	\
              DEBUG_RUN=$(DEBUG_RUN)        	\
              LTX="$(LTX)"          	       
#   	\
#   MCS="$(MCS)"
MODE        ?= batch
VIVADOFLAGS ?= -nojournal -mode $(MODE)
# Define TARGET_$(BOARD) macro with bender
BENDER_TARGETS += -t $(BOARD) -t fpga

# Include Xilinx IPs simulation makefile
# include sim/simulate.mk

all: $(PROJECT) $(BIT)

$(PROJECT):
	mkdir -p $(PROJECT)

# Generate mcs from bitstream
$(MCS): $(BIT)
	cd $(PROJECT); $(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source $(TCL_DIR)/write_cfgmem.tcl -tclargs $@ $^

bit: $(BIT)
$(BIT): $(IPS) $(TCL_DIR)/add_sources.tcl
	mkdir -p $(out)
	cd $(PROJECT); $(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source $(TCL_DIR)/run.tcl 
	-cp $(PROJECT)/$(PROJECT).runs/impl_1/cheshire_top_xilinx.bit $(BIT)
	-cp $(PROJECT)/$(PROJECT).ltx $(LTX)
	cd $(PROJECT); $(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) $(PROJECT).xpr -source $(TCL_DIR)/get_run_info.tcl | grep " \[REPORT]" > reports/report.tmp
	grep " cheshire_top_xilinx " $(PROJECT)/reports/$(PROJECT).utilization.rpt | sed -E "s/.+top\) //g" >> $(PROJECT)/reports/report.tmp

# Build all the IPS
ips: $(IPS)

%.xci:
	@echo "Generating IP $(basename $@)"
	cd $(IP_DIR)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO="$(VIVADO)" $(MAKE)
	cp $(IP_DIR)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@

gui:
	@echo "Starting $(VIVADO) GUI"
	cd $(PROJECT); $(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

tcl:
	@echo "Starting $(VIVADO) TCL"
	cd $(PROJECT); $(VIVADOENV) $(VIVADO) -nojournal -mode tcl $(PROJECT).xpr

debug_gui:
	@echo "Starting $(VIVADO) GUI for debug"
	$(VIVADOENV) $(VIVADO) -nojournal -mode gui -source $(TCL_DIR)/debug_gui.tcl

program: #$(BIT)
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO_BORDCOMPUTER) $(VIVADOFLAGS) -source $(TCL_DIR)/program.tcl

# This must be forked from pulp-platform and checked-out at the cheshire branch, not the main from openhw
CVA6_SDK				?= ../../../cva6-sdk

# FW_PAYLOAD_FILE			?= $(CVA6_SDK)/install64/fw_payload.elf 
# SPIKE_FW_PAYLOAD_FILE	?= $(CVA6_SDK)/install64/spike_fw_payload.elf 
# LINUX_UIMAGE_FILE		?= $(CVA6_SDK)/install64/uImage
# DTB_FILE				?= cheshire_$(BOARD).dtb 
# Same offsets as u-boot "sf read" command, 
# see pulp-platform/cva6-sdk/u-boot/configs/pulp-platform_cheshire_defconfig:CONFIG_BOOTCOMMAND
# LINUX_UIMAGE_FLASH_OFFSET	?= 0x6100000
# FW_PAYLOAD_FLASH_OFFSET		?= 0x6000000 

write_cfgmem: 
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source $(TCL_DIR)/write_cfgmem.tcl \
		-tclargs $(MCS_FILE) $(FLASH_OFFSET) $(FLASH_FILE)

flash_spi_gpt: FLASH_FILE=../../sw/boot/linux-$(BOARD).gpt.bin  
flash_spi_gpt: MCS_FILE=linux-$(BOARD).gpt.mcs 
flash_spi_gpt: FLASH_OFFSET=0
flash_spi_gpt: write_cfgmem
flash_spi_gpt: flash_spi

flash_spi: $(MCS_FILE) 
	@echo "Flashing QSPI for board $(BOARD) ($(XILINX_PART)) with file $(MCS_FILE)"
	$(VIVADOENV) $(VIVADO_BORDCOMPUTER) $(VIVADOFLAGS) -source $(TCL_DIR)/flash_spi.tcl -tclargs $(MCS_FILE) 

# TODO: merge operations in a single script with multiple arguments
# flash_uImage: $(LINUX_UIMAGE_FILE)
# 	make write_cfgmem MCS_FILE=$@.mcs FLASH_OFFSET=$(LINUX_UIMAGE_FLASH_OFFSET) FLASH_FILE=$(LINUX_UIMAGE_FILE)
# 	make flash_spi    MCS_FILE=$@.mcs	
#	(Untested) \
# $(VIVADOENV) $(VIVADO_BORDCOMPUTER) $(VIVADOFLAGS) \
# 	-source $(TCL_DIR)/write_cfgmem.tcl -tclargs $(MCS_FILE) $(FLASH_OFFSET) $(FLASH_FILE) \
# 	-source $(TCL_DIR)/flash_spi.tcl 	 -tclargs $(MCS_FILE) 

# flash_fw_payload: $(FW_PAYLOAD_FILE)
# 	make write_cfgmem MCS_FILE=$@.mcs FLASH_OFFSET=$(LINUX_UIMAGE_FLASH_OFFSET) FLASH_FILE=$(LINUX_UIMAGE_FILE)
# 	make flash_spi    MCS_FILE=$@.mcs	

# $(DTB_FILE): dtb
# dtb: ../../sw/boot/$(BOARD).dts 
# 	dtc -I dts -O dtb -o $(DTB_FILE) $<

# # OpenSBI + U-boot
# # DTB/FDT is included in the OpenSBI payload
# $(FW_PAYLOAD_FILE): fw_payload
# fw_payload: $(DTB_FILE)
# 	make -C $(CVA6_SDK) fw_payload.bin FW_FDT_PATH=$(realpath $(DTB_FILE))

# # OpenSBI + uImage
# spike_payload: $(DTB_FILE)
# 	make -C $(CVA6_SDK) spike_payload FW_FDT_PATH=$(realpath $(DTB_FILE))

# Launch gdb
# GDB ?= riscv64-unknown-elf-gdb 
GDB ?= /usr/scratch/fenga3/vmaisto/cva6-sdk_fork_update_kernel/buildroot/output/host/bin/riscv64-buildroot-linux-gnu-gdb
launch_gdb:
	-ssh -L $(GDB_LOCAL_PORT):localhost:$(GDB_REMOTE_PORT) -C -N -f -l $$USER $(XILINX_HOST)
	$(GDB) -ex "target extended-remote :$(GDB_LOCAL_PORT)"

# Spare IPS from clean
clean:
	# Bender script
	rm -rf $(TCL_DIR)/add_sources.tcl 
	# Vivado products
	rm -rf vivado* probes.ltx *.log *.jou *.str *.mif .Xil/ $(PROJECT)
	# Programming files
	rm -rf *.mcs *.prm
	# Software products
	rm -rf cheshire.dtb fw_payload.elf spike_fw_payload.elf linux-*gpt.*

clean_ips:
	rm -rf *.xci
	cd xilinx; $(foreach ip, $(IPS_NAMES), make -C $(ip) clean;)

# Call all the clean targets
clean_all: clean_cva6-sdk clean-all_cva6-sdk clean clean_ips

# Clean only top and copy back the IPS output here
rebuild_top:
	${MAKE} clean
	rm -f $(TCL_DIR)/add_sources.tcl
	find xilinx -wholename "**/*.srcs/**/*.xci" | xargs -n 1 -I {} cp {} .
	${MAKE} $(BIT)

# Bender
# TODO: this needs to be redirected to the top makefile to align with questa script generation
$(TCL_DIR)/add_sources.tcl: ../../Bender.yml
	$(BENDER) script vivado $(BENDER_TARGETS) $(BENDER_DEFS) > $@ 

.PHONY: clean sim $(TCL_DIR)/add_sources.tcl
