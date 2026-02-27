// Timing constraints for Hazard3 example SoC on Tang Nano 9K

// 27 MHz on-board oscillator (period = 1000/27 ≈ 37.037 ns)
create_clock -name clk_osc -period 37.037 -waveform {0 18.518} [get_ports {clk_osc}]

// JTAG TCK (10 MHz maximum)
create_clock -name tck -period 100 [get_ports {tck}]
