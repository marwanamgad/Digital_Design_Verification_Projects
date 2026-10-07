 
## Clock signal (100 MHz, 10 ns period)
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK]
 
set_property PACKAGE_PIN W5 [get_ports CLK]