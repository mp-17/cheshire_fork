# Includes the defines for bender common to questa and vivado

#######
# ARA #
#######

##########################################################################################################
# NOTE: Cheshire is configuration oriented but the current strategy requires 
#		source code modifications of a cheshire_cfg_t struct. 
#		Ara itself is configurable and runs with different configurations must
#		be performed and controlled at build time. 
#		In order to avoid source code re-generation, here we define simple macros
#		wich are, then, used bby the source code itself to build the target configuration.
#		The basic macros and their values are:
#		- ARA:
#			0. Don't instantiate Ara
#			1. Instantiate Ara
#		- ARA_NR_LANES: number of parallel lanes inside Ara
#			- {2, 4, 8}
#			- any other power of 2 is, in theory, supported, but nearly impossible to realistically build
#		- VLEN: derived from ARA_NR_LANES
#		- Ara AXI interconnection (mutually exclusive)
#			- ARA_INTEGRATION_V0_1: direct connection to Cheshire xbar, only supports ARA_NR_LANES=2
#			- ARA_INTEGRATION_V0_2: with axi_dw_converter
#			- ARA_INTEGRATION_V0_3: split crossbar (not yet implemented)
##########################################################################################################

# Ara-capable CVA6
BENDER_ARA_TARGETS += -t cv64a6_imafdcv_sv39

ARA ?= 1
ARA_NR_LANES ?= 2
VLEN := $$(($(ARA_NR_LANES) * 1024))
# Needs to be defined alongside with RVV (cv64a6_imafdcv_sv39)
BENDER_ARA_DEFS += --define ARIANE_ACCELERATOR_PORT=1
BENDER_ARA_DEFS += --define WT_CACHE=1
# Questa requires these to be defined since Ara sources are built anyway
BENDER_ARA_DEFS += --define ARA_NR_LANES=$(ARA_NR_LANES)  
BENDER_ARA_DEFS += --define VLEN=$(VLEN)

# MMU-related defines
# # Instantiate MMU interface in CVA6 and Ara
# BENDER_ARA_DEFS += --define ACC_MMU_INTERFACE
# Prioritize Ara translation requests to MMU
BENDER_ARA_DEFS += --define MMU_ACC_PRIORITY

ifeq ($(ARA),1)
	BENDER_ARA_DEFS += --define ARA
#	TODO: after v0.3 is implemented, pickup v0.2 for 2 lanes
#	ifeq ($(ARA_NR_LANES),2)
#		BENDER_ARA_DEFS += --define ARA_INTEGRATION_V0_2
#	else
		BENDER_ARA_DEFS += --define ARA_INTEGRATION_V0_2
# 		BENDER_ARA_DEFS += --define ARA_INTEGRATION_V0_3 (not yet implemented)
#	endif
endif

xilinx_targs := $(BENDER_ARA_TARGETS) $(BENDER_ARA_DEFS)