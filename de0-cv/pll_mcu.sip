set_global_assignment -entity "pll_mcu" -library "lib_pll_mcu" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_mcu" -library "lib_pll_mcu" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "pll_mcu" -library "lib_pll_mcu" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_mcu" -name SPD_FILE [file join $::quartus(sip_path) "pll_mcu.spd"]

set_global_assignment -library "lib_pll_mcu" -name MISC_FILE [file join $::quartus(sip_path) "pll_mcu_sim/pll_mcu.vo"]
