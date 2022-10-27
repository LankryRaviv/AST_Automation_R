load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/FSW_FS_Upload.rb'
load('Operations/FSW/FSW_Telem.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
load("Operations/FSW/FSW_CSP.rb")
load('Operations/FSW/FSW_FDIR.rb')
load('Operations/FSW/FSW_MEDIC.rb')

def fdir_check_fsw_tlm_status(collector_list, tlm_mod_instance, realtime_dest)
  collector_list.each do | collector |
    # Step 1 - Turn on live telem
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
    puts "Checking #{collector[:sid]} fsw telemetry"
    # Step 2 - Check the FDIR task init status is GENERAL_OK
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    puts "Checking #{collector[:sid]} task initialization" #TODO: Need to change the below to only accept a GENERAL_OK init status once the config serialization integration is complete
    check("BW3", full_pkt_name, "FDIR_INIT_STATUS", "== 'GENERAL_OK' || 'FDIR_CONFIG_INVALID' || 'FDIR_CONFIG_UNKNOWN_FAILURE_MODE_CODE' || 'FDIR_CONFIG_DUPLICATE' || 'FDIR_CONFIG_MISSING'")
    # Step 4 - Check there are no errors (optionally add this once fsw is complete)
  end
end

def fdir_check_task_tlm_status(collector_list, tlm_mod_instance, board, realtime_dest)
  collector_list.each do | collector |
    # Step 1 - Turn on live telem
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
    # Step 2 - Check the FDIR telemetry
    puts "Checking #{collector[:sid]} diag status"
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    # Step 2.1 - Check the FDIR diag statuses are either NOT_MANAGED (0), INACTIVE (1), OK (2), YELLOW (3), or RED (4).
    # and the FDIR fault info's are either NOT_RELIABLE (0), or RELIABLE (1)
    if collector[:board] == "APC_YP"
      board = "APC"
    elsif collector[:board] == "FC_YP"
      board = "FC"
    end

    numFdirDiagnostics = 458 # This needs to updated manually
    
    (0..numFdirDiagnostics-1).each do |i|
      check("BW3", full_pkt_name, "FDIR_DIAG_STATUS_#{i}", "== 'NOT_MANAGED' || 'INACTIVE' || 'OK' || 'YELLOW' || 'RED'")
    end
    # Step 3 - In the future this test can be expanded to check that all failure mode codes are running properly
  end
end

def run_demo_fault(task_collectors, medic_collectors, fsw_collectors, apcs, cmd_sender, fs_mod_instance, tlm_mod_instance, fdir_mod_instance, medic_mod_instance, realtime_dest, entry_sz, check_aspect, target, fdir_script_fid, fdir_config_file, fdir_demo_fmc, fault_trigger_time_s)
  medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

  # Turn on live telem for fdir and medic
  task_collectors.each do | collector |
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
  end

  medic_collectors.each do | collector |
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
  end

  # Set this stack stack to primary
  puts "Setting up both stacks"
  # Set up both APC's such that this APC = primary, other APC = secondary, both master_enables = enabled
  # First setup the other stack to be in secondary
  medic_mod_instance.set_stack_state(apcs[:other_apc], medic_enums[:secondary_state], true);
  medic_mod_instance.set_me_ok_enable(apcs[:other_apc], medic_enums[:me_ok_enabled], true);
  wait(7)

  # Check the Medic Leader telemetry are admissible values before setting this stack to primary
  puts "Verifying the other APC's Medic task is configured to a safe state"
  full_pkt_name = CmdSender.get_full_pkt_name(apcs[:this_apc], 'MEDIC_LEADER_TLM')
  check(target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
  check(target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY'")

  # Set this stack's state to primary
  medic_mod_instance.set_stack_state(apcs[:this_apc], medic_enums[:primary_state], true);
  medic_mod_instance.set_me_ok_enable(apcs[:this_apc], medic_enums[:me_ok_enabled], true);
  wait(10)

  # Check all Medic Leader telemetry values are admissible
  medic_collectors.each do | collector |
    puts "Verifying that this stacks Medic telemetry has admissible values"
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    # Check the Medic Leader telemetry are admissible values
    check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
    check(target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{collector[:location]}'")
    if (collector[:board] == apcs[:this_apc]) || (collector[:sid] == apcs[:other_apc])
      check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
    end
  end

  # Clear the file that will contain the failsafe response script file and wait for operation to be completed
  fsw_collectors.each do | collector |

      fs_mod_instance.file_clear(collector[:board], fdir_script_fid)
      file_status = fs_mod_instance.wait_for_file_ok(collector[:board], fdir_script_fid, 30)
      # Check for nil first
      if file_status == nil
        check_expression("false")
      end
      check_expression("#{file_status} != ''")
      check_expression("#{file_status} == 55")
      # Upload the failsafe response script file to the board's file system
      FSW_FS_Upload(entry_sz, fdir_script_fid, collector[:fdir_script_file_name], collector[:board], check_aspect)
      # Uploading all configs to board's Config Service from the binary file
  
      puts "Setting up FDIR for this stack"
      fdir_mod_instance.upload_configs(collector[:board], fdir_config_file, true)

      # Unlock and save the active configs to main
      cmd_sender.send(collector[:board], 'FSW_UNLOCK_CONFIG_SAVING', {}, true)
      wait(1)
      cmd_sender.send(collector[:board], "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {}, true)

      # Update the FDIR manager's configurations
      fdir_mod_instance.update_configs(collector[:board], true)
      # Enable the FDIR FMC
      wait(1)
      fdir_mod_instance.enable_failsafe_resp(collector[:board], fdir_demo_fmc, true)
      wait(2)
      # Clear the Diag Status so the failsafe response script is executed (since it's only executed on crossing the threshold)
      fdir_mod_instance.clear_diag_status(collector[:board], fdir_demo_fmc, true)
      wait(5)

      # Check the FDIR diagnostic status and activation
      if collector[:board] == 'APC_YP' || collector[:board] == 'APC_YM'
        full_pkt_name = CmdSender.get_full_pkt_name(task_collectors[0][:board], task_collectors[0][:pkt_name])
        check("BW3", full_pkt_name, "FDIR_DIAG_STATUS_#{fdir_demo_fmc}", "== 'RED'")
        check("BW3", full_pkt_name, "FDIR_IS_FAILSAFE_ACTIVATED_#{fdir_demo_fmc}", "== 'ACTIVE'")
      elsif collector[:board] == 'FC_YP' || collector[:board] == 'FC_YM'
        full_pkt_name = CmdSender.get_full_pkt_name(task_collectors[1][:board], task_collectors[1][:pkt_name])
        check("BW3", full_pkt_name, "FDIR_DIAG_STATUS_#{fdir_demo_fmc}", "== 'RED'")
        check("BW3", full_pkt_name, "FDIR_IS_FAILSAFE_ACTIVATED_#{fdir_demo_fmc}", "== 'ACTIVE'")
      end

      # Wait for the script to run
      wait(30)

      # Check the FDIR diagnostic status and activation
      if collector[:board] == 'APC_YP' || collector[:board] == 'APC_YM'
        full_pkt_name = CmdSender.get_full_pkt_name(task_collectors[0][:board], task_collectors[0][:pkt_name])
        check("BW3", full_pkt_name, "FDIR_DIAG_STATUS_#{fdir_demo_fmc}", "== 'INACTIVE'")
        check("BW3", full_pkt_name, "FDIR_IS_FAILSAFE_ACTIVATED_#{fdir_demo_fmc}", "== 'NOT_ACTIVE'")
      elsif collector[:board] == 'FC_YP' || collector[:board] == 'FC_YM'
        full_pkt_name = CmdSender.get_full_pkt_name(task_collectors[1][:board], task_collectors[1][:pkt_name])
        check("BW3", full_pkt_name, "FDIR_DIAG_STATUS_#{fdir_demo_fmc}", "== 'INACTIVE'")
        check("BW3", full_pkt_name, "FDIR_IS_FAILSAFE_ACTIVATED_#{fdir_demo_fmc}", "== 'NOT_ACTIVE'")
      end
  end


    # If this stack is YM, set it to secondary, otherwise leave it as primary
    if apcs[:this_apc] == "APC_YM"

      puts "Setting up both stacks"
      # Set up both APC's such that other APC = primary, this APC = secondary, both master_enables = enabled
      # First setup the other stack to be in secondary
      medic_mod_instance.set_stack_state(apcs[:this_apc], medic_enums[:secondary_state], true);
      medic_mod_instance.set_me_ok_enable(apcs[:this_apc], medic_enums[:me_ok_enabled], true);
      wait(7)

      # Check all Medic Leader telemetry values are admissible
      medic_collectors.each do | collector |
        puts "Verifying that this stacks Medic telemetry has admissible values"
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
        # Check the Medic Leader telemetry are admissible values
        check(target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
        check(target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{collector[:location]}'")
        if (collector[:board] == apcs[:this_apc]) || (collector[:sid] == apcs[:other_apc])
          check(target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
        end
      end

      # Set this stack's state to primary
      medic_mod_instance.set_stack_state(apcs[:other_apc], medic_enums[:primary_state], true);
      medic_mod_instance.set_me_ok_enable(apcs[:other_apc], medic_enums[:me_ok_enabled], true);
      wait(10)
    
      # Check the Medic Leader telemetry are admissible values before setting this stack to primary
      puts "Verifying the other APC's Medic task is configured to a safe state"
      full_pkt_name = CmdSender.get_full_pkt_name(apcs[:this_apc], 'MEDIC_LEADER_TLM')
      check(target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'ENABLED'")
      check(target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'PRIMARY'")
    end


end