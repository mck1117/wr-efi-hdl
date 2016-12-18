set_global_assignment -entity "pll_sync" -library "lib_pll_sync" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_sync" -library "lib_pll_sync" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "pll_sync" -library "lib_pll_sync" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_sync" -name SPD_FILE [file join $::quartus(sip_path) "pll_sync.spd"]

set_global_assignment -library "lib_pll_sync" -name MISC_FILE [file join $::quartus(sip_path) "pll_sync_sim/pll_sync.vo"]
