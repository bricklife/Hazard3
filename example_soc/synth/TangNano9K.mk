include ../project_paths.mk

CHIPNAME := fpga_tangnano9k
DOTF     := ../fpga/fpga_tangnano9k.f

DEVICE   := GW1NR-LV9QN88PC6/I5
FAMILY   := gw1n

# Reuse the pin constraints from the Gowin EDA target (same format, compatible
# with nextpnr-himbaechel -o cst=).
CST := $(abspath ../synth_gowin/fpga_tangnano9k.cst)

# Firmware preloading -----------------------------------------------------------
BUILD_DIR   := build
SW_DIR      := $(abspath ../sw/tangnano9k)
PRELOAD_HEX := $(abspath $(BUILD_DIR)/blink.hex)
PRELOAD_V   := $(abspath $(BUILD_DIR)/preload.v)

# preload.v must come FIRST so the TANGNANO9K_PRELOAD_FILE define is established
# before fpga_tangnano9k.v is parsed (yosys processes files in list order).
PRE_SRCS := $(PRELOAD_V)

include $(SCRIPTS)/synth_gowin.mk

# Add firmware build to the romfiles hook provided by synth_gowin.mk.
romfiles:: $(PRELOAD_V)

$(PRELOAD_V): $(PRELOAD_HEX) | $(BUILD_DIR)
	@echo '`define TANGNANO9K_PRELOAD_FILE "$(PRELOAD_HEX)"' > $@

$(PRELOAD_HEX): $(SW_DIR)/blink.hex | $(BUILD_DIR)
	cp $< $@

$(SW_DIR)/blink.hex:
	$(MAKE) -C $(SW_DIR)

$(BUILD_DIR):
	mkdir -p $@

# Load bitstream to SRAM (volatile, lost on power cycle)
run: bit
	$(OPENFPGA_LOADER) --board tangnano9k --write-sram $(CHIPNAME).fs

# Burn bitstream to flash (persistent)
flash: bit
	$(OPENFPGA_LOADER) --board tangnano9k --write-flash $(CHIPNAME).fs

# Remove synthesis outputs only (keeps firmware hex; useful when only RTL changed)
clean-synth:
	rm -f $(CHIPNAME).json $(CHIPNAME).pack $(CHIPNAME).fs $(CHIPNAME)_synth.v
	rm -f synth.log pnr.log

# Remove everything including firmware
clean::
	rm -rf $(BUILD_DIR)
	$(MAKE) -C $(SW_DIR) clean
