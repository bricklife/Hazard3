include ../project_paths.mk

CHIPNAME      := fpga_tangnano9k
DOTF          := ../fpga/fpga_tangnano9k.f
BUILD_DIR     := build

DEVICE_FAMILY := GW1NR-9C
DEVICE_PART   := GW1NR-LV9QN88PC6/I5

GW_SH           ?= gw_sh
OPENFPGA_LOADER ?= openFPGALoader
PYTHON          ?= python3

# Blink firmware
SW_DIR      := $(abspath ../sw/tangnano9k)
PRELOAD_HEX := $(abspath $(BUILD_DIR)/blink.hex)
PRELOAD_V   := $(abspath $(BUILD_DIR)/preload.v)

# preload.v must come FIRST so TANGNANO9K_PRELOAD_FILE is defined before
# fpga_tangnano9k.v is parsed (Gowin EDA processes files in list order).
SRCS    := $(PRELOAD_V) $(shell HDL=$(HDL) $(SCRIPTS)/listfiles $(DOTF))
INCDIRS := $(shell HDL=$(HDL) $(SCRIPTS)/listfiles -f flati $(DOTF))

CST          := $(abspath fpga_tangnano9k.cst)
SDC          := $(abspath fpga_tangnano9k.sdc)
FILELIST_TCL := $(abspath $(BUILD_DIR)/filelist.tcl)
BITSTREAM    := $(BUILD_DIR)/impl/pnr/$(CHIPNAME).fs

.PHONY: synth run flash clean clean-synth sw

synth: $(BITSTREAM)

# Build firmware first, then synthesise.
# TangNano9K.mk is also a dependency: any change to this file (e.g. SRCS
# ordering, device options) automatically triggers re-synthesis.
$(BITSTREAM): $(SRCS) $(CST) $(SDC) project.tcl TangNano9K.mk
	mkdir -p $(BUILD_DIR)
	@echo "set SRCS {$(SRCS)}" > $(FILELIST_TCL)
	@echo "set INCDIRS {$(INCDIRS)}" >> $(FILELIST_TCL)
	cd $(BUILD_DIR) && $(GW_SH) $(abspath project.tcl) \
		$(DEVICE_FAMILY) $(DEVICE_PART) $(CHIPNAME) \
		$(CST) $(SDC) $(FILELIST_TCL)

# Build the firmware hex image.
sw: $(PRELOAD_HEX)

$(PRELOAD_HEX): $(SW_DIR)/blink.hex | $(BUILD_DIR)
	cp $< $@

$(SW_DIR)/blink.hex:
	$(MAKE) -C $(SW_DIR)

# Generate a Verilog file that defines TANGNANO9K_PRELOAD_FILE to the
# absolute path of the firmware hex, so $readmemh can locate it at
# elaboration time regardless of the working directory.
$(PRELOAD_V): $(PRELOAD_HEX) | $(BUILD_DIR)
	@echo '`define TANGNANO9K_PRELOAD_FILE "$(PRELOAD_HEX)"' > $@

$(BUILD_DIR):
	mkdir -p $@

# Load bitstream to SRAM (volatile, lost on power cycle)
run: synth
	$(OPENFPGA_LOADER) --board tangnano9k --write-sram $(BITSTREAM)

# Burn bitstream to flash (persistent)
flash: synth
	$(OPENFPGA_LOADER) --board tangnano9k --write-flash $(BITSTREAM)

# Remove synthesis outputs only (keeps firmware hex; useful when only RTL changed).
clean-synth:
	rm -rf $(BUILD_DIR)/impl $(BUILD_DIR)/filelist.tcl

# Remove everything including firmware.
clean:
	rm -rf $(BUILD_DIR)
	$(MAKE) -C $(SW_DIR) clean
