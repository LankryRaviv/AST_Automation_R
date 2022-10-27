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


class AIT_RELEASE < ASTCOSMOSTestFSW
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
    @startup_tlm_file_id = 4120
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
    # TEST SE
    @exec_file_id_0 = 4610 
    @exec_file_id_1 = 4611
    @exec_file_id_2 = 4612
    @log_tlm_file_id = 4613
    @entry_size_SE = 744
    @script_id_0 = 69
    @script_id_1 = 70
    @script_id_2 = 71
    @test_file_name_0  = "#{__dir__}\\Script2_exe.txt"
    @test_file_name_1  = "#{__dir__}\\Script3_exe.txt"
    @test_file_name_2  = "#{__dir__}\\Script7_exe.txt"
    @wait_time = 100
    # TEST FWUPD
    @file_id_fwupd = 4108
    # TEST CPU
    @cpu_percentage_max = 70
    # TIME SYNC -- ONLY RUNS WITH FULL STACK
    @collectors_TS = [
      {board: 'APC_YP', pkt_name: 'GET_TIMESTAMP_RESP',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YP',  pkt_name: 'GET_TIMESTAMP_RESP',  sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_1', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
      {board: 'DPC_2', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
      {board: 'DPC_3', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_4', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
      {board: 'DPC_5', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
    ]

    # FDIR -- ONLY RUNS WITH FULL STACK
    @entry_size = 186
    @fdir_script_file_id = 89
    @fdir_config_file = "#{__dir__}\\config_binary_all_fsa_disabled.bin"
    @check_aspect = "CRC"
    @fault_trigger_time_s = 10
    @fdir_demo_fmc = 68

    # SUPERVISOR
    @max_tasks = 26
    @APC_task_count = 26 # This must be manually updated
    @FC_task_count = 15  # This too
    @DPC_task_count = 13 # This three
    @failed_task_count = 5

    @APC_task_status = Array.new(@APC_task_count,0) #Length must be manually updated
    for i in 1..(@max_tasks-@APC_task_count)
      @APC_task_status.append(123)                  #Append 123 for indices without tasks
    end

    @FC_task_status = Array.new(@FC_task_count,0)
    for i in 1..(@max_tasks-@FC_task_count)
      @FC_task_status.append(123)                  #Append 123 for indices without tasks
    end

    @DPC_task_status = Array.new(@DPC_task_count, 0)
    for i in 1..(@max_tasks - @DPC_task_count)
      @DPC_task_status.append(123)
    end



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

    @boards_fwupd = []
    if @board == "APC_YP" or @board == "ALL_YP"
      @boards_fwupd <<
        {
          BOARD: 'APC_YP', FILE_APPLICATION_TEST: 'apcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'apcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'apcBL2_Test.bin',
          APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
          BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
          BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
          FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
          APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
          BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
          BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
        }
    end
    if @board == "APC_YM" or @board == "ALL_YM"
      @boards_fwupd <<
      {
        BOARD: 'APC_YM', FILE_APPLICATION_TEST: 'apcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'apcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'apcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
    end
    if @board == "FC_YP" or @board == "ALL_YP"
      @boards_fwupd <<
      {
        BOARD: 'FC_YP', FILE_APPLICATION_TEST: 'fcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'fcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'fcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
    end
    if @board == "FC_YM" or @board == "ALL_YM"
      @boards_fwupd <<
      {
        BOARD: 'FC_YM', FILE_APPLICATION_TEST: 'fcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'fcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'fcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
    end
    if @board == "DPC" or @board == "ALL_YM" or @board == "ALL_YP"
      @boards_fwupd <<
      {
        BOARD: 'DPC_1', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
      @boards_fwupd <<
      {
        BOARD: 'DPC_2', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,

      }
      @boards_fwupd <<
      {
        BOARD: 'DPC_3', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,

      }
      @boards_fwupd <<
      {
        BOARD: 'DPC_4', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,

      }
      @boards_fwupd <<
      {
        BOARD: 'DPC_5', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
    end
    
        
    if @board == "ALL_YP"
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

    board_ind = []
    if @board.eql?('APC_YP') or @board.eql?('APC_YM') or @board.eql?('ALL_YP') or @board.eql?('ALL_YM')
      board_ind << "apc"
      puts "Upgrading APC"
    end
    if @board.eql?('FC_YP') or @board.eql?('FC_YM') or @board.eql?('ALL_YP') or @board.eql?('ALL_YM')
      board_ind << "fc"
      puts "Upgrading FC"
    end
    if @board.eql?('DPC') or @board.eql?('ALL_YP') or @board.eql?('ALL_YM')
      board_ind << "dpc"
      puts "Upgrading DPC"
    end

    @apc_board_loc = {}
    @fc_board_loc = {}
    @dpc_board_loc = {}

    @apc_major = {}
    @apc_minor = {}
    @apc_patch = {}

    @fc_major = {}
    @fc_minor = {}
    @fc_patch = {}

    @dpc_major = {}
    @dpc_minor = {}
    @dpc_patch = {}



    
    board_ind.each_with_index do |ind, i|
      #location = "C:/Users/psaripalli/Documents/repos/apc-bug/apc/Cube" #ask("Image Recovery path (CUBE FOLDER) for board #{fwupdboard[:BOARD]} (e.g.  C:/Users/psaripalli/Documents/repos/apc-bug/apc/Cube/):")
      location = open_directory_dialog("/", "Image Recovery path (CUBE FOLDER) for board #{@boards_fwupd[i][:BOARD]} (e.g.  C:/repos/" + ind + "/Cube):")
    
      puts "location: " + location
      @boards_fwupd[i][:FILE_APPLICATION]  =  location + "/APP-Debug/" + ind + 'App.bin'
      @boards_fwupd[i][:FILE_BOOTLOADERL1] =   location + "/BL1-Debug/" + ind + 'BL1.bin'
      @boards_fwupd[i][:FILE_BOOTLOADERL2] =  location + "/BL2-Debug/" + ind + 'BL2.bin'

          # Use the location to navigate to the version.def stuff.
      def_location = location + "/../src/application/versionOfApplication.def"
      if File.exist?(def_location)
        f = File.new(def_location, "r")
        line = f.readline()
        /^VERSION\(\s*(\d+),\s*(\d+),\s*(\d+)\)$/.match(line)
        @boards_fwupd[i][:MAJOR] = $1.to_i()
        @boards_fwupd[i][:MINOR] = $2.to_i()
        @boards_fwupd[i][:PATCH] = $3.to_i()
      else
        @boards_fwupd[i][:MAJOR] = ask("MAJOR version # for board #{@boards[i][:BOARD]}")
        @boards_fwupd[i][:MINOR] = ask("MINOR version # for board #{@boards[i][:BOARD]}")
        @boards_fwupd[i][:PATCH] = ask("PATCH version # for board #{@boards[i][:BOARD]}")
      end
    
      @boards_fwupd[i][:APPLICATION_MAJOR]= @boards_fwupd[i][:MAJOR]
      @boards_fwupd[i][:APPLICATION_MINOR]= @boards_fwupd[i][:MINOR]
      @boards_fwupd[i][:APPLICATION_PATCH]= @boards_fwupd[i][:PATCH]

      @boards_fwupd[i][:BOOTLOADERL2_MAJOR] = @boards_fwupd[i][:MAJOR]
      @boards_fwupd[i][:BOOTLOADERL2_MINOR] = @boards_fwupd[i][:MINOR]
      @boards_fwupd[i][:BOOTLOADERL2_PATCH] = @boards_fwupd[i][:PATCH]

      @boards_fwupd[i][:BOOTLOADERL1_MAJOR] = @boards_fwupd[i][:MAJOR]
      @boards_fwupd[i][:BOOTLOADERL1_MINOR] = @boards_fwupd[i][:MINOR]
      @boards_fwupd[i][:BOOTLOADERL1_PATCH] = @boards_fwupd[i][:PATCH]

      if ind == "apc"
        @apc_board_loc = location
        @apc_major = @boards_fwupd[i][:MAJOR]
        @apc_minor = @boards_fwupd[i][:MINOR]
        @apc_patch = @boards_fwupd[i][:PATCH]
      elsif ind == "fc"
        @fc_board_loc = location
        @fc_major = @boards_fwupd[i][:MAJOR]
        @fc_minor = @boards_fwupd[i][:MINOR]
        @fc_patch = @boards_fwupd[i][:PATCH]

      elsif ind == "dpc"
        @dpc_board_loc = location
        @dpc_major = @boards_fwupd[i][:MAJOR]
        @dpc_minor = @boards_fwupd[i][:MINOR]
        @dpc_patch = @boards_fwupd[i][:PATCH]
      end


      if @board.eql?("DPC")
        for i in 1..(@boards_fwupd.length() - 1) do
          @boards_fwupd[i][:FILE_APPLICATION]   = @boards_fwupd[i-1][:FILE_APPLICATION]
          @boards_fwupd[i][:FILE_BOOTLOADERL1]  = @boards_fwupd[i-1][:FILE_BOOTLOADERL1]
          @boards_fwupd[i][:FILE_BOOTLOADERL2]  = @boards_fwupd[i-1][:FILE_BOOTLOADERL2]
          @boards_fwupd[i][:APPLICATION_MAJOR]  = @boards_fwupd[i-1][:APPLICATION_MAJOR]
          @boards_fwupd[i][:APPLICATION_MINOR]  = @boards_fwupd[i-1][:APPLICATION_MINOR]
          @boards_fwupd[i][:APPLICATION_PATCH]  = @boards_fwupd[i-1][:APPLICATION_PATCH]
          @boards_fwupd[i][:BOOTLOADERL2_MAJOR] = @boards_fwupd[i-1][:BOOTLOADERL2_MAJOR]
          @boards_fwupd[i][:BOOTLOADERL2_MINOR] = @boards_fwupd[i-1][:BOOTLOADERL2_MINOR]
          @boards_fwupd[i][:BOOTLOADERL2_PATCH] = @boards_fwupd[i-1][:BOOTLOADERL2_PATCH]
          @boards_fwupd[i][:BOOTLOADERL1_MAJOR] = @boards_fwupd[i-1][:BOOTLOADERL1_MAJOR]
          @boards_fwupd[i][:BOOTLOADERL1_MINOR] = @boards_fwupd[i-1][:BOOTLOADERL1_MINOR]
          @boards_fwupd[i][:BOOTLOADERL1_PATCH] = @boards_fwupd[i-1][:BOOTLOADERL1_PATCH]
        end
      # if Doing DPC with other boards_fwupd, copy over from index 2 to reset
      elsif @board.eql? ('ALL_YP') or @board.eql?('ALL_YM')
        for i in 3..(@boards_fwupd.length() - 1) do
          @boards_fwupd[i][:FILE_APPLICATION]   = @boards_fwupd[i-1][:FILE_APPLICATION]
          @boards_fwupd[i][:FILE_BOOTLOADERL1]  = @boards_fwupd[i-1][:FILE_BOOTLOADERL1]
          @boards_fwupd[i][:FILE_BOOTLOADERL2]  = @boards_fwupd[i-1][:FILE_BOOTLOADERL2]
          @boards_fwupd[i][:APPLICATION_MAJOR]  = @boards_fwupd[i-1][:APPLICATION_MAJOR]
          @boards_fwupd[i][:APPLICATION_MINOR]  = @boards_fwupd[i-1][:APPLICATION_MINOR]
          @boards_fwupd[i][:APPLICATION_PATCH]  = @boards_fwupd[i-1][:APPLICATION_PATCH]
          @boards_fwupd[i][:BOOTLOADERL2_MAJOR] = @boards_fwupd[i-1][:BOOTLOADERL2_MAJOR]
          @boards_fwupd[i][:BOOTLOADERL2_MINOR] = @boards_fwupd[i-1][:BOOTLOADERL2_MINOR]
          @boards_fwupd[i][:BOOTLOADERL2_PATCH] = @boards_fwupd[i-1][:BOOTLOADERL2_PATCH]
          @boards_fwupd[i][:BOOTLOADERL1_MAJOR] = @boards_fwupd[i-1][:BOOTLOADERL1_MAJOR]
          @boards_fwupd[i][:BOOTLOADERL1_MINOR] = @boards_fwupd[i-1][:BOOTLOADERL1_MINOR]
          @boards_fwupd[i][:BOOTLOADERL1_PATCH] = @boards_fwupd[i-1][:BOOTLOADERL1_PATCH]
        end
      end
    
    end
    puts @boards_fwupd

    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_AIT_TEST_RELEASE_#{@board}", dpc=true)
      @stack = @test_case_util.stack
    end

    ## Message Prompt to verify all the inputs that the user put ##
    value = vertical_message_box("Here are the following values inputted by the user. Please verify that these are corrrect and hit ok. \n \n Run for Record: #{@run_for_record} \n Realtime Destinattion: #{@realtime_destination} \n Board: #{@board} \n \n APC \n Application Folder: #{@apc_board_loc} \n Major: #{@apc_major} \n Minor: #{@apc_minor} \n Patch: #{@apc_patch} \n \n FC \n Application Folder: #{@fc_board_loc} \n Major: #{@fc_major} \n Minor: #{@fc_minor} \n Patch: #{@fc_patch} \n \n DPC \n Application Folder: #{@dpc_board_loc} \n Major: #{@dpc_major} \n Minor: #{@dpc_minor} \n Patch: #{@dpc_patch} \n \n", 'Ok', 'Stop')
    case value
      when 'Ok'
        puts 'Continuing'
      when 'Stop'
        abort
    end

    cspReboot(@board)
    status_bar("setup")
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

  def test_CS_FS_04_CONFIG_SERVICE_TEST
    status_bar("CS_FS_04_CONFIG_SERVICE_TEST")
    wait(30)
    @orig_values = retrieve_original_values(@boards_config, @command_sender)
    check_update_bounded_configs(@boards_config, @command_sender, @orig_values, @target)
    check_update_config_rows(@boards_config, @command_sender, @orig_values, @target)
    check_main_config_save(@boards_config, @command_sender, @target, @module_csp, @orig_values)
    check_fallback_config_update(@boards_config, @command_sender, @target, @orig_values)
    cspReboot(@board)
  end

  def test_CS_FS_05_SCRIPT_ENGINE_TEST
    status_bar("CS_FS_05_SCRIPT_ENGINE_TEST")
    wait(30)
    se_basic_functions(@collectors, @module_telem, @module_csp, @module_fs, @module_SE, @target, @exec_file_id_0,@exec_file_id_1,@exec_file_id_2,@log_tlm_file_id,@entry_size_SE,@check_aspect, @script_id_0, @script_id_1,@script_id_2,@test_file_name_0,@test_file_name_1,@test_file_name_2,@wait_time,@realtime_destination)
    cspReboot(@board)
  end

  def test_CS_FS_06_FIRMWARE_UPGRADE_TEST
    status_bar("CS_FS_06_FIRMWARE_UPGRADE_TEST")
    wait(30)
    update_app_layers(@boards_fwupd, @file_id_fwupd)
    checking_version_patch(@boards_fwupd, "bl1", @fwupd)
    checking_version_patch(@boards_fwupd, "bl2", @fwupd)
    cspReboot(@board)
  end

  def test_CS_FS_07_PROCESSOR_UTILIZATION_TEST
    status_bar("CS_FS_07_PROCESSOR_UTILIZATION_TEST")
    wait(30)
    @collectors.each do | collector |
      # Turn on FSW telemetry for all tests
      @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)
    end
    wait(2)
    check_uptimes(@collectors, @command_sender)
    check_cpu_utilization(@collectors, @command_sender, @cpu_percentage_max)
    cspReboot(@board)
  end


  def test_CS_FS_08_TIME_SYNCHRONIZATION_TEST
    status_bar("CS_FS_08_TIME_SYNCHRONIZATION_TEST")
    wait(30)
    if @board.eql? ('ALL_YP') or @board.eql?('ALL_YM')
      @collectors_TS[0, 2].each do |collector|
        # Clear startup telem so that boot count will be properly read. This can take a while
        @module_fs.file_clear(collector[:board], @startup_tlm_file_id)
        file_status = @module_fs.wait_for_file_ok(collector[:board], @startup_tlm_file_id, 30)
      end
      get_board_timestamps(@collectors_TS, @command_sender)
      measure_timesync_accuracy(@collectors_TS, @command_sender, @target)
      cspReboot(@board)
    end
  end

  def test_CS_FS_09_FDIR_TEST
    status_bar("CS_FS_09_FDIR_TEST")
    wait(30)
    if @board.eql? ('ALL_YP') or @board.eql?('ALL_YM')
      fdir_check_fsw_tlm_status(@fsw_tlm_collector, @module_telem, @realtime_destination)
      fdir_check_task_tlm_status(@task_tlm_collector, @module_telem, @board, @realtime_destination)
      run_demo_fault(@task_tlm_collector, @medic_task_tlm_collector, @fsw_tlm_collector, @apcs, @command_sender, @module_fs, @module_telem, @fdir, @medic, @realtime_destination, @entry_size, @check_aspect, @target, @fdir_script_file_id, @fdir_config_file, @fdir_demo_fmc, @fault_trigger_time_s)
      #cspReboot(@board)
    end
  end

  def test_CS_FS_10_SUPERVISOR_TEST
    status_bar("CS_FS_10_SUPERVISOR_TEST")
    wait(30)
    check_task_count(@collectors, @realtime_destination, @module_telem, @APC_task_count, @FC_task_count, @DPC_task_count)
    check_task_status(@collectors, @module_telem, @realtime_destination, @APC_task_status, @FC_task_status, @DPC_task_status)
    check_failed_count(@collectors, @module_telem, @realtime_destination, @failed_task_count)
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
