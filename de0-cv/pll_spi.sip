set_global_assignment -entity "pll_spi" -library "lib_pll_spi" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_spi" -library "lib_pll_spi" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "pll_spi" -library "lib_pll_spi" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_spi" -name SPD_FILE [file join $::quartus(sip_path) "pll_spi.spd"]

set_global_assignment -library "lib_pll_spi" -name MISC_FILE [file join $::quartus(sip_path) "pll_spi_sim/pll_spi.vo"]
