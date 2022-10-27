load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_FS_Upload.rb')
load('AIT/FSW/individual_tests/Medic_test_individual.rb')
load 'Operations/FSW/FSW_Telem.rb'
load('Operations/FSW/UTIL_CmdSender.rb')
load("Operations/FSW/FSW_CSP.rb")
load('Operations/FSW/FSW_FDIR.rb')
load('Operations/FSW/FSW_MEDIC.rb')

# Before running this test, both APC's must be configured to have the correct stack location

class MEDIC_TEST_YP < ASTCOSMOSTestFSW
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
    @wait_time = 1
    @fdir_script_file_name = "#{__dir__}\\medic_failover_secondary_board_script.txt"
    @alloted_failover_time = 7
    @realtime_destination = 'COSMOS_DPC'

    @apcs =  {this_apc: "APC_YP", other_apc: "APC_YM"}
    @fcs = {this_fc: "FC_YP", other_fc: "FC_YM"}

    @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

    @fsw_tlm_pkts = [
      {board: "APC_YP", pkt_name: "FSW_TLM_APC", startup_pkt_name: "FSW_STARTUP_TLM_FC",
          sid: "FSW", tid: "NORMAL", task_name: "MEDIC_LEADER"},

      {board: "FC_YP", pkt_name: "FSW_TLM_FC", startup_pkt_name: "FSW_STARTUP_TLM_APC",
          sid: "FSW", tid: "NORMAL", task_name: "MEDIC_FOLLOWER"}
    ]

    @task_tlm_pkts = [
      {board: "APC_YP", other_board: "APC_YM", location: "YP", pkt_name: "MEDIC_LEADER_TLM",
      sid: "MEDIC", tid: "NORMAL"},
      {board: "FC_YP",  other_board: "FC_YM", location: "YP", pkt_name: "MEDIC_FOLLOWER_TLM_FC",
      sid: "MEDIC", tid: "NORMAL"}
    ]

    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestMedic_#{@board}")
    end
    @module_csp.reboot("FC_YP")
    @module_csp.reboot("APC_YP")
    @module_csp.reboot("FC_YM")
    @module_csp.reboot("APC_YM")
    wait(7)
    status_bar("setup")
  end

  def setup_stacks()
    puts "Running setup_stacks"
    # Set up both APC's such that APC_YP = primary, APC_YM = secondary, both master_enables = enabled, both modes = 0
    # Step 1 - First setup the other stack to be in secondary
    @medic.set_stack_state(@apcs[:other_apc], @medic_enums[:secondary_state]);
    @medic.set_me_ok_enable(@apcs[:other_apc], @medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 2 - Check the Medic Leader telemetry are admissible values before setting this stack to primary
    puts "Verifying the other APC's Medic task is configured to a safe state"
    full_pkt_name = CmdSender.get_full_pkt_name(@apcs[:this_apc], 'MEDIC_LEADER_TLM')
    check(@target, full_pkt_name, "MEDIC_OTHER_MASTER_STATE_PIN", "== 'DISABLED'")
    check(@target, full_pkt_name, "MEDIC_OTHER_STACK_STATE_VIA_CAN2", "== 'SECONDARY'")

    # Step 3 - Set this stack's state to primary
    @medic.set_stack_state(@apcs[:this_apc], @medic_enums[:primary_state]);
    @medic.set_me_ok_enable(@apcs[:this_apc], @medic_enums[:me_ok_enabled]);
    wait(7)

    # Step 4 - Check all Medic Leader telemetry values are admissible
    @task_tlm_pkts.each do | collector |  
      puts "Verifying that this stacks Medic telemetry has admissible values"
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
      # Check the Medic Leader telemetry are admissible values
      check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
      check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{collector[:location]}'")
      if (collector[:board] == @apcs[:this_apc]) || (collector[:sid] == @apcs[:other_apc])
        check(@target, full_pkt_name, "MEDIC_ME_OK_ENABLE", "== 'ENABLED'")
      end
    end
  end

  def test_a_fsw_tlm_status
    medic_check_fsw_tlm_status(@fsw_tlm_pkts, @module_telem, @realtime_destination)
  end

  def test_b_task_tlm_status
    medic_check_task_tlm_status(@task_tlm_pkts, @module_telem, @medic, @apcs, @target, @realtime_destination)
  end

  def test_c_config_persistence
    medic_check_config_persistence(@task_tlm_pkts, @module_telem, @medic, @module_csp, @apcs, @target, @realtime_destination)
  end

  def test_d_follower_task_send_cmd
    medic_follower_check_send_command(@task_tlm_pkts, @module_telem, @medic, @realtime_destination, @apcs, @fcs, @target)
  end

  def test_e_board_to_board_comm
    medic_check_board2board_comm(@task_tlm_pkts, @module_telem, @medic, @cmd_sender, @apcs, @fcs, @realtime_destination, @target)
  end

  def test_f_medic_yp_to_ym_failover # In order to run this test, the cosmos instance must be connected to stack yp
    medic_check_ypym_failover(@task_tlm_pkts, @cmd_sender, @medic, @module_telem, @module_csp, @module_fs, @fdir, @apcs, @target, @realtime_destination, @check_aspect, @entry_size, @allotted_failover_time, @fdir_script_file_id, @fdir_script_file_name, @fdir_config_file, @secondary_board_failover_fmc)
  end

  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

end