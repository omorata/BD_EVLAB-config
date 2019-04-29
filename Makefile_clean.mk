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
SOURCES = J041757 J041836 J041847 J041938

targets = J041757_avg
#targets += J041757_comb
actions = rob0 natural uniform
actions_xtra = taper01 taper02 taper03
actions2 = com_uv_rob0 com_uv_natural com_uv_uniform

show_plot =  uvwave uv  wt

#
##-- End of project info -----------------------------------------------

##-- Directory set-up --------------------------------------------------
#
ROOT_DIR=/lustre/opsw/work/omoratac

HOME_DIR=$(ROOT_DIR)/$(PRJ_NAME)

# names of directories to use
#
BIN_DIR=$(HOME_DIR)/scripts
CFG_DIR=$(HOME_DIR)/config
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
merge-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)

$(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2):
	$(SH_DIR)/mk_merge.sh \
	    -c $(CFG_DIR)/clean/band_$(1)/merge_sbs-$(1)-$(2).cfg \
	    -w $(RES_DIR)/band_$(1) \
            -l $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)


chanaverage-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2)

$(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)
	$(SH_DIR)/mk_avg.sh  \
	    -c $(CFG_DIR)/clean/band_$(1)/chanaverage-$(1)-$(2).cfg \
	    -w $(RES_DIR)/band_$(1)/merged  \
	    -l $(RES_DIR)/band_$(1)/merged/log_chanaverage-$(1)-$(2)


.PHONY: chanaverage_comb-$(1)-$(2)
chanaverage_comb-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)

$(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_merge-$(1)-$(2)
	$(SH_DIR)/mk_avg.sh  \
	    -c $(CFG_DIR)/clean/band_$(1)/chanaverage_comb-$(1)-$(2).cfg \
	    -w $(RES_DIR)/band_$(1)/merged \
	    -l $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)


endef



define PlotData

.PHONY: $(3)-$(1)-$(2)

$(3)-$(1)-$(2): $(RES_DIR)/band_$(1)/maps/$(2)/plots-$(1)-$(2)-$(3).png

$(RES_DIR)/band_$(1)/maps/$(2)/plots-$(1)-$(2)-$(3).png:  $(RES_DIR)/band_$(1)/merged/$(SNAME)-$(1)-$(2).ms
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/clean/band_$(1)/$(1)-$(2).ini \
	    -o $(RES_DIR)/band_$(1)/maps  \
	    -a $(3)  \
	    -w $(RES_DIR)/band_$(1)/merged/ \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)_view


endef



define Clean_Template
# template to clean data
#  first parameter - band, second parameter - target, third - action
#
img-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img

$(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img: $(RES_DIR)/band_$(1)/merged/$(SNAME)-$(1)-$(2).ms
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/clean/band_$(1)/$(1)-$(2).ini \
	    -i $(RES_DIR)/band_$(1)/merged \
	    -o $(RES_DIR)/band_$(1)/maps  \
	    -t $(3)  -r 'ok'  -a 'img'   \
	    -w $(RES_DIR)/band_$(1)/maps/$(2) \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img


view-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/clean/band_$(1)/$(1)-$(2).ini \
	    -i $(RES_DIR)/band_$(1)/merged \
	    -o $(RES_DIR)/band_$(1)/maps  \
	    -a 'view'   -t $(3) -r 'ok' \
	    -w $(RES_DIR)/band_$(1)/maps/$(2) \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_view


tofits-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/img-$(1)-$(2)-$(3).fits

$(RES_DIR)/band_$(1)/maps/$(2)/img-$(1)-$(2)-$(3).fits:  $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_img
	$(SH_DIR)/mk_clean.sh  \
	    -c $(CFG_DIR)/clean/band_$(1)/$(1)-$(2).ini \
	    -o $(RES_DIR)/band_$(1)/maps  \
	    -a 'tofits'  -t $(3) \
	    -w $(RES_DIR)/band_$(1)/merged/  \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_tofits


dirty-$(1)-$(2)-$(3): $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_dirty

$(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_dirty: $(RES_DIR)/band_$(1)/merged/$(SNAME)-$(1)-$(2).ms
	$(SH_DIR)/mk_clean.sh  -c $(CFG_DIR)/clean/band_$(1)/$(1)-$(2).ini \
	    -i $(RES_DIR)/band_$(1)/merged \
	    -o $(RES_DIR)/band_$(1)/maps  \
	    -a $(3)  -r 'ok'  -t 'dirty'   \
	    -w $(RES_DIR)/band_$(1)/maps/$(2) \
	    -l $(RES_DIR)/band_$(1)/maps/$(2)/log_clean-$(1)-$(2)-$(3)_dirty


endef



define Target_Template

.PHONY: plot_data-$(1)-$(2)

plot_data-$(1)-$(2): $(plot_list_$(1)_$(2))

endef



define Combine_Template
# template to combine data from different configurations
#
combine-$(1)-$(2): combine_prep-$(1)-$(2)

combine_prep-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2)

$(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2): $(RES_DIR)/band_$(1)/merged/log_chanaverage_comb-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/clean/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'prep_data' \
	    -w $(RES_DIR)/band_$(1)/combined_evlaBC \
	    -l $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2)


combine_viewdata-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_viewdata-$(1)-$(2)

$(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_viewdata-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/clean/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'viewdata' \
	    -w $(RES_DIR)/band_$(1)/combined_evlaBC \
	    -l $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_viewdata-$(1)-$(2)


combine_calc_wt-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_calc_wt-$(1)-$(2)

$(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_calc_wt-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_prep-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/clean/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'calc_wt' \
	    -w $(RES_DIR)/band_$(1)/combined_evlaBC \
	    -l $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_calc_wt-$(1)-$(2)

combine_concat-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_concat-$(1)-$(2)

$(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_concat-$(1)-$(2): $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_calc_wt-$(1)-$(2)
	@$(SH_DIR)/mk_combine.sh \
	    -c $(CFG_DIR)/clean/band_$(1)/comb_evlaBC-$(1)-$(2).cfg \
	    -s 'concat' \
	    -w $(RES_DIR)/band_$(1)/combined_evlaBC \
	    -l $(RES_DIR)/band_$(1)/combined_evlaBC/log_comb_concat-$(1)-$(2)

endef

##-- End of definition of templates ------------------------------------


.PHONY: merge merge-C merge-X merge-K
.PHONY: merge-C-J041757 merge-X-J041757 merge-K-J041757
.PHONY: merge-J041757
.PHONY: chanaverage chanaverage-C chanaverage-X chanaverage-K
.PHONY: chanaverage-C-J041757 chanaverage-X-J041757 chanaverage-K-J041757
.PHONY: chanaverage-J041757


merge: merge-C merge-X merge-K

merge-C: merge-C-J041757
merge-X: merge-X-J041757 
merge-K: merge-K-J041757 

merge-J041757: merge-C-J041757 merge-X-J041757 merge-K-J041757

chanaverage: chanaverage-C chanaverage-X chanaverage-K

chanaverage-C: chanaverage-C-J041757
chanaverage-X: chanaverage-X-J041757
chanaverage-K: chanaverage-K-J041757

chanaverage-J041757: chanaverage-C-J041757 chanaverage-X-J041757 chanaverage-K-J041757


## generate rules
##

# for sources
#
$(foreach band, $(BANDS),\
    $(foreach src, $(SOURCES),\
        $(eval $(call PrepData_Template,$(band),$(src)))\
        $(eval $(call Combine_Template,$(band),$(src)))\
    )\
)



# for targets
#
$(foreach band, $(BANDS), \
    $(foreach tgt, $(targets),\
        $(eval plot_list_$(band)_$(tgt) = ) \
	$(foreach plot, $(show_plot),\
            $(eval $(call PlotData,$(band),$(tgt),$(plot)))\
            $(eval plot_list_$(band)_$(tgt) += $(plot)-$(band)-$(tgt))\
        ) \
        $(eval $(call Target_Template,$(band),$(tgt)))\
        $(foreach action, $(actions),\
            $(eval $(call Clean_Template,$(band),$(tgt),$(action)))\
        )\
    )\
)

