#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition
#
#************************************************************

# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints


create_generated_clock -divide_by 100 -source [get_pins {p1|pll_spi_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -name "clk_efi" [get_nets {efi_divider|clk_out}]

#create_clock -name "CLOCK_50" -period 20.000ns [get_ports {CLOCK_50}]
#create_clock -name "CLOCK2_50" -period 20.000ns [get_ports {CLOCK2_50}]


# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints



set_false_path -from * -to [get_ports { GPIO_1[*] }]
set_false_path -from * -to [get_ports { LEDR[*] }]

set_false_path -from [get_ports { GPIO_1[*] }] -to *
set_false_path -from [get_ports { RESET_N }] -to *
