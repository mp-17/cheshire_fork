# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

PROJECT      ?= cheshire
BOARD        ?= genesys2
XILINX_PART  ?= xc7k325tffg900-2
XILINX_BOARD ?= digilentinc.com:genesys2:part0:1.1
XILINX_PORT  ?= 3332
XILINX_HOST  ?= bordcomputer
FPGA_PATH    ?= xilinx_tcf/Digilent/200300A8C60DB

out := out
bit := $(out)/cheshire_top_xilinx.bit
mcs := $(out)/cheshire_top_xilinx.mcs
BIT ?= $(bit)


VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \
              PORT=$(XILINX_PORT)           \
              HOST=$(XILINX_HOST)           \
              FPGA_PATH=$(FPGA_PATH)        \
              BIT=$(BIT)

# select IIS-internal tool commands if we run on IIS machines
ifneq (,$(wildcard /etc/iis.version))
	VIVADO ?= vitis-2020.1 vivado
# VIVADO ?= vitis-2022.1 vivado
else
	VIVADO ?= vivado
endif

VIVADOFLAGS ?= -nojournal -mode batch
# VIVADOFLAGS ?= -nojournal -mode tcl

ip-dir  := xilinx
ips     :=  xlnx_mig_7_ddr3.xci
# ips     +=  xlnx_vio.xci 

all: $(mcs)

# Generate mcs from bitstream
$(mcs): $(bit)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/write_cfgmem.tcl -tclargs $@ $^

$(bit): $(ips)
	# Updade scripts/add_sources.tcl
	-rm -v scripts/add_sources.tcl
	make -C ../../ xilinx-all
	@mkdir -p $(out)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/prologue.tcl -source scripts/run.tcl
	cp $(PROJECT).runs/impl_1/$(PROJECT)* ./$(out)

$(ips):
	@echo "Generating IP $(basename $@)"
	cd $(ip-dir)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO="$(VIVADO)" $(MAKE)
	cp $(ip-dir)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@

gui:
	@echo "Starting $(vivado) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

program:
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
# hw_server in IIS bordcomputer is v2020.2
	$(VIVADOENV) vitis-2020.2 vivado $(VIVADOFLAGS) -source scripts/program.tcl

clean:
# Spare IPs from clean
	rm -rf *.log *.jou *.str *.mif *.xpr .Xil/ $(out) $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).sim

clean_ips:
	rm -rf *.xci

.PHONY:
	clean
