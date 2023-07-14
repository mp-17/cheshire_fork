VSIM = questa-2022.3-bt vsim

BENDER_TARGETS ?= 

include ../../common.mk

all: sim

compile.cheshire_soc.tcl:
	make -C ../../../ sim-all BENDER_TARGETS="$(BENDER_TARGETS)" BENDER_DEFS="$(BENDER_DEFS)"

sim: compile.cheshire_soc.tcl start.cheshire_soc.tcl
	$(VSIM) -c -do $< -do start.cheshire_soc.tcl -do "run -a"

clean:
	rm -rf work compile.cheshire_soc.tcl