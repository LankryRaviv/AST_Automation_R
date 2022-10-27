load_utility('Operations/FSW/FSW_FS')
load_utility('Operations/FSW/FSW_Telem')
load_utility('Operations/FSW/UTIL_CmdSender')
fs = ModuleFS.new
telem = ModuleTelem.new
cs = CmdSender.new
@realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
freq = 0
telem.set_realtime("FC_YP", "FSW_TLM_FC", realtime_destination, freq)
telem.set_realtime("FC_YP", "AOCS_TLM", realtime_destination, freq)
telem.set_realtime("APC_YP", "FSW_TLM_APC", realtime_destination, freq)
telem.set_realtime("APC_YP", "POWER_PCDU_LVC_TLM", realtime_destination, freq)
telem.set_realtime("APC_YP", "POWER_CSBATS_TLM", realtime_destination, freq)
telem.set_realtime("APC_YP", "PAYLOAD_TLM", realtime_destination, freq)
telem.set_realtime("APC_YP", "COMM_TLM", realtime_destination, freq)
telem.set_realtime("APC_YP", "FDIR_TLM_APC", realtime_destination, freq)
telem.set_realtime("FC_YP", "FDIR_TLM_FC", realtime_destination, freq)
telem.set_realtime("APC_YP", "MEDIC_LEADER_TLM", 1realtime_destination28, freq)
telem.set_realtime("FC_YP", "MEDIC_FOLLOWER_TLM_FC", realtime_destination, freq)