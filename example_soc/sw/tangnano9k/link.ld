/* link.ld -- Linker script for Tang Nano 9K blink demo
 *
 * SRAM: 32 kB starting at 0x00000000
 *   0x00000000 - 0x0000003f : trap vectors (.vectors)
 *   0x00000040 - 0x00007fff : code + data (.text, .data, .bss)
 *
 * Reset vector is 0x40 (matches RESET_VECTOR in example_soc.v).
 * Trap vector is  0x00 (matches MTVEC_INIT in example_soc.v).
 */

MEMORY {
    SRAM (rwx) : ORIGIN = 0x00000000, LENGTH = 32K
}

SECTIONS {
    /* Trap handler at address 0x00 */
    .vectors : {
        KEEP(*(.vectors))
        /* Pad to 0x40 so _start is at the reset vector */
        . = 0x40;
    } > SRAM

    /* Code and read-only data */
    .text : {
        *(.text.startup)
        *(.text*)
        *(.rodata*)
    } > SRAM

    /* Initialised data (no separate load region -- SRAM is preloaded) */
    .data : {
        *(.data*)
    } > SRAM

    /* Zero-initialised data */
    .bss : {
        *(.bss*)
        *(COMMON)
    } > SRAM

    _end = .;
}
