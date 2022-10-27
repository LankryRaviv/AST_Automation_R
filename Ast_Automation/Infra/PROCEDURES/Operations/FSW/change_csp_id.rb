load 'Operations/FSW/FSW_FWUPD.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'
load("Operations/FSW/FSW_CSP.rb")

cmd_sender = CmdSender.new
fwupd = ModuleFWUPD.new
module_csp = ModuleCSP.new

# Step 1 - Gather and process user input

original_board = combo_box("Select board", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "LVC_YP", "LVC_YM")
new_location = combo_box("Select new side", "YP", "YM")

if new_location == "YP"
    if original_board == "APC_YP"
        puts "Already YP"
        abort
    elsif original_board == "APC_YM"
        new_board = "APC_YP"
        config_id = 0
        new_id = 1
    elsif original_board == "FC_YP"
        puts "Already YP"
        abort
    elsif original_board == "FC_YM"
        new_board = "FC_YP"
        config_id = 0
        new_id = 3
    elsif original_board == "LVC_YP"
        puts "Already YP"
        abort
    elsif original_board == "LVC_YM"
        new_board = "LVC_YP"
        config_id = 187
        new_id = 5
    else
        abort
    end
elsif new_location == "YM"
    if original_board == "APC_YP"
        new_board = "APC_YM"
        config_id = 0
        new_id = 2
    elsif original_board == "APC_YM"
        puts "Already YM"
        abort
    elsif original_board == "FC_YP"
        new_board = "FC_YM"
        config_id = 0
        new_id = 4
    elsif original_board == "FC_YM"
        puts "Already YM"
        abort
    elsif original_board == "LVC_YP"
        new_board = "LVC_YM"
        config_id = 187
        new_id = 6
    elsif original_board == "LVC_YM"
        puts "Already YM"
        abort
    else
        abort
    end
else
    abort
end

prompt("Changing #{original_board} to #{new_board}")


# Step 2 - Confirm communication with board
module_csp.ping(original_board)

# Step 3 - Gather MCU ID and compute password
fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(original_board,true, true)
mcu_uid_1 = fwupd_version_hash_raw["MCU_UID_1"]
board_password = mcu_uid_1 ^ 0xAAAAAAAA

puts board_password

# Step 4 - Elevate access role
cmd_sender.send(original_board, 'FSW_ELEVATE_ACCESS_ROLE', {ROLE: "MANUFACTURER", PASSWORD: board_password}, true)
wait(3)

# Step 5 - Set new CSP ID
cmd_sender.send(original_board, 'FSW_SET_CONFIG_PARAMETER_U8', {ID: config_id, TYPE_ID: 0, DATA_U8: new_id})
wait(3)

# Step 6 - Unlock and save to main
cmd_sender.send(original_board, 'FSW_UNLOCK_CONFIG_SAVING', {}, true)
wait(3)
cmd_sender.send(original_board, "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {}, true)
wait(3)

# Step 7 - Unlock and save to fallback
cmd_sender.send(original_board, 'FSW_UNLOCK_CONFIG_SAVING', {}, true)
wait(3)
cmd_sender.send(original_board, "FSW_SAVE_ACTIVE_CONFIG_FALLBACK_FILE", {}, true)
wait(3)

# Step 8 - Reboot
module_csp.reboot(original_board)
wait(20) # Long wait because LVC needs to boot up, turn on channel, then APC needs to boot up

# Step 9 - Ping with new ID
module_csp.ping(new_board)