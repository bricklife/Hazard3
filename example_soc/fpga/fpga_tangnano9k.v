/*****************************************************************************\
|                        Copyright (C) 2021 Luke Wren                         |
|                     SPDX-License-Identifier: Apache-2.0                     |
\*****************************************************************************/

// FPGA toplevel for ../soc/example_soc.v on a Tang Nano 9K dev board
// (Gowin GW1NR-9C, 27 MHz oscillator)
//
// JTAG is available on PMOD0:
//   PMOD0 pin 1 (FPGA pin 28) = TCK
//   PMOD0 pin 2 (FPGA pin 26) = TDI
//   PMOD0 pin 3 (FPGA pin 39) = TDO
//   PMOD0 pin 4 (FPGA pin 37) = TMS
//
// UART is available on PMOD1:
//   PMOD1 pin 1 (FPGA pin 33) = TX
//   PMOD1 pin 2 (FPGA pin 30) = RX

`default_nettype none

module fpga_tangnano9k (
	input  wire       clk_osc,   // 27 MHz on-board oscillator

	// Button S2 (active-low: 0 = pressed, used as system reset)
	input  wire       btn,

	// 6 on-board LEDs (active-low, 1.8 V I/O)
	output wire [5:0] led,

	// JTAG debug port (PMOD0)
	input  wire       tck,
	input  wire       tms,
	input  wire       tdi,
	output wire       tdo,

	// UART (PMOD1)
	output wire       uart_tx,
	input  wire       uart_rx
);

wire clk_sys = clk_osc;
wire rst_n_sys;
wire trst_n;

// btn is high when not pressed; pressing it forces rst_n low.
fpga_reset #(
	.SHIFT (3)
) rstgen (
	.clk         (clk_sys),
	.force_rst_n (btn),
	.rst_n       (rst_n_sys)
);

// Synchronise system reset into TCK domain for JTAG TAP reset.
reset_sync trst_sync_u (
	.clk       (tck),
	.rst_n_in  (rst_n_sys),
	.rst_n_out (trst_n)
);

// led[0] blinks to indicate JTAG TCK activity.
wire tck_led;
activity_led #(
	.WIDTH        (1 << 8),
	.ACTIVE_LEVEL (1'b0)
) tck_led_u (
	.clk   (clk_sys),
	.rst_n (rst_n_sys),
	.i     (tck),
	.o     (tck_led)
);
// LEDs are active-low: output 1 = off, output 0 = on.
assign led = {5'b11111, tck_led};

example_soc #(
	.CLK_MHZ             (27),
	.SRAM_DEPTH          (1 << 13),  // 32 kB
	.EXTENSION_A         (1),
	.EXTENSION_C         (0),
	.EXTENSION_M         (1),
	.EXTENSION_ZBA       (0),
	.EXTENSION_ZBB       (0),
	.EXTENSION_ZBC       (0),
	.EXTENSION_ZBS       (0),
	.EXTENSION_ZBKB      (0),
	.EXTENSION_ZIFENCEI  (0),
	.EXTENSION_XH3BEXTM  (0),
	.EXTENSION_XH3PMPM   (0),
	.EXTENSION_XH3POWER  (0),
	.CSR_COUNTER         (0),
	.U_MODE              (0),
	.PMP_REGIONS         (0),
	.BREAKPOINT_TRIGGERS (0),
	.IRQ_PRIORITY_BITS   (0),
	.REDUCED_BYPASS      (0),
	.MULDIV_UNROLL       (1),
	.MUL_FAST            (0),
	.MUL_FASTER          (0),
	.MULH_FAST           (0),
	.FAST_BRANCHCMP      (1),
	.BRANCH_PREDICTOR    (0)
) soc_u (
	.clk     (clk_sys),
	.rst_n   (rst_n_sys),

	.tck     (tck),
	.trst_n  (trst_n),
	.tms     (tms),
	.tdi     (tdi),
	.tdo     (tdo),

	.uart_tx (uart_tx),
	.uart_rx (uart_rx)
);

endmodule
