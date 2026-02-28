// start.S -- Reset/trap entry for Tang Nano 9K blink demo
//
// Memory layout (see link.ld):
//   0x00000000 : trap vector (mtvec points here)
//   0x00000040 : _start (reset vector, RESET_VECTOR=0x40)

	.section .vectors, "ax"

// ---------------------------------------------------------------------------
// Trap vector (address 0x00)
// Simple infinite loop; real programs would handle traps here.

	.globl _trap_vector
_trap_vector:
	j _trap_vector

// Pad up to 0x40 so _start lands exactly at the reset vector.
	.org 0x40

// ---------------------------------------------------------------------------
// Reset entry (_start at 0x40)

	.section .text.startup, "ax"
	.globl _start
_start:
	// Zero all registers (except x0).
	li  x1,  0
	li  x2,  0
	li  x3,  0
	li  x4,  0
	li  x5,  0
	li  x6,  0
	li  x7,  0
	li  x8,  0
	li  x9,  0
	li  x10, 0
	li  x11, 0
	li  x12, 0
	li  x13, 0
	li  x14, 0
	li  x15, 0
	li  x16, 0
	li  x17, 0
	li  x18, 0
	li  x19, 0
	li  x20, 0
	li  x21, 0
	li  x22, 0
	li  x23, 0
	li  x24, 0
	li  x25, 0
	li  x26, 0
	li  x27, 0
	li  x28, 0
	li  x29, 0
	li  x30, 0
	li  x31, 0

	// Set up stack pointer (top of SRAM: base 0x0 + 32 kB).
	li  sp, 0x8000

	// Jump to C main.
	call main

	// If main returns, loop forever.
1:	j 1b
