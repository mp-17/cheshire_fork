VSIM = questa-2022.3-bt vsim
VSIM_ARGS ?= -c

CHS_VSIM_DIR  ?= $(CHS_ROOT)/target/sim/vsim

all: sim

OLD_HIERARCHY := /ara_tb/dut/i_ara_soc/i_system/
NEW_HIERARCHY := sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0].
$(CHS_VSIM_DIR)/add_waves.tcl: $(CHS_VSIM_DIR)/wave_lane.tcl
# 	Add Cheshire waves
	echo "add wave -group SoC sim:/tb_cheshire_soc/fix/dut/*" > $@
	touch $@
#	Add CVA6 waves
	find $(shell bender path ara) -name wave_core.tcl | xargs cat >> $@
	sed -i "s|$(OLD_HIERARCHY)i_ariane|$(NEW_HIERARCHY)i_core_cva6|g" $@
#	Add Ara waves
	find ../../../.bender/git/checkouts/ara*/ -name wave_ara.tcl | xargs cat >> $@
	sed -i "s|$(OLD_HIERARCHY)i_ara|$(NEW_HIERARCHY)i_ara|g" $@
	sed -i -E "s|\[examine.+\]|$(ARA_NR_LANES)|g" $@
	sed -i "s|../scripts/wave_lane.tcl|wave_lane.tcl|g" $@
# sed -i "s|sim:||g" $@

$(CHS_VSIM_DIR)/wave_lane.tcl: 
#	Add lane waves
	cp $(shell find $(shell bender path ara) -name $@) .
	sed -i "s|$(OLD_HIERARCHY)i_ara|$(NEW_HIERARCHY)i_ara|g" $@
	sed -i -E "s|ara_pkg|work.ara_pkg|g" $@
# sed -i "s|.sim:||g" $@

BINARY ?= $(CHS_SW_DIR)/tests/rvv_hello_world.spm.elf
chs-sim-run: $(CHS_VSIM_DIR)/compile.cheshire_soc.tcl $(CHS_VSIM_DIR)/start.cheshire_soc.tcl $(CHS_VSIM_DIR)/add_waves.tcl
	# $(VSIM) $(VSIM_ARGS) -do $(word 1,$^) \
	# 					 -do "set BINARY $(BINARY)" \
	# 					 -do $(word 2,$^) \
	# 					 -do "log -r /*"  \
	# 					 -do $(word 3,$^) \
	# 					 -do "run -a"
	@echo "[INFO] Moving artifacts into the simulation directory $(CHS_VSIM_DIR)"
	mv -v trace*.log transcript vsim.wlf $(CHS_VSIM_DIR)

chs-sim-waves: $(CHS_VSIM_DIR)/add_waves.tcl
	vsim vsim.wlf -do $^

chs-sim-clean:
	cd $(CHS_VSIM_DIR); rm -rf work compile.cheshire_soc.tcl add_waves.tcl wave_lane.tcl trace*.log transcript