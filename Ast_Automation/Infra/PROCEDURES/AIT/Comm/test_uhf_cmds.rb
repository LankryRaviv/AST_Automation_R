load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/FSW/FSW_Config.rb')
load_utility('Operations/COMM/COMM_TTC.rb')
load_utility('Operations/COMM/UHF_Config_Params.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')

# ------------------------------------------------------------------------------------

class UHFCmdTest < ASTCOSMOSTestComm 

  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @module_ttc = ModuleTTC.new
    @target = target
    @csp_destination = "COSMOS_UMBILICAL"
    @uhf_config = UHFConfig.new
    @test_util = ModuleTestCase.new
    @wait_time = 10
    super()

    @test_list = ["diagnostic_packet_test",
        "watchdog_test",
        "transmitter_test",
        "doppler_shift_test",
        "rf_power_test",
        "rf_address_test",
        "tx_freq_test",
        "txrx_mod_test",
        "rx_mod_test",
        "tx_mod_test",
        "rx_freq_test",
        "beacon_test"]
        #"configuration_update"]
        #
  end


  def test_all_UHF_cmds
    stack = @test_util.initialize_test_case('UHF_CMDs')
    board = "APC_" + stack

    # Turn on telemetry
    @module_telem.set_realtime(board, "COMM_TLM", @csp_destination, 1) 

    @test_list.each do |test|

      # Construct method name
      method_name = test

      Cosmos::Test.puts("Starting test #{test}")

      # Turn on Switch
      public_send(method_name, board)   

      Cosmos::Test.puts("Completed test #{test}")
  
    end
      
    @test_util.teardown()
  end

  def test_select_UHF_cmd
    stack = @test_util.initialize_test_case('UHF_CMDs')
    board = "APC_" + stack

    # Turn on telemetry
    @module_telem.set_realtime(board, "COMM_TLM", @csp_destination, 1) 

    ask_for_test = true
    while ask_for_test

      # Get test
      test = combo_box("Select test.\n\nSelect 'Exit Procedure' to stop", "diagnostic_packet_test", "watchdog_test", "transmitter_test", "doppler_shift_test", "rf_power_test","rf_address_test","tx_freq_test","txrx_mod_test","rx_mod_test","tx_mod_test", "rx_freq_test", "beacon_test", "Exit Procedure") # "configuration_update"
      #
      if test == "Exit Procedure"
        # Stop procedure
        break
      end

      Cosmos::Test.puts("Starting test #{test}")
      # Construct method name
      public_send(test, board)

      Cosmos::Test.puts("Completed test #{test}")
    end

    @test_util.teardown()

  end


  def diagnostic_packet_test(board)

    # Get current packet received count
    orig_rec_count = tlm(@target, "#{board}-UHF_DIAGNOSTIC", "RECEIVED_COUNT")

    # Request Diagnostics packet
    @cmd_sender.send_with_cmd_count_check(board, "UHF_REQUEST_DIAGNOSTIC", {}, "COMM", @wait_time)

    # Verify the packet count increased
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "RECEIVED_COUNT", "==#{orig_rec_count + 1}", @wait_time)

  end

  def watchdog_test(board)

    # Read time left on watchdog timer
    puts "Time left on watch dog timer = " + (tlm(@target, "#{board}-COMM_TLM", "UHF_GS_WDT_TIME_LEFT_IN_SEC")).to_s
    init_timer = tlm(@target, "#{board}-COMM_TLM", "UHF_GS_WDT_TIME_LEFT_IN_SEC")

    # Reset the watchdog
    @cmd_sender.send_with_cmd_count_check(board, "UHF_GSWDT_RST", {}, "COMM", @wait_time)

    # Check the watchdog was reset
    wait_check(@target, "#{board}-COMM_TLM", "UHF_GS_WDT_TIME_LEFT_IN_SEC", "> #{init_timer}", @wait_time)

  end

  def transmitter_test(board)

    # Turn on transmitter (check counters within send_with_cmd_count_check)
    @cmd_sender.send_with_cmd_count_check(board, "UHF_TXON", {}, "COMM", @wait_time)

    # Check telemetry
    wait_check(@target, "#{board}-COMM_TLM", "UHF_IS_TX_ON", "== 1", @wait_time)

    # Turn on transmitter (check counters within send_with_cmd_count_check)
    @cmd_sender.send_with_cmd_count_check(board, "UHF_TXOFF", {}, "COMM", @wait_time)

    # Check telemetry
    wait_check(@target, "#{board}-COMM_TLM", "UHF_IS_TX_ON", "== 0", @wait_time)
  end

  def doppler_shift_test(board)

    # Read doppler shift telemetry
    @module_ttc.get_uhf_diagnostic_packet(board)
    orig_dplrshft = tlm(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_DPLRSHFT")
    puts "Doppler shift original value: #{orig_dplrshft}"

    # Set the new doppler shift to original + 1
    new_dplr_shft = orig_dplrshft + 1 # Hz
    cmd_params = {"DOPPLER_SHIFT": new_dplr_shft}
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_DPLRSHFT", cmd_params, "COMM", @wait_time)

    # Check doppler shift updated
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_DPLRSHFT", "==#{new_dplr_shft}", @wait_time)

  end

  def rf_power_test(board)

    # Read power first
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check_tolerance(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFPWR", -5, 11, 1) # -16 to 6 (20 to 34.7 dBm)

    # Set the RF power to 30 dBm
    cmd_params = {"POWER": -4} # 30.7 dBm
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_RFPWR", cmd_params, "COMM", @wait_time)

    # Read the RF power 
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFPWR", "==-4", @wait_time) #30.7 dBm
    

    # Read min and max power
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFMINPWR", "<= -4", @wait_time) 
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFMAXPWR", ">= -4", @wait_time) 

    # Set the RF power to 33 dBm
    cmd_params = {"POWER": 0} # 33.3 dBm
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_RFPWR", cmd_params, "COMM", @wait_time)

    # Read the RF power 
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFPWR", "== 0", @wait_time) # 33.3 dBm

    # Read min and max power
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFMINPWR", "<= 0", @wait_time) 
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFMAXPWR", ">= 0", @wait_time) 
  
   
  end

  def rf_address_test(board)
    # Read the RF address 
    @module_ttc.get_uhf_diagnostic_packet(board)
    puts "Original RF Address is " + (tlm(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFADDR")).to_s

    # Set the RF Address to 100
    cmd_params = {"RF_ADDER": 100}
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_RFADDR", cmd_params, "COMM", @wait_time)

    # Read the RF address 
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFADDR", "==100", @wait_time)

    # Set the RF Address to 11111
    cmd_params = {"RF_ADDER": 11111}
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_RFADDR", cmd_params, "COMM", @wait_time)

    # Read the RF address 
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RFADDR", "==11111", @wait_time)

  end

  def tx_freq_test(board)

    # Read the tx frequency
    @module_ttc.get_uhf_diagnostic_packet(board)
    puts "Original tx frequency is " + (tlm(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXFREQ")).to_s

    # Set the frequency to 400 MHz
    #cmd_params = {"TX_FREQ": 400000000}
    #@cmd_sender.send_with_cmd_count_check(board, "UHF_SET_TXFREQ", cmd_params, "COMM", @wait_time)

    # Read the tx frequency
    #wait(0.25)
    #@module_ttc.get_uhf_diagnostic_packet(board)
    #wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXFREQ", "==400000000", @wait_time)

    # Set the frequency to 437.5 MHz
    cmd_params = {"TX_FREQ": 437500000}
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_TXFREQ", cmd_params, "COMM", @wait_time)

    # Read the tx frequency
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXFREQ", "==437500000", @wait_time)
  end

  def txrx_mod_test(board)

    # Read rx and tx modulation setting
    @module_ttc.get_uhf_diagnostic_packet(board)
    puts "Original TX Mod is " + (tlm(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXMOD")).to_s
    puts "Original RX Mod is " + (tlm(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXMOD")).to_s

    # Set modulation (rx to 2 and tx to 3)
    cmd_params = {"TX_MODULATION": 2,
                  "RX_MODULATION": 3}
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_TXRXMOD", cmd_params, "COMM", @wait_time)

    # Read the tx frequency
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXMOD", "==2", @wait_time)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXMOD", "==3", @wait_time)

    # Set modulation (rx to 10 and tx to 10)
    cmd_params = {"TX_MODULATION": 10,
                  "RX_MODULATION": 10}
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_TXRXMOD", cmd_params, "COMM", @wait_time)

    # Read the tx frequency
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXMOD", "==10", @wait_time)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXMOD", "==10", @wait_time)
  end

  

  def rx_mod_test(board)

    # Read rx modulation setting
    @module_ttc.get_uhf_diagnostic_packet(board)
    puts "Original RX Mod is " + (tlm(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXMOD")).to_s

    # Set modulation (rx to 2)
    cmd_params = {"RX_MOD": 2} 
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_RXMOD", cmd_params, "COMM", @wait_time)

    # Read the rx frequency
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXMOD", "==2", @wait_time)

    # Set modulation (rx to 10)
    cmd_params = {"RX_MOD": 10} 
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_RXMOD", cmd_params, "COMM", @wait_time)

    # Read the rx frequency
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXMOD", "==10", @wait_time)

  end

  def tx_mod_test(board)

    # Read tx  modulation setting
    @module_ttc.get_uhf_diagnostic_packet(board)
    puts "Original TX Mod is " + (tlm(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXMOD")).to_s

    # Set modulation ( tx to 3)
    cmd_params = {"TX_MOD": 3} 
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_TXMOD", cmd_params, "COMM", @wait_time)

    # Read the tx frequency
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXMOD", "==3", @wait_time)

    # Set modulation (tx to 10)
    cmd_params = {"TX_MOD": 10} 
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_TXMOD", cmd_params, "COMM", @wait_time)

    # Read the tx frequency
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_TXMOD", "==10", @wait_time)

  end

  def rx_freq_test(board)

    # read the frequency
    @module_ttc.get_uhf_diagnostic_packet(board)
    puts "Current frequency: " + (tlm(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXFREQ")).to_s

    # set freq to 395000000 Hz
    #cmd_params = {"RX_FREQ": 395000000} 
    #@cmd_sender.send_with_cmd_count_check(board, "UHF_SET_RXFREQ", cmd_params, "COMM", @wait_time)

    # read frequency
    #wait(0.25)
    #@module_ttc.get_uhf_diagnostic_packet(board)
    #wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXFREQ", "==395000000", @wait_time)

    # set frequency to 437500000 Hz
    cmd_params = {"RX_FREQ": 437500000} 
    @cmd_sender.send_with_cmd_count_check(board, "UHF_SET_RXFREQ", cmd_params, "COMM", @wait_time)

    # read frequency 
    wait(0.25)
    @module_ttc.get_uhf_diagnostic_packet(board)
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "UHF_RXFREQ", "==437500000", @wait_time)

  end


  def beacon_test(board)
    # Reboot
    cmd_params = {"CSP_REBOOT_MAGIC_VALUE": "REBOOT"}
    @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_params)
    wait(5)

    password = ask("Input UHF Password")

    # Test the beacon period changes
    beacon_turn_on_off(board, 0, 1, password)
    #beacon_turn_on_off(board, 60, 20, password)

    # Test the beacon initial delay changes
    #beacon_turn_on_off(board, 60, 10, password)
    #beacon_turn_on_off(board, 120, 10, password)

    # Set the beacon delay back to 3600

    # # Elevate Access level to super user
    # cmd_params = {"ROLE": "SUPERUSER",
    # "PASSWORD": password} 
    # @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    # # Update the beacon delay 
    # @uhf_config.uhf_beacon_initial_delay_in_s(3600)

    # # Save the beacon delay
    # @uhf_config.uhf_save_active_to_main()

    # # Set access back to user
    # cmd_params = {"ROLE": "USER",
    # "PASSWORD": password} 
    # @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)
  end

  def beacon_turn_on_off(board, init_delay, beacon_period, password)

    # Check the TX packet counter
    #orig_tx_pkt_count = tlm(@target, "#{board}-COMM_TLM", "UHF_TX_PACKET_COUNTER")
    orig_tx_pkt_count = tlm(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER")

    # Elevate Access level to super user
    cmd_params = {"ROLE": "SUPERUSER",
                  "PASSWORD": password} 
    @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    # Update the beacon delay 
    @uhf_config.uhf_beacon_tx_period_in_ms(beacon_period*1000)
    @uhf_config.uhf_beacon_initial_delay_in_s(init_delay)
    @uhf_config.uhf_beacon_tx_on(1)
	@uhf_config.uhf_radio_tx_on(1)
    
    # Save the beacon delay
    @uhf_config.uhf_save_active_to_main()

    # Set access back to user
    cmd_params = {"ROLE": "USER",
    "PASSWORD": password} 
    @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    # reboot
    cmd_params = {"CSP_REBOOT_MAGIC_VALUE": "REBOOT"}
    @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_params)
    wait(5)
    
    # Enable the beacon
    # cmd_params = {"ERROR_CODE": 0,
    #             "BEACON_PERIOD_INS": 10}
    # @cmd_sender.send_with_cmd_count_check(board, "UHF_ENABLE_BEACON", cmd_params, "COMM", @wait_time)

    # wait slightly less than the initial delay time
    #wait(init_delay-5) 

    # Read Tx packet counter and verify it did not incremente
    ##wait_check(@target, "#{board}-COMM_TLM", "UHF_TX_PACKET_COUNTER", ">#{orig_tx_pkt_count}", @wait_time)
    #wait_check(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER", "==#{orig_tx_pkt_count}", 60)

    # wait the rest of the initial delay time
    #wait(7)
    orig_tx_pkt_count = tlm(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER")

    # wait one beacon period
    wait(beacon_period+2)

    # Verify the packet count increased
    wait_check(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER", ">#{orig_tx_pkt_count}", 60)

    # Disable the beacon
    #@cmd_sender.send_with_cmd_count_check(board, "UHF_DISABLE_BEACON", {}, "COMM", @wait_time)

    # Check the TX packet counter
    #orig_tx_pkt_count = tlm(@target, "#{board}-COMM_TLM", "UHF_TX_PACKET_COUNTER")
    orig_tx_pkt_count = tlm(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER")

    # wait one beacon period
    wait(beacon_period+2)

    # Read Tx packet counter and verify it did not increment
    #wait_check(@target, "#{board}-COMM_TLM", "UHF_TX_PACKET_COUNTER", "==#{orig_tx_pkt_count}", @wait_time)
    wait_check(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER", ">#{orig_tx_pkt_count}", @wait_time)

    # Turn off the beacon
    # Elevate Access level to super user
    cmd_params = {"ROLE": "SUPERUSER",
                  "PASSWORD": password} 
    @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    # Update the beacon delay 
    @uhf_config.uhf_beacon_tx_on(0)
	@uhf_config.uhf_radio_tx_on(0)
    
    # Save the beacon delay
    @uhf_config.uhf_save_active_to_main()

    # Set access back to user
    cmd_params = {"ROLE": "USER",
    "PASSWORD": password} 
    @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    # reboot
    cmd_params = {"CSP_REBOOT_MAGIC_VALUE": "REBOOT"}
    @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_params)
    wait(5)

  end

  def configuration_update(board)

    password = ask("Input UHF Password")

    # Elevate access level to super user
    cmd_params = {"ROLE": "SUPERUSER",
                  "PASSWORD": password} 
    @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    # radioTxOn - superuser
    @uhf_config.uhf_radio_tx_on(1)

    # radioEncryptionOn
    @uhf_config.uhf_radio_encryption_on(1)

    #radioEncryptionKey
    @uhf_config.uhf_radio_encryption_key("\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x22\x22\x13\x14\x15\x16\x17\x18\x19\x1F\x1B\x1C\x1D\x1E\x1F\x20")

    # radioEncryptionIV
    @uhf_config.uhf_radio_encryption_iv("\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x11")

    # radioPowerAmplifierDelayInMs
    @uhf_config.uhf_radio_power_amplifier_delay(50)
    
    # radioChipOscillatorFrequency
    #@uhf_config.uhf_radio_chip_oscillator_frequency(38400000)
    
    # radioRxFrequency
    @uhf_config.uhf_radio_rx_frequency(437500000)
    
    # radioTxFrequency
    @uhf_config.uhf_radio_tx_frequency(437500000)
    
    # radioPower
    @uhf_config.uhf_radio_power(3)
    
    # radioFreqOffset
    @uhf_config.uhf_radio_freq_offset(100)
    
    # radioRssiOffset
    @uhf_config.uhf_radio_rssi_offset(100)
    
    # radioProtocolVersion
    @uhf_config.uhf_radio_protocol_version(0)
    
    # radioTxModulation
    @uhf_config.uhf_radio_tx_modulation(4)
    
    # radioRxModulation
    @uhf_config.uhf_radio_rx_modulation(8)
    
    # gsWatchdogPerioInS
    @uhf_config.uhf_gs_watchdog_period_in_s(60)
    
    # generalTmCollectionPeriodInMs
    @uhf_config.uhf_general_tm_collection_period_in_ms(10000)
    
    # beaconTmCollectionPeriodInMs
    @uhf_config.uhf_beacon_tm_collection_period_in_ms(20000)
    
    # beaconTxOn
    @uhf_config.uhf_beacon_tx_on(0)
    
    # beaconInitialDelayInS
    @uhf_config.uhf_beacon_initial_delay_in_s(30)
    
    # beaconTxPeriodInMs
    @uhf_config.uhf_beacon_tx_period_in_ms(20000)
    
    # beaconDestinationID
    @uhf_config.uhf_beacon_destination_id(4)
    
    # beaconDestinationPort
    @uhf_config.uhf_beacon_destination_port(1)
    
    # telemetryOriginId_1
    @uhf_config.uhf_telemetry_origin_id_1(4)
    
    # telemetryOriginPort_1
    @uhf_config.uhf_origin_port_1(7)
    
    # telemetryRequest_1
    @uhf_config.uhf_telemetry_request_1(1.01e30)
    
    # telemetryMask_1
    @uhf_config.uhf_telemetry_mask_1(8.08e30)
    
    # telemetryOriginId_2
    @uhf_config.uhf_telemetry_origin_id_2(1)
    
    # telemetryOriginPort_2
    @uhf_config.uhf_origin_port_2(7)
    
    # telemetryRequest_2
    @uhf_config.uhf_telemetry_request_2(1e30)
    
    # telemetryMask_2
    @uhf_config.uhf_telemetry_mask_2(4.14e30)
    
    # telemetryOriginId_3
    @uhf_config.uhf_telemetry_origin_id_3(6)
    
    # telemetryOriginPort_3
    @uhf_config.uhf_telemetry_origin_port_3(7)
    
    # telemetryRequest_3
    @uhf_config.uhf_telemetry_request_3(1e30)
    
    # telemetryMask_3
    @uhf_config.uhf_telemetry_mask_3("\x04\x0C\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    
    # telemetryOriginId_4
    @uhf_config.uhf_telemetry_origin_id_4(3)
    
    # telemetryOriginPort_4
    @uhf_config.uhf_origin_port_4(7)
    
    # telemetryRequest_4
    @uhf_config.uhf_telemetry_request_4(1.01e30)
    
    # telemetryMask_4
    @uhf_config.uhf_telemetry_mask_4(4.04e30)
    
    # telemetryOriginId_5
    @uhf_config.uhf_telemetry_origin_id_5(3)
    
    # telemetryOriginPort_5
    @uhf_config.uhf_origin_port_5(7)
    
    # telemetryRequest_5
    @uhf_config.uhf_telemetry_request_5(1.03e30)
    
    # telemetryMask_5
    @uhf_config.uhf_telemetry_mask_5(2.50e29)
    
    # telemetryOriginId_6
    @uhf_config.uhf_telemetry_origin_id_6(3)
    
    # telemetryOriginPort_6
    @uhf_config.uhf_origin_port_6(7)
    
    # telemetryRequest_6
    @uhf_config.uhf_telemetry_request_6(1e30)
    
    # telemetryMask_6
    @uhf_config.uhf_telemetry_mask_6("\x04\x08\x2F\x08\x3B\x35\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    
    # telemetryOriginId_7
    @uhf_config.uhf_telemetry_origin_id_7(4)
    
    # telemetryOriginPort_7
    @uhf_config.uhf_origin_port_7(7)
    
    # telemetryRequest_7
    @uhf_config.uhf_telemetry_request_7(1.01e30)
    
    # telemetryMask_7
    @uhf_config.uhf_telemetry_mask_7(8.08e30)
    
    # telemetryOriginId_8
    @uhf_config.uhf_telemetry_origin_id_8(4)
    
    # telemetryOriginPort_8
    @uhf_config.uhf_origin_port_8(7)
    
    # telemetryRequest_8
    @uhf_config.uhf_telemetry_request_8(1e30)
    
    # telemetryMask_8
    @uhf_config.uhf_telemetry_mask_8("\x08\x08\x14\x1A\x30\x1E\x58\x04\xCF\x0E\x00\x00\x00\x00\x00\x00")
    
    # rtcClockSourceLSE
    @uhf_config.uhf_rtc_clock_source_lse(2)
    
    # logSeverity
    @uhf_config.uhf_log_severity(3)
    
    # Set access back to user
    cmd_params = {"ROLE": "USER",
    "PASSWORD": password} 
    @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

  end


  def load_config_test
    # Verify if loading the configuration causes parameters to take effect immediately

    password = ask("Input UHF Password")

    # Elevate Access level to super user
    cmd_params = {"ROLE": "SUPERUSER",
    "PASSWORD": password} 
    @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    # Save the beacon delay
    @uhf_config.uhf_save_active_to_main()
  
    # Set the beacon delay to 0 
    @uhf_config.uhf_beacon_initial_delay_in_s(0)

    # Set beacon on to true 
    @uhf_config.uhf_beacon_tx_on(1)

    # Save to fallback
    @uhf_config.uhf_save_active_to_fallback()

    # Load Main
    uhf_load_main_config()

    orig_tx_pkt_count = tlm(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER")

    wait(16)

    wait_check(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER", "==#{orig_tx_pkt_count}", 5)

    # Load fallback
    uhf_load_fallback_config()

    # Check the beacon tx count
    orig_tx_pkt_count = tlm(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER")

    wait(16)

    wait_check(@target, "#{board}-COMM_TLM", "UHF_BEACON_TX_COUNTER", ">#{orig_tx_pkt_count}", 5)

    # Set access back to user
    cmd_params = {"ROLE": "USER",
    "PASSWORD": password} 
    @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

  end

end

#handle = UHFCmdTest.new
#handle.test_select_UHF_cmd