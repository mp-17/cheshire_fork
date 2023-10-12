VSIM = questa-2022.3-bt vsim
VSIM_ARGS ?= -c

CHS_VSIM_DIR  ?= $(CHS_ROOT)/target/sim/vsim

OLD_HIERARCHY := /ara_tb/dut/i_ara_soc/i_system/
NEW_HIERARCHY := sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0].
ARA_PATH ?= $(shell bender path ara)
$(CHS_VSIM_DIR)/add_waves.tcl: $(CHS_VSIM_DIR)/wave_lane.tcl
# 	Add ungrouped waves
	echo "add wave sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/commit_stage_i/pc_o"  > $@
# 	Add Cheshire waves
	echo "add wave -group SoC sim:/tb_cheshire_soc/fix/dut/*" >> $@
	touch $@
#	Add CVA6 waves
	find $(ARA_PATH) -name wave_core.tcl | xargs cat >> $@
	sed -i "s|$(OLD_HIERARCHY)i_ariane|$(NEW_HIERARCHY)i_core_cva6|g" $@
#	Add Ara waves
	find $(ARA_PATH) -name wave_ara.tcl | xargs cat >> $@
	sed -i "s|$(OLD_HIERARCHY)i_ara|$(NEW_HIERARCHY)i_ara|g" $@
	sed -i -E "s|\[examine.+\]|$(ARA_NR_LANES)|g" $@
	sed -i "s|../scripts/wave_lane.tcl|wave_lane.tcl|g" $@

# NrOperandQueues := $(shell grep "NrOperandQueues =" $(shell bender path ara)/hardware/include/ara_pkg.sv | awk '{print $$6}' | sed "s/;//g")
$(CHS_VSIM_DIR)/wave_lane.tcl: 
#	Add lane waves
	cp $(shell find $$(bender path ara) -name $(shell basename $@)) $(CHS_VSIM_DIR)
	sed -i "s|$(OLD_HIERARCHY)i_ara|$(NEW_HIERARCHY)i_ara|g" $@
	sed -i -E "s|ara_pkg|work.ara_pkg|g" $@
#	Remove operand_requester
	sed -i "s/\[examine -radix dec work.ara_pkg::NrOperandQueues\]/0/g" $@

VSIM_ROOT ?= $(CHS_VSIM_DIR) 
BINARY ?= $(CHS_SW_DIR)/tests/rvv_hello_world.spm.elf
chs-sim-run: $(CHS_VSIM_DIR)/compile.cheshire_soc.tcl $(CHS_VSIM_DIR)/start.cheshire_soc.tcl $(CHS_VSIM_DIR)/add_waves.tcl
	cd $(VSIM_ROOT); $(VSIM) $(VSIM_ARGS) -do $(word 1,$^) \
						-do "set BINARY $(BINARY)" \
						-do $(word 2,$^) \
						-do "log -r /*"  \
						-do $(word 3,$^) \
						-do "run -a"

# Remove the simulation prefix
$(CHS_VSIM_DIR)/%.post-sim.tcl: $(CHS_VSIM_DIR)/%.tcl
	sed -i "s|wave_lane.tcl|wave_lane.post-sim.tcl|g" $< 
	sed "s|sim:||g" $< > $@

chs-sim-waves: $(CHS_VSIM_DIR)/add_waves.post-sim.tcl $(CHS_VSIM_DIR)/wave_lane.post-sim.tcl $(VSIM_ROOT)/vsim.wlf $(VSIM_ROOT)/vsim.dbg 
#	Launch Questa
	$(VSIM) $(VSIM_ROOT)/vsim.wlf -do $< -debugdb $(VSIM_ROOT)/vsim.dbg 

chs-sim-clean:
	cd $(CHS_VSIM_DIR); rm -rf compile.cheshire_soc.tcl vsim.dbg add_waves*.tcl wave_lane*.tcl trace*.log transcript
	rm -rf work