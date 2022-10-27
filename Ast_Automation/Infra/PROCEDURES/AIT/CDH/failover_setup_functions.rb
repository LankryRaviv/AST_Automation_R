load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_FS_Upload.rb')
load_utility('Operations/FSW/FSW_Telem')
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility("Operations/FSW/FSW_CSP")
load_utility('Operations/FSW/FSW_FDIR')
load_utility('Operations/FSW/FSW_MEDIC')
load_utility('AIT/CDH/test_failover')

# TODO: Add in the DPC eventually

class FailoverSetup
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @fdir = ModuleFdir.new
    @cmd_sender = CmdSender.new
    @medic = ModuleMedic.new

    @entry_size = 186
    @fdir_script_file_id = 23
    @fdir_config_file = "#{__dir__}\\config_binary_all_fsa_disabled.bin"
    @check_aspect = "CRC"
    @target = "BW3"
    @secondary_board_failover_fmc = 120 # Failure Mode CDH_045
    @fdir_script_file_name = "#{__dir__}\\medic_failover_secondary_board_script.txt"
    @alloted_failover_time = 7
    @realtime_destination = 'COSMOS_DPC'

    @apcs =  {apc_yp: "APC_YP", apc_ym: "APC_YM"}

    @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

    @medic_task_tlm_pkts = [
      {yp_board: "APC_YP", ym_board: "APC_YM", pkt_name: "MEDIC_LEADER_TLM", sid: "MEDIC", tid: "NORMAL"},
      {yp_board: "FC_YP",  ym_board: "FC_YM", pkt_name: "MEDIC_FOLLOWER_TLM_FC", sid: "MEDIC", tid: "NORMAL"}]

    @yp_fsw_collectors = [
      {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}]

    @ym_fsw_collectors = [
      {board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}]

    @file_ids = {
        fdir_script_file_id: 23,
        config_file_main: 4103,
        config_file_main_backup: 4104,
        config_file_fallback: 4105,
        config_file_fallback_backup: 4106
    }

    super()
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def setup_yp_as_primary(realtime_destination)
    puts "Setting up stacks to have yp as primary"
    @medic_task_tlm_pkts.each do | collector |
      @module_telem.set_realtime(collector[:yp_board], collector[:pkt_name], realtime_destination, 1)
    end
    # Set up both APC's such that APC_YP = primary, APC_YM = secondary, both master_enables = enabled
    # Step 1 - First setup the other stack to be in secondary
    @medic.set_stack_state("APC_YM", @medic_enums[:secondary_state]);
    @medic.set_me_ok_enable("APC_YM", @medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 2 - Check the Medic Leader telemetry are admissible values before setting this stack to primary
    puts "Verifying the other APC's Medic task is configured to a safe state"
    full_pkt_name = CmdSender.get_full_pkt_name("APC_YP", 'MEDIC_LEADER_TLM')
    check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
    check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY'")

    # Step 3 - Set this stack's state to primary
    @medic.set_stack_state("APC_YP", @medic_enums[:primary_state]);
    @medic.set_me_ok_enable("APC_YP", @medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 4 - Verify medic has the correct telem values
    @medic_task_tlm_pkts.each do | collector |
        # Check the values were set within the medic tasks of the APC and FC
        puts "Checking #{collector[:yp_board]} #{collector[:sid]} telemetry"
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:yp_board], collector[:pkt_name])
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YP'")
        if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
            check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== ENABLED")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== RELIABLE")
            check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
            check(@target, full_pkt_name, "MEDIC_SECONDARY_PKTS_RECEIVED", "> 0")
            check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'PRESENT'")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YM")
            check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED")
        end
    end
  end


# This function assumes that it will be run from a COSMOS instance linked to stack YP
def setup_ym_as_primary(realtime_destination)
    puts "Setting up stacks to have ym as primary"
    @medic_task_tlm_pkts.each do | collector |
      @module_telem.set_realtime(collector[:yp_board], collector[:pkt_name], realtime_destination, 1)
    end
    # Set up both APC's such that APC_YP = secondary, APC_YM = primary, both master_enables = enabled
    # Step 1 - First setup the this stack to be in secondary
    @medic.set_stack_state("APC_YP", @medic_enums[:secondary_state]);
    @medic.set_me_ok_enable("APC_YP", @medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 2 - Check the Medic Leader telemetry are admissible values before setting the other stack to primary
    puts "Verifying APC YM's Medic task is configured to a safe state"
    @medic_task_tlm_pkts.each do | collector |
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:yp_board], collector[:pkt_name])
        # Check the Medic Leader telemetry are admissible values
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YP'")
        if (collector[:yp_board] == "APC_YP") || (collector[:sid] == "APC_YM")
        check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
        end
    end

    # Step 3 - Set the other stack's state to primary
    @medic.set_stack_state("APC_YM", @medic_enums[:primary_state]);
    @medic.set_me_ok_enable("APC_YM", @medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 4 - Verify medic has the correct telem values
    @medic_task_tlm_pkts.each do | collector |
        # Check the values were set within the medic tasks of the APC and FC
        puts "Checking #{collector[:yp_board]} #{collector[:sid]} telemetry"
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:yp_board], collector[:pkt_name])
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YP'")
        if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
            check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== ENABLED")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== RELIABLE")
            check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'ENABLED'")
            check(@target, full_pkt_name, "MEDIC_PRIMARY_PKTS_RECEIVED", "> 0")
            check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'PRESENT'")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'PRIMARY")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YM")
            check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED")
        end
    end
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  # This function sets up the fdir diagnostics and failsafe response scripts for APC_YP
  def setup_yp_fdir
    # Upload the fdir script to this APC (since this will be the one monitoring the meOk line and taking over the primary stack status)
    # Clear the file that will contain the failsafe response script file and wait for operation to be completed
    @module_fs.file_clear("APC_YP", @fdir_script_file_id)
    file_status = @module_fs.wait_for_file_ok("APC_YP", @fdir_script_file_id, 30)
    # Check for nil first
    if file_status == nil
      check_expression("false")
    end
    check_expression("#{file_status} != ''")
    check_expression("#{file_status} == 55")
    # Upload the failsafe response script file to the board's file system
    FSW_FS_Upload(@entry_size, @fdir_script_file_id, @fdir_script_file_name, "APC_YP", @check_aspect)
    # Uploading all configs to board's Config Service from the binary file
    @fdir.upload_num_config_rows("APC_YP", @fdir_config_file)
    @fdir.upload_configs("APC_YP", @fdir_config_file)
    # Unlock and save the active configs to main
    @cmd_sender.send("APC_YP", 'FSW_UNLOCK_CONFIG_SAVING', {})
    @cmd_sender.send("APC_YP", "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})
    # Update the FDIR manager's configurations
    full_pkt_name = CmdSender.get_full_pkt_name("APC_YP", "FSW_STARTUP_TLM_APC")
    current_recv = tlm(@target, full_pkt_name, "RECEIVED_COUNT")
    @fdir.update_configs("APC_YP")
    # Unlock and save the active configs to main
    @cmd_sender.send("APC_YP", 'FSW_UNLOCK_CONFIG_SAVING', {})
    @cmd_sender.send("APC_YP", "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})
    @cmd_sender.send("FC_YP", 'FSW_UNLOCK_CONFIG_SAVING', {})
    @cmd_sender.send("FC_YP", "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YM
  # This function sets up the fdir diagnostics and failsafe response scripts for APC_YM
  def setup_ym_fdir
    # Upload the fdir script to the other APC (since this will be the one monitoring the meOk line and taking over the primary stack status)
    # Clear the file that will contain the failsafe response script file and wait for operation to be completed
    @module_fs.file_clear("APC_YM", @fdir_script_file_id)
    file_status = @module_fs.wait_for_file_ok("APC_YM", @fdir_script_file_id, 30)
    # Check for nil first
    if file_status == nil
      check_expression("false")
    end
    check_expression("#{file_status} != ''")
    check_expression("#{file_status} == 55")
    # Upload the failsafe response script file to the board's file system
    FSW_FS_Upload(@entry_size, @fdir_script_file_id, @fdir_script_file_name, "APC_YM", @check_aspect)
    # Uploading all configs to board's Config Service from the binary file
    @fdir.upload_num_config_rows("APC_YM", @fdir_config_file)
    @fdir.upload_configs("APC_YM", @fdir_config_file)
    # Unlock and save the active configs to main
    @cmd_sender.send("APC_YM", 'FSW_UNLOCK_CONFIG_SAVING', {})
    @cmd_sender.send("APC_YM", "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})
    # Update the FDIR manager's configurations
    full_pkt_name = CmdSender.get_full_pkt_name("APC_YM", "FSW_STARTUP_TLM_APC")
    current_recv = tlm(@target, full_pkt_name, "RECEIVED_COUNT")
    @fdir.update_configs("APC_YM")
    # Unlock and save the active configs to main
    @cmd_sender.send("APC_YM", 'FSW_UNLOCK_CONFIG_SAVING', {})
    @cmd_sender.send("APC_YM", "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})
    @cmd_sender.send("FC_YM", 'FSW_UNLOCK_CONFIG_SAVING', {})
    @cmd_sender.send("FC_YM", "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})
  end

  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def clear_yp_files
    # Clear the files that store the configs
    @module_fs.file_clear("APC_YP", @file_ids[:config_file_main])
    @module_fs.file_clear("APC_YP", @file_ids[:config_file_main_backup])
    @module_fs.file_clear("APC_YP", @file_ids[:config_file_fallback])
    @module_fs.file_clear("APC_YP", @file_ids[:config_file_fallback_backup])
  end

  # This function assumes that it will be run from a COSMOS instance linked to stack YM
  # This function assumes that it will be run from a COSMOS instance linked to stack YM
  def clear_ym_files
    # Clear the files that store the configs
    @module_fs.file_clear("APC_YM", @file_ids[:config_file_main])
    @module_fs.file_clear("APC_YM", @file_ids[:config_file_main_backup])
    @module_fs.file_clear("APC_YM", @file_ids[:config_file_fallback])
    @module_fs.file_clear("APC_YM", @file_ids[:config_file_fallback_backup])
  end

  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def power_APC_YP_on
    message_box("Open an instance on NanoMCS connected to LVC_YP and send the following command: 'output 4 1 0'. When finished, verify that the command has been sent by selecting Finished", 'Finished') 
    #@medic.set_lvc_output('APC_YP', 'APC_FC', 'ON') comment this back in once the apc's lvc driver is up to date with the most recent lvc firmware
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def power_APC_YP_off
    message_box("Open an instance on NanoMCS connected to LVC_YP and send the following command: 'output 4 0 0'. When finished, verify that the command has been sent by selecting Finished", 'Finished') 
    #@medic.set_lvc_output('APC_YP', 'APC_FC', 'OFF') comment this back in once the apc's lvc driver is up to date with the most recent lvc firmware
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YM
  def power_APC_YM_on
    message_box("Open an instance on NanoMCS connected to LVC_YM and send the following command: 'output 4 1 0'. When finished, verify that the command has been sent by selecting Finished", 'Finished') 
    #@medic.set_lvc_output('APC_YM', 'APC_FC', 'ON') comment this back in once the apc's lvc driver is up to date with the most recent lvc firmware
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YM
  def power_APC_YM_off
    message_box("Open an instance on NanoMCS connected to LVC_YM and send the following command: 'output 4 0 0'. When finished, verify that the command has been sent by selecting Finished", 'Finished') 
    #@medic.set_lvc_output('APC_YM', 'APC_FC', 'OFF') comment this back in once the apc's lvc driver is up to date with the most recent lvc firmware
  end


  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end


end