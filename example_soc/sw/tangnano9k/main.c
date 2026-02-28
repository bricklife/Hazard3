// main.c -- LED blink demo for Hazard3 on Tang Nano 9K
//
// GPIO output peripheral is at 0x40008000.
// Bits [5:0] of GPIO drive the 6 LEDs (active-high in software;
// the FPGA wrapper inverts them for the active-low LED hardware).
//
// Pattern: walk a single lit LED across all 6 LEDs, then repeat.

#include <stdint.h>

#define GPIO_BASE ((volatile uint32_t *)0x40008000u)
#define CLK_MHZ   27u

// Busy-wait for approximately ms milliseconds.
// Each iteration is ~4 cycles on Hazard3 (branch + counter decrement).
static void delay_ms(uint32_t ms) {
    volatile uint32_t n = (CLK_MHZ * 1000u / 4u) * ms;
    while (n--) {}
}

int main(void) {
    const uint32_t pattern[] = {
        0x01u, 0x02u, 0x04u, 0x08u, 0x10u, 0x20u,
        0x10u, 0x08u, 0x04u, 0x02u,
    };
    const int npattern = sizeof(pattern) / sizeof(pattern[0]);

    int i = 0;
    while (1) {
        *GPIO_BASE = pattern[i];
        delay_ms(200);
        i = (i + 1 >= npattern) ? 0 : i + 1;
    }
}
