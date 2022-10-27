load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_Telem.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
load("Operations/FSW/FSW_CSP.rb")
load('Operations/FSW/FSW_FDIR.rb')
load('Operations/FSW/FSW_MEDIC.rb')

def setup_stacks(task_collectors, medic_instance, apc_list, target)
  medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}
  puts "Running setup_stacks"
  # Set up both APC's such that APC_YP = primary, APC_YM = secondary, both master_enables = enabled, both modes = 0
  # Step 1 - First setup the other stack to be in secondary
  medic_instance.set_stack_state(apc_list[:other_apc], medic_enums[:secondary_state]);
  medic_instance.set_me_ok_enable(apc_list[:other_apc], medic_enums[:me_ok_enabled]);
  wait(7)

  # Step 2 - Check the Medic Leader telemetry are admissible values before setting this stack to primary
  puts "Verifying the other APC's Medic task is configured to a safe state"
  full_pkt_name = CmdSender.get_full_pkt_name(apc_list[:this_apc], 'MEDIC_LEADER_TLM')
  check(target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
  check(target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY'")

  # Step 3 - Set this stack's state to primary
  medic_instance.set_stack_state(apc_list[:this_apc], medic_enums[:primary_state]);
  medic_instance.set_me_ok_enable(apc_list[:this_apc], medic_enums[:me_ok_enabled]);
  wait(7)

  # Step 4 - Check all Medic Leader telemetry values are admissible
  task_collectors.each do | collector |  
    puts "Verifying that this stacks Medic telemetry has admissible values"
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    # Check the Medic Leader telemetry are admissible values
    check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
    check(target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{collector[:location]}'")
    if (collector[:board] == apc_list[:this_apc]) || (collector[:sid] == apc_list[:other_apc])
      check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
    end
  end
end

def medic_check_fsw_tlm_status(fsw_collectors, tlm_mod_instance, realtime_dest)
  fsw_collectors.each do | collector |
    # Step 1 - Turn on live telem
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
    puts "Checking #{collector[:sid]} fsw telemetry"
    # Step 2 - Check the Medic Leader/Follower task init status is GENERAL_OK
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    puts "Checking #{collector[:sid]} task initialization"
    check("BW3", full_pkt_name, "#{collector[:task_name]}_INIT_STATUS", "== 'GENERAL_OK'")
    # Step 4 - Check there are no errors in the Medic Leader/Follower task
    puts "Checking #{collector[:sid]} fsw telemetry errors"
    check("BW3", full_pkt_name, "#{collector[:task_name]}_ERR_COUNTER", "== 0")
  end
end

def medic_check_task_tlm_status(task_collectors, tlm_mod_instance, medic_instance, apc_list, target, realtime_dest)
  # Step 0 - Turn on live telem
  task_collectors.each do | collector |
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
  end

  # Step 1 - Call the setup_stacks function to set up both APC's such that APC_YP = primary, APC_YM = secondary,
  # both master_enables = enabled
  setup_stacks(task_collectors, medic_instance, apc_list, target)

  # Check all the other telem that isn't checked by the setup_stacks function
  task_collectors.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    check(target, full_pkt_name, "MEDIC_SAVE_CONFIGS_ERROR", "== 'GENERAL_OK'")
    if (collector[:board] == apc_list[:this_apc]) || (collector[:sid] == apc_list[:other_apc])
      check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
      check(target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== 'ENABLED'")
      check(target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== 'RELIABLE'")
      check(target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
      check(target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY'")
      check(target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED'")
    end
  end
end

def medic_check_config_persistence(task_collectors, tlm_instance, medic_instance, csp_instance, apc_list, target, realtime_dest)
    medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}
    # Step 0 - Turn on live telem
    task_collectors.each do | collector |
      tlm_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
    end

    # Step 1 - Set up both APC's such that APC_YP = primary, APC_YM = secondary, both master_enables = enabled
    setup_stacks(task_collectors, medic_instance, apc_list, target)

    # Step 2 - Set the Sc Config and Stack State of this APC to 1 and secondary, then set the meOkEnable to disable
    medic_instance.set_stack_state(apc_list[:this_apc], medic_enums[:secondary_state]);
    medic_instance.set_me_ok_enable(apc_list[:this_apc], medic_enums[:me_ok_disabled]);
    wait(2)

    task_collectors.each do | collector |
      # Step 3 - Check the values were set within the medic tasks of the APC and FC
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
      check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
      if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
        check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'DISABLED'")
      end
      # Step 4 - Reboot the APC and FC
      csp_instance.reboot("#{collector[:board]}")
      wait(7)
      tlm_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
      # Step 5 - Checking persistence of the Medic telemetry (since it should save on change automatically after it is updated)
      puts "Checking persistence of the medic #{collector[:board]} #{collector[:sid]} telemetry"
      check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
      # Step 6 - Check there are no issues with the saving of configs
      check(target, full_pkt_name, "MEDIC_SAVE_CONFIGS_ERROR", "== 'GENERAL_OK'")
    end

    # Reset both APC's so they have initial values for medic task telem
    setup_stacks(task_collectors, medic_instance, apc_list, target)
end

def medic_follower_check_send_command(task_collectors, tlm_instance, medic_instance, realtime_dest, apc_list, fc_list, target)
  medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}
  # Step 0 - Turn on live telem
  task_collectors.each do | collector |
    tlm_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
  end

  # Step 1 - Set up both APC's such that APC_YP = primary, APC_YM = secondary, both master_enables = enabled
  setup_stacks(task_collectors, medic_instance, apc_list, target)

  # Step 2 - Tell the FC to send a command to the APC to change each of the Stack State, Sc Config, and MeOkEnable task telem points
  medic_instance.send_set_stack_state_cmd(fc_list[:this_fc], medic_enums[:secondary_state])
  medic_instance.send_set_me_ok_enable_cmd(fc_list[:this_fc], medic_enums[:me_ok_disabled])
  wait(7)

  task_collectors.each do | collector |
    # Step 3 - Check the values were set within the medic tasks of the APC and FC
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
    if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
      check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'DISABLED'")
    end
  end

  # Set both APC's so they have initial values for medic task telem
  setup_stacks(task_collectors, medic_instance, apc_list, target)
end

def medic_check_board2board_comm(task_collectors, tlm_instance, medic_instance, cmd_sender, apc_list, fc_list, realtime_dest, target)
  medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}
  # Step 0 - Turn on live telem
  task_collectors.each do | collector |
    tlm_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
  end

  # Set up both APC's such that APC_YP = secondary, APC_YM = primary, both master_enables = enabled
  # Step 1 - First setup this stack to be in secondary
  medic_instance.set_stack_state(apc_list[:this_apc], medic_enums[:secondary_state]);
  medic_instance.set_me_ok_enable(apc_list[:this_apc], medic_enums[:me_ok_enabled]);
  wait(7)

  # Step 2 - Check the Medic Leader telemetry are admissible values before setting this stack to primary
  puts "Verifying that this stacks Medic task is configured to a safe state"
  task_collectors.each do | collector |
    # Check the values were set within the medic tasks of the APC and FC
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
    if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
      check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
    end
  end

  # Step 3 - Set the other stack's state to primary
  medic_instance.set_stack_state(apc_list[:other_apc], medic_enums[:primary_state]);
  medic_instance.set_me_ok_enable(apc_list[:other_apc], medic_enums[:me_ok_enabled]);
  wait(7)

  # Step 4 - Check all Medic Leader telemetry values are admissible
  task_collectors.each do | collector |
    # Step 4.1 - Check the Medic telemetry
    puts "Checking #{collector[:board]} #{collector[:sid]} telemetry"
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    # Step 4.2 - Check the Medic Leader telemetry are admissible values
    check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
    check(target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{collector[:location]}'")
    check(target, full_pkt_name, "MEDIC_SAVE_CONFIGS_ERROR", "== 'GENERAL_OK'")
    if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
      check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
      check(target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== 'ENABLED")
      check(target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== 'RELIABLE'")
      check(target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'ENABLED'")
      check(target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'PRIMARY'")
      check(target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED'")
    end
  end

  # Switch the primary CP (twice to put it back to normal) to trigger the other APC to send us its packet
  apc_primary_pkts_received = cmd_sender.get_current_val(apc_list[:this_apc], "MEDIC_LEADER_TLM", "MEDIC_PRIMARY_PKTS_RECEIVED")
  fc_apc_pkts_received = cmd_sender.get_current_val(fc_list[:this_fc], "MEDIC_FOLLOWER_TLM_FC", "MEDIC_APC_PKTS_RECEIVED")

  payload_cmd_name = "CPBF_SET_PRIMARY"
  cmd_params = {
    "CPBF_ID": 0,
  }
  payload_cmd_params = {
  }
  payload_no_hazardous_check = false
  cmd_sender.send(apc_list[:other_apc], payload_cmd_name, payload_cmd_params, no_hazardous_check)

  wait(1)
  cmd_params = {
    "CPBF_ID": 1,
  }
  cmd_sender.send(apc_list[:other_apc], payload_cmd_name, payload_cmd_params, no_hazardous_check)

  wait(1)
  cmd_params = {
    "CPBF_ID": 0,
  }
  cmd_sender.send(apc_list[:other_apc], payload_cmd_name, payload_cmd_params, no_hazardous_check)

  wait(2)
  # Step 6 - Check this APC and this FC received packets
  check(target, "APC_YP-MEDIC_LEADER_TLM", "RECEIVED_COUNT", "> #{apc_primary_pkts_received  + 3}")
  check(target, "FC_YP-MEDIC_FOLLOWER_TLM_FC", "RECEIVED_COUNT", "> #{fc_apc_pkts_received + 3}")
  wait(6)

  # Step 7 - Wait for the APC to send the periodic packet (sent every 5 seconds, so wait an additional 1 second for it to be received on the other APC and the FC)
  apc_primary_pkts_received = cmd_sender.get_current_val(apc_list[:this_apc], "MEDIC_LEADER_TLM", "MEDIC_PRIMARY_PKTS_RECEIVED")
  fc_apc_pkts_received = cmd_sender.get_current_val(fc_list[:this_fc], "MEDIC_FOLLOWER_TLM_FC", "MEDIC_APC_PKTS_RECEIVED")
  wait(6)

  # Step 8 - Check this APC and this FC received packets
  check(target, "APC_YP-MEDIC_LEADER_TLM", "RECEIVED_COUNT", "> #{apc_primary_pkts_received  + 1}")
  check(target, "FC_YP-MEDIC_FOLLOWER_TLM_FC", "RECEIVED_COUNT", "> #{fc_apc_pkts_received + 1}")

  # Set both APC's so they have initial values for medic task telem
  setup_stacks(task_collectors, medic_instance, apc_list, target)
end

def medic_check_ypym_failover(task_collectors, cmd_sender, medic_instance, tlm_instance, csp_instance, fs_instance, fdir_instance, apc_list, target, realtime_dest, check_aspect, entry_sz, allotted_failover_time, fdir_script_fid, fdir_script_name, fdir_config_file, secondary_board_failover_fmc)
    medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

    # Step 0 - Turn on live telem
    task_collectors.each do | collector |
      tlm_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
    end

    # Set up both APC's such that APC_YP = secondary, APC_YM = primary, both master_enables = enabled
    # Step 1 - First setup the other stack to be in secondary
    medic_instance.set_stack_state(apc_list[:this_apc], medic_enums[:secondary_state]);
    medic_instance.set_me_ok_enable(apc_list[:this_apc], medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 2 - Check the Medic Leader telemetry are admissible values before setting this stack to primary
    puts "Verifying that this stacks Medic task is configured to a safe state"
    task_collectors.each do | collector |
      # Check the values were set within the medic tasks of the APC and FC
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
      check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
      if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
        check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
      end
    end

    # Step 3 - Set the other stack's state to primary
    medic_instance.set_stack_state(apc_list[:other_apc], medic_enums[:primary_state]);
    medic_instance.set_me_ok_enable(apc_list[:other_apc], medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 4 - Check all Medic Leader telemetry values are admissible
    task_collectors.each do | collector |
      # Step 4.1 - Check the Medic telemetry
      puts "Checking #{collector[:board]} #{collector[:sid]} telemetry"
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
      # Step 4.2 - Check the Medic Leader telemetry are admissible values
      check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
      check(target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{collector[:location]}'")
      check(target, full_pkt_name, "MEDIC_SAVE_CONFIGS_ERROR", "== 'GENERAL_OK'")
      if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
        check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
        check(target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== 'ENABLED")
        check(target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== 'RELIABLE'")
        check(target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'ENABLED'")
        check(target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'PRIMARY'")
        check(target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED'")
      end
    end

    # Step 5 - Setup fdir
    # Upload the fdir script to this APC (since this will be the one monitoring the meOk line and taking over the primary stack status)
    # Clear the file that will contain the failsafe response script file and wait for operation to be completed
    fs_instance.file_clear(apc_list[:this_apc], fdir_script_fid)
    file_status = fs_instance.wait_for_file_ok(apc_list[:this_apc], fdir_script_fid, 30)
    # Check for nil first
    if file_status == nil
      check_expression("false")
    end
    check_expression("#{file_status} != ''")
    check_expression("#{file_status} == 55")
    # Upload the failsafe response script file to the board's file system
    FSW_FS_Upload(entry_sz, fdir_script_fid, fdir_script_name, apc_list[:this_apc], check_aspect)
    # Uploading all configs to board's Config Service from the binary file
    fdir_instance.upload_num_config_rows(apc_list[:this_apc], fdir_config_file)
    fdir_instance.upload_configs(apc_list[:this_apc], fdir_config_file)
    # Unlock and save the active configs to main
    cmd_sender.send(apc_list[:this_apc], 'FSW_UNLOCK_CONFIG_SAVING', {})
    cmd_sender.send(apc_list[:this_apc], "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})
    # Update the FDIR manager's configurations
    full_pkt_name = CmdSender.get_full_pkt_name(apc_list[:this_apc], "FSW_STARTUP_TLM_APC")
    current_recv = tlm(target, full_pkt_name, "RECEIVED_COUNT")
    fdir_instance.update_configs(apc_list[:this_apc])
    # Enable the fdir FMC
    fdir_instance.enable_diag(apc_list[:this_apc], secondary_board_failover_fmc)
    fdir_instance.enable_failsafe_resp(apc_list[:this_apc], secondary_board_failover_fmc)

    # Step 6 - Simulate a component failure by acting as fdir and sending the other APC the command to failover to secondary
    abort("failover_to_secondary command no longer exists -- this script must me modified due to failover method changes")


    # Step 7 - Wait for the fdir fault code to trigger and cause the fdir task to run the fail safe respone script, setting this stack's state to primary
    wait(alloted_failover_time)

    # Step 8 - Verify the current stack took over as primary and has the correct telem values
    task_collectors.each do | collector |
      # Step 7.1 - Check the Medic telemetry
      puts "Checking #{collector[:board]} #{collector[:sid]} telemetry"
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
      # Step 7.2 - Check the Medic Leader telemetry are the correct values
      check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
      if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
        check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
        check(target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== 'DISABLED")
        check(target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== 'RELIABLE'")
        check(target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
        check(target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY'")
        check(target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'DISABLED'")
      end
    end

    # Reboot both boards to disable the fdir diganostics so it doesn't affect anything hereon after (one could also just disable the diagnostics on both boards)
    csp_instance.reboot("APC_YP")
    csp_instance.reboot("APC_YM")

    # Set both APC's so they have initial values for medic task telem
    #setup_stacks()
end