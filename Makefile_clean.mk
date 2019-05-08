##
##  Makefile to run the reduction of the EVLA B-configuration data of
##  BD EVLA B
##
##  O. Morata
##  2018-2019
##

##-- Project info ------------------------------------------------------
#
# definition of project name, general prefix, bands, and sources
#
PRJ_NAME := BD-EVLA_B
SNAME := protoBDsTau
BANDS := C X K
#SOURCES = J041757 J041836 J041847 J041938
SOURCES := J041757



# Definition of targets
#
# for merging, combining data from two configurations, for averaging
#
# suffixes
#
suf_merge := 
suf_avg := _avg 
#suf_comb = _evlaBC


# sources where to merge SBs
#
list_merge := $(SOURCES)
merged := $(foreach f,$(list_merge), $(addsuffix $(suf_merge),$(f)))


# source where to combine data from configurations
#
#list_comb = 
#combd = $(foreach f,$(list_comb), $(addsuffix $(suf_comb),$(f)))


# sources where to average channels
#
list_avg := $(merged)
avgd := $(foreach av,$(suf_avg),\
             $(foreach f,$(list$(av)),$(addsuffix $(av),$(f))))


#targets = _avg



list_of_targets := $(avgd) 

# definition of extra_targets for a source
#
#extra_target-J041836 = _xcd
#extrad = $(foreach src,$(SOURCES),$(foreach xx,$(extra_target-$(src)),\
#               $(addsuffix $(xx),$(src))))

#list_of_targets = $(avgd)$(combd)$(extrad)



# definition of weights for cleaning
#
weights := rob0 natural uniform
#weights = rob0 natural uniform com_uv_rob0 com_uv_natural com_uv_uniform
#
# definition of extra weights for a target
#
#extra-weights-J041757_avg = taper00
#
# definition of extra weights for a target and band
#
#extra_weights-K-J041757_avg = taper01 taper02 taper03



show_plot := uvwave uv  wt



# definition of tasks for all
#
result_rules := merge chanaverage img
#result_rules = merge chanaverage img tofits plot_data maps


##-- End of project info -----------------------------------------------

##-- Directory set-up --------------------------------------------------
#
ROOT_DIR := /lustre/opsw/work/omoratac

HOME_DIR := $(ROOT_DIR)/$(PRJ_NAME)

# names of directories to use
#
BIN_DIR := $(HOME_DIR)/scripts
CFG_DIR := $(HOME_DIR)/config/clean
DATA_DIR := $(HOME_DIR)/data
REDC_DIR := $(HOME_DIR)/reduction
RES_DIR := $(HOME_DIR)/results

SH_DIR := $(BIN_DIR)/bash
PYTHON_DIR := $(BIN_DIR)/python
CASABIN := casa


export


##-- End of directory set-up -------------------------------------------


##-- Definition of templates -------------------------------------------

define Merge_Template
# templates to prepare the data before the cleaning
#  the first parameter is the band name, the second the source name
#
.PHONY: merge-$(1) merge-$(2)
.PHONY: merge-$(1)-$(2)

$(eval LOG_MERGE := $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2))

merge-$(1): merge-$(1)-$(2)

merge-$(2): merge-$(1)-$(2)

merge-$(1)-$(2): $(LOG_MERGE)

$(LOG_MERGE):
	$(SH_DIR)/mk_merge.sh \
	    -c $(CFG_DIR)/band_$(1)/merge_sbs-$(1)-$(2).cfg \
	    -w $(RES_DIR)/band_$(1) \
            -l $(LOG_MERGE)
endef



define ChanAvg_Template
# templates to prepare the data before the cleaning
#  the first parameter is the band name, the second the source name
#

.PHONY: chanaverage-$(1) chanaverage-$(2)
.PHONY: chanaverage-$(1)-$(2)

$(eval LOG_MERGE := $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2))
$(eval LOG_CHANAVG := $(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2))

chanaverage-$(1): chanaverage-$(1)-$(2)
chanaverage-$(2): chanaverage-$(1)-$(2)

chanaverage-$(1)-$(2): $(LOG_CHANAVG)

$(LOG_CHANAVG): $(LOG_MERGE)
	$(SH_DIR)/mk_avg.sh  \
	    -c $(CFG_DIR)/band_$(1)/chanaverage-$(1)-$(2).cfg \
	    -w $(RES_DIR)/band_$(1)/merged  \
	    -l $(LOG_CHANAVG)

endef



#define PrepData_Template
# templates to prepare the data before the cleaning
#  the first parameter is the band name, the second the source name
#
#.PHONY: merge-$(1) merge-$(2)
#.PHONY: merge-$(1)-$(2)
#
#merge-$(1): merge-$(1)-$(2)
#
#merge-$(2): merge-$(1)-$(2)
#
#
#merge-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)
#
#$(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2):
#	$(SH_DIR)/mk_merge.sh \
#	    -c $(CFG_DIR)/band_$(1)/merge_sbs-$(1)-$(2).cfg \
#	    -w $(RES_DIR)/band_$(1) \
#            -l $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)
#
#
#
#.PHONY: chanaverage-$(1) chanaverage-$(2)
#.PHONY: chanaverage-$(1)-$(2)
#
#chanaverage-$(1): chanaverage-$(1)-$(2)
#chanaverage-$(2): chanaverage-$(1)-$(2)
#
#chanaverage-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2)
#
#$(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)
#	$(SH_DIR)/mk_avg.sh  \
#	    -c $(CFG_DIR)/band_$(1)/chanaverage-$(1)-$(2).cfg \
#	    -w $(RES_DIR)/band_$(1)/merged  \
#	    -l $(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2)



#.PHONY: chanaverage_comb-$(1)-$(2)
#
#chanaverage_comb-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)
#
#$(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)
#	$(SH_DIR)/mk_avg.sh  \
#	    -c $(CFG_DIR)/band_$(1)/chanaverage_comb-$(1)-$(2).cfg \
#	    -w $(RES_DIR)/band_$(1)/merged \
#	    -l $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)
#
#endef



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
#  first parameter - band, second parameter - target, third - weight
#
# It includes the actions:
#   dirty: to make a dirty map to estimate the map rms
#   img: to clean the map
#   tofits: to export the cleaned map to fits
#   view: to view the result of the clean
#
$(eval mrg_dir := $(RES_DIR)/band_$(1)/merged)
$(eval map_dir := $(RES_DIR)/band_$(1)/maps)


.PHONY: dirty-$(1)-$(2)
.PHONY: dirty-$(1)-$(2)-$(3)

$(eval log_dirty := $(map_dir)/$(2)/log_clean-$(1)-$(2)-$(3)_dirty)

dirty-$(1)-$(2): dirty-$(1)-$(2)-$(3)

dirty-$(1)-$(2)-$(3): $(log_dirty)

$(log_dirty): $(mrg_dir)/$(SNAME)-$(1)-$(2).ms
	$(SH_DIR)/mk_clean.sh \
            -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -i $(mrg_dir) \
	    -o $(map_dir)  \
	    -t $(3) \
            -r 'ok' \
            -a 'dirty'   \
	    -w $(map_dir)/$(2) \
	    -l $(log_dirty)



.PHONY: img-$(1)-$(2)
.PHONY: img-$(1)-$(2)-$(3)

$(eval log_img := $(map_dir)/$(2)/log_clean-$(1)-$(2)-$(3)_img)

img-$(1)-$(2):  img-$(1)-$(2)-$(3)

img-$(1)-$(2)-$(3): $(log_img)

$(log_img): $(mrg_dir)/$(SNAME)-$(1)-$(2).ms
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -i $(mrg_dir) \
	    -o $(map_dir)  \
	    -t $(3) \
            -r 'ok' \
            -a 'img'  \
	    -w $(map_dir)/$(2) \
	    -l $(log_img)



.PHONY: tofits-$(1)-$(2)-$(3)

$(eval OUT_FITS := $(map_dir)/$(2)/img-$(1)-$(2)-$(3).fits)

tofits-$(1)-$(2)-$(3): $(OUT_FITS)

$(OUT_FITS):  $(log_img)
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -o $(map_dir) \
            -t $(3) \
	    -a 'tofits' \
	    -w $(mrg_dir) \
	    -l $(map_dir)/$(2)/log_clean-$(1)-$(2)-$(3)_tofits



view-$(1)-$(2)-$(3): $(log_img)
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/band_$(1)/$(1)-$(2).ini \
	    -i $(mrg_dir) \
	    -o $(map_dir) \
            -t $(3) \
            -r 'ok' \
	    -a 'view' \
	    -w $(map_dir)/$(2) \
	    -l $(map_dir)/$(2)/log_view-$(1)-$(2)-$(3)

endef



define Target_Template
# Template to create combinations of weights for targets and bands
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
$(eval comb_dir := $(RES_DIR)/band_$(1)/combined_evlaBC)

.PHONY: combine-$(1)-$(2)
.PHONY: combine_prep-$(1)-$(2)

$(eval log_comb_prep := $(comb_dir)/log_comb_prep-$(1)-$(2))

combine-$(1)-$(2): combine_prep-$(1)-$(2)

combine_prep-$(1)-$(2): $(log_comb_prep)

$(log_comb_prep): $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'prep_data' \
	    -w $(comb_dir) \
	    -l $(log_comb_prep)



$(eval log_comb_viewdata := $(comb_dir)/log_comb_viewdata-$(1)-$(2))

combine_viewdata-$(1)-$(2): $(log_comb_viewdata)

$(log_comb_viewdata): $(log_comb_prep)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'viewdata' \
	    -w $(comb_dir) \
	    -l $(log_comb_viewdata)



$(eval log_comb_calc_wt := $(comb_dir)/log_comb_calc_wt-$(1)-$(2))

combine_calc_wt-$(1)-$(2): $(log_comb_calc_wt)

$(log_comb_calc_wt): $(log_comb_prep)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'calc_wt' \
	    -w $(comb_dir) \
	    -l $(log_comb_calc_wt)



$(eval log_comb_concat := $(comb_dir)/log_comb_concat-$(1)-$(2))

combine_concat-$(1)-$(2): $(log_comb_concat)

$(log_comb_concat): $(log_comb_calc_wt)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'concat' \
	    -w $(comb_dir) \
	    -l $(log_comb_concat)

endef



define Template_OnlyTarget
# Template to create combination of weights only for targets
#
#  parameter - target
#
.PHONY: dirty

dirty: dirty-$(1)  ## make dirty map of dirty-$$(1)


.PHONY: img

img: img-$(1)

endef



define Merge_Sources
# Template to create merge list for sources
#
#  parameter - source
#
.PHONY: merge

merge: merge-$(1)

endef



define ChanAvg_Sources
# Template to create chanavg list for sources
#
#  parameter - source
#
.PHONY: chanaverage

chanaverage: chanaverage-$(1)

endef



#define Template_Sources
# Template to create combination of weights only for sources
#
#  parameter - source
#
#.PHONY: merge
#.PHONY: chanaverage
#
#merge: merge-$(1)
#
#chanaverage: chanaverage-$(1)
#
#endef

#
#-- End of definition of templates ------------------------------------


# Define list of targets
#
#list_of_targets = $(list_tgtm)
#list_of_targets = 
#$(foreach src,$(SOURCES),\
#    $(foreach tg,$(targets),\
#        $(eval tgt = $(subst _@,,$(tg)))\
#        $(eval list_of_targets += $(src)$(tgt))\
#    )\
#    $(foreach xx,$(extra_targets-$(src)),\
#        $(eval addxx = $(subst _@,,$(xx)))\
#        $(eval list_of_targets += $(src)$(addxx))\
#    )\
#)
#
##


##-- Rules -------------------------------------------------------------


all: $(result_rules)



# For sources
#
# merge
#
$(foreach mgsrc, $(list_merge),\
    $(eval $(call Merge_Sources,$(mgsrc)))\
    $(foreach band, $(BANDS),\
        $(eval $(call Merge_Template,$(band),$(mgsrc)))\
    )\
)

# chanaverage
#
$(foreach avsrc, $(list_avg),\
    $(eval $(call ChanAvg_Sources,$(avsrc)))\
    $(foreach avband, $(BANDS),\
        $(eval $(call ChanAvg_Template,$(avband),$(avsrc)))\
    )\
)

#$(foreach src, $(SOURCES),\
#    $(eval $(call Template_Sources,$(src)))\
#    $(foreach band, $(BANDS),\
#        $(eval $(call PrepData_Template,$(band),$(src)))\
#        $(eval $(call Combine_Template,$(band),$(src)))\
#    )\
#)



# For targets
#
$(foreach tgt, $(list_of_targets), \
    $(eval $(call Template_OnlyTarget,$(tgt))) \
    $(foreach band, $(BANDS), \
        $(eval plot_list-$(band)_$(tgt) = ) \
	$(foreach plot, $(show_plot),\
            $(eval $(call PlotData,$(band),$(tgt),$(plot))) \
            $(eval plot_list-$(band)_$(tgt) += \
                plot_data-$(band)-$(tgt)-$(plot)) \
        ) \
        $(eval $(call Target_Template,$(band),$(tgt))) \
        $(foreach wt, $(weights), \
            $(eval $(call Clean_Template,$(band),$(tgt),$(wt))) \
        ) \
        $(foreach wt, $(extra_weights-$(tgt)), \
            $(eval $(call Clean_Template,$(band),$(tgt),$(wt))) \
        ) \
        $(foreach wt, $(extra_weights-$(band)-$(tgt)), \
            $(eval $(call Clean_Template,$(band),$(tgt),$(wt))) \
        ) \
     ) \
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
	@echo "     Weights for clean = $(weights)"
	@echo "       CASA executable = $(CASABIN)"
	@echo
	@echo "   General rule structure:"
	@echo "     make [task][-band/source][-source/targets][-weight]"
	@echo
	@echo "        where:"
	@echo "          task: all, merge, chanaverage, dirty, img"
	@echo
	@echo "     example:  make img-$(word 1, $(BANDS))-$(word 1, $(list_of_targets))-$(word 1, $(weights))"
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
	@echo "           data : $(DATA_DIR)"
	@echo "      reduction : $(REDC_DIR)"
	@echo "        results : $(RES_DIR)"
	@echo


list:
# lists all the rules in the Makefile
#
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

##
## End of rules --------------------------------------------------------
