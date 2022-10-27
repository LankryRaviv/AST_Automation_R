load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")


class TELEMETRY_TEST < ASTCOSMOSTestFSW
  def initialize
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @target = "BW3"
    # Note: The following values must yield a whole integer num of pkts based upon the temp_realtime frequencies used in this test
    @temp_realtime_duration_in_ms = 10000 # 10 seconds
    @temp_realtime_duration_in_sec = @temp_realtime_duration_in_ms/1000
    @missed_pkts_allowed = 2
    @process_delay = 3
    @check_delay = 2
    @tlm_point_to_check = "RECEIVED_COUNT"
    @realtime_destination = 'COSMOS_DPC'

    # All APC tlm packets
    @apc_pkts = [
      {name: 'PAYLOAD_TLM', freq: 0.1, count: 0, expected_pkts: 0},
      {name: 'POWER_PCDU_LVC_TLM', freq: 0.2, count: 0, expected_pkts: 0},
      {name: 'POWER_CSBATS_TLM', freq: 0.2, count: 0, expected_pkts: 0},
      {name: 'COMM_TLM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'THERMAL_TLM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'PROP_TLM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'MEDIC_LEADER_TLM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'FSW_TLM_APC', freq: 1, count: 0, expected_pkts: 0},
      {name: 'FDIR_TLM_APC', freq: 2, count: 0, expected_pkts: 0},
      {name: 'FDIR_SUPPLEMENTAL_TLM_APC', freq: 5, count: 0, expected_pkts: 0},
      {name: 'FSW_SLIM_TLM', freq: 10, count: 0, expected_pkts: 0}
    ]

    # All FC tlm packets
    @fc_pkts = [
      {name: 'AOCS_TLM', freq: 0.5, count: 0, expected_pkts: 0},
      {name: 'FSW_TLM_FC', freq: 1, count: 0, expected_pkts: 0},
      {name: 'MEDIC_FOLLOWER_TLM_FC', freq: 2, count: 0, expected_pkts: 0},
      {name: 'FDIR_TLM_FC', freq: 3, count: 0, expected_pkts: 0},
      {name: 'FDIR_SUPPLEMENTAL_TLM_FC', freq: 4, count: 0, expected_pkts: 0},
      {name: 'FSW_SLIM_TLM', freq: 5, count: 0, expected_pkts: 0}
    ]

    # All DPC tlm packets, duplicate tables for each proc.
    @dpc1_pkts = [
      {name: 'FSW_TLM_DPC', freq: 1, count: 0, expected_pkts: 0},
    ]
    @dpc2_pkts = [
      {name: 'FSW_TLM_DPC', freq: 1, count: 0, expected_pkts: 0},
    ]
    @dpc3_pkts = [
      {name: 'FSW_TLM_DPC', freq: 1, count: 0, expected_pkts: 0},
    ]
    @dpc4_pkts = [
      {name: 'FSW_TLM_DPC', freq: 1, count: 0, expected_pkts: 0},
      #{name: 'CAMERA_TLM', freq: 1, count: 0, expected_pkts: 0},
    ]
    @dpc5_pkts = [
      {name: 'FSW_TLM_DPC', freq: 1, count: 0, expected_pkts: 0},
    ]

    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @board = combo_box("Select board", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC")
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestTLM_#{@board}")
    end
    @boards = []
    if @board == "APC_YP"
      @boards << { board_name: 'APC_YP', pkts: @apc_pkts, destination_csp_id: @realtime_destination }
    elsif @board == "APC_YM"
      @boards << { board_name: 'APC_YM', pkts: @apc_pkts, destination_csp_id: @realtime_destination }
    elsif @board == "FC_YP"
      @boards << { board_name: 'FC_YP', pkts: @fc_pkts, destination_csp_id: @realtime_destination }
    elsif @board == "FC_YM"
      @boards << { board_name: 'FC_YM', pkts: @fc_pkts, destination_csp_id: @realtime_destination }
    elsif @board == "DPC"
      @boards << {board_name: 'DPC_1', pkts: @dpc1_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_2', pkts: @dpc2_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_3', pkts: @dpc3_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_4', pkts: @dpc4_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_5', pkts: @dpc5_pkts, destination_csp_id: @realtime_destination}
    end

    if @board == "DPC"
      @module_csp.reboot("DPC_1", true)
      @module_csp.reboot("DPC_2", true)
      @module_csp.reboot("DPC_3", true)
      @module_csp.reboot("DPC_4", true)
      @module_csp.reboot("DPC_5", true)
    else
      @module_csp.reboot(@board, true)
    end
    wait(7)
    status_bar("setup")
  end

  # Modified Telemetry Service Tests
  def test_f_realtime_on
    set_realtime_on(@boards, @module_telem, @cmd_sender, @process_delay, @check_delay, @target, @tlm_point_to_check)
  end

  def test_g_realtime_off
    set_realtime_off(@boards, @module_telem, @cmd_sender, @process_delay, @check_delay, @target, @tlm_point_to_check)
  end

  def test_h_instantaneous_tlm
    check_instantaneous_tlm(@boards, @module_telem)
  end

  def test_i_temp_realtime_on
    set_temp_realtime_on(@boards, @module_telem, @cmd_sender, @process_delay, @check_delay, @tlm_point_to_check, @target, @missed_pkts_allowed, @temp_realtime_duration_in_ms, @temp_realtime_duration_in_sec)
  end

  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

end
