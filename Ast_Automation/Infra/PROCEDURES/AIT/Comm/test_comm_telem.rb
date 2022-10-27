load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')

# ------------------------------------------------------------------------------------

class CommTelem < ASTCOSMOSTestComm 
  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @test_util = ModuleTestCase.new
    @target = target
    @csp_destination = "COSMOS_UMBILICAL"
    @wait_time = 3
    super()
  end

  def setup(test_case_name = "COMM_Telemetry")
    @stack = @test_util.initialize_test_case(test_case_name)
    @apc_board = "APC_#{@stack}"
    @module_telem.set_realtime(@apc_board, "COMM_TLM", @csp_destination, 1) 
  end

  # ------------------------------------------------------------------------------------
  def test_uhf_check_telemetry
    setup("UHF_Telemetry")
    uhf_check_SOH(@apc_board)

    start_logging("ALL")
  end

  # ------------------------------------------------------------------------------------
  def test_sband_check_telemetry
    setup("SBand_Telemetry")

    sband_check_SOH(@apc_board)

    start_logging("ALL")
  end

  # ------------------------------------------------------------------------------------
  def uhf_check_SOH(board)
    # Check Telemetry

    packet = board + "-COMM_TLM"
    wait_time = 3


    # UHF
    # ----------
    # UHF_TIMESTAMP (>0)
    #wait_check(@target, packet, "UHF_TIMESTAMP", "> 0", wait_time)
    if tlm(@target, packet, "UHF_TIMESTAMP") <= 0
      Cosmos::Test.puts("Warning: UHF_TIMESTAMP out of range with value " + tlm(@target, packet, "UHF_TIMESTAMP").to_s)
    else
      Cosmos::Test.puts("UHF_TIMESTAMP in range with value " + tlm(@target, packet, "UHF_TIMESTAMP").to_s)
    end

    # UHF_UPTIME_IN_SEC(>0)
    #wait_check(@target, packet, "UHF_UPTIME_IN_SEC", "> 0", wait_time)
    if tlm(@target, packet, "UHF_UPTIME_IN_SEC") <= 0
      Cosmos::Test.puts("Warning: UHF_UPTIME_IN_SEC out of range with value " + tlm(@target, packet, "UHF_UPTIME_IN_SEC").to_s)
    else
      Cosmos::Test.puts("UHF_UPTIME_IN_SEC in range with value " + tlm(@target, packet, "UHF_UPTIME_IN_SEC").to_s)
    end

    # UHF_BOOTCOUNT(>0)
    #wait_check(@target, packet, "UHF_BOOTCOUNT", "> 0", wait_time)
    if tlm(@target, packet, "UHF_BOOTCOUNT") <= 0
      Cosmos::Test.puts("Warning: UHF_BOOTCOUNT out of range with value " + tlm(@target, packet, "UHF_BOOTCOUNT").to_s)
    else
      Cosmos::Test.puts("UHF_BOOTCOUNT in range with value " + tlm(@target, packet, "UHF_BOOTCOUNT").to_s)
    end

    # UHF_LAST_RESET_CAUSE 
    #wait_check(@target, packet, "UHF_LAST_RESET_CAUSE", "== 335544210", wait_time)
    if tlm(@target, packet, "UHF_LAST_RESET_CAUSE") != 335544210
      Cosmos::Test.puts("Warning: UHF_LAST_RESET_CAUSE out of range with value " + tlm(@target, packet, "UHF_LAST_RESET_CAUSE").to_s)
    else
      Cosmos::Test.puts("UHF_LAST_RESET_CAUSE in range with value " + tlm(@target, packet, "UHF_LAST_RESET_CAUSE").to_s)
    end

    # TEMPs

    # UHF_POWER_AMPLIFIER_TEMP (-40 to 85)
    #wait_check(@target, packet, "UHF_POWER_AMPLIFIER_TEMP", "< 85", wait_time)
    #wait_check(@target, packet, "UHF_POWER_AMPLIFIER_TEMP", "> -40", wait_time)
    if tlm(@target, packet, "UHF_POWER_AMPLIFIER_TEMP") > 85 or tlm(@target, packet, "UHF_POWER_AMPLIFIER_TEMP") <-40
      Cosmos::Test.puts("Warning: UHF_POWER_AMPLIFIER_TEMP out of range with value " + tlm(@target, packet, "UHF_POWER_AMPLIFIER_TEMP").to_s)
    else
      Cosmos::Test.puts("UHF_POWER_AMPLIFIER_TEMP in range with value " + tlm(@target, packet, "UHF_POWER_AMPLIFIER_TEMP").to_s)
    end

    # UHF_QUARTZ_TEMP (-40 to 85)
    #wait_check(@target, packet, "UHF_QUARTZ_TEMP", "< 85", wait_time)
    #wait_check(@target, packet, "UHF_QUARTZ_TEMP", "> -40", wait_time)
    if tlm(@target, packet, "UHF_QUARTZ_TEMP") > 85 or tlm(@target, packet, "UHF_QUARTZ_TEMP") <-40
      Cosmos::Test.puts("Warning: UHF_QUARTZ_TEMP out of range with value " + tlm(@target, packet, "UHF_QUARTZ_TEMP").to_s)
    else
      Cosmos::Test.puts("UHF_QUARTZ_TEMP in range with value " + tlm(@target, packet, "UHF_QUARTZ_TEMP").to_s)
    end

    # RSSI

    # UHF_LAST_SYNC_RSSI (-98 to -80) (on orbit)
    if tlm(@target, packet, "UHF_LAST_SYNC_RSSI") < -98 or tlm(@target, packet, "UHF_LAST_SYNC_RSSI") > -80
      Cosmos::Test.puts("Warning: UHF_LAST_SYNC_RSSI out of range with value " + tlm(@target, packet, "UHF_LAST_SYNC_RSSI").to_s)
    else
      Cosmos::Test.puts("UHF_LAST_SYNC_RSSI in range with value " + tlm(@target, packet, "UHF_LAST_SYNC_RSSI").to_s)
    end

    # UHF_AVERAGE_SYNC_RSSI (-101 to -85) (on orbit)
    if tlm(@target, packet, "UHF_AVERAGE_SYNC_RSSI") < -101 or tlm(@target, packet, "UHF_AVERAGE_SYNC_RSSI") > -85
      Cosmos::Test.puts("Warning: UHF_AVERAGE_SYNC_RSSI out of range with value " + tlm(@target, packet, "UHF_AVERAGE_SYNC_RSSI").to_s)
    else
      Cosmos::Test.puts("UHF_AVERAGE_SYNC_RSSI in range with value " + tlm(@target, packet, "UHF_AVERAGE_SYNC_RSSI").to_s)
    end

    # UHF_LAST_PACKET_RSSI (-98 to -80) (on orbit)
    if tlm(@target, packet, "UHF_LAST_PACKET_RSSI") < -98 or tlm(@target, packet, "UHF_LAST_PACKET_RSSI") > -80
      Cosmos::Test.puts("Warning: UHF_LAST_PACKET_RSSI out of range with value " + tlm(@target, packet, "UHF_LAST_PACKET_RSSI").to_s)
    else
      Cosmos::Test.puts("UHF_LAST_PACKET_RSSI in range with value " + tlm(@target, packet, "UHF_LAST_PACKET_RSSI").to_s)
    end

    # UHF_AVERAGE_PACKET_RSSI (-101 to -85) (on orbit)
    if tlm(@target, packet, "UHF_AVERAGE_PACKET_RSSI") < -101 or tlm(@target, packet, "UHF_AVERAGE_PACKET_RSSI") > -85
      Cosmos::Test.puts("Warning: UHF_AVERAGE_PACKET_RSSI out of range with value " + tlm(@target, packet, "UHF_AVERAGE_PACKET_RSSI").to_s)
    else
      Cosmos::Test.puts("UHF_AVERAGE_PACKET_RSSI in range with value " + tlm(@target, packet, "UHF_AVERAGE_PACKET_RSSI").to_s)
    end

    # UHF_ENVIRONMENT_RSSI (-116 to -106) (on orbit)
    if tlm(@target, packet, "UHF_ENVIRONMENT_RSSI") < -116 or tlm(@target, packet, "UHF_ENVIRONMENT_RSSI") > -106
      Cosmos::Test.puts("Warning: UHF_ENVIRONMENT_RSSI out of range with value " + tlm(@target, packet, "UHF_ENVIRONMENT_RSSI").to_s)
    else
      Cosmos::Test.puts("UHF_ENVIRONMENT_RSSI in range with value " + tlm(@target, packet, "UHF_ENVIRONMENT_RSSI").to_s)
    end

    # Counters

    # UHF_TX_PACKET_COUNTER
    #wait_check(@target, packet, "UHF_TX_PACKET_COUNTER", ">= 0", wait_time)
    if tlm(@target, packet, "UHF_TX_PACKET_COUNTER") < 0
      Cosmos::Test.puts("Warning: UHF_TX_PACKET_COUNTER out of range with value " + tlm(@target, packet, "UHF_TX_PACKET_COUNTER").to_s)
    else
      Cosmos::Test.puts("UHF_TX_PACKET_COUNTER in range with value " + tlm(@target, packet, "UHF_TX_PACKET_COUNTER").to_s)
    end

    # UHF_TX_BYTE_COUNTER
    #wait_check(@target, packet, "UHF_TX_BYTE_COUNTER", ">= 0", wait_time)
    if tlm(@target, packet, "UHF_TX_BYTE_COUNTER") < 0
      Cosmos::Test.puts("Warning: UHF_TX_BYTE_COUNTER out of range with value " + tlm(@target, packet, "UHF_TX_BYTE_COUNTER").to_s)
    else
      Cosmos::Test.puts("UHF_TX_BYTE_COUNTER in range with value " + tlm(@target, packet, "UHF_TX_BYTE_COUNTER").to_s)
    end

    # UHF_RX_PACKET_COUNTER
    #wait_check(@target, packet, "UHF_RX_PACKET_COUNTER", ">= 0", wait_time)
    if tlm(@target, packet, "UHF_RX_PACKET_COUNTER") < 0
      Cosmos::Test.puts("Warning: UHF_RX_PACKET_COUNTER out of range with value " + tlm(@target, packet, "UHF_RX_PACKET_COUNTER").to_s)
    else
      Cosmos::Test.puts("UHF_RX_PACKET_COUNTER in range with value " + tlm(@target, packet, "UHF_RX_PACKET_COUNTER").to_s)
    end

    # UHF_RX_BYTE_COUNTER
    #wait_check(@target, packet, "UHF_RX_BYTE_COUNTER", ">= 0", wait_time)
    if tlm(@target, packet, "UHF_RX_BYTE_COUNTER") < 0
      Cosmos::Test.puts("Warning: UHF_RX_BYTE_COUNTER out of range with value " + tlm(@target, packet, "UHF_RX_BYTE_COUNTER").to_s)
    else
      Cosmos::Test.puts("UHF_RX_BYTE_COUNTER in range with value " + tlm(@target, packet, "UHF_RX_BYTE_COUNTER").to_s)
    end

    # UHF_BAD_CRC_COUNTER
    #wait_check(@target, packet, "UHF_BAD_CRC_COUNTER", ">= 0", wait_time)
    if tlm(@target, packet, "UHF_BAD_CRC_COUNTER") < 0
      Cosmos::Test.puts("Warning: UHF_BAD_CRC_COUNTER out of range with value " + tlm(@target, packet, "UHF_BAD_CRC_COUNTER").to_s)
    else
      Cosmos::Test.puts("UHF_BAD_CRC_COUNTER in range with value " + tlm(@target, packet, "UHF_BAD_CRC_COUNTER").to_s)
    end

    # UHF_BAD_VERSION_COUNTER
    #wait_check(@target, packet, "UHF_BAD_VERSION_COUNTER", "> 0", wait_time)

    # UHF_BEACON_TX_COUNTER
    #wait_check(@target, packet, "UHF_BEACON_TX_COUNTER", ">= 0", wait_time)
    if tlm(@target, packet, "UHF_BEACON_TX_COUNTER") < 0
      Cosmos::Test.puts("Warning: UHF_BEACON_TX_COUNTER out of range with value " + tlm(@target, packet, "UHF_BEACON_TX_COUNTER").to_s)
    else
      Cosmos::Test.puts("UHF_BEACON_TX_COUNTER in range with value " + tlm(@target, packet, "UHF_BEACON_TX_COUNTER").to_s)
    end
    
    # Watchdog Timer

    # Reset watchdog timer
    @cmd_sender.send_with_cmd_count_check(board, "UHF_GSWDT_RST", {}, "COMM", 4)
    
    # UHF_GS_WDT_TIME_LEFT_IN_SEC
    #wait_check(@target, packet, "UHF_GS_WDT_TIME_LEFT_IN_SEC", ">= 0", wait_time)
    if tlm(@target, packet, "UHF_GS_WDT_TIME_LEFT_IN_SEC") < 0
      Cosmos::Test.puts("Warning: UHF_GS_WDT_TIME_LEFT_IN_SEC out of range with value " + tlm(@target, packet, "UHF_GS_WDT_TIME_LEFT_IN_SEC").to_s)
    else
      Cosmos::Test.puts("UHF_GS_WDT_TIME_LEFT_IN_SEC in range with value " + tlm(@target, packet, "UHF_GS_WDT_TIME_LEFT_IN_SEC").to_s)
    end

    # UHF_GS_WDT_COUNTER
    #wait_check(@target, packet, "UHF_GS_WDT_COUNTER", "> 0", wait_time)

    #UHF_PRIMARY_TRANS
    #UHF_CURRENT_ANT
    #UHF_DEPLOY_MON_CMD_EXEC
    #UHF_DEPLOY_HELIX_CMD_EXEC
    #UHF_IS_TX_ON
    #UHF_PRESENCE

  end

  # S-band
  # ----------
  def sband_check_SOH(board)
   
    packet = board + "-COMM_TLM"
    wait_time = 3
    cmd_params = {"TLM_PACKET_NAME": "PAYLOAD_TLM",
                  "DESTINATION_CSP_ID": "SBAND_GS",
                  "FREQ": 25}
    @cmd_sender.send(@apc_board, "FSW_SET_REALTIME", cmd_params) 
    
    wait(5)

    # SBAND_BOOTCOUNT ( => 0)
    #wait_check(@target, packet, "SBAND_BOOTCOUNT", ">= 0", wait_time)
    if tlm(@target, packet, "SBAND_BOOTCOUNT") < 0
      Cosmos::Test.puts("Warning: SBAND_BOOTCOUNT out of range with value " + tlm(@target, packet, "SBAND_BOOTCOUNT").to_s)
    else
      Cosmos::Test.puts("SBAND_BOOTCOUNT in range with value " + tlm(@target, packet, "SBAND_BOOTCOUNT").to_s)
    end

    # SBAND_CMD_COUNTER ( => 0)
    #wait_check(@target, "#{board}-FSW_TLM_APC", "SBAND_CMD_COUNTER", ">= 0", wait_time)
    if tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_CMD_COUNTER") < 0
      Cosmos::Test.puts("Warning: SBAND_CMD_COUNTER out of range with value " + tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_CMD_COUNTER").to_s)
    else
      Cosmos::Test.puts("SBAND_CMD_COUNTER in range with value " + tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_CMD_COUNTER").to_s)
    end

    # SBAND_CUR_V3V3 (150-400)
    #wait_check(@target,  packet, "SBAND_CUR_V3V3", ">= 0", wait_time)
    if tlm(@target, packet, "SBAND_CUR_V3V3") < 150 or tlm(@target, packet, "SBAND_CUR_V3V3") > 400
      Cosmos::Test.puts("Warning: SBAND_CUR_V3V3 out of range with value " + tlm(@target, packet, "SBAND_CUR_V3V3").to_s)
    else
      Cosmos::Test.puts("SBAND_CUR_V3V3 in range with value " + tlm(@target, packet, "SBAND_CUR_V3V3").to_s)
    end

    # SBAND_CUR_VIN ( => 0)
    #wait_check(@target, packet, "SBAND_CUR_VIN", ">= 0", wait_time)
    if tlm(@target, packet, "SBAND_CUR_VIN") < 0
      Cosmos::Test.puts("Warning: SBAND_CUR_VIN out of range with value " + tlm(@target, packet, "SBAND_CUR_VIN").to_s)
    else
      Cosmos::Test.puts("SBAND_CUR_VIN in range with value " + tlm(@target, packet, "SBAND_CUR_VIN").to_s)
    end

    # SBAND_CUR_VREG ( 800 to 1200)
    #wait_check_tolerance(@target, packet, "SBAND_CUR_VREG", 5, 5, wait_time)
    if tlm(@target, packet, "SBAND_CUR_VREG") < 800 or tlm(@target, packet, "SBAND_CUR_VREG") > 1200
      Cosmos::Test.puts("Warning: SBAND_CUR_VREG out of range with value " + tlm(@target, packet, "SBAND_CUR_VREG").to_s)
    else
      Cosmos::Test.puts("SBAND_CUR_VREG in range with value " + tlm(@target, packet, "SBAND_CUR_VREG").to_s)
    end

    # SBAND_CURRENT_ANT (0 to 1) (.5 +/- .5)
    #wait_check_tolerance(@target, packet, "SBAND_CURRENT_ANT", 0, 1, wait_time)
    if tlm(@target, packet, "SBAND_CURRENT_ANT") != "SBAND_ANT_YP_YM" and tlm(@target, packet, "SBAND_CURRENT_ANT") != "SBAND_ANT_NADIR"
      Cosmos::Test.puts("Warning: SBAND_CURRENT_ANT out of range with value " + tlm(@target, packet, "SBAND_CURRENT_ANT").to_s)
    else
      Cosmos::Test.puts("SBAND_CURRENT_ANT in range with value " + tlm(@target, packet, "SBAND_CURRENT_ANT").to_s)
    end

    # SBAND_CURRENT_RX_ANT (0 to 1) (0.5 +/- 0.5)
    #wait_check_tolerance(@target, packet, "SBAND_CURRENT_RX_ANT", 0.5, 0.5, wait_time)
    if tlm(@target, packet, "SBAND_CURRENT_RX_ANT") != "SBAND_ANT_YP_YM" and tlm(@target, packet, "SBAND_CURRENT_RX_ANT") != "SBAND_ANT_NADIR"
      Cosmos::Test.puts("Warning: SBAND_CURRENT_RX_ANT out of range with value " + tlm(@target, packet, "SBAND_CURRENT_RX_ANT").to_s)
    else 
      Cosmos::Test.puts("SBAND_CURRENT_RX_ANT in range with value " + tlm(@target, packet, "SBAND_CURRENT_RX_ANT").to_s)
    end

    # SBAND_CURRENT_TX_ANT (-100 to 100) (0 +/- 100)
    #wait_check_tolerance(@target, packet, "SBAND_CURRENT_TX_ANT", 0, 100, wait_time)
    if tlm(@target, packet, "SBAND_CURRENT_TX_ANT") != "SBAND_ANT_YP_YM" and tlm(@target, packet, "SBAND_CURRENT_TX_ANT") != "SBAND_ANT_NADIR"
      Cosmos::Test.puts("Warning: SBAND_CURRENT_TX_ANT out of range with value " + tlm(@target, packet, "SBAND_CURRENT_TX_ANT").to_s)
    else 
      Cosmos::Test.puts("SBAND_CURRENT_TX_ANT in range with value " + tlm(@target, packet, "SBAND_CURRENT_TX_ANT").to_s)
    end

    # Check if the RX and TX ANT are the same
    tx_tlm = tlm(@target, packet, "SBAND_CURRENT_TX_ANT")
    #wait_check(@target, packet, "SBAND_CURRENT_RX_ANT", tx_tlm, wait_time)
    if tlm(@target, packet, "SBAND_CURRENT_RX_ANT") != tx_tlm
      Cosmos::Test.puts("Warning: SBAND_CURRENT_RX_ANT is not the same as SBAND_CURRENT_TX_ANT with value " + tlm(@target, packet, "SBAND_CURRENT_RX_ANT").to_s)
    else
      Cosmos::Test.puts("SBAND_CURRENT_RX_ANT is the same as SBAND_CURRENT_TX_ANT with value " + tlm(@target, packet, "SBAND_CURRENT_RX_ANT").to_s)
    end

    # SBAND_PRESENCE (1) 
    #wait_check(@target, packet, "SBAND_PRESENCE", "== 'PRESENT'", wait_time)
    if tlm(@target, packet, "SBAND_PRESENCE") != 'PRESENT'
      Cosmos::Test.puts("Warning: SBAND_PRESENCE out of range with value " + tlm(@target, packet, "SBAND_PRESENCE").to_s)
    else
      Cosmos::Test.puts("SBAND_PRESENCE in range with value " + tlm(@target, packet, "SBAND_PRESENCE").to_s)
    end

    # SBAND_ERROR_COUNTER ( > 0)
    #wait_check(@target, "#{board}-FSW_TLM_APC", "SBAND_ERROR_COUNTER", ">=0", wait_time)
    if tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_ERROR_COUNTER") < 0
      Cosmos::Test.puts("Warning: SBAND_ERROR_COUNTER out of range with value " + tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_ERROR_COUNTER").to_s)
    else
      Cosmos::Test.puts("SBAND_ERROR_COUNTER in range with value " + tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_ERROR_COUNTER").to_s)
    end

    # SBAND_GWD_COUNTER (0 - time out value) (time out value/2 +/- time out value/2)
    get_sband_diagnostic_packet(board)
    max_counter = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_GWDTINIT")
    #wait_check_tolerance(@target, packet, "SBAND_GWD_COUNTER", max_counter/2, max_counter/2, wait_time)
    if tlm(@target, packet, "SBAND_GWD_COUNTER") < 0 or tlm(@target, packet, "SBAND_GWD_COUNTER") > max_counter
      Cosmos::Test.puts("Warning: SBAND_GWD_COUNTER out of range with value " + tlm(@target, packet, "SBAND_GWD_COUNTER").to_s)
    else
      Cosmos::Test.puts("SBAND_GWD_COUNTER in range with value " + tlm(@target, packet, "SBAND_GWD_COUNTER").to_s)
    end

    # SBAND_INIT (-100 to 100) (0 +/- 100) #UPDATE - not a range, its 0 or 1 (GENERAL_OK or GENERAL_UNINITIALIZED) in the database
    #wait_check_tolerance(@target, "#{board}-FSW_TLM_APC", "SBAND_INIT", 0, 100, wait_time)

    #SBAND_LAST_ERROR ( => 0) # UPDATE either 0 (GENERAL_OK) or 11 (GENERAL_UNITIIALIZED)
    #wait_check(@target, "#{board}-FSW_TLM_APC", "SBAND_LAST_ERROR", ">= 0", wait_time)

    # SBAND_LAST_RSSI ( =< 0)
    #wait_check(@target, packet, "SBAND_LAST_RSSI", "<= 0", wait_time)
    if tlm(@target, packet, "SBAND_LAST_RSSI") > 0
      Cosmos::Test.puts("Warning: SBAND_LAST_RSSI out of range with value " + tlm(@target, packet, "SBAND_LAST_RSSI").to_s)
    else
      Cosmos::Test.puts("SBAND_LAST_RSSI in range with value " + tlm(@target, packet, "SBAND_LAST_RSSI").to_s)
    end

    # SBAND_POWER_V3V3 (3100 to 3500)
    #wait_check(@target, packet, "SBAND_POWER_V3V3", ">= 0", wait_time)
    if tlm(@target, packet, "SBAND_POWER_V3V3") < 3100 or tlm(@target, packet, "SBAND_POWER_V3V3") > 3500
      Cosmos::Test.puts("Warning: SBAND_POWER_V3V3 out of range with value " + tlm(@target, packet, "SBAND_POWER_V3V3").to_s)
    else
      Cosmos::Test.puts("SBAND_POWER_V3V3 in range with value " + tlm(@target, packet, "SBAND_POWER_V3V3").to_s)
    end

    # SBAND_POWER_VIN ( => 0)
    #wait_check(@target, packet, "SBAND_POWER_VIN", ">= 0", wait_time)
    if tlm(@target, packet, "SBAND_POWER_VIN") < 0
      Cosmos::Test.puts("Warning: SBAND_POWER_VIN out of range with value " + tlm(@target, packet, "SBAND_POWER_VIN").to_s)
    else
      Cosmos::Test.puts("SBAND_POWER_VIN in range with value " + tlm(@target, packet, "SBAND_POWER_VIN").to_s)
    end

    # SBAND_POWER_VREG ( 3000 to 5000)
    #wait_check_tolerance(@target, packet, "SBAND_POWER_VREG", 25, 25, wait_time)
    if tlm(@target, packet, "SBAND_POWER_VREG") < 3000 or tlm(@target, packet, "SBAND_POWER_VREG") > 5000
      Cosmos::Test.puts("Warning: SBAND_POWER_VREG out of range with value " + tlm(@target, packet, "SBAND_POWER_VREG").to_s)
    else
      Cosmos::Test.puts("SBAND_POWER_VREG in range with value " + tlm(@target, packet, "SBAND_POWER_VREG").to_s)
    end

    # SBAND_PRIMARY_TRANS (0 or 1) #UPDATE - value is not zero, it is a string
    #wait_check(@target, packet, "SBAND_PRIMARY_TRANS", ">= 0", wait_time)
    if tlm(@target, packet, "SBAND_PRIMARY_TRANS") !="SBAND_TRANS_YM" and tlm(@target, packet, "SBAND_PRIMARY_TRANS") !="SBAND_TRANS_YM"
      Cosmos::Test.puts("Warning: SBAND_PRIMARY_TRANS out of range with value " + tlm(@target, packet, "SBAND_PRIMARY_TRANS").to_s)
    else
      Cosmos::Test.puts("SBAND_PRIMARY_TRANS in range with value " + tlm(@target, packet, "SBAND_PRIMARY_TRANS").to_s)
    end

    # SBAND_RX_FRAMES ( == 0)
    #wait_check(@target, packet, "SBAND_RX_FRAMES", "== 0", wait_time)
    if tlm(@target, packet, "SBAND_RX_FRAMES") != 0
      Cosmos::Test.puts("Warning: SBAND_RX_FRAMES out of range with value " + tlm(@target, packet, "SBAND_RX_FRAMES").to_s)
    else
      Cosmos::Test.puts("SBAND_RX_FRAMES in range with value " + tlm(@target, packet, "SBAND_RX_FRAMES").to_s)
    end

    # SBAND_TEMP_LNA (-40 to 85) divide telemetry by 100
    #wait_check_tolerance(@target, packet, "SBAND_TEMP_LNA", 22.5, 62.5, wait_time)
    if tlm(@target, packet, "SBAND_TEMP_LNA") < -4000 or tlm(@target, packet, "SBAND_TEMP_LNA") > 8500
      Cosmos::Test.puts("Warning: SBAND_TEMP_LNA out of range with value " + tlm(@target, packet, "SBAND_TEMP_LNA").to_s)
    else
      Cosmos::Test.puts("SBAND_TEMP_LNA in range with value " + tlm(@target, packet, "SBAND_TEMP_LNA").to_s)
    end

    # SBAND_TEMP_MCU (-40 to 70) divide telem by 100
    #wait_check_tolerance(@target, packet, "SBAND_TEMP_MCU", 15, 55, wait_time)
    if tlm(@target, packet, "SBAND_TEMP_MCU") < -4000 or tlm(@target, packet, "SBAND_TEMP_MCU") > 7000
      Cosmos::Test.puts("Warning: SBAND_TEMP_MCU out of range with value " + tlm(@target, packet, "SBAND_TEMP_MCU").to_s)
    else
      Cosmos::Test.puts("SBAND_TEMP_MCU in range with value " + tlm(@target, packet, "SBAND_TEMP_MCU").to_s)
    end  

    # SBAND_TEMP_PA (15 +/- 55) divide telemetry by 100
    #wait_check_tolerance(@target, packet, "SBAND_TEMP_PA", 15, 55, wait_time)
    if tlm(@target, packet, "SBAND_TEMP_PA") < -4000 or tlm(@target, packet, "SBAND_TEMP_PA") > 7000
      Cosmos::Test.puts("Warning: SBAND_TEMP_PA out of range with value " + tlm(@target, packet, "SBAND_TEMP_PA").to_s)
    else
      Cosmos::Test.puts("SBAND_TEMP_PA in range with value " + tlm(@target, packet, "SBAND_TEMP_PA").to_s)
    end

    # SBAND_TEMP_POWER (15 +/- 55) divide telemetry by 100
    #wait_check_tolerance(@target, packet, "SBAND_TEMP_POWER", 15, 55, wait_time)
    if tlm(@target, packet, "SBAND_TEMP_POWER") < -4000 or tlm(@target, packet, "SBAND_TEMP_POWER") > 7000
      Cosmos::Test.puts("Warning: SBAND_TEMP_POWER out of range with value " + tlm(@target, packet, "SBAND_TEMP_POWER").to_s)
    else
      Cosmos::Test.puts("SBAND_TEMP_POWER in range with value " + tlm(@target, packet, "SBAND_TEMP_POWER").to_s)
    end

    # SBAND_TLM_COUNTER ( => 0)
    #wait_check(@target, "#{board}-FSW_TLM_APC", "SBAND_TLM_COUNTER", ">= 0", wait_time)
    if tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_TLM_COUNTER") < 0
      Cosmos::Test.puts("Warning: SBAND_TLM_COUNTER out of range with value " + tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_TLM_COUNTER").to_s)
    else
      Cosmos::Test.puts("SBAND_TLM_COUNTER in range with value " + tlm(@target, "#{board}-FSW_TLM_APC", "SBAND_TLM_COUNTER").to_s)
    end

    # SBAND_TX_FRAMES ( => 0)
    #wait_check(@target, packet, "SBAND_TX_FRAMES", ">= 0", wait_time) 
    if tlm(@target, packet, "SBAND_TX_FRAMES") < 0
      Cosmos::Test.puts("Warning: SBAND_TX_FRAMES out of range with value " + tlm(@target, packet, "SBAND_TX_FRAMES").to_s)
    else
      Cosmos::Test.puts("SBAND_TX_FRAMES in range with value " + tlm(@target, packet, "SBAND_TX_FRAMES").to_s)
    end

    # SBAND_TX_POWER_FWD (current value +/- 0.5)
    get_sband_diagnostic_packet(board)
    current_value = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXPOUT")
    #wait_check_tolerance(@target, packet, "SBAND_TX_POWER_FWD", current_value, 0.5, wait_time)
    if tlm(@target, packet, "SBAND_TX_POWER_FWD") < current_value-0.5 or tlm(@target, packet, "SBAND_TX_POWER_FWD") > current_value+0.5 
      Cosmos::Test.puts("Warning: SBAND_TX_POWER_FWD out of range with value " + tlm(@target, packet, "SBAND_TX_POWER_FWD").to_s)
    else
      Cosmos::Test.puts("SBAND_TX_POWER_FWD in range with value " + tlm(@target, packet, "SBAND_TX_POWER_FWD").to_s)
    end

    # SBAND_VOLT_V3V3 (3.2 - 3.4) (3.3 +/- 0.1)
    #wait_check_tolerance(@target, packet, "SBAND_VOLT_V3V3", 3.3, 0.1, wait_time
    if tlm(@target, packet, "SBAND_VOLT_V3V3") < 3100 or tlm(@target, packet, "SBAND_VOLT_V3V3") > 3500
      Cosmos::Test.puts("Warning: SBAND_VOLT_V3V3 out of range with value " + tlm(@target, packet, "SBAND_VOLT_V3V3").to_s)
    else
      Cosmos::Test.puts("SBAND_VOLT_V3V3 in range with value " + tlm(@target, packet, "SBAND_VOLT_V3V3").to_s)
    end

    # SBAND_VOLT_VIN (11800 - 12200 mv)
    #wait_check_tolerance(@target, packet, "SBAND_VOLT_VIN", 22.5, 17.5, wait_time)
    if tlm(@target, packet, "SBAND_VOLT_VIN") < 11800 or tlm(@target, packet, "SBAND_VOLT_VIN") > 12200
      Cosmos::Test.puts("Warning: SBAND_VOLT_VIN out of range with value " + tlm(@target, packet, "SBAND_VOLT_VIN").to_s)
    else
      Cosmos::Test.puts("SBAND_VOLT_VIN in range with value " + tlm(@target, packet, "SBAND_VOLT_VIN").to_s)
    end

    # SBAND_VOLT_VREG (3500 - 4000)
    #wait_check_tolerance(@target, packet, "SBAND_VOLT_VREG", 3.75, 0.2, wait_time)
    if tlm(@target, packet, "SBAND_VOLT_VREG") > 4000 or tlm(@target, packet, "SBAND_VOLT_VREG") < 3500
      Cosmos::Test.puts("Warning: SBAND_VOLT_VREG out of range with value " + tlm(@target, packet, "SBAND_VOLT_VREG").to_s)
    else
      Cosmos::Test.puts("SBAND_VOLT_VREG in range with value " + tlm(@target, packet, "SBAND_VOLT_VREG").to_s)
    end

    # SBAND_ALCLGAIN ( => 0)
    #wait_check(@target, packet, "SBAND_ALCLGAIN", ">= 0", wait_time)
    if tlm(@target, packet, "SBAND_ALCLGAIN") < 0
      Cosmos::Test.puts("Warning: SBAND_ALCLGAIN out of range with value " + tlm(@target, packet, "SBAND_ALCLGAIN").to_s)
    else
      Cosmos::Test.puts("SBAND_ALCLGAIN in range with value " + tlm(@target, packet, "SBAND_ALCLGAIN").to_s)
    end

    # SBAND_RX_DETECTED ( == 0)
    #wait_check(@target, packet, "SBAND_RX_DETECTED", "== 0", wait_time)
    if tlm(@target, packet, "SBAND_RX_DETECTED") != 0
      Cosmos::Test.puts("Warning: SBAND_RX_DETECTED out of range with value " + tlm(@target, packet, "SBAND_RX_DETECTED").to_s)
    else
      Cosmos::Test.puts("SBAND_RX_DETECTED in range with value " + tlm(@target, packet, "SBAND_RX_DETECTED").to_s)
    end

    # SBAND_RX_PLLNOLOCK ( == 0)
    #wait_check(@target, packet, "SBAND_RX_PLLNOLOCK", "== 0", wait_time)
    if tlm(@target, packet, "SBAND_RX_PLLNOLOCK") != 0
      Cosmos::Test.puts("Warning: SBAND_RX_PLLNOLOCK out of range with value " + tlm(@target, packet, "SBAND_RX_PLLNOLOCK").to_s)
    else
      Cosmos::Test.puts("SBAND_RX_PLLNOLOCK in range with value " + tlm(@target, packet, "SBAND_RX_PLLNOLOCK").to_s)
    end

    # SBAND_TX_OVERPWR ( == 0)
    #wait_check(@target, packet, "SBAND_TX_OVERPWR", "== 0", wait_time)
    if tlm(@target, packet, "SBAND_TX_OVERPWR") != 0
      Cosmos::Test.puts("Warning: SBAND_TX_OVERPWR out of range with value " + tlm(@target, packet, "SBAND_TX_OVERPWR").to_s)
    else
      Cosmos::Test.puts("SBAND_TX_OVERPWR in range with value " + tlm(@target, packet, "SBAND_TX_OVERPWR").to_s)
    end

    # SBAND_TX_PLLNOLOCK ( => 0)
    #wait_check(@target, packet, "SBAND_TX_PLLNOLOCK", "== 0", wait_time)
    if tlm(@target, packet, "SBAND_TX_PLLNOLOCK") != 0
      Cosmos::Test.puts("Warning: SBAND_TX_PLLNOLOCK out of range with value " + tlm(@target, packet, "SBAND_TX_PLLNOLOCK").to_s)
    else
      Cosmos::Test.puts("SBAND_TX_PLLNOLOCK in range with value " + tlm(@target, packet, "SBAND_TX_PLLNOLOCK").to_s)
    end
 
    # SBAND_TX_PWDRFL ( <=20)
    #wait_check(@target, packet, "SBAND_TX_PWDRFL", "<= 20", wait_time)
    if tlm(@target, packet, "SBAND_TX_PWDRFL") >20
      Cosmos::Test.puts("Warning: SBAND_TX_PWDRFL out of range with value " + tlm(@target, packet, "SBAND_TX_PWDRFL").to_s)
    else
      Cosmos::Test.puts("SBAND_TX_PWDRFL in range with value " + tlm(@target, packet, "SBAND_TX_PWDRFL").to_s)
    end

    # SBAND_RX_FREQERR ( 0 +/- 0.01) (10 KHz) - value in MHz
    #wait_check_tolerance(@target, packet, "SBAND_RX_FREQERR", 0, 0.01, wait_time)
    if tlm(@target, packet, "SBAND_RX_FREQERR") < -0.01 or tlm(@target, packet, "SBAND_RX_FREQERR") > 0.01
      Cosmos::Test.puts("Warning: SBAND_RX_FREQERR out of range with value " + tlm(@target, packet, "SBAND_RX_FREQERR").to_s)
    else
      Cosmos::Test.puts("SBAND_RX_FREQERR in range with value " + tlm(@target, packet, "SBAND_RX_FREQERR").to_s)
    end
    cmd_params = {"TLM_PACKET_NAME": "PAYLOAD_TLM",
                  "DESTINATION_CSP_ID": "SBAND_GS",
                  "FREQ": 0}
    @cmd_sender.send(@apc_board, "FSW_SET_REALTIME", cmd_params) 
  end

    # QVA
    # ----------
    #QVA_AZ_ELEV_TABLE_ID
    #QVA_AZ_ELEV_TABLE_IDX
    #QVA_AZ_ELEV_AZIMUTH
    #QVA_AZ_ELEV_ELEVATION
    #QVA_TEMP_CNTLR_INDEX
    #QVA_TEMP_CNTLR_TEMP
    #QVA_TEMP_CNTLR_TIMESTAMP
    #QVA_TEMP_AZ_ENCODER_INDEX
    #QVA_TEMP_AZ_ENCODER_TEMP
    #QVA_TEMP_AZ_ENCODER_TIMESTAMP
    #QVA_TEMP_AZ_DRIVE_INDEX
    #QVA_TEMP_AZ_DRIVE_TEMP
    #QVA_TEMP_AZ_DRIVE_TIMESTAMP
    #QVA_TEMP_ELEV_ENCODER_INDEX
    #QVA_TEMP_ELEV_ENCODER_TEMP
    #QVA_TEMP_ELEV_ENCODER_TIMESTAMP
    #QVA_TEMP_ELEV_DRIVE_INDEX
    #QVA_TEMP_ELEV_DRIVE_TEMP
    #QVA_TEMP_ELEV_DRIVE_TIMESTAMP
    #QVA_TEMP_PCB_INDEX
    #QVA_TEMP_PCB_TEMP
    #QVA_TEMP_PCB_TIMESTAMP
    #QVA_CURR_AZ_MOTOR_INDEX
    #QVA_CURR_AZ_MOTOR_CURR
    #QVA_CURR_AZ_MOTOR_TIMESTAMP
    #QVA_CURR_ELEV_MOTOR_INDEX
    #QVA_CURR_ELEV_MOTOR_CURR
    #QVA_CURR_ELEV_MOTOR_TIMESTAMP
    #QVA_CURR_TILT_MOTOR_INDEX
    #QVA_CURR_TILT_MOTOR_CURR
    #QVA_CURR_TILT_MOTOR_TIMESTAMP
    #QVA_VEHICLE_OFFSET_AZIMUTH
    #QVA_VEHICLE_OFFSET_ELEV
    #QVA_VEHICLE_OFFSET_TIMESTAMP
    #QVA_STATUS_LAST_ERROR
    #QVA_STATUS_CURRENT_STATE
    #QVA_STATUS_TIMESTAMP
    #QVA_TABLE_STATUS_LOAD
    #QVA_TABLE_STATUS_VALIDATE
    #QVA_TABLE_STATUS_RUN
    #QVA_PRESENCE
    #QVT_PRIMARY_TRANS
    #QVT_CURRENT_ANT
    #QVT_PLL_RX_LOCK
    #QVT_PLL_TX_LOCK
    #QVT_TEMP
    #QVT_CLK_DETECTION
    #QVT_COMPARATOR_CLK_DETECT
    #QVT_TX_DETECT_LEVEL
    #QVT_P12V_LEVEL
    #QVT_P5V_LEVEL
    #QVT_P6V5_LEVEL
    #QVT_N5V_LEVEL
    #QVT_PWR_GOOD
    #QVT_PLL_LOW_IF_LOCK
    #QVT_PLL_MID_IF_LOCK
    #QVT_PLL_HIGH_IF_LOCK
    #QVT_PRESENCE



    
    #RTC_TIME
    #PA_POWER_DETECT
    #PA_TEMP_SENSE
    #PA_PRESENCE
    
    def get_sband_diagnostic_packet(board)

      # Get current packet received count
      orig_rec_count = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "RECEIVED_COUNT")
  
      # Request Diagnostics packet
      @cmd_sender.send_with_cmd_count_check(board, "SBAND_SEND_DIAGNOSTIC_PKT", {}, "COMM", @wait_time)
  
      # Verify the packet count increased
      wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "RECEIVED_COUNT", "==#{orig_rec_count + 1}", @wait_time)
    end

end
#handle = CommTelem.new
#handle.test_uhf_check_telemetry_APC_YP
