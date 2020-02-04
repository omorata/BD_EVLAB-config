##
## Makefile to run analysis of the EVLA B-configuration data
## observations of four proto-BD candidates in Taurus
##
## O.Morata
## 2020
##

##-- Project info ------------------------------------------------------
#
# definition of project name, general prefix, bands, and sources
#
PRJ_NAME := BD-EVLA_B
SNAME := protoBDsTau
BANDS := C X K
SOURCES := J041757 J041836 J041847 J041938

targets := _avg _comb 
weights := natural rob0 uniform com_uv-natural com_uv-rob0 com_uv-uniform


# definition of extra weights for a target and band
#
extra_weights-K-J041757_avg := taper_01 taper_02 taper_03
#


# sources where to merge SBs
#
list_of_targets := $(foreach f,$(SOURCES), $(addsuffix $(targets),$(f)))

ifneq ($(targets),)
   list_src := $(SOURCES) 
   list_of_targets  = $(foreach f,$(list_src), \
               $(foreach suf,$(targets),$(addsuffix $(suf),$(f))))
endif


# definition of tasks for all
#
result_rules := getflux

##-- End of project info -----------------------------------------------

##-- Directory set-up --------------------------------------------------
#
ROOT_DIR := /lustre/opsw/work/omoratac

HOME_DIR := $(ROOT_DIR)/$(PRJ_NAME)

# names of directories to use
#
BIN_DIR := $(HOME_DIR)/scripts
CFG_DIR := $(HOME_DIR)/config/analysis
RES_DIR := $(HOME_DIR)/results

SH_DIR := $(BIN_DIR)/bash
PYTHON_DIR := $(BIN_DIR)/python
CASABIN := casa


export

##-- End of directory set-up -------------------------------------------

##-- Definition of templates -------------------------------------------

define Template_OnlyTarget
# Template to create combination of weights only for targets
#
#  parameter 1 - target
#
.PHONY: getflux

maps: getflux-$(1)
endef


define Analysis_Template
# template to analyse the data
#  parameters: 1 - band, 2 - target, 3 - weight
#
# It includes the actions:
#    getflux: to measure the fluxes in the cleaned images
#
$(eval map_dir := $(RES_DIR)/band_$(1)/maps)


$(eval out_getflux := $(map_dir)/$(2)/$(SNAME)-flux-$(1)-$(2)-$(3).dat)

.PHONY: getflux-$(1) getflux-$(2)
.PHONY: getflux-$(1)-$(2)
.PHONY: getflux-$(1)-$(2)-$(3)

getflux-$(1): getflux-$(1)-$(2)
getflux-$(2): getflux-$(1)-$(2)

getflux-$(1)-$(2): getflux-$(1)-$(2)-$(3)

getflux-$(1)-$(2)-$(3): $(out_getflux)

$(eval cfg_getflux := $(CFG_DIR)/band_$(1)/getflux-$(1)-$(2)-$(3).cfg )
$(eval image := $(map_dir)/$(2)/img-$(1)-$(2)-$(3).image.tt0 )

$(out_getflux): $(image) $(wildcard $(cfg_getflux))
	@if [ -f $(cfg_getflux) ]; then \
            $(SH_DIR)/getflux.sh \
		-c $(cfg_getflux)  \
		-w $(map_dir)/$(2)  \
		-o $(map_dir)/$(2)  \
		-l $(map_dir)/$(2)/log_getflux-$(1)-$(2)-$(3) ; \
         else \
             echo " ignoring rule $(out_getflux). No cfg file $(cfg_getflux)";\
         fi
endef

##-- End of definition of templates ------------------------------------

##-- Rules -------------------------------------------------------------

## IMPORTANT: if cfg file of targets does not exist, ignore action!!!

all: $(result_rules)

# For targets
#

$(foreach tgt, $(list_of_targets), \
    $(eval $(call Template_OnlyTarget,$(tgt))) \
    $(foreach band, $(BANDS), \
        $(foreach wt, $(weights), \
		$(eval $(call Analysis_Template,$(band),$(tgt),$(wt))) \
         ) \
        $(foreach wt, $(extra_weights-$(band)-$(tgt)), \
            $(eval $(call Analysis_Template,$(band),$(tgt),$(wt))) \
        ) \
    ) \
)



.PHONY: help help_dirs help_rules list

help:
	@echo
	@echo " Makefile to analyse the data of $(PRJ_NAME)"
	@echo "-------------------------------------------"
	@echo "   Variables:"
	@echo "          Project Name = $(PRJ_NAME)"
	@echo "           File prefix = $(SNAME)"
	@echo "       Frequency bands = $(BANDS)"
	@echo "               Sources = $(SOURCES)"
	@echo "               Targets = $(list_of_targets)"
	@echo "     Weights for clean = $(weights)"
	@echo "       CASA executable = $(CASABIN)"
	@echo
	@echo "   General rule structure:"
	@echo "     make [task][-band/source][-source/targets][-weight]"
	@echo
	@echo "        where:"
	@echo "          task: all, getflux"
	@echo
	@echo "     example:  make getflux-$(word 1, $(BANDS))-$(word 1, $\
                $(list_of_targets))-$(word 1, $(weights))"
	@echo
	@echo "   Help options:"
	@echo "      make help_dirs  -  info on directories"
	@echo "      make help_rules -  info on defined rules"
	@echo



help_dirs:
	@echo
	@echo " Directory set-up:"
	@echo "-------------------"
	@echo "           root : $(ROOT_DIR)"
	@echo "        project : $(HOME_DIR)"
	@echo "           bin  : $(BIN_DIR)"
	@echo "                +  shell scripts : $(SH_DIR)"
	@echo "                + python scripts : $(PYTHON_DIR)"
	@echo "  configuration : $(CFG_DIR)"
	@echo "        results : $(RES_DIR)"
	@echo



list:
# lists all the rules in the Makefile
#
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | \
           awk -v RS= -F: '/^# File/,/^# Finished Make data base/ \
               {if ($$1 !~ "^[#.]") {print $$1}}' | sort | \
           egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

##
##-- End of rules ------------------------------------------------------
