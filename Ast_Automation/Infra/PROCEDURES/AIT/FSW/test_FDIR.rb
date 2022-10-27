load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/FSW_FS_Upload.rb'
load 'AIT/FSW/individual_tests/FDIR_test_individual.rb'
load 'Operations/FSW/FSW_Telem.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'
load 'Operations/FSW/FSW_CSP.rb'
load 'Operations/FSW/FSW_FDIR.rb'
load 'Operations/FSW/FSW_MEDIC.rb'

class FDIR_STACK_TEST < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @fdir = ModuleFdir.new
    @cmd_sender = CmdSender.new
    @medic = ModuleMedic.new

    @entry_size = 186
    @fdir_script_file_id = 89
    @fdir_config_file = "#{__dir__}\\config_binary_all_fsa_disabled.bin"
    @check_aspect = "CRC"
    @fdir_collector_status = Array.new(2,0) # APC and FC collector tasks 2, one for APC and one for FC
    @fdir_task_status = Array.new(2,0) # APC and FC collector tasks 2, one for APC and one for FC
    @target = "BW3"
    @pkt_name = "FSW_STARTUP_TLM"
    @fault_trigger_time_s = 10
    @fdir_demo_fmc = 68
    @config_main_file_id = 4103
    @config_main_backup_file_id = 4104
    @config_fallback_file_id = 4105
    @config_fallback_backup_file_id = 4106
    @realtime_destination = 'COSMOS_DPC'

    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestFDIR")
    end
    
    @board = combo_box("Select Board", "APC_YP", "FC_YP", "ALL_YP", "APC_YP", "FC_YP", "ALL_YM")
    if @board == "APC_YP"
      @apcs =  {this_apc: "APC_YP", other_apc: "APC_YM"}
      @fcs = {this_fc: "FC_YP", other_fc: "FC_YM"}

      @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

      @fsw_tlm_collector = [
        {board: 'APC_YP', pkt_name: 'FSW_TLM_APC', startup_pkt_name: 'FSW_STARTUP_TLM_APC',
        sid: "FSW", tid: "NORMAL", fdir_script_file_name: "#{__dir__}\\fdir_demo_script.txt"}
      ]

      @task_tlm_collector = [
        {board: 'APC_YP', pkt_name: 'FDIR_TLM_APC',  sid: "FDIR", tid: "NORMAL"} # pkt_name and sid are distinct symbols, just called the same thing in this case
      ]

      @medic_task_tlm_collector = [
        {board: "APC_YP", other_board: "APC_YM", location: "YP", pkt_name: "MEDIC_LEADER_TLM",
        sid: "MEDIC", tid: "NORMAL"},
      ]
    elsif @board == "FC_YP"
      @apcs =  {this_apc: "APC_YP", other_apc: "APC_YM"}
      @fcs = {this_fc: "FC_YP", other_fc: "FC_YM"}

      @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

      @fsw_tlm_collector = [
        {board: 'FC_YP', pkt_name: 'FSW_TLM_FC', startup_pkt_name: 'FSW_STARTUP_TLM_FC',
            sid: "FSW", tid: "NORMAL", fdir_script_file_name: "#{__dir__}\\fdir_demo_script.txt"}
      ]

      @task_tlm_collector = [
        {board: 'FC_YP', pkt_name: 'FDIR_TLM_FC',  sid: "FDIR", tid: "NORMAL"} # pkt_name and sid are distinct symbols, just called the same thing in this case
      ]

      @medic_task_tlm_collector = [
        {board: "FC_YP",  other_board: "FC_YM", location: "YP", pkt_name: "MEDIC_FOLLOWER_TLM_FC",
        sid: "MEDIC", tid: "NORMAL"}
      ]
    elsif @board == "ALL_YP"
      @apcs =  {this_apc: "APC_YP", other_apc: "APC_YM"}
      @fcs = {this_fc: "FC_YP", other_fc: "FC_YM"}

      @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

      @fsw_tlm_collector = [
        {board: 'APC_YP', pkt_name: 'FSW_TLM_APC', startup_pkt_name: 'FSW_STARTUP_TLM_APC',
        sid: "FSW", tid: "NORMAL", fdir_script_file_name: "#{__dir__}\\fdir_demo_script.txt"},

        {board: 'FC_YP', pkt_name: 'FSW_TLM_FC', startup_pkt_name: 'FSW_STARTUP_TLM_FC',
            sid: "FSW", tid: "NORMAL", fdir_script_file_name: "#{__dir__}\\fdir_demo_script.txt"}
      ]

      @task_tlm_collector = [
        {board: 'APC_YP', pkt_name: 'FDIR_TLM_APC',  sid: "FDIR", tid: "NORMAL"}, # pkt_name and sid are distinct symbols, just called the same thing in this case
        {board: 'FC_YP', pkt_name: 'FDIR_TLM_FC',  sid: "FDIR", tid: "NORMAL"} # pkt_name and sid are distinct symbols, just called the same thing in this case
      ]

      @medic_task_tlm_collector = [
        {board: "APC_YP", other_board: "APC_YM", location: "YP", pkt_name: "MEDIC_LEADER_TLM",
        sid: "MEDIC", tid: "NORMAL"},
        {board: "FC_YP",  other_board: "FC_YM", location: "YP", pkt_name: "MEDIC_FOLLOWER_TLM_FC",
        sid: "MEDIC", tid: "NORMAL"}
      ]
    elsif @board == "APC_YM"
      @apcs =  {this_apc: "APC_YM", other_apc: "APC_YP"}
      @fcs = {this_fc: "FC_YM", other_fc: "FC_YP"}

      @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

      @fsw_tlm_collector = [
        {board: 'APC_YM', pkt_name: 'FSW_TLM_APC', startup_pkt_name: 'FSW_STARTUP_TLM_APC',
        sid: "FSW", tid: "NORMAL", fdir_script_file_name: "#{__dir__}\\fdir_demo_script.txt"}
      ]

      @task_tlm_collector = [
        {board: 'APC_YM', pkt_name: 'FDIR_TLM_APC',  sid: "FDIR", tid: "NORMAL"} # pkt_name and sid are distinct symbols, just called the same thing in this case
      ]

      @medic_task_tlm_collector = [
        {board: "APC_YM", other_board: "APC_YM", location: "YM", pkt_name: "MEDIC_LEADER_TLM",
        sid: "MEDIC", tid: "NORMAL"}
      ]
    elsif @board == "FC_YM"
      @apcs =  {this_apc: "APC_YM", other_apc: "APC_YP"}
      @fcs = {this_fc: "FC_YM", other_fc: "FC_YP"}

      @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

      @fsw_tlm_collector = [
        {board: 'FC_YM', pkt_name: 'FSW_TLM_FC', startup_pkt_name: 'FSW_STARTUP_TLM_FC',
            sid: "FSW", tid: "NORMAL", fdir_script_file_name: "#{__dir__}\\fdir_demo_script.txt"}
      ]

      @task_tlm_collector = [
        {board: 'FC_YM', pkt_name: 'FDIR_TLM_FC',  sid: "FDIR", tid: "NORMAL"} # pkt_name and sid are distinct symbols, just called the same thing in this case
      ]

      @medic_task_tlm_collector = [
        {board: "FC_YM",  other_board: "FC_YM", location: "YM", pkt_name: "MEDIC_FOLLOWER_TLM_FC",
        sid: "MEDIC", tid: "NORMAL"}
      ]
    elsif @board == "ALL_YM"
      @apcs =  {this_apc: "APC_YM", other_apc: "APC_YP"}
      @fcs = {this_fc: "FC_YM", other_fc: "FC_YP"}

      @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

      @fsw_tlm_collector = [
        {board: 'APC_YM', pkt_name: 'FSW_TLM_APC', startup_pkt_name: 'FSW_STARTUP_TLM_APC',
        sid: "FSW", tid: "NORMAL", fdir_script_file_name: "#{__dir__}\\fdir_demo_script.txt"},

        {board: 'FC_YM', pkt_name: 'FSW_TLM_FC', startup_pkt_name: 'FSW_STARTUP_TLM_FC',
            sid: "FSW", tid: "NORMAL", fdir_script_file_name: "#{__dir__}\\fdir_demo_script.txt"}
      ]

      @task_tlm_collector = [
        {board: 'APC_YM', pkt_name: 'FDIR_TLM_APC',  sid: "FDIR", tid: "NORMAL"}, # pkt_name and sid are distinct symbols, just called the same thing in this case
        {board: 'FC_YM', pkt_name: 'FDIR_TLM_FC',  sid: "FDIR", tid: "NORMAL"} # pkt_name and sid are distinct symbols, just called the same thing in this case
      ]

      @medic_task_tlm_collector = [
        {board: "APC_YM", other_board: "APC_YM", location: "YM", pkt_name: "MEDIC_LEADER_TLM",
        sid: "MEDIC", tid: "NORMAL"},
        {board: "FC_YM",  other_board: "FC_YM", location: "YM", pkt_name: "MEDIC_FOLLOWER_TLM_FC",
        sid: "MEDIC", tid: "NORMAL"}
      ]
    end

  
    if @board == "APC_YP"
      @module_csp.reboot("APC_YP", true)
    elsif @board == "FC_YP"
      @module_csp.reboot("FC_YP", true)
    elsif @board == "ALL_YP"
      @module_csp.reboot("FC_YP", true)
      @module_csp.reboot("APC_YP", true)
    elsif @board == "APC_YM"
      @module_csp.reboot("APC_YM", true)
    elsif @board == "FC_YM"
      @module_csp.reboot("FC_YM", true)
    elsif @board == "ALL_YM"
      @module_csp.reboot("FC_YM", true)
      @module_csp.reboot("APC_YM", true)
    end

    wait(7)
    status_bar("setup")
  end

  def test_a_fsw_tlm_status
    fdir_check_fsw_tlm_status(@fsw_tlm_collector, @module_telem, @realtime_destination)
  end

  def test_b_task_tlm_status
    fdir_check_task_tlm_status(@task_tlm_collector, @module_telem, @board, @realtime_destination)
  end

  # In order to run this test, both the APC and FC connected to this cosmos instance must be in the primary stack state.
  # It is important to note that if two APC's are connected via the crossover connector, only one can ever be in primary state
  # at any given point in time to avoid damaging the boards and connectors/cables.
  def test_c_run_demo_fault
    run_demo_fault(@task_tlm_collector, @medic_task_tlm_collector, @fsw_tlm_collector, @apcs, @cmd_sender, @module_fs, @module_telem, @fdir, @medic, @realtime_destination, @entry_size, @check_aspect, @target, @fdir_script_file_id, @fdir_config_file, @fdir_demo_fmc, @fault_trigger_time_s)
  end

  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

end