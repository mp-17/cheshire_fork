VSIM = questa-2022.3-bt vsim
VSIM_ARGS ?= -c

BENDER_TARGETS ?= 

include ../../common.mk

all: sim

add_waves.tcl: wave_lane.tcl
# 	Add Cheshire waves
	# TBD
	touch $@
#	Add CVA6 waves
	find ../../../.bender/git/checkouts/ara*/ -name wave_core.tcl | xargs cat >> $@
	sed -i "s|/ara_tb/dut/i_ara_soc/i_system/i_ariane|sim:/tb_cheshire_soc/fix/dut/i_cva6|g" $@
#	Add Ara waves
	find ../../../.bender/git/checkouts/ara*/ -name wave_ara.tcl | xargs cat >> $@
	sed -i "s|/ara_tb/dut/i_ara_soc/i_system/i_ara|sim:/tb_cheshire_soc/fix/dut/i_ara|g" $@
	sed -i "s|ara_tb.NrLanes|sim:/tb_cheshire_soc/fix/dut/i_ara.NrLanes|g" $@
	sed -i "s|../scripts/wave_lane.tcl|wave_lane.tcl|g" $@

wave_lane.tcl: 
#	Add lane waves
	cp $(shell find ../../../.bender/git/checkouts/ara*/ -name $@) .
	# find ../../../.bender/git/checkouts/ara*/ -name $@ | xargs -n 1 -I {} cp {} .
	sed -i "s|/ara_tb/dut/i_ara_soc/i_system/i_ara|sim:/tb_cheshire_soc/fix/dut/i_ara|g" $@

compile.cheshire_soc.tcl: 
	make -C ../../../ sim-all BENDER_TARGETS="$(BENDER_TARGETS)" BENDER_DEFS="$(BENDER_DEFS)"

sim: compile.cheshire_soc.tcl start.cheshire_soc.tcl add_waves.tcl
	$(VSIM) $(VSIM_ARGS) -do $(word 1,$^) \
						 -do $(word 2,$^) \
						 -do "log -r /*"  \
						 -do $(word 3,$^) \
						 -do "run -a"
clean:
	rm -rf work compile.cheshire_soc.tcl add_waves.tcl wave_lane.tcl