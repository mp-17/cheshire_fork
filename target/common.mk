# Includes the defines for bender common to questa and vivado

#######
# ARA #
#######

# Ara-capable CVA6
BENDER_TARGETS += -t cv64a6_imafdcv_sv39 

ARA ?= 1
ifeq ($(ARA),1)
# 	RVV and Ara parameters
	ARA_NR_LANES ?= 2
	VLEN ?= $$(($(ARA_NR_LANES) * 1024))
	BENDER_DEFS += --define ARA
# 	Ara-required CVA6 configs
	BENDER_DEFS += --define ARIANE_ACCELERATOR_PORT=1
	BENDER_DEFS += --define WT_CACHE=1
	BENDER_DEFS += --define ARA_NR_LANES=$(ARA_NR_LANES)  
	BENDER_DEFS += --define VLEN=$(VLEN)
# 	Axi interconnection version for Ara integration (mutually exclusive)
#	TODO: pickup v0.1 for 2 lanes
#	ifeq ($(ARA_NR_LANES),2)
#		BENDER_DEFS += --define ARA_INTEGRATION_v0_1=1
#	else
		BENDER_DEFS += --define ARA_INTEGRATION_v0_2=1
# 		BENDER_DEFS += --define ARA_INTEGRATION_v0_3=1 (not yet implemented)
#	endif
# 	Project name
	PROJECT := $(PROJECT)_ara_$(ARA_NR_LANES)_lanes
else
	PROJECT := $(PROJECT)_no_ara
endif