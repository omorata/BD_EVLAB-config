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

targets := _avg _avg-com_uv _comb _comb-com-uv
weights := natural rob0 uniform

##-- End of project info -----------------------------------------------

##-- Directory set-up --------------------------------------------------
#
ROOT_DIR := /lustre/opsw/work/omoratac

HOME_DIR := $(ROOT_DIR)/$(PRJ_NAME)

# names of directories to use
#
BIN_DIR := $(HOME_DIR)/scripts
CFG_DIR := $(HOME_DIR)/config/analysis
DATA_DIR := $(HOME_DIR)/data
RES_DIR := $(HOME_DIR)/results

SH_DIR := $(BIN_DIR)/bash
PYTHON_DIR := $(BIN_DIR)/python
CASABIN := casa


export

##-- End of directory set-up -------------------------------------------

## IMPORTANT: if cfg file of targets does not exist, ignore action!!!

$(RES_DIR)/band_X/maps/J041757_avg/$(SNAME)-X-J041757_avg-rob0-flux.dat:
