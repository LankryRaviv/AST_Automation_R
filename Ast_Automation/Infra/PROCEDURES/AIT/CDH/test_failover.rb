load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_FS_Upload.rb')
load_utility('Operations/FSW/FSW_Telem')
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility("Operations/FSW/FSW_CSP")
load_utility('Operations/FSW/FSW_FDIR')
load_utility('Operations/FSW/FSW_MEDIC')

# TODO: Add in the DPC eventually

class TestFailoverCDH < ASTCOSMOSTestCDH
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @fdir = ModuleFdir.new
    @cmd_sender = CmdSender.new
    @medic = ModuleMedic.new
    @failover = FailoverSetup.new

    @entry_size = 186
    @fdir_script_file_id = 23
    @fdir_config_file = "#{__dir__}\\config_binary_all_fsa_disabled.bin"
    @check_aspect = "CRC"
    @target = "BW3"
    @secondary_board_failover_fmc = 120 # Failure Mode CDH_045
    @fdir_script_file_name = "#{__dir__}\\medic_failover_secondary_board_script.txt"
    @alloted_failover_time = 7
    @realtime_destination = 'COSMOS_UMBILICAL'

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

  def setup
    @module_csp.reboot("FC_YM")
    @module_csp.reboot("APC_YM")
    @module_csp.reboot("FC_YP")
    @module_csp.reboot("APC_YP")
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestFailover")
    end
    wait(7)
    status_bar("setup")
  end

  def setup_environment
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
  end

  # This test assumes that it will be run from a COSMOS instance linked to stack YP
  def test_a_1st_bootup_yp_to_ym_to_yp_failover_component_failure # In order to run this test, the cosmos instance must be connected to stack yp
    # Clear the files that store the configs
    @failover.clear_yp_files()
    message_box("Open another COSMOS instance for APC_YM and run test_0_clear_ym_files. When finished, verify that the test is complete by selecting Finished", 'Finished')

    # Reboot the boards and simulate a component failure and verify the nominal operation is successful
    simulate_yp_to_ym_to_yp_component_failure()
  end


  # This test assumes that it will be run from a COSMOS instance linked to stack YP
  def test_b_2nd_bootup_yp_to_ym_to_yp_component_failure # In order to run this test, the cosmos instance must be connected to stack yp
    # Reboot the boards and simulate a component failure and verify the nominal operation is successful
    simulate_yp_to_ym_to_yp_component_failure()
  end


  # This test assumes that it will be run from a COSMOS instance linked to stack YP
  def test_c_2nd_bootup_ym_to_yp_apc_board_failure # In order to run this test, the cosmos instance must be connected to stack yp
    # Reboot the boards and simulate a board failure and verify the nominal operation is successful
    simulate_ym_to_yp_apc_board_failure()
  end


  # This test assumes that it will be run from a COSMOS instance linked to stack YM
  def test_d_2nd_bootup_yp_to_ym_apc_board_failure # In order to run this test, the cosmos instance must be connected to stack yp
    # Reboot the boards and simulate a board failure and verify the nominal operation is successful
    simulate_yp_to_ym_apc_board_failure()
  end


  # This test assumes that it will be run from a COSMOS instance linked to stack YP
  def test_e_config_persistence
    # Step 0 - Turn on live telem
    @medic_task_tlm_pkts.each do | collector |
      @module_telem.set_realtime(collector[:yp_board], collector[:pkt_name], @realtime_destination, 1)
    end

    # Step 1 - Set up both APC's such that APC_YP = primary, APC_YM = secondary, both master_enables = enabled
    @failover.setup_yp_as_primary(@realtime_destination)

    # Step 2 - Set the Sc Config and Stack State of this APC to 1 and secondary, then set the meOkEnable to disable
    @medic.set_stack_state("APC_YP", @medic_enums[:secondary_state]);
    @medic.set_me_ok_enable("APC_YP", @medic_enums[:me_ok_disabled]);
    wait(2)

    @medic_task_tlm_pkts.each do | collector |
      # Step 3 - Check the values were set within the medic tasks of the APC and FC
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:yp_board], collector[:pkt_name])
      check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
      if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
        check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'DISABLED'")
      end
      # Step 4 - Reboot the APC and FC
      @module_csp.reboot("#{collector[:yp_board]}")
      wait(7)
      @module_telem.set_realtime(collector[:yp_board], collector[:pkt_name], @realtime_destination, 1)
      # Step 5 - Checking persistence of the Medic telemetry (since it should save on change automatically after it is updated)
      puts "Checking persistence of the medic #{collector[:yp_board]} #{collector[:sid]} telemetry"
      check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
      # Step 6 - Check there are no issues with the saving of configs
      check(@target, full_pkt_name, "MEDIC_SAVE_CONFIGS_ERROR", "== 'GENERAL_OK'")
    end

    # Reset both APC's so they have initial values for medic task telem
    @failover.setup_yp_as_primary(@realtime_destination)
  end


  # ********* Helper functions *********
  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def simulate_yp_to_ym_to_yp_component_failure
    # Step 1 - Reset all boards so that they either boot up and read the harness or read the stack configurations from the config files (reset APC's then FC's and DPC's)
    @medic_task_tlm_pkts.each do | collector |
      @module_csp.reboot(collector[:ym_board])
      @module_csp.reboot(collector[:yp_board])
      wait(7)
    end
    wait(10)

    # At this point, APC_YP will be primary, and APC_YM will be secondary, and the other boards will fall in line
    # Step 2 - Turn on live telem
    @medic_task_tlm_pkts.each do | collector |
      @module_telem.set_realtime(collector[:yp_board], collector[:pkt_name], @realtime_destination, 1)
    end
    wait(7)

    # Step 3 - Check the Medic Leader telemetry are admissible values
    puts "Verifying that this stacks Medic task is configured to a safe state"
    @medic_task_tlm_pkts.each do | collector |
      # Check the values were set within the medic tasks of the APC and FC
      puts "Checking #{collector[:yp_board]} #{collector[:sid]} telemetry"
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:yp_board], collector[:pkt_name])
      check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
      check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YP'")
      if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
        check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
        check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== 'ENABLED'")
        check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== 'RELIABLE'")
        check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
        check(@target, full_pkt_name, "MEDIC_SECONDARY_PKTS_RECEIVED", "> 0")
        check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'PRESENT'")
        check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY'")
        check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YM'")
        check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED'")
      end
    end

    # Now we can go into simulating a failover

    # Step 4 - Setup fdir
    puts "Setting up FDIR for this stack's APC"
    @uploadFdirDiags = combo_box("Do you wish to re-upload all fdir diagnostics?", 'YES','NO')
    if @uploadFdirDiags == 'YES'
        @failover.setup_yp_fdir()
      message_box("Open another COSMOS instance for APC_YM and run test_0_setup_ym_fdir. When finished, verify that the test is complete by selecting Finished", 'Finished')  
    end

    # For testing purposes, since the FDIR diagnostics are all disabled by default for AIT purposes, enable the failover diagnostic FMC for both boards
    @fdir.enable_diag("APC_YP", @secondary_board_failover_fmc)
    @fdir.enable_failsafe_resp("APC_YP", @secondary_board_failover_fmc)
    @fdir.enable_diag("APC_YM", @secondary_board_failover_fmc)
    @fdir.enable_failsafe_resp("APC_YM", @secondary_board_failover_fmc)

    # Step 5 - Simulate a component failure by acting as fdir and sending the this APC the command to set the stack state to secondary
    # then set the MeOkEnable to low in order to trigger the diagnostic on this APC
    puts "***********Simulating a component failure on APC YP to trigger a failover of YP to YM***********"
    abort("failover_to_secondary command no longer exists -- this script must me modified due to failover method changes")

    # Step 6 - Wait for the fdir fault code to trigger and cause the fdir task to run the fail safe respone script, setting this stack's state to primary
    wait(@alloted_failover_time)

    # Step 7 - Verify the current stack took over as primary and has the correct telem values
    @medic_task_tlm_pkts.each do | collector |
        # Check the values were set within the medic tasks of the APC and FC
        puts "Checking #{collector[:yp_board]} #{collector[:sid]} telemetry"
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:yp_board], collector[:pkt_name])
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YP'")
        if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
            check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'DISABLED'")
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

    # Step 8 - Now enable the ME OK on this APC again to tell the other APC this APC is okay
    @medic.set_me_ok_enable("APC_YP", @medic_enums[:me_ok_enabled])
    wait(7)

    # Step 9 - Now set the APC_YM state to secondary and disable the ME_OK to get it to switch over again
    puts "***********Simulating a component failure on APC YM to trigger a failover of YM to YP***********"
    abort("failover_to_secondary command no longer exists -- this script must me modified due to failover method changes")
    wait(@alloted_failover_time)

    # Step 10 - Verify medic has the correct telem values
    @medic_task_tlm_pkts.each do | collector |
        # Check the values were set within the medic tasks of the APC and FC
        puts "Checking #{collector[:yp_board]} #{collector[:sid]} telemetry"
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:yp_board], collector[:pkt_name])
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YP'")
        if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
            check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== DISABLED")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== RELIABLE")
            check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
            check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'PRESENT'")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YM")
            check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'DISABLED")
        end
    end

    # Reboot both boards to disable the fdir diganostics so it doesn't affect anything hereon after (one could also just disable the diagnostics on both boards)
    @module_csp.reboot("APC_YM")
    @module_csp.reboot("APC_YP")
    wait(7)

    @failover.setup_yp_as_primary(@realtime_destination)
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def simulate_ym_to_yp_apc_board_failure
    # Step 1 - Reset all boards so that they either boot up and read the harness or read the stack configurations from the config files (reset APC's then FC's and DPC's)
    @medic_task_tlm_pkts.each do | collector |
      @module_csp.reboot(collector[:ym_board])
      @module_csp.reboot(collector[:yp_board])
      wait(7)
    end
    wait(10)

    # Step 3 - Setup both stacks such that APC_YM is primary and APC_YP is secondary, and both me_ok's are enabled
    @medic.set_stack_state("APC_YP", @medic_enums[:secondary_state]);
    @medic.set_me_ok_enable("APC_YP", @medic_enums[:me_ok_enabled]);
    
    @medic.set_stack_state("APC_YM", @medic_enums[:primary_state]);
    @medic.set_me_ok_enable("APC_YM", @medic_enums[:me_ok_enabled]);

    # At this point, APC_YP will be primary, and APC_YM will be secondary, and the other boards will fall in line
    # Step 2 - Turn on live telem
    @medic_task_tlm_pkts.each do | collector |
      @module_telem.set_realtime(collector[:yp_board], collector[:pkt_name], @realtime_destination, 1)
    end
    wait(7)

    # Step 3 - Check the Medic Leader telemetry are admissible values
    puts "Verifying that this stacks Medic task is configured to a safe state"
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

    # Step 4 - Setup fdir
    puts "Setting up FDIR for this stack's APC"
    @uploadFdirDiags = combo_box("Do you wish to re-upload all fdir diagnostics?", 'YES','NO')
    if @uploadFdirDiags == 'YES'
      setup_yp_fdir()
      message_box("Open another COSMOS instance for APC_YM and run test_0_setup_ym_fdir. When finished, verify that the test is complete by selecting Finished", 'Finished')  
    end

    # For testing purposes, since the FDIR diagnostics are all disabled by default for AIT purposes, enable the failover diagnostic FMC for both boards
    @fdir.enable_diag("APC_YP", @secondary_board_failover_fmc)
    @fdir.enable_failsafe_resp("APC_YP", @secondary_board_failover_fmc)
    @fdir.enable_diag("APC_YM", @secondary_board_failover_fmc)
    @fdir.enable_failsafe_resp("APC_YM", @secondary_board_failover_fmc)

    # Step 5 - Simulate an apc failure on APC_YM by turning off the LVC output to cut power to the APC_YM
    puts "***********Simulating a board failure on APC YM to trigger a failover of YM to YP***********"
    @failover.power_APC_YM_off()

    # Step 6 - Wait for the fdir fault code to trigger and cause the fdir task to run the fail safe respone script, setting this stack's state to primary
    wait(@alloted_failover_time)

    # Step 7 - Verify the current stack took over as primary and has the correct telem values
    @medic_task_tlm_pkts.each do | collector |
        # Check the values were set within the medic tasks of the APC and FC
        puts "Checking #{collector[:yp_board]} #{collector[:sid]} telemetry"
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:yp_board], collector[:pkt_name])
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YP'")
        if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
            check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== DISABLED")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== UNRELIABLE")
            check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
            check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'NOT_PRESENT'")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'PRIMARY")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YM")
            check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED")
        end
    end
    wait(7)

    # Note: When the other APC boots back up, it will try to boot up as primary since that's what was last in the config file, but it will detect
    # that APC_YP has it's MASTER_ENABLE on, so it will demote itself to secondary and save that as the current configuration

    # Step 8 - Now turn APC_YM back on again and verify its stack boots up as secondary
    message_box("Open another COSMOS instance for APC_YM and run test_0_power_APC_YM_on. When finished, verify that the test is complete by selecting Finished", 'Finished')

    # Step 9 - Wait for the APC to boot back up
    wait(10)

    # Step 10 - Verify medic has the correct telem values
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
          check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'NOT_PRESENT'")
          check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY")
          check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YM")
          check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED")
      end
    end

    @failover.setup_yp_as_primary(@realtime_destination)
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YM
  def simulate_yp_to_ym_apc_board_failure
    # Step 1 - Reset all boards so that they either boot up and read the harness or read the stack configurations from the config files (reset APC's then FC's and DPC's)
    @medic_task_tlm_pkts.each do | collector |
      @module_csp.reboot(collector[:ym_board])
      @module_csp.reboot(collector[:yp_board])
      wait(7)
    end
    wait(10)

    # Step 3 - Setup both stacks such that APC_YP is primary and APC_YM is secondary, and both me_ok's are enabled
    @medic.set_stack_state("APC_YP", @medic_enums[:primary_state]);
    @medic.set_me_ok_enable("APC_YP", @medic_enums[:me_ok_enabled]);
        
    @medic.set_stack_state("APC_YM", @medic_enums[:secondary_state]);
    @medic.set_me_ok_enable("APC_YM", @medic_enums[:me_ok_enabled]);

    # At this point, APC_YP will be primary, and APC_YM will be secondary, and the other boards will fall in line
    # Step 2 - Turn on live telem
    @medic_task_tlm_pkts.each do | collector |
      @module_telem.set_realtime(collector[:ym_board], collector[:pkt_name], @realtime_destination, 1)
    end

    wait(7)

    # Step 3 - Check the Medic Leader telemetry are admissible values
    puts "Verifying that this stacks Medic task is configured to a safe state"
    @medic_task_tlm_pkts.each do | collector |
      # Check the values were set within the medic tasks of the APC and FC
      puts "Checking #{collector[:ym_board]} #{collector[:sid]} telemetry"
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:ym_board], collector[:pkt_name])
      check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
      check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YM'")
      if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
        check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
        check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== ENABLED")
        check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== RELIABLE")
        check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'ENABLED'")
        check(@target, full_pkt_name, "MEDIC_PRIMARY_PKTS_RECEIVED", "> 0")
        check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'PRESENT'")
        check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'PRIMARY")
        check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YP")
        check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED")
      end
    end

    # Step 4 - Setup fdir
    puts "Setting up FDIR for this stack's APC"
    @uploadFdirDiags = combo_box("Do you wish to re-upload all fdir diagnostics?", 'YES','NO')
    if @uploadFdirDiags == 'YES'
        @failover.setup_ym_fdir()
        message_box("Open another COSMOS instance for APC_YM and run test_0_setup_yp_fdir. When finished, verify that the test is complete by selecting Finished", 'Finished')  
    end

    # For testing purposes, since the FDIR diagnostics are all disabled by default for AIT purposes, enable the failover diagnostic FMC for both boards
    @fdir.enable_diag("APC_YP", @secondary_board_failover_fmc)
    @fdir.enable_failsafe_resp("APC_YP", @secondary_board_failover_fmc)
    @fdir.enable_diag("APC_YM", @secondary_board_failover_fmc)
    @fdir.enable_failsafe_resp("APC_YM", @secondary_board_failover_fmc)

    # Step 5 - Simulate an apc failure on APC_YP by turning off the LVC output to cut power to the APC_YP
    puts "***********Simulating a board failure on APC YP to trigger a failover of YP to YM***********"
    @failover.power_APC_YP_off()

    # Step 6 - Wait for the fdir fault code to trigger and cause the fdir task to run the fail safe respone script, setting this stack's state to primary
    wait(@alloted_failover_time)

    # Step 7 - Verify the current stack took over as primary and has the correct telem values
    @medic_task_tlm_pkts.each do | collector |
        # Check the values were set within the medic tasks of the APC and FC
        puts "Checking #{collector[:ym_board]} #{collector[:sid]} telemetry"
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:ym_board], collector[:pkt_name])
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YM'")
        if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
            check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== DISABLED")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== UNRELIABLE")
            check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
            check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'NOT_PRESENT'")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'PRIMARY")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YP")
            check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED")
        end
    end
    wait(7)

    # Note: When the other APC boots back up, it will try to boot up as primary since that's what was last in the config file, but it will detect
    # that APC_YM has it's MASTER_ENABLE on, so it will demote itself to secondary and save that as the current configuration

    # Step 8 - Now turn APC_YM back on again and verify its stack boots up as secondary
    message_box("Open another COSMOS instance for APC_YM and run test_0_power_APC_YP_on. When finished, verify that the test is complete by selecting Finished", 'Finished')

    # Step 9 - Wait for the APC to boot back up
    wait(10)

    # Step 10 - Verify medic has the correct telem values
    @medic_task_tlm_pkts.each do | collector |
      # Check the values were set within the medic tasks of the APC and FC
      puts "Checking #{collector[:ym_board]} #{collector[:sid]} telemetry"
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:ym_board], collector[:pkt_name])
      check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
      check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YM'")
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

    # Setup Yp as primary (from a YM cosmos instance)

    puts "Setting up stacks to have yp as primary"
    # Set up both APC's such that APC_YP = primary, APC_YM = secondary, both master_enables = enabled
    # Step 1 - First setup the other stack to be in secondary
    @medic.set_stack_state("APC_YM", @medic_enums[:secondary_state]);
    @medic.set_me_ok_enable("APC_YM", @medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 2 - Check the Medic Leader telemetry are admissible values before setting this stack to primary
    puts "Verifying the other APC's Medic task is configured to a safe state"
    full_pkt_name = CmdSender.get_full_pkt_name("APC_YM", 'MEDIC_LEADER_TLM')
    check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
    check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YM'")

    # Step 3 - Set this stack's state to primary
    @medic.set_stack_state("APC_YP", @medic_enums[:primary_state]);
    @medic.set_me_ok_enable("APC_YP", @medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 4 - Verify medic has the correct telem values
    @medic_task_tlm_pkts.each do | collector |
        # Check the values were set within the medic tasks of the APC and FC
        puts "Checking #{collector[:ym_board]} #{collector[:sid]} telemetry"
        full_pkt_name = CmdSender.get_full_pkt_name(collector[:ym_board], collector[:pkt_name])
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'SECONDARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== 'YM'")
        if (collector[:sid] == 'APC_YP') || (collector[:sid] == 'APC_YM')
            check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE", "== ENABLED")
            check(@target, full_pkt_name, "MEDIC_AVG_OTHER_ME_OK_ENABLE_RELIABLE", "== RELIABLE")
            check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'ENABLED'")
            check(@target, full_pkt_name, "MEDIC_PRIMARY_PKTS_RECEIVED", " > 0")
            check(@target, full_pkt_name, "MEDIC_OTHER_APC_DATA_PRESENCE", "== 'PRESENT'")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'PRIMARY")
            check(@target, full_pkt_name, "MEDIC_OTHER_STACK_LOCATION_VIA_CAN2", "== 'YP")
            check(@target, full_pkt_name, "MEDIC_OTHER_ME_OK_ENABLE_VIA_CAN2", "== 'ENABLED")
        end
    end
  end


  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

end