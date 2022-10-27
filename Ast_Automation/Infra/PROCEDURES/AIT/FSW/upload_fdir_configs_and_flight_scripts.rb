load('Operations/FSW/FSW_FDIR.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
cmd_sender = CmdSender.new
fdir = ModuleFdir.new
entry_size = 186
check_aspect = "CRC"
fdir_config_file = "#{__dir__}\\config_binary_flight_candidate_1.bin"
apc_scripts = [{file_path: "#{__dir__}\\FDIR_scripts\\APC_scripts\\FDIR_SCRIPT_LOSS_OF_COMM_AS1_POST.txt", file_id: 90}, 
                {file_path: "#{__dir__}\\FDIR_scripts\\APC_scripts\\FDIR_SCRIPT_LOSS_OF_COMM_AS2_POST.txt", file_id: 93}, 
                {file_path: "#{__dir__}\\FDIR_scripts\\APC_scripts\\FDIR_SCRIPT_LOSS_OF_COMM_AS2_PRIOR.txt", file_id: 92}, 
                {file_path: "#{__dir__}\\FDIR_scripts\\APC_scripts\\FDIR_SCRIPT_LOSS_OF_COMM_AS2_PRIOR_ONCE.txt", file_id: 91}, 
                {file_path: "#{__dir__}\\FDIR_scripts\\APC_scripts\\FDIR_SCRIPT_LOSS_OF_COMM_AS3.txt", file_id: 94}, 
                {file_path: "#{__dir__}\\FDIR_scripts\\APC_scripts\\FDIR_SCRIPT_LOSS_OF_COMM_AS6.txt", file_id: 95}, 
                {file_path: "#{__dir__}\\FDIR_scripts\\APC_scripts\\FDIR_SCRIPT_RED_STACK_FAILOVER.txt", file_id: 2}]
fc_scripts = [{file_path: "#{__dir__}\\FDIR_scripts\\FC_scripts\\FDIR_SCRIPT_RED_AOCS_EXCL_IMU_PRIM.txt", file_id: 66}, 
                {file_path: "#{__dir__}\\FDIR_scripts\\FC_scripts\\FDIR_SCRIPT_RED_AOCS_RESET_FILTER_STIMUKF0.txt", file_id: 60}, 
                {file_path: "#{__dir__}\\FDIR_scripts\\FC_scripts\\FDIR_SCRIPT_RED_AOCS_RESET_FILTER_STIMUKF1.txt", file_id: 61}]


# ----------------- Configure the APC -----------------
apc_to_update = "APC_YP"
#Upload the scripts to apc_to_update
apc_scripts.each do | script |
    FSW_FS_Upload(entry_size, script[:file_id], script[:file_path], apc_to_update, check_aspect)
end
#Uploading all configs to apc_to_update from the binary file
#Note: You only have to run the following two lines the first time you run this script on any given board
#      due to the fact that we save the configs into NVM after we upload them in this script.
fdir.upload_num_config_rows(apc_to_update, fdir_config_file)
fdir.upload_configs(apc_to_update, fdir_config_file)
#Unlock and save the active configs to main
cmd_sender.send(apc_to_update, 'FSW_UNLOCK_CONFIG_SAVING', {}, true)
wait(1)
cmd_sender.send(apc_to_update, "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {}, true)
#Update the FDIR manager's config
fdir.update_configs(apc_to_update)


# ----------------- Configure the FC -----------------
fc_to_update = "FC_YP"
#Upload the scripts to apc_to_update
fc_scripts.each do | script |
    FSW_FS_Upload(entry_size, script[:file_id], script[:file_path], fc_to_update, check_aspect)
end
#Uploading all configs to fc_to_update from the binary file
#Note: You only have to run the following two lines the first time you run this script on any given board
#      due to the fact that we save the configs into NVM after we upload them in this script.
fdir.upload_num_config_rows(fc_to_update, fdir_config_file)
fdir.upload_configs(fc_to_update, fdir_config_file)
#Unlock and save the active configs to main
cmd_sender.send(fc_to_update, 'FSW_UNLOCK_CONFIG_SAVING', {}, true)
wait(1)
cmd_sender.send(fc_to_update, "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {}, true)
#Update the FDIR manager's config
fdir.update_configs(fc_to_update)
