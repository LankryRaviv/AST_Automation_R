load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/COMM/COMM_TTC.rb')
load_utility('Operations/COMM/SBand_Properties.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')

# ------------------------------------------------------------------------------------

class SBandCmdTest < ASTCOSMOSTestComm 

  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @module_ttc = ModuleTTC.new
    @test_util = ModuleTestCase.new
    @sband_prop = ModuleSBandProperties.new
    @target = target
    @csp_destination = "COSMOS_UMBILICAL"
    @wait_time = 10
    super()
    @test_list = ["watchdog_test",
                "can_rate_rate",
                "can_promisc_rate",
                "reboot_timer_test",
                "transmit_freq_test",
                "transmit_rate_test",
                "gmsk_bt_test",
                "transmit_power_test",
                "txgain_test",
                "transmit_alc_mode",
                "auto_level_control_test",
                "alc_limit_test",
                "transmit_rs_test",
                "transmit_cc_test",
                "transmit_rand_test",
                "set_tx_crc_test",
                "set_idle_frames_test",
                "set_train_type_test",
                "set_preamble_test",
                "set_postamble_test",
                "set_midamble_test",
                "tx_size_test",
                "set_txid_test",
                "tx_crypto_key_test",
                "tx_crypoencrypt_test",
                "tx_crypoauth_test",
                "set_rx_freq_test",
                "set_rx_receive_rate_test",
                "set_rx_bw_test",
                "set_rx_rs_test",
                "set_rx_cc_test",
                "set_rx_rand_test",
                "set_rx_crc_test",
                "set_rx_size_test",
                "set_rx_id_test",
                "set_rx_cryptokey_test",
                "set_rx_crypto_decrypt_test",
                "set_rx_crypt_auth_test",
                "diagnostic_packet_test"]
  end

  # ------------------------------------------------------------------------------------
  def test_all_SBand_cmds
    stack = @test_util.initialize_test_case('SBAND_CMDs')
    board = "APC_" + stack

    # Turn on telemetry
    @module_telem.set_realtime(board, "COMM_TLM", @csp_destination, 1) 

    

    @test_list.each do |test|

        # Construct method name
        method_name = test

        # Print which test is starting
        Cosmos::Test.puts("Starting test #{test}")
  
        # Turn on Switch
        public_send(method_name, board)   

        Cosmos::Test.puts("Completed test #{test}")
  
      end

    start_logging("ALL")
  end

  # ------------------------------------------------------------------------------------
  def test_select_SBand_cmd

    stack = @test_util.initialize_test_case('SBAND_CMDs')
    board = "APC_" + stack

    # Turn on telemetry
    @module_telem.set_realtime(board, "COMM_TLM", @csp_destination, 1) 

    ask_for_test = true
    while ask_for_test

      # Get test
      test = combo_box("Select test.\n\nSelect 'Exit Procedure' to stop",
      "watchdog_test","can_rate_rate","can_promisc_rate","reboot_timer_test",
      "transmit_freq_test","transmit_rate_test","gmsk_bt_test",
      "transmit_power_test","txgain_test","transmit_alc_mode","auto_level_control_test","alc_limit_test",
      "transmit_rs_test","transmit_cc_test","transmit_rand_test","set_tx_crc_test","set_idle_frames_test",
      "set_train_type_test","set_preamble_test","set_postamble_test","set_midamble_test","tx_size_test","set_txid_test",
      "tx_crypto_key_test","tx_crypoencrypt_test","tx_crypoauth_test","set_rx_freq_test","set_rx_receive_rate_test","set_rx_bw_test",
      "set_rx_rs_test","set_rx_cc_test","set_rx_rand_test","set_rx_crc_test","set_rx_size_test","set_rx_id_test",
      "set_rx_cryptokey_test","set_rx_crypto_decrypt_test","set_rx_crypt_auth_test","diagnostic_packet_test", "Exit Procedure")

      if test == "Exit Procedure"
        # Stop procedure
        break
      end

      # Print which test is starting
      Cosmos::Test.puts("Starting test #{test}")

      # Construct method name
      public_send(test, board)

      Cosmos::Test.puts("Completed test #{test}")
    end


    start_logging("ALL")
  end

  # ------------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------
  def watchdog_test(board)
    # Set the watch dog time out value, verify telem, reset timer, verify telem
  
    # Determine new time out value (half of current)
    @module_ttc.get_sband_diagnostic_packet(board)
    orig_timer_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_GWDTINIT")
    if orig_timer_val <= 7400 # 3600*2
      new_timer_val = orig_timer_val * 2
    else
      new_timer_val = orig_timer_val / 2
    end

    # Set watch dog time out value
    cmd_params = {"INIT": new_timer_val}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_GWDTINIT", cmd_params, "COMM", @wait_time)

    # Check the telemetry to verify time out was succesfully set
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_GWDTINIT","==#{new_timer_val}", @wait_time)
    
    # Unlock
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_UNLOCK_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)

    # Save to boot
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SAVE_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)

    # Lock
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOCK_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    
    # Reboot the Sband
    cmd_params = {"TIME": 2}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)

    # Verify the telemetry is still the same
    wait(3)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_GWDTINIT","==#{new_timer_val}", @wait_time)
    
    # Check the current watch dog counter
    orig_wd_counter = tlm(@target, "#{board}-COMM_TLM", "SBAND_GWD_COUNTER")
    puts "Current watch dog counter is #{orig_wd_counter}"

    # Reset the watch dog timer
    cmd_params = {"WATCHDOG_TIMER": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_GWDTRST", cmd_params, "COMM", @wait_time)

    # Check telemetry to verify counter reset (new timer val +/- 2 seconds)
    wait_check_tolerance(@target, "#{board}-COMM_TLM", "SBAND_GWD_COUNTER",new_timer_val,2, @wait_time)

    # Reset watch dog timer to 24 hrs (86400) to prevent time out during testing
    cmd_params = {"INIT": orig_timer_val}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_GWDTINIT", cmd_params, "COMM", @wait_time)

    # Unlock
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_UNLOCK_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)

    # Save to boot
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SAVE_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)

    # Lock
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOCK_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)

    # Reboot the Sband
    cmd_params = {"TIME": 2}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def can_rate_rate(board)
    @module_ttc.get_sband_diagnostic_packet(board)
    Cosmos::Test.puts("Can Rate is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_CANRATE")).to_s)

  end

  # ------------------------------------------------------------------------------------
  def can_promisc_rate(board)
    @module_ttc.get_sband_diagnostic_packet(board)
    Cosmos::Test.puts("CAN Promisc is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_CANPROMISC")).to_s)
  end

  # ------------------------------------------------------------------------------------
  def reboot_timer_test(board)

    # Get initial reboot count
    init_reboot_cnt = tlm(@target, "#{board}-COMM_TLM", "SBAND_BOOTCOUNT")

    # Set the timer to 60 sec 
    cmd_params = {"TIME": 60}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)

    # wait 30 sec
    wait(30)

    # Read the timer (30 sec +/- 2 sec)
    #wait_check_tolerance(@target, "#{board}-COMM_TLM", "SBAND_REBOOTTIMER", 30, 2, @wait_time)

    # wait another 30s
    wait(30)

    # Verify reboot occured (reboot count = initial reboot count + 1)
    wait_check(@target, "#{board}-COMM_TLM", "SBAND_BOOTCOUNT", "==#{init_reboot_cnt + 1}", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def led_test(board)

    # Enable the LED
    cmd_params = {"STATE_SB_LED": 1} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_LEDENABLE", cmd_params, "COMM", @wait_time)

    message_box("LED is enabled. Visually verify LED is on, then press Continue","Continue")

    # Disable the LED
    cmd_params = {"STATE_SB_LED": 0} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_LEDENABLE", cmd_params, "COMM", @wait_time)

    message_box("LED is disabled. Visually verify LED is off, then press Continue","Continue")

  end

  # ------------------------------------------------------------------------------------
  def transmit_freq_test(board)

    # Check transmitter frequency (2200 - 2290 MHz) (2245 +/- 45 MHz)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check_tolerance(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXFREQ", 2245000000, 45000000, @wait_time)
    current_freq = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXFREQ")

    # Set transmitter frequency to 2290 - current_frequncy/2 + current_frequency
    new_freq = (2290000000 - current_freq)/2 + current_freq
    cmd_params = {"FREQ_TX": new_freq}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXFREQ", cmd_params, "COMM", @wait_time)

    # Verify transmitter frequency updated
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXFREQ", "==#{new_freq}", @wait_time)
    
  end
  # ------------------------------------------------------------------------------------
  def transmit_rate_test(board)

    # Read the transmit rate
    @module_ttc.get_sband_diagnostic_packet(board)
    current_rate = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXRATE")
    
    # Set rate to half the current value
    #new_rate = current_rate / 2
    new_rate = 128000
    cmd_params = {"RATE_TX": new_rate}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXRATE", cmd_params, "COMM", @wait_time)

    # Verify rate changed
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXRATE", "==#{new_rate}", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def gmsk_bt_test(board)

    # Read BT value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXBT")
    puts "Current BT rate is: #{tlm_val}" 

    if tlm_val == 50
      Cosmos::Test.puts("Default value is 50, setting to 50")
    else
      Cosmos::Test.puts("WARNING: Default BT value is not 50, skipping test")
    end    

    # Set value to 30
    cmd_params = {"BT": 30}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXBT", cmd_params, "COMM", @wait_time)

    # Verify value changed
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXBT", "== 30", @wait_time)

    # Set value to 60
    cmd_params = {"BT": 60}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXBT", cmd_params, "COMM", @wait_time)

    # Verify value changed
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXBT", "==60", @wait_time)


  end

  # ------------------------------------------------------------------------------------
  def transmit_power_test(board)

    # Read current power out
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current TX power is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXPOUT")).to_s

    # Set value to 20
    cmd_params = {"POUT": 20}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXPOUT", cmd_params, "COMM", @wait_time)

    # Verify value changed
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXPOUT", "== 20", @wait_time)

    # Set value to 30
    cmd_params = {"POUT": 30}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXPOUT", cmd_params, "COMM", @wait_time)

    # Verify value changed
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXPOUT", "== 30", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def txgain_test(board)
    @module_ttc.get_sband_diagnostic_packet(board)
    Cosmos::Test.puts("TX Gain is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXGAIN")).to_s)
  end

  # ------------------------------------------------------------------------------------
  def transmit_alc_mode(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current Mode is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXALCMODE")).to_s

    # set mode to 0 
    cmd_params = {"ALC_MODE": 0}
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXALCMODE", cmd_params, "COMM", @wait_time)

    # check tx power fwd telem 
    txpwr_val = tlm(@target, "#{board}-COMM_TLM", "SBAND_TX_POWER_FWD")
    Cosmos::Test.puts("TX PWR FWD is: #{txpwr_val}")

  end

  # ------------------------------------------------------------------------------------
  def auto_level_control_test(board)

    # check telem is 40
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC","SBAND_ALCKP")
    if tlm_val == 40
        Cosmos::Test.puts("Automatic loop control level passed check with value: #{tlm_val}")
    else
        Cosmos::Test.puts("Warning: Automatic loop control level FAILED check with value: #{tlm_val}")
    end

  end

  # ------------------------------------------------------------------------------------
  def alc_limit_test(board)

    # check telem is 300
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC","SBAND_ALCKP")
    if tlm_val == 300
        Cosmos::Test.puts("Automatic loop control level passed check with value: #{tlm_val}")
    else
        Cosmos::Test.puts("Warning: Automatic loop control level FAILED check with value: #{tlm_val}")
    end

  end

  # ------------------------------------------------------------------------------------
  def transmit_rs_test(board)

    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current RS is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXRS")).to_s

    # set to 0
    cmd_params = {"STATE_SB_TXRS": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXRS", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXRS", "==0", @wait_time)

    # set to 1
    cmd_params = {"STATE_SB_TXRS": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXRS", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXRS", "==1", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def transmit_cc_test(board)

    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current CC is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC")).to_s

    # set to 0
    cmd_params = {"STATE_SB_TXCC": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCC", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC", "==0", @wait_time)

    # set to 1
    cmd_params = {"STATE_SB_TXCC": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCC", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC", "==1", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def transmit_rand_test(board)

    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current RAND is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXRAND")).to_s

    # set to 0
    cmd_params = {"STATE_SB_TXRAND": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXRAND", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXRAND", "==0", @wait_time)

    # set to 1
    cmd_params = {"STATE_SB_TXRAND": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXRAND", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXRAND", "==1", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def set_tx_crc_test(board)

    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current CRC is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRC")).to_s

    # set mode to 0
    cmd_params = {"STATE_SB_TXCRC": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCRC", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRC", "==0", @wait_time)

    # set to 1
    cmd_params = {"STATE_SB_TXCRC": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCRC", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRC", "==1", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def set_idle_frames_test(board)

    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current Idle frames is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_IDLEFRAMES")).to_s

    # set to 0
    cmd_params = {"IDLE_FRAMES": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_IDLEFRAMES", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_IDLEFRAMES", "==0", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def set_train_type_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current Train sequence type is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TRAINTYPE")).to_s

    # set mode to 0
    cmd_params = {"TRAIN_TYPE": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TRAINTYPE", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TRAINTYPE", "==0", @wait_time)

    # set to 1
    cmd_params = {"TRAIN_TYPE": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TRAINTYPE", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TRAINTYPE", "==1", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def set_preamble_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_PREAMBLE")
    puts "Current preamble is: #{tlm_val}"

    if tlm_val == 8
        Cosmos::Test.puts("Preamble is set to default with value 8")
    else
        Cosmos::Test.puts("Warning: Preamble is NOT set to default with value #{tlm_val}")
    end

    # set to 10
    cmd_params = {"PREAMBLE": 10}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_PREAMBLE", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_PREAMBLE", "== 10", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def set_postamble_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_POSTAMBLE")
    puts "Current postamble is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("Postamble is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: Postamble is NOT set to default with value #{tlm_val}")
    end

    # set to 12
    cmd_params = {"POSTAMBLE": 12}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_POSTAMBLE", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_POSTAMBLE", "== 12", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def set_midamble_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_MIDAMBLE")
    puts "Current midamble is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("Midamble is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: Midamble is NOT set to default with value #{tlm_val}")
    end

    # set to 16
    cmd_params = {"MIDAMBLE": 16}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_MIDAMBLE", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_MIDAMBLE", "== 16", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def tx_size_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXSIZE")
    puts "Current tx size is: #{tlm_val}"

    if tlm_val == 217
        Cosmos::Test.puts("TX Size is set to default with value 217")
    else
        Cosmos::Test.puts("Warning: TX Size is NOT set to default with value #{tlm_val}")
    end

    # set to 1024
    cmd_params = {"PAYLOAD_SIZE": 1024}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXSIZE", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXSIZE", "== 1024", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def set_txid_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXID")
    puts "Current tx ID is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("TX ID is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: TX ID is NOT set to default with value #{tlm_val}")
    end

    # set to 60000
    cmd_params = {"ID_TX": 60000}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXID", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXID", "== 60000", @wait_time)

    # set to 0
    cmd_params = {"ID_TX": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXID", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXID", "== 0", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def tx_crypto_key_test(board)
  #Cosmos::Test.puts("TX Crypto Key test skipped")
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRYPTOKEY")
    puts "Current key is: #{tlm_val}"

    if tlm_val == 0
       Cosmos::Test.puts("TX Key is set to default with value 0")
    else
       Cosmos::Test.puts("Warning: TX Key is NOT set to default with value #{tlm_val}")
    end

    #set Key
    hex_key_val = "DA 46 B5 59 F2 1B 3E 95 5B B1 92 5C 96 4A C5 C3 B3 D7 2F E1 BF 37 47 6A 10 4B 0E 73 96 02 7B 65" # hex value for 1101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101100101
    hex_key_val = @sband_prop.hex_string_to_config(hex_key_val)
    cmd_params = {"KEY_SBAND": hex_key_val} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCRYPTOKEY", cmd_params, "COMM", @wait_time)

    #Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    #wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRYPTOKEY", "== #{hex_key_val}", @wait_time)
    if tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRYPTOKEY").unpack('*V') == hex_key_val.unpack('*V')
      puts "TX Crypto Key set correctly"
    else
      raise("TX Crypto Key failed")
    end
  end

  # ------------------------------------------------------------------------------------
  def tx_crypoencrypt_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRYPTOENCRYPT")
    puts "Current Encrypt is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("TX Encrypt is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: TX Encrypt is NOT set to default with value #{tlm_val}")
    end

    # set to true
    cmd_params = {"STATE_SB_TXCDECRYPT": 1} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCRYPTOENCRYPT", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRYPTOENCRYPT", "== 1", @wait_time) 
  end

  # ------------------------------------------------------------------------------------
  def tx_crypoauth_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRYPTOAUTH")
    puts "Current Auth is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("TX Auth is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: TX Auth is NOT set to default with value #{tlm_val}")
    end

    # set to true
    cmd_params = {"STATE_SB_TXCAUTH": 1} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCRYPTOAUTH", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCRYPTOAUTH", "== 1", @wait_time) ###UPDATE
  end

  # ------------------------------------------------------------------------------------
  def set_rx_freq_test(board)

    # Read frequency and check its between 2025 and 2110 mHz
    @module_ttc.get_sband_diagnostic_packet(board)
    current_freq = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXFREQ")

    # set frequency to 2110-current frequency)/2 + current receiver frequency
    new_freq = (2110000000-current_freq)/2 + current_freq
    cmd_params = {"FREQ_RX": new_freq} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXFREQ", cmd_params, "COMM", @wait_time)

    # check the frequency changed
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXFREQ", "== #{new_freq}", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def set_rx_receive_rate_test(board)

    # read the value (kps/s)
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current rx rate: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXRATE")).to_s

    # set to 64000 bits/s
    cmd_params = {"RATE_RX": 64000} #bps  ##Current min and max is 128
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXRATE", cmd_params, "COMM", @wait_time)

    # check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXRATE", "== 64000", @wait_time)

    # set to 192000 (this will error)
    # cmd_params = {"RATE_RX": 192000} #bps 
    # begin
    #     @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXRATE", cmd_params, "COMM", @wait_time)
    # rescue
    #     Cosmos::Test.puts("Commanding to a rate of 192 successfully errored")
    # else
    #     # This is an error 
    #     Cosmos::Test.puts("Warning: Commanding to a rate of 192 did not error (max of 128)")
    # end


  end

  # ------------------------------------------------------------------------------------
  def set_rx_bw_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXBW")
    if tlm_val == 150
        Cosmos::Test.puts("RXBW Rand is set to default with value 150")
    else
        Cosmos::Test.puts("Warning: RXBW Rand is NOT set to default with value #{tlm_val}")
    end

    # set to 50% of default
    cmd_params = {"BW": 100} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXBW", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXBW", "==100", @wait_time)

    # set to 200% of default
    cmd_params = {"BW": 200}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXBW", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXBW", "==200", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def set_rx_rs_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current RS is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXRS")).to_s

    # set to 0
    cmd_params = {"STATE_SB_RXRS": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXRS", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXRS", "==0", @wait_time)

    # set to 1
    cmd_params = {"STATE_SB_RXRS": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXRS", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXRS", "==1", @wait_time)

  end

  # ------------------------------------------------------------------------------------
  def set_rx_cc_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    puts "Current RS is: " + (tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCC")).to_s

    # set to 0
    cmd_params = {"STATE_SB_RXCC": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCC", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCC", "==0", @wait_time)

    # set to 1
    cmd_params = {"STATE_SB_RXCC": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCC", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCC", "==1", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def set_rx_rand_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXRAND")
    puts "Current rx rand is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("RX Rand is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: RX Rand is NOT set to default with value #{tlm_val}")
    end

    # set to 0
    cmd_params = {"STATE_SB_RXRAND": 0} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXRAND", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXRAND", "== 0", @wait_time) 

    # set to 1
    cmd_params = {"STATE_SB_RXRAND": 1} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXRAND", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXRAND", "== 1", @wait_time) 
  end

  # ------------------------------------------------------------------------------------
  def set_rx_crc_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRC")
    puts "Current CRC is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("RX CRC is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: RX CRC is NOT set to default with value #{tlm_val}")
    end

    # set to 0
    cmd_params = {"STATE_SB_RXCRC": 0} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCRC", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRC", "== 0", @wait_time) 

    # set to 1
    cmd_params = {"STATE_SB_RXCRC": 1} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCRC", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRC", "== 1", @wait_time) 
  end

  # ------------------------------------------------------------------------------------
  def set_rx_size_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXSIZE")
    puts "Current rx size is: #{tlm_val}"

    if tlm_val == 217
        Cosmos::Test.puts("RX Size is set to default with value 217")
    else
        Cosmos::Test.puts("Warning: RX Size is NOT set to default with value #{tlm_val}")
    end

    # set to 1024
    cmd_params = {"PAYLOAD_SIZE": 1024}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXSIZE", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXSIZE", "== 1024", @wait_time)

    # set to 122
    cmd_params = {"PAYLOAD_SIZE": 187}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXSIZE", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXSIZE", "== 187", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def set_rx_id_test(board)
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXID")
    puts "Current rx ID is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("RX ID is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: RX ID is NOT set to default with value #{tlm_val}")
    end

    # set to 60000
    cmd_params = {"ID_RX": 60000}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXID", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXID", "== 60000", @wait_time)

    # set to 0
    cmd_params = {"ID_RX": 0}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXID", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXID", "== 0", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def set_rx_cryptokey_test(board)
    #Cosmos::Test.puts("RX Crypto Key test skipped")
    # read value
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRYPTOKEY")
    puts "Current key is: #{tlm_val}"

    if tlm_val == 0
        Cosmos::Test.puts("RX Key is set to default with value 0")
    else
        Cosmos::Test.puts("Warning: RX Key is NOT set to default with value #{tlm_val}")
    end

    # set Key
    hex_key_val = "DA 46 B5 59 F2 1B 3E 95 5B B1 92 5C 96 4A C5 C3 B3 D7 2F E1 BF 37 47 6A 10 4B 0E 73 96 02 7B 7F" # hex for 1101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101111111
    hex_key_val = @sband_prop.hex_string_to_config(hex_key_val)    
    cmd_params = {"KEY_SBAND": hex_key_val}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCRYPTOKEY", cmd_params, "COMM", @wait_time)

    # Check telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    #wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRYPTOKEY", "== #{hex_key_val}", @wait_time)
    if tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRYPTOKEY").unpack('*V') == hex_key_val.unpack('*V')
      puts "RX Crypto Key Set Correctly"
    else
      raise("RX Crypto Key set Failed")
    end
  end

  # ------------------------------------------------------------------------------------
  def set_rx_crypto_decrypt_test(board)
    
  
    # Read value - should be false
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRYPTODECRYPT")
    if tlm_val != 0
        Cosmos::Test.puts("Warning: default SBAND_RXCRYPTODECRYPT not set to false with value : #{tlm_val}")
    else
        Cosmos::Test.puts("Default SBAND_RXCRYPTODECRYPT set to 0")
    end

    # set to True
    cmd_params = {"STATE_SB_RXCDECRYPT": 1} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCRYPTODECRYPT", cmd_params, "COMM", @wait_time)

    # read value
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRYPTODECRYPT", "== 1", @wait_time) 
  end

  # ------------------------------------------------------------------------------------
  def set_rx_crypt_auth_test(board)

    # Read value - should be false
    @module_ttc.get_sband_diagnostic_packet(board)
    tlm_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRYPTOAUTH")
    if tlm_val != 0
        Cosmos::Test.puts("Warning: default SBAND_RXCRYPTOAUTH not set to false with value : #{tlm_val}")
    else
        Cosmos::Test.puts("Default SBAND_RXCRYPTOAUTH set to 0")
    end

    # set to True
    cmd_params = {"STATE_SB_RXCAUTH": 1} 
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCRYPTOAUTH", cmd_params, "COMM", @wait_time)

    # read value
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_RXCRYPTOAUTH", "== 1", @wait_time) 
  end

  # ------------------------------------------------------------------------------------
  def diagnostic_packet_test(board)
    @module_ttc.get_sband_diagnostic_packet(board)
  end

end
#handle = SBandCmdTest.new
#handle.test_select_SBand_cmd