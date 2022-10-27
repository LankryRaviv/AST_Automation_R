load_utility('Operations/CPBF/CPBF_Telem')

@cpbf = ModuleCPBF.new

cmd_params = {
    "MICRON_ID": 20, 
    "FILE_ID": 25, 
    "STATUS": 0,
    "ASPECT": 0,
    "START_ENTRY_ID": 1,
    "END_ENTRY_ID": 3
}

@cpbf.send_cmd_get_micron_pkt("MIC_LSL",20,"MIC_FILE_CHECK",cmd_params,"MIC_FILE_CHECK_RES",1000,30,3)