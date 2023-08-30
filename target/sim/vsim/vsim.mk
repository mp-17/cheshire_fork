VSIM = questa-2022.3-bt vsim
VSIM_ARGS ?= -c

CHS_VSIM_DIR  ?= $(CHS_ROOT)/target/sim/vsim

OLD_HIERARCHY := /ara_tb/dut/i_ara_soc/i_system/
NEW_HIERARCHY := sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0].
ARA_PATH ?= $(shell bender path ara)
$(CHS_VSIM_DIR)/add_waves.tcl: $(CHS_VSIM_DIR)/wave_lane.tcl
# 	Add Cheshire waves
	echo "add wave -group SoC sim:/tb_cheshire_soc/fix/dut/*" > $@
	touch $@
#	Add CVA6 waves
	find $(ARA_PATH) -name wave_core.tcl | xargs cat >> $@
	sed -i "s|$(OLD_HIERARCHY)i_ariane|$(NEW_HIERARCHY)i_core_cva6|g" $@
#	Add Ara waves
	find $(ARA_PATH) -name wave_ara.tcl | xargs cat >> $@
	sed -i "s|$(OLD_HIERARCHY)i_ara|$(NEW_HIERARCHY)i_ara|g" $@
	sed -i -E "s|\[examine.+\]|$(ARA_NR_LANES)|g" $@
	sed -i "s|../scripts/wave_lane.tcl|wave_lane.tcl|g" $@

$(CHS_VSIM_DIR)/wave_lane.tcl: 
#	Add lane waves
	cp $(shell find $$(bender path ara) -name $(shell basename $@)) $(CHS_VSIM_DIR)
	sed -i "s|$(OLD_HIERARCHY)i_ara|$(NEW_HIERARCHY)i_ara|g" $@
	sed -i -E "s|ara_pkg|work.ara_pkg|g" $@

BINARY ?= $(CHS_SW_DIR)/tests/rvv_hello_world.spm.elf
chs-sim-run: $(CHS_VSIM_DIR)/compile.cheshire_soc.tcl $(CHS_VSIM_DIR)/start.cheshire_soc.tcl $(CHS_VSIM_DIR)/add_waves.tcl
	$(VSIM) $(VSIM_ARGS) -do $(word 1,$^) \
						 -do "set BINARY $(BINARY)" \
						 -do $(word 2,$^) \
						 -do "log -r /*"  \
						 -do $(word 3,$^) \
						 -do "run -a"
	@echo "[INFO] Moving artifacts into the simulation directory $(CHS_VSIM_DIR)"
	mv -v trace*.log transcript vsim.wlf $(CHS_VSIM_DIR)

#	Remove the simulation prefix
$(CHS_VSIM_DIR)/%.post-sim.tcl: $(CHS_VSIM_DIR)/%.tcl
	sed -i "s|wave_lane.tcl|wave_lane.post-sim.tcl|g" $< 
	sed "s|sim:||g" $< > $@

chs-sim-waves: $(CHS_VSIM_DIR)/add_waves.post-sim.tcl $(CHS_VSIM_DIR)/wave_lane.post-sim.tcl $(CHS_VSIM_DIR)/vsim.wlf
#	Launch Questa
	$(VSIM) $(CHS_VSIM_DIR)/vsim.wlf -do $<

chs-sim-clean:
	cd $(CHS_VSIM_DIR); rm -rf compile.cheshire_soc.tcl add_waves*.tcl wave_lane*.tcl trace*.log transcript
	rm -rf work