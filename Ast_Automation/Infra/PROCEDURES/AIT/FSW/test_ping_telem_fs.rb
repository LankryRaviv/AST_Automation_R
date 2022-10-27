load 'Operations/FSW/FSW_CSP.rb'
load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'AIT/FSW/individual_tests/TLM_test_individual.rb'
load 'Operations/FSW/FSW_Telem.rb'
load 'Operations/FSW/FSW_CSP.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/FSW_FS_Upload.rb'
load 'Operations/FSW/FSW_FS_Continue_Upload.rb'
load 'Operations/FSW/FSW_FS.rb'
load 'Operations/FSW/UTIL_ByteString.rb'
load 'Operations/FSW/FSW_Config_Types.rb'
load 'Operations/FSW/FSW_Config_Properties.rb'
load 'AIT/FSW/individual_tests/Config_test_individual.rb'
load 'Operations/FSW/FSW_SE.rb'
load 'AIT/FSW/individual_tests/SE_BasicTest_individual.rb'
load 'Operations/FSW/FSW_FWUPD.rb'

# A group of tests we plan on running for every AIT release. 
# CSP 
# TLM
# File System
# CONFIG


class PING_TELEM_FS_TEST < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @command_sender = CmdSender.new
    @module_SE = ModuleSE.new
    @fwupd = ModuleFWUPD.new
    @medic = ModuleMedic.new
    @fdir = ModuleFdir.new
    
    @stack = "YP"
    @realtime_destination = 'COSMOS_DPC'

    # TEST CSP
    @target = "BW3"
    @startup_tlm_file_id = 4119
    @check_delay = 2
    # TEST TELM
    # Note: The following values must yield a whole integer num of pkts based upon the temp_realtime frequencies used in this test
    @temp_realtime_duration_in_ms = 10000 # 10 seconds
    @temp_realtime_duration_in_sec = @temp_realtime_duration_in_ms/1000
    @missed_pkts_allowed = 2
    @process_delay = 3
    @tlm_point_to_check = "RECEIVED_COUNT"
    # TEST FS
    @firmware_file_id = 4108
    @fsw_tlm_file_id = 4122
    @entry_size = 1754
    @download_time_s = 90
    @check_aspect = "CRC"
    @test_bin_name  = "#{__dir__}\\testImg.bin"
    @harvester_id = 'HARVESTER_1_HZ'


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
      {name: 'HDRM_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'COMM_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'POWER_CSBAT1_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'POWER_CSBAT2_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'POWER_CSBAT_HEATER_THRESHOLD_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'POWER_PCDU_POWER_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'POWER_PCDU_SWITCH_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'THERMAL_TLM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'THERMAL_OTHER_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'THERMAL_RTD_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'FDIR_SLIM_TLM_APC', freq: 1, count: 0, expected_pkts: 0},
      {name: 'BEACON_TLM_APC', freq: 1, count: 0, expected_pkts: 0},
    ]
    # All FC tlm packets
    @fc_pkts = [
      {name: 'AOCS_TLM', freq: 0.5, count: 0, expected_pkts: 0},
      {name: 'FSW_TLM_FC', freq: 1, count: 0, expected_pkts: 0},
      {name: 'MEDIC_FOLLOWER_TLM_FC', freq: 2, count: 0, expected_pkts: 0},
      {name: 'FDIR_TLM_FC', freq: 3, count: 0, expected_pkts: 0},
      {name: 'FDIR_SUPPLEMENTAL_TLM_FC', freq: 4, count: 0, expected_pkts: 0},
      {name: 'AOCS_GEN_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'AOCS_FSS_ST_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'AOCS_GPS_IMU_MAG_RWA_SLIM', freq: 1, count: 0, expected_pkts: 0},
      {name: 'FDIR_SLIM_TLM_FC', freq: 1, count: 0, expected_pkts: 0},

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
    @board = combo_box("Select board", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC", "ALL_YP", "ALL_YM")

    
    puts "Powering on DPC"
    if (@board == "APC_YP" or @board == "ALL_YP")
      cmd_no_hazardous_check("BW3 APC_YP-APC_LVC_OUTPUT_SINGLE with OUTPUT_CHANNEL DPC, STATE_ONOFF ON, DELAY 0")
      wait(8)
    elsif (@board == "APC_YM" or @board == "ALL_YM")
      cmd_no_hazardous_check("BW3 APC_YM-APC_LVC_OUTPUT_SINGLE with OUTPUT_CHANNEL DPC, STATE_ONOFF ON, DELAY 0")
      wait(8)
    end

    @run_for_record = combo_box("Run for record?", "YES", "NO")
    @boards = []    
    @boards_config = []
    if @board == "APC_YP"
      @collectors = [
        {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}
      ]
      @boards << { board_name: 'APC_YP', pkts: @apc_pkts, destination_csp_id: @realtime_destination }
      @boards_config = [ 'APC_YP']


    elsif @board == "APC_YM"
      @collectors = [
        {board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}
      ]
      @boards << { board_name: 'APC_YM', pkts: @apc_pkts, destination_csp_id: @realtime_destination }
      @boards_config = [ 'APC_YM']

    elsif @board == "FC_YP"
      @collectors = [
        {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      ]
      @boards << { board_name: 'FC_YP', pkts: @fc_pkts, destination_csp_id: @realtime_destination }
      @boards_config = [ 'FC_YP']


    elsif @board == "FC_YM"
      @collectors = [
        {board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      ]
      @boards << { board_name: 'FC_YM', pkts: @fc_pkts, destination_csp_id: @realtime_destination }
      @boards_config = [ 'FC_YM']
    elsif @board == "DPC"
      @collectors = [
        {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      ]
      @boards << {board_name: 'DPC_1', pkts: @dpc1_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_2', pkts: @dpc2_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_3', pkts: @dpc3_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_4', pkts: @dpc4_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_5', pkts: @dpc5_pkts, destination_csp_id: @realtime_destination}
      @boards_config = [ 'DPC_1', 'DPC_2', 'DPC_3', 'DPC_4', 'DPC_5']
    elsif @board == "ALL_YP" 
      @collectors = [
      {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"}
     ]
      @boards << { board_name: 'APC_YP', pkts: @apc_pkts, destination_csp_id: @realtime_destination }
      @boards << { board_name: 'FC_YP', pkts: @fc_pkts, destination_csp_id: @realtime_destination }
      @boards << {board_name: 'DPC_1', pkts: @dpc1_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_2', pkts: @dpc2_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_3', pkts: @dpc3_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_4', pkts: @dpc4_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_5', pkts: @dpc5_pkts, destination_csp_id: @realtime_destination}
      @boards_config = ['FC_YP', 'DPC_1', 'DPC_2', 'DPC_3', 'DPC_4', 'DPC_5','APC_YP',]
    elsif @board == "ALL_YM"
      @collectors = [
      {board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"}
    ]
      @boards << { board_name: 'APC_YM', pkts: @apc_pkts, destination_csp_id: @realtime_destination }
      @boards << { board_name: 'FC_YM', pkts: @fc_pkts, destination_csp_id: @realtime_destination }
      @boards << {board_name: 'DPC_1', pkts: @dpc1_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_2', pkts: @dpc2_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_3', pkts: @dpc3_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_4', pkts: @dpc4_pkts, destination_csp_id: @realtime_destination}
      @boards << {board_name: 'DPC_5', pkts: @dpc5_pkts, destination_csp_id: @realtime_destination}
      @boards_config =['FC_YM', 'DPC_1', 'DPC_2', 'DPC_3', 'DPC_4', 'DPC_5','APC_YM',]
      @collectors_TS = [
        {board: 'APC_YM', pkt_name: 'GET_TIMESTAMP_RESP',  sid: "FSW", tid: "NORMAL"},
        {board: 'FC_YM',  pkt_name: 'GET_TIMESTAMP_RESP',  sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_1', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
        {board: 'DPC_2', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
        {board: 'DPC_3', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_4', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
        {board: 'DPC_5', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
      ]
    end

    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_AIT_TEST_RELEASE_#{@board}", dpc=true)
      @stack = @test_case_util.stack
    end
  end

  
  def test_CS_FS_01_CSP_PING_TEST
    status_bar("CS_FS_01_CSP_PING_TEST")
    wait(30)
    @collectors.each do |collector|
      # Clear startup telem so that boot count will be properly read. This can take a while
      @module_fs.file_clear(collector[:board], @startup_tlm_file_id)
      file_status = @module_fs.wait_for_file_ok(collector[:board], @startup_tlm_file_id, 30)
    end

    ping_collectors(@collectors, @module_csp)
  
    cspReboot(@board)
    
  end

  def test_CS_FS_02_TELEMETRY_TEST
    status_bar("CS_FS_02_TELEMETRY_TEST")
    wait(30)
    set_realtime_on(@boards, @module_telem, @command_sender, @process_delay, @check_delay, @target, @tlm_point_to_check)
    set_realtime_off(@boards, @module_telem, @command_sender, @process_delay, @check_delay, @target, @tlm_point_to_check)
    cspReboot(@board)
  end
  def test_CS_FS_03_FILESYSTEM_TEST
    status_bar("CS_FS_03_FILESYSTEM_TEST")
    wait(30)
    clear_file_on_boards(@collectors, @module_telem, @module_fs, @harvester_id, @fsw_tlm_file_id, @realtime_destination)
    download_test_file(@collectors, @module_telem, @module_fs, @target, @download_time_s, @realtime_destination, @fsw_tlm_file_id)
    cspReboot(@board)
  end
  
  def cspReboot(board)
    if @board == "DPC"
      @module_csp.reboot("DPC_1", true)
      wait(1)
      @module_csp.reboot("DPC_2", true)
      wait(1)
      @module_csp.reboot("DPC_3", true)
      wait(1)
      @module_csp.reboot("DPC_4", true)
      wait(1)
      @module_csp.reboot("DPC_5", true)
    elsif @board == 'ALL_YP'
      @module_csp.reboot("FC_YP", true)
      wait(1)
      @module_csp.reboot("DPC_1", true)
      wait(1)
      @module_csp.reboot("DPC_2", true)
      wait(1)
      @module_csp.reboot("DPC_3", true)
      wait(1)
      @module_csp.reboot("DPC_4", true)
      wait(1)
      @module_csp.reboot("DPC_5", true)
      wait(1)
      @module_csp.reboot("APC_YP", true)
    elsif @board == 'ALL_YM'
      @module_csp.reboot("FC_YM", true)
      wait(1)
      @module_csp.reboot("DPC_1", true)
      wait(1)
      @module_csp.reboot("DPC_2", true)
      wait(1)
      @module_csp.reboot("DPC_3", true)
      wait(1)
      @module_csp.reboot("DPC_4", true)
      wait(1)
      @module_csp.reboot("DPC_5", true)
      wait(1)
      @module_csp.reboot("APC_YM", true)
    else
      @module_csp.reboot(@board, true)
    end
      wait(10)
  end
end

