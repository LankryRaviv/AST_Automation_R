load_utility('Operations/MICRON/MICRON_MODULE.rb')

micron = MICRON_MODULE.new
board = "MIC_LSL"
micron_id = 107
slim_mode = "ENABLE_BASIC_SLIM"
ret = micron.get_tlm_slim(board, micron_id, is_enabled, converted=true, raw=false, wait_check_timeout=0.2)

if !ret.nil?
    mic_current_power_mode = ret[0]["MIC_CURRENT_POWER_MODE"]
    mic_general_health = ret[0]["MIC_GENERAL_HEALTH"]
    puts mic_current_power_mode
    puts mic_general_health
end