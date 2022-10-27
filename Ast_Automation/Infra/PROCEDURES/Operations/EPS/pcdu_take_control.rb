load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/EPS/EPS_PCDU')
load_utility('Operations/FSW/FSW_Telem')

telem = ModuleTelem.new
realtime_destination = 'COSMOS_UMBILICAL'
telem.set_realtime("APC_YP", "FSW_TLM_APC", realtime_destination, 1)
telem.set_realtime("APC_YP", "POWER_CSBATS_TLM", realtime_destination, 1)

cmd_sender = CmdSender.new
target = "BW3"

cmd_name = "PCDU_CHANGE_BATT_CARD_CONTROL"
params = {
"CONTROL": 'TAKE_CONTROL'
}
cmd_sender.send_with_cmd_count_check("APC_YP", cmd_name, params, "POWER", wait_time=4)

wait_check(target, CmdSender.get_full_pkt_name("APC_YP", "POWER_CSBATS_TLM"), "PCDU_BATT_IM_ALIVE", "== 'ALIVE'", 4)
wait_check(target, CmdSender.get_full_pkt_name("APC_YP", "POWER_CSBATS_TLM"), "PCDU_BATT_ITS_ALIVE", "== 'DEAD'", 4)
wait_check(target, CmdSender.get_full_pkt_name("APC_YP", "POWER_CSBATS_TLM"), "PCDU_BATT_HEALTH_STATE", "== 'IDLE'", 4)

cmd_name = "PCDU_SET_OTHER_CARD_POWER_STATE"
params = {
"CARD": 'CARD_MPPT',
"OTHER_CARD_POWER_STATE": 'POWER_DOWN_OTHER'
}
cmd_sender.send_with_cmd_count_check("APC_YP", cmd_name, params, "POWER", wait_time=4)
wait_check(target, CmdSender.get_full_pkt_name("APC_YP", "POWER_CSBATS_TLM"), "PCDU_MPPT_IM_ALIVE", "== 'ALIVE'", 4)
wait_check(target, CmdSender.get_full_pkt_name("APC_YP", "POWER_CSBATS_TLM"), "PCDU_MPPT_ITS_ALIVE", "== 'DEAD'", 4)


cmd_name = "PCDU_SET_OTHER_CARD_POWER_STATE"
params = {
"CARD": 'CARD_MICRON',
"OTHER_CARD_POWER_STATE": 'POWER_DOWN_OTHER'
}
cmd_sender.send_with_cmd_count_check("APC_YP", cmd_name, params, "POWER", wait_time=4)
wait_check(target, CmdSender.get_full_pkt_name("APC_YP", "POWER_CSBATS_TLM"), "PCDU_MICRON_IM_ALIVE", "== 'ALIVE'", 4)
wait_check(target, CmdSender.get_full_pkt_name("APC_YP", "POWER_CSBATS_TLM"), "PCDU_MICRON_ITS_ALIVE", "== 'DEAD'", 4)
