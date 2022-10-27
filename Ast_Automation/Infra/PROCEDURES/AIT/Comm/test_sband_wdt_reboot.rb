load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/COMM/COMM_TTC.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')


# ------------------------------------------------------------------------------------

class SBandConfigReboot < ASTCOSMOSTestComm 

  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @module_ttc = ModuleTTC.new
    @target = target
    @csp_destination = "COSMOS_UMBILICAL"
    @test_util = ModuleTestCase.new
    @wait_time = 10
    super()
  end

  # ------------------------------------------------------------------------------------
  def test_wdt_reboot_configuration
    # This test saves a configuration parameter to boot and fallback, lets the watchdog timer
    #  reboot and checks the fallback configuration is present after reboot

    stack = @test_util.initialize_test_case('SBAND_Reboot_config')
    board = "APC_" + stack 

    message_box("This test will take 1 hour to complete. Press Continue to start the test","Continue")

    # Turn on telemetry
    @module_telem.set_realtime(board, "FSW_TLM_APC", @csp_destination, 1) 
    @module_telem.set_realtime(board, "COMM_TLM", @csp_destination, 1) 
    
    # Load Main 
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    cmd_params = {"PROPERTY_ID": "SL_CS_TX_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    cmd_params = {"PROPERTY_ID": "SL_CS_RX_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)

    # Get the initial telem parameter value (TXCC)
    @module_ttc.get_sband_diagnostic_packet(board)
    init_config_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC")
    Cosmos::Test.puts("Initial set value for TXCC is : #{init_config_val}")

    # Set Config values
    # -----------------------------------------

    # Update a config parameter (TXCC) and save to the fallback only
    fallback_val = 0
    cmd_params = {"STATE_SB_TXCC": fallback_val}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCC", cmd_params, "COMM", @wait_time)

    # Verify the telemetry 
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC", "==#{fallback_val}", @wait_time)

    # Save to fallback
    @module_ttc.sband_config_param_save_to_fallback(board, "SL_CS_TX_GROUP_ID")
  
    # Update a config parameter (TXCC) and save to the boot only
    boot_val = 1
    cmd_params = {"STATE_SB_TXCC": boot_val}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCC", cmd_params, "COMM", @wait_time)

    # Verify the telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC", "==#{boot_val}", @wait_time)

    # Save to boot
    @module_ttc.sband_config_param_save_to_boot(board, "SL_CS_TX_GROUP_ID") 
   
    # Set the watchdog timer to 1 hour
    cmd_params = {"INIT": 3600}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_GWDTINIT", cmd_params, "COMM", @wait_time)

    # Verify the telemetry
    wait(0.25)
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_GWDTINIT","==3600", @wait_time)

    # Save to boot
    @module_ttc.sband_config_param_save_to_boot(board, "SL_CS_SYS_GROUP_ID")

    # Reboot the Sband
    cmd_params = {"TIME": 2}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)

    # Reset the watchdog timer
    # -----------------------------------------

    # Get the initial Reboot counter
    init_reboot = tlm(@target, "#{board}-COMM_TLM", "SBAND_BOOTCOUNT")

    # Reset the watchdog timer
    cmd_params = {"WATCHDOG_TIMER": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_GWDTRST", cmd_params, "COMM", @wait_time)

    # Check the time out value is ~1 hour
    wait_check_tolerance(@target, "#{board}-COMM_TLM", "SBAND_GWD_COUNTER",3600,5, @wait_time)

    # wait
    # -----------------------------------------

    # Wait 1 hour (plus a few seconds)
    wait(3620)

    # Verify Boot count and config value
    # -----------------------------------------
    # Verify the reboot count increased
    wait_check(@target, "#{board}-COMM_TLM", "SBAND_BOOTCOUNT", "==#{init_reboot+1}", @wait_time)

    # Read the set parameter value and verify it is the fallback value
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC", "==#{fallback_val}", @wait_time) 
    
    
    # Reset time out to 86400
    cmd_params = {"INIT": 86400}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_GWDTINIT", cmd_params, "COMM", @wait_time)
    # Save to boot
    @module_ttc.sband_config_param_save_to_boot(board, "SL_CS_SYS_GROUP_ID")
    
    # Reboot the Sband
    cmd_params = {"TIME": 2}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)
    
    start_logging("ALL")
  end

  # ------------------------------------------------------------------------------------
  def test_config_param_save_to_boot
    # This test saves a configuration parameter to boot, resets using the reset timer
    # and verifies the boot configuration is present after reboot

    stack = @test_util.initialize_test_case('SBAND_save_to_boot')
    board = "APC_" + stack 

    # Turn on telemetry
    @module_telem.set_realtime(board, "FSW_TLM_APC", @csp_destination, 1) 
    @module_telem.set_realtime(board, "COMM_TLM", @csp_destination, 1)
    
    # Load Main 
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    cmd_params = {"PROPERTY_ID": "SL_CS_TX_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    cmd_params = {"PROPERTY_ID": "SL_CS_RX_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time) 

    # Get the initial config value
    @module_ttc.get_sband_diagnostic_packet(board)
    init_config_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC")
    Cosmos::Test.puts("Initial set value for TXCC is : #{init_config_val}")

    # Set the value to something different and save to boot
    if init_config_val == 0
      boot_val = 1
    else
      boot_val = 0
    end
    cmd_params = {"STATE_SB_TXCC": boot_val}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCC", cmd_params, "COMM", @wait_time)
    @module_ttc.sband_config_param_save_to_boot(board, "SL_CS_TX_GROUP_ID") 

    # Get initial bootcount
    init_boot = tlm(@target, "#{board}-COMM_TLM", "SBAND_BOOTCOUNT")

    # Set reboot timer to 1 second
    cmd_params = {"TIME": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)

    # wait for reboot
    wait(1)
    wait_check(@target, "#{board}-COMM_TLM", "SBAND_BOOTCOUNT", "== #{init_boot+1}",5)

    # Check the configuration
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC", "== #{boot_val}", 1)

  end


  # ------------------------------------------------------------------------------------
  def test_config_param_no_save
    # This test modifies a configuration parameter, resets using the reset timer
    # and verifies the boot configuration is present after reboot, not the updated parameter

    stack = @test_util.initialize_test_case('SBAND_config_no_save')
    board = "APC_" + stack 

    # Turn on telemetry
    @module_telem.set_realtime(board, "FSW_TLM_APC", @csp_destination, 1) 
    @module_telem.set_realtime(board, "COMM_TLM", @csp_destination, 1) 
    
    # Load Main 
    cmd_params = {"PROPERTY_ID": "SL_CS_SYS_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    cmd_params = {"PROPERTY_ID": "SL_CS_TX_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    cmd_params = {"PROPERTY_ID": "SL_CS_RX_GROUP_ID",
                  "FALLBACK": "FALSE"}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOAD_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)

    # Get the initial config value
    @module_ttc.get_sband_diagnostic_packet(board)
    init_config_val = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC")
    Cosmos::Test.puts("Initial set value for TXCC is : #{init_config_val}")

    # Set the value to something different and don't save
    if init_config_val == 0
      boot_val = 1
    else
      boot_val = 0
    end
    cmd_params = {"STATE_SB_TXCC": boot_val}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCC", cmd_params, "COMM", @wait_time)
    
    # Get initial bootcount
    init_boot = tlm(@target, "#{board}-COMM_TLM", "SBAND_BOOTCOUNT")

    # Set reboot timer to 1 second
    cmd_params = {"TIME": 1}
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)

    # wait for reboot
    wait(1)
    wait_check(@target, "#{board}-COMM_TLM", "SBAND_BOOTCOUNT", "== #{init_boot+1}",5)

    # Check the configuration
    @module_ttc.get_sband_diagnostic_packet(board)
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "SBAND_TXCC", "!= #{boot_val}", 1)

  end 

end

#handle = SBandConfigReboot.new 
#handle.test_wdt_reboot_configuration