CROSS   ?= riscv64-unknown-elf
CC       = $(CROSS)-gcc
OBJCOPY  = $(CROSS)-objcopy
PYTHON   ?= python3

TARGET   = blink
SRCS     = start.S main.c

ARCH_FLAGS = -march=rv32im_zicsr -mabi=ilp32
CFLAGS     = $(ARCH_FLAGS) -Os -g -Wall -ffreestanding -nostdlib -T link.ld
LDFLAGS    = $(ARCH_FLAGS) -nostdlib -T link.ld

.PHONY: all clean

all: $(TARGET).hex

$(TARGET).elf: $(SRCS) link.ld
	$(CC) $(CFLAGS) $(SRCS) -o $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).bin bin2hex.py
	$(PYTHON) bin2hex.py $< $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).hex
