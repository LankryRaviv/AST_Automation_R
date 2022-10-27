load('Operations/FSW/FSW_FDIR.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
cmd_sender = CmdSender.new
fdir = ModuleFdir.new
entry_size = 186
apc_red_stack_failover_script_file_id = 2
apc_red_stack_failover_script = "#{__dir__}\\red_stack_failover_script.txt"
apc_this_sec_apc_take_over_script_file_id = 3
apc_this_sec_apc_take_over_script = "#{__dir__}\\this_sec_apc_take_over_script.txt"

fdir_config_file = "#{__dir__}\\config_binary_all_fsa_disabled.bin"
#fdir_config_file = "#{__dir__}\\config_binary_all_but_failover_fsa_disabled.bin"
#fdir_config_file = "#{__dir__}\\config_binary_flight_candidate_1.bin"

check_aspect = "CRC"

board_to_update = "APC_YM"

#Uploading all configs to APC_YP from the binary file
#Note: You only have to run the following two lines the first time you run this script on any given board
#      due to the fact that we save the configs into NVM after we upload them in this script.
fdir.upload_num_config_rows(board_to_update, fdir_config_file)
fdir.upload_configs(board_to_update, fdir_config_file)

#Unlock and save the active configs to main
cmd_sender.send(board_to_update, 'FSW_UNLOCK_CONFIG_SAVING', {}, true)
wait(1)
cmd_sender.send(board_to_update, "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {}, true)

#Upload the script file to APC_YP
FSW_FS_Upload(entry_size, apc_red_stack_failover_script_file_id, apc_red_stack_failover_script, board_to_update, check_aspect)
FSW_FS_Upload(entry_size, apc_this_sec_apc_take_over_script_file_id, apc_this_sec_apc_take_over_script, board_to_update, check_aspect)
#Update the FDIR manager's config
fdir.update_configs(board_to_update)