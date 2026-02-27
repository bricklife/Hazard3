include ../project_paths.mk

CHIPNAME      := fpga_tangnano9k
DOTF          := ../fpga/fpga_tangnano9k.f
BUILD_DIR     := build

DEVICE_FAMILY := GW1NR-9C
DEVICE_PART   := GW1NR-LV9QN88PC6/I5

GW_SH           ?= gw_sh
OPENFPGA_LOADER ?= openFPGALoader

SRCS    := $(shell HDL=$(HDL) $(SCRIPTS)/listfiles $(DOTF))
INCDIRS := $(shell HDL=$(HDL) $(SCRIPTS)/listfiles -f flati $(DOTF))

CST          := $(abspath fpga_tangnano9k.cst)
SDC          := $(abspath fpga_tangnano9k.sdc)
FILELIST_TCL := $(abspath $(BUILD_DIR)/filelist.tcl)
BITSTREAM    := $(BUILD_DIR)/impl/pnr/$(CHIPNAME).fs

.PHONY: synth run flash clean

synth: $(BITSTREAM)

$(BITSTREAM): $(SRCS) $(CST) $(SDC) project.tcl
	mkdir -p $(BUILD_DIR)
	@echo "set SRCS {$(SRCS)}" > $(FILELIST_TCL)
	@echo "set INCDIRS {$(INCDIRS)}" >> $(FILELIST_TCL)
	cd $(BUILD_DIR) && $(GW_SH) $(abspath project.tcl) \
		$(DEVICE_FAMILY) $(DEVICE_PART) $(CHIPNAME) \
		$(CST) $(SDC) $(FILELIST_TCL)

# Load bitstream to SRAM (volatile, lost on power cycle)
run: synth
	$(OPENFPGA_LOADER) --board tangnano9k --write-sram $(BITSTREAM)

# Burn bitstream to flash (persistent)
flash: synth
	$(OPENFPGA_LOADER) --board tangnano9k --write-flash $(BITSTREAM)

clean:
	rm -rf $(BUILD_DIR)
