##
##  Makefile to run the reduction of the EVLA B-configuration data of
##  BD EVLA B
##
##  O. Morata
##  2018-2019
##

##-- Project info ------------------------------------------------------
#
# project name, general prefix, and bands to process
#
PRJ_NAME=BD-EVLA_B
SNAME =protoBDsTau
BANDS = C X K
#SOURCES = J041757 J041836 J041847 J041938
SOURCES = J041757

targets = _avg
#extra_targets-J041836 = _i_ _ccomb

actions = rob0 natural uniform
#extra_actions-J041757_avg = taper01 taper02 taper03
#actions2 = com_uv_rob0 com_uv_natural com_uv_uniform

show_plot =  uvwave uv  wt

result_rules = merge chanaverage img
#
##-- End of project info -----------------------------------------------

##-- Directory set-up --------------------------------------------------
#
ROOT_DIR=/lustre/opsw/work/omoratac

HOME_DIR=$(ROOT_DIR)/$(PRJ_NAME)

# names of directories to use
#
BIN_DIR=$(HOME_DIR)/scripts
CFG_DIR=$(HOME_DIR)/config/clean
DATA_DIR=$(HOME_DIR)/data
REDC_DIR=$(HOME_DIR)/reduction
RES_DIR=$(HOME_DIR)/results

SH_DIR=$(BIN_DIR)/bash
PYTHON_DIR=$(BIN_DIR)/python
#CASABIN=casa512
CASABIN=casa


export



##-- End of directory set-up -------------------------------------------


##-- Definition of templates -------------------------------------------

define PrepData_Template
# templates to prepare the data before the cleaning
#  the first parameter is the band name, the second the source name
#
.PHONY: merge-$(1) merge-$(2)
.PHONY: merge-$(1)-$(2)

merge-$(1): merge-$(1)-$(2)

merge-$(2): merge-$(1)-$(2)

merge-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)

$(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2):
	$(SH_DIR)/mk_merge.sh \
	    -c $(CFG_DIR)/band_$(1)/merge_sbs-$(1)-$(2).cfg \
	    -w $(RES_DIR)/band_$(1) \
            -l $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)


.PHONY: chanaverage-$(1) chanaverage-$(2)
.PHONY: chanaverage-$(1)-$(2)

chanaverage-$(1): chanaverage-$(1)-$(2)
chanaverage-$(2): chanaverage-$(1)-$(2)

chanaverage-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2)

$(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)
	$(SH_DIR)/mk_avg.sh  \
	    -c $(CFG_DIR)/band_$(1)/chanaverage-$(1)-$(2).cfg \
	    -w $(RES_DIR)/band_$(1)/merged  \
	    -l $(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2)


.PHONY: chanaverage_comb-$(1)-$(2)

chanaverage_comb-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)

$(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)
	$(SH_DIR)/mk_avg.sh  \
	    -c $(CFG_DIR)/band_$(1)/chanaverage_comb-$(1)-$(2).cfg \
	    -w $(RES_DIR)/band_$(1)/merged \
	    -l $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)


endef



define PlotData

.PHONY: plot_data-$(1)-$(2)-$(3)

plot_data-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/plots-$(1)-$(2)-$(3).png

$(RES_DIR)/band_$(1)/maps/$(2)/plots-$(1)-$(2)-$(3).png:  $(RES_DIR)/band_$(1)/merged/$(SNAME)-$(1)-$(2).ms
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -o $(RES_DIR)/band_$(1)/maps  \
	    -a $(3)  \
	    -w $(RES_DIR)/band_$(1)/merged/ \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)_view


endef



define Clean_Template
# template to clean data
#  first parameter - band, second parameter - target, third - action
#
# It includes the actions:
#   dirty: to make a dirty map to estimate map rms
#   img: to clean the map
#   tofits: to export the cleaned map to fits
#   view: to view the result of the clean
#
.PHONY: dirty-$(1)-$(2)
.PHONY: dirty-$(1)-$(2)-$(3)

dirty-$(1)-$(2):  dirty-$(1)-$(2)-$(3)

dirty-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_dirty

$(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_dirty: $(RES_DIR)/band_$(1)/merged/$(SNAME)-$(1)-$(2).ms
	$(SH_DIR)/mk_clean.sh  -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -i $(RES_DIR)/band_$(1)/merged \
	    -o $(RES_DIR)/band_$(1)/maps  \
	    -t $(3) \
            -r 'ok' \
            -a 'dirty'   \
	    -w $(RES_DIR)/band_$(1)/maps/$(2) \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_dirty


.PHONY: img-$(1)-$(2)
.PHONY: img-$(1)-$(2)-$(3)

img-$(1)-$(2):  img-$(1)-$(2)-$(3)

img-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img

$(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img: $(RES_DIR)/band_$(1)/merged/$(SNAME)-$(1)-$(2).ms
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -i $(RES_DIR)/band_$(1)/merged \
	    -o $(RES_DIR)/band_$(1)/maps  \
	    -t $(3) \
            -r 'ok'\
            -a 'img'   \
	    -w $(RES_DIR)/band_$(1)/maps/$(2) \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img


tofits-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/img-$(1)-$(2)-$(3).fits

$(RES_DIR)/band_$(1)/maps/$(2)/img-$(1)-$(2)-$(3).fits:  $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -o $(RES_DIR)/band_$(1)/maps  \
            -t $(3) \
	    -a 'tofits' \
	    -w $(RES_DIR)/band_$(1)/merged/  \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_tofits


view-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -i $(RES_DIR)/band_$(1)/merged \
	    -o $(RES_DIR)/band_$(1)/maps  \
            -t $(3) \
            -r 'ok' \
	    -a 'view' \
	    -w $(RES_DIR)/band_$(1)/maps/$(2) \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_view


endef



define Target_Template
# Template to create combinations of actions for targets and bands
#
# first parameter - band, second parameter - target
#
.PHONY: dirty-$(1) dirty-$(2)

dirty-$(1): dirty-$(1)-$(2)
dirty-$(2): dirty-$(1)-$(2)


.PHONY: img-$(1) img-$(2)

img-$(1): img-$(1)-$(2)
img-$(2): img-$(1)-$(2)


.PHONY: plot_data-$(1)-$(2)

plot_data-$(1)-$(2): $(plot_list-$(1)_$(2))

endef



define Combine_Template
# template to combine data from different configurations
#
combine-$(1)-$(2): combine_prep-$(1)-$(2)

combine_prep-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2)

$(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'prep_data' \
	    -w $(RES_DIR)/band_$(1)/combined_evlaBC \
	    -l $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2)


combine_viewdata-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_viewdata-$(1)-$(2)

$(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_viewdata-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'viewdata' \
	    -w $(RES_DIR)/band_$(1)/combined_evlaBC \
	    -l $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_viewdata-$(1)-$(2)


combine_calc_wt-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_calc_wt-$(1)-$(2)

$(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_calc_wt-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'calc_wt' \
	    -w $(RES_DIR)/band_$(1)/combined_evlaBC \
	    -l $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_calc_wt-$(1)-$(2)

combine_concat-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_concat-$(1)-$(2)

$(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_concat-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_calc_wt-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'concat' \
	    -w $(RES_DIR)/band_$(1)/combined_evlaBC \
	    -l $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_concat-$(1)-$(2)

endef



define Template_OnlyTarget
# Template to create combination of actions only for targets
#
#  parameter - target
#
.PHONY: dirty

dirty: dirty-$(1)  ## make dirty map of dirty-$$(1)


.PHONY: img

img: img-$(1)
endef


define Template_Sources
# Template to create combination of actions only for sources
#
#  parameter - source
#
.PHONY: merge
.PHONY: chanaverage

merge: merge-$(1)

chanaverage: chanaverage-$(1)

endef

#
#-- End of definition of templates ------------------------------------


# Define list of targets
#
list_of_targets =
$(foreach src,$(SOURCES),\
    $(foreach tg,$(targets),\
        $(eval tgt = $(subst _i_,,$(tg)))\
        $(eval list_of_targets += $(src)$(tgt))\
    )\
    $(foreach xx,$(extra_targets-$(src)),\
        $(eval addxx = $(subst _i_,,$(xx)))\
        $(eval list_of_targets += $(src)$(addxx))\
    )\
)
$(info $(list_of_targets))
#
##


##-- Rules -------------------------------------------------------------


all: merge chanaverage img
#all: tofits plot_data



# for sources
#
$(foreach src, $(SOURCES),\
    $(eval $(call Template_Sources,$(src)))\
    $(foreach band, $(BANDS),\
        $(eval $(call PrepData_Template,$(band),$(src)))\
        $(eval $(call Combine_Template,$(band),$(src)))\
    )\
)



# for targets
#
$(foreach tgt, $(list_of_targets), \
    $(eval $(call Template_OnlyTarget,$(tgt))) \
    $(foreach band, $(BANDS), \
        $(eval plot_list-$(band)_$(tgt) = ) \
	$(foreach plot, $(show_plot),\
            $(eval $(call PlotData,$(band),$(tgt),$(plot)))\
            $(eval plot_list-$(band)_$(tgt) += plot_data-$(band)-$(tgt)-$(plot))\
        ) \
        $(eval $(call Target_Template,$(band),$(tgt)))\
        $(foreach action, $(actions),\
            $(eval $(call Clean_Template,$(band),$(tgt),$(action)))\
        )\
     )\
)


.PHONY: help help_dirs help_rules
help:
	@echo
	@echo " Makefile to clean data of $(PRJ_NAME)"
	@echo "-------------------------------------------"
	@echo "   Variables:"
	@echo "          Project Name = $(PRJ_NAME)"
	@echo "           File prefix = $(SNAME)"
	@echo "       Frequency bands = $(BANDS)"
	@echo "               Sources = $(SOURCES)"
	@echo "               Targets = $(list_of_targets)"
	@echo "     Actions for clean = $(actions)"
	@echo "       CASA executable = $(CASABIN)"
	@echo
	@echo "   Help options:"
	@echo "      make help_dirs  -  info on directories"
	@echo "      make help_rules -  info on defined rules"
	@echo
	@echo " General rule structure:"
	@echo "   make [task][-band/source][-source/targets][-action]"
	@echo
	@echo "    where:"
	@echo "       task: all, merge, chanaverage, dirty, img"
	@echo
	@echo "    example:  make img-$(word 1, $(BANDS))-$(word 1, $(list_of_targets))-$(word 1, $(actions))"
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
	@echo "           data : $(DATA_DIR)"
	@echo "      reduction : $(REDC_DIR)"
	@echo "        results : $(RES_DIR)"
	@echo


list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

##
## End of rules --------------------------------------------------------

