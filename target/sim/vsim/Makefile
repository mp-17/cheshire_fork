VSIM = questa-2022.3-bt vsim

all: sim

compile.cheshire_soc.tcl:
	make -C ../../../ sim-all

sim: compile.cheshire_soc.tcl start.cheshire_soc.tcl
	$(VSIM) $(VSIM_FLAGS) -c -do $< -do start.cheshire_soc.tcl -do "run -a"

clean:
	rm -rf work compile.cheshire_soc.tcl