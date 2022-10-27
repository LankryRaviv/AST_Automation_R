load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/EPS/EPS_PCDU')
load_utility('TestRunnerUtils/test_case_utils.rb')

# ------------------------------------------------------------------------------------

class QVATest < ASTCOSMOSTestComm 
  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @test_util = ModuleTestCase.new
    @csp_destination = "COSMOS_UMBILICAL"
    @pcdu = PCDU.new
    @target = target
    @wait_time = 3
    @long_wait_time = 120
    super()
  end

  def setup(test_case_name = "QV_Antenna")
    stack = @test_util.initialize_test_case(test_case_name)
    @board = "APC_" + stack

    @module_telem.set_realtime(@board, "COMM_TLM", @csp_destination, 1) 

  end

  # QV Antenna Deploy
  # ------------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def test_QV_Antenna_Deploy()
    
    setup("QV_Antenna_Deploy")

    # Ask for QV
    qva_side = combo_box("Select QV:", "YP", "YM")
  
    # wait for user to start
    message_box("test_QV_Antenna_Deploy test procedure launched successfully. Press enter to start","Enter")

    Cosmos::Test.puts("Using APC: #{@board} and QVA: #{qva_side}")
    
    # Power on
    # -------------------------------------------------------------------------------
    Cosmos::Test.puts("Powering #{qva_side} on")
    power_qva_switches(qva_side, 1) # 1 = ON

    Cosmos::Test.puts("Waiting for the antenna to be ready")

    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE","== 'READY'", 10)
  
    message_box("Antenna is ready, press Enter to start Self Test", "Enter")

    # Send QVA_SELF_TEST command
    # -------------------------------------------------------------------------------
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_SELF_TEST", cmd_params, "COMM", 2)
    wait(3)

    wait_check("BW3", "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "== 'WAITING_FOR_COMMAND'", 60)

    # Self test was successful
    Cosmos::Test.puts("Self Test successful, firing frangibolt")

    # Fire the Frangibolt - Note: this is a critical command and will ask the user to continue
    # -------------------------------------------------------------------------------
    Cosmos::Test.puts("Frangibolt phase: Changing to deployment mode")

    # Enable deploy
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_CMD_ENABLE_DEPLOY", cmd_params, "COMM", 2)
    wait(3)
    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE","== 'DEPLOYMENT_HOME'", 60)

    # Fire frangibolt
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_FIRE_FRANGIBOLT", cmd_params, "COMM", 2)

    wait(3)

    wait_check("BW3", "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'FIRING_FRANGIBOLT_PRIMARY_PHASE'", 300)

    if tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == 'FRANGIBOLT_COMPLETED_NORMALLY' or
      tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == 'FRANGIBOLT_COMPLETED_BY_OVER_TIME' or
      tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == 'FRANGIBOLT_COMPLETED_BY_OVER_TEMP'
    
      Cosmos::Test.puts("Frangibolt sucessfully fired with status: " + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)

    else
      Cosmos::Test.puts("Frangibolt firing failed with status: " + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
      exit #("Frangibolt firing failed")
    end

    # Run Tilt Motor
    # -------------------------------------------------------------------------------
    Cosmos::Test.puts("Tilt Motor Phase: changing to deployment mode")

    # Enable deployment
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_CMD_ENABLE_DEPLOY", cmd_params, "COMM", 2)
    wait(3)
    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE","== 'DEPLOYMENT_HOME'", 60)

    # Send Run Tilt Motor Command
    Cosmos::Test.puts("Running tilt motor")
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_RUN_TILT_MOTOR", cmd_params, "COMM", 2)
    wait(3)

    # wait until telemetry status is not 'Deploying Tilt Motor'
    wait_check("BW3", "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'DEPLOYING_TILT_MOTOR'", 300) 

    # Check the status is 'Tilt Motor Deployed'
    if tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == "TILT_MOTOR_DEPLOYED"
      Cosmos::Test.puts("Tilt motor successfullyl deployed with status: " + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
    else
      Cosmos::Test.puts("Tilt motor deployment failed with status:" + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
      exit #("Tilt motor deployment failed") # stop the script
    end

    # Deploy Reflector
    # -------------------------------------------------------------------------------
    Cosmos::Test.puts("Reflector Phase: Chagning to deployment mode")

    # Enable deploy
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_CMD_ENABLE_DEPLOY", cmd_params, "COMM", 2)
    wait(3)
    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE","== 'DEPLOYMENT_HOME'", 60)

    # Send Deploy Reflector Command
    Cosmos::Test.puts("Deploying reflector")
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_DEPLOY_REFLECTOR", cmd_params, "COMM", 2)

    wait(3) 

    # wait until telemetry is not "Deploying Til Motor"
    wait_check("BW3", "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'DEPLOYING_REFLECTOR'", 1800) # 30 min

    # Check the telemetry is "Reflector Deployed"
    if tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == "REFLECTOR_DEPLOYED"
      Cosmos::Test.puts("Reflector deployment was successfully deployed with status: " + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
    else
      Cosmos::Test.puts("Reflector deployment failed with status:" + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
      exit #("Reflector deployment failed") # stop the script
    end

    message_box("Press enter to confirm, antenna will be powered down", "Continue")

    # Power off the downstream switches
    # -------------------------------------------------------------------------------
    power_qva_switches(qva_side, 0) # 0 = OFF

    start_logging("ALL")
  end



  # ------------------------------------------------------------------------------------
  def test_gimbal_motion
   
     setup("QV_Gimbal_Motion")

     # Ask for QV
     qva_side = combo_box("Select QV:", "YP", "YM")
 
     # wait for user to start
     message_box("test_gimbal_motion test procedure launched successfully. Press enter to start","Enter")
      
     Cosmos::Test.puts("Using APC: #{@board} and QVA: #{qva_side}")

     # Power On 
     Cosmos::Test.puts("Powering #{qva_side} on")
     power_qva_switches(qva_side, 1) # 1 = ON
 
     puts("Waiting for the antenna to be ready")

     # Wait until the antenna status is ready
     wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "== 'READY'", 10) 

     puts("Antenna is ready, starting self-test")

     # Start self Test
     cmd_params = {"QVA_LOCATION": qva_side}
     @cmd_sender.send_with_cmd_count_check(@board, "QVA_SELF_TEST", cmd_params, "COMM", 2)
     wait(3)

     #  Verify status is self test
     #wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "== 'SELF_TEST'", 10)

     # wait for self test to finish
     wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'SELF_TEST'", 60) 
     wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'HEATING'", 60) 
     wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'COOLING'", 60) 

    if tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == "WAITING_FOR_COMMAND"
      Cosmos::Test.puts("Self Test successful with current state: " + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
    else
      Cosmos::Test.puts("Self Test failed with current state:" + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
      exit #("Self test failed") # stop the script
    end

    puts("Self test successful, homing")

    # Send Home Gimbal command
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_HOME_GIMBAL", cmd_params, "COMM", 2)

    wait(3)

    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'HOMING'", 1800) 

    if tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == "HOME"
      Cosmos::Test.puts("Homing successful with status: " + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
    else
      Cosmos::Test.puts("Homing failed with status:" + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
      exit #("Homing failed") # stop the script
    end

    puts("Homing successful. Az = 0, El = 0")

    var_table = 0
    accept_user_input = true

    while accept_user_input
      az_val = ask("Enter the Azimuth value (3 to 357)")
      el_val = ask("Enter the Elevation value (-87 to 87)")

      if az_val ==0 and el_val == 0
        Cosmos::Test.puts("Test finished by user, homing")
        cmd_params = {"QVA_LOCATION": qva_side}
        @cmd_sender.send_with_cmd_count_check(@board, "QVA_HOME_GIMBAL", cmd_params, "COMM", 2)

        wait(3)

        wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'HOMING'", 1800) 

        if tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == "HOME"
          Cosmos::Test.puts("Homing successful with status: " + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
        else
          Cosmos::Test.puts("Homing failed with status:" + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
          exit #("Homing failed") # stop the script
        end

        break
      elsif az_val >3 and az_val <= 357 and el_val >=-87 and el_val <= 87

          Cosmos::Test.puts("Moving Gimbal to AZ: #{az_val} / EL: #{el_val}")

          # Send set azimuth elevation
          cmd_params = {"QVA_LOCATION": qva_side,
                        "QVA_AZIMUTH":az_val,
                        "QVA_ELEVATION": el_val,
                        "QVA_TABLE_ID":var_table,
                        "QVA_TABLE_IDX": 0}
          @cmd_sender.send_with_cmd_count_check(@board, "QVA_SET_AZIMUTH_ELEVATION", cmd_params, "COMM", 2)

          # Send set last index
          cmd_params = {"QVA_LOCATION": qva_side,
                        "QVA_TABLE_ID":var_table,
                        "QVA_TABLE_IDX": 0}
          @cmd_sender.send_with_cmd_count_check(@board, "QVA_SET_LAST_INDEX", cmd_params, "COMM", 2)

          # Send prime table
          cmd_params = {"QVA_LOCATION": qva_side,
                        "QVA_TABLE_ID":var_table}
          @cmd_sender.send_with_cmd_count_check(@board, "QVA_PRIME_TABLE", cmd_params, "COMM", 2)

          wait(3)
          # Wait until status is not TABLEZEROPRIMING or TABLEONEPRIMING
          wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'TABLE_ZERO_PRIMING'", 120)
          wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "!= 'TABLE_ONE_PRIMING'", 120)

          if tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == "TABLE_ZERO_PRIMED" or tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE") == "TABLE_ONE_PRIMED"
            Cosmos::Test.puts("Priming successful with status: " + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
          else
            Cosmos::Test.puts("Priming failed with status:" + (tlm("BW3 #{@board}-COMM_TLM QVA_#{qva_side}_STATUS_CURRENT_STATE")).to_s)
            exit #("Priming failed") # stop the script
          end

          if var_table ==0
            var_table = 1
          else
            var_table = 0
          end

      else
        puts("Values out of range. Try again")
      end


      

    end
    start_logging("ALL")

  end
  # ------------------------------------------------------------------------------------

  # PA Power and temperature test
  # ------------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def test_QV_PA

    setup("QV_PA")

    @module_telem.set_realtime(@board, "POWER_PCDU_LVC_TLM", @csp_destination, 1) 
    @module_telem.set_realtime(@board, "POWER_CSBATS_TLM", @csp_destination, 1)
    @module_telem.set_realtime(@board, "THERMAL_TLM", @csp_destination, 1) 
    
    message_box("test_QV_PA script launched successfully. Press Enter to start","Enter")

    Cosmos::Test.puts("Using #{@board}")

    pa_list = "QVA_YP_PA_RH","QVA_YP_PA_LH", "QVA_YM_PA_RH", "QVA_YM_PA_LH"

    pa_list.each do |sel_pa|
      Cosmos::Test.puts("Starting test for #{sel_pa}")

      method_name = "set_#{sel_pa}"
      if sel_pa == "QVA_YP_PA_RH"
        us_switch_tlm_name = "PCDU_BATT_V12_3"
        enable_param_name = "YP_RH"
      elsif sel_pa == "QVA_YP_PA_LH"
        us_switch_tlm_name = "PCDU_BATT_V12_4"
        enable_param_name = "YP_LH"
      elsif sel_pa == "QVA_YM_PA_RH"
        us_switch_tlm_name = "PCDU_BATT_V12_5"
        enable_param_name = "YM_RH"
      elsif sel_pa == "QVA_YM_PA_LH"
        us_switch_tlm_name = "PCDU_MPPT_V12_6"
        enable_param_name = "YM_LH"
      end

      message_box("PA #{sel_pa} will be enabled for 10 seconds. Get your tester ready to measure voltage and current, if required. Press Enter","Enter")

      puts("Measuring OFF state current for 10 seconds...")
      # Average OFF state for 10 seconds
      off_avg_vals = avg_current_voltage(@board, us_switch_tlm_name)

      # Enable PA (also enables upstream switch and checks the switch state)
      puts("Enabling PA and measuring ON state current and voltage for 10 seconds...")
      @pcdu.public_send(method_name, @board, 1)
      cmd_params = {"STATE": "ENABLE",
                    "PA_NUM": enable_param_name}
      @cmd_sender.send_with_cmd_count_check(@board, "QVA_ENABLE_DISABLE_PA", cmd_params, "COMM", @wait_time)

      # Check Current Telemetry and Average over 10 seconds
      on_avg_vals = avg_current_voltage(@board, us_switch_tlm_name)

      # Read the temperature and power
      temp_name = "#{sel_pa}_TEMP" 
      pa_temp = tlm(@target,"#{@board}-THERMAL_TLM", temp_name)
      #pa_pwr = tlm(@target,"#{@board}-POWER_PCDU_LVC_TLM", "#{sel_pa}_PWR")

      # Disable PA (does not disable upstream switch and checks the switch state)
      cmd_params = {"STATE": "ENABLE",
                    "PA_NUM": enable_param_name}
      @cmd_sender.send_with_cmd_count_check(@board, "QVA_ENABLE_DISABLE_PA", cmd_params, "COMM", @wait_time)
      @pcdu.public_send(method_name, @board, 0)


      # Print results 
      Cosmos::Test.puts("Measurement done. Results:")
      Cosmos::Test.puts("Voltage reading: #{on_avg_vals[0]} V")
      Cosmos::Test.puts("Delta current reading: #{on_avg_vals[1] - off_avg_vals[1]} A")
      #Cosmos::Test.puts("Power sensor reading: #{pa_pwr}")
      Cosmos::Test.puts("Temperature reading: #{pa_temp}")
    
    end

    puts("PA checks finished")
    start_logging("ALL")
    
  end

  # LNA Power  test
  # ------------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def test_QV_LNA

    setup("QV_LNA")

    @module_telem.set_realtime(@board, "POWER_PCDU_LVC_TLM", @csp_destination, 1) 
    @module_telem.set_realtime(@board, "POWER_CSBATS_TLM", @csp_destination, 1) 
    
    message_box("test_QV_LNA script launched successfully. Press Enter to start","Enter")

    Cosmos::Test.puts("Using #{@board}")

    pa_list = "QVA_YP_LNA_RH","QVA_YP_LNA_LH", "QVA_YM_LNA_RH", "QVA_YM_LNA_LH"

    pa_list.each do |sel_lna|
      Cosmos::Test.puts("Starting test for #{sel_lna}")

      method_name = "set_#{sel_lna}"
      if sel_lna == "QVA_YP_LNA_RH"
        us_switch_tlm_name = "PCDU_BATT_V12_3"
      elsif sel_lna == "QVA_YP_LNA_LH"
        us_switch_tlm_name = "PCDU_BATT_V12_4"
      elsif sel_lna == "QVA_YM_LNA_RH"
        us_switch_tlm_name = "PCDU_BATT_V12_5"
      elsif sel_lna == "QVA_YM_LNA_LH"
        us_switch_tlm_name = "PCDU_MPPT_V12_6"
      end

      message_box("LNA #{sel_lna} will be enabled for 10 seconds. Get your tester ready to measure voltage and current, if required. Press Enter","Enter")

      puts("Measuring OFF state current for 10 seconds...")
      # Average OFF state for 10 seconds
      off_avg_vals = avg_current_voltage(@board, us_switch_tlm_name)

      # Enable PA (also enables upstream switch and checks the switch state)
      puts("Enabling PA and measuring ON state current and voltage for 10 seconds...")
      @pcdu.public_send(method_name, @board, 1)

      # Check Current Telemetry and Average over 10 seconds
      on_avg_vals = avg_current_voltage(@board, us_switch_tlm_name)

      # Disable PA (does not disable upstream switch and checks the switch state)
      @pcdu.public_send(method_name, @board, 0)

      # Print results 
      Cosmos::Test.puts("Measurement done. Results:")
      Cosmos::Test.puts("Voltage reading: #{on_avg_vals[0]} V")
      Cosmos::Test.puts("Delta current reading: #{on_avg_vals[1] - off_avg_vals[1]} A")
    
    end

    puts("LNA checks finished")
    start_logging("ALL")
    
  end

  def avg_current_voltage(board, us_switch_tlm_name)

    if us_switch_tlm_name == "PCDU_BATT_V12_3"
      current_name = "PCDU_BATT_V12_3_ADC_IMON"
      voltage_name = "PCDU_BATT_V12_3_ADC_VMON"
    elsif us_switch_tlm_name == "PCDU_BATT_V12_4"
      current_name = "PCDU_BATT_V12_4_ADC_IMON"
      voltage_name = "PCDU_BATT_V12_4_ADC_VMON"
    elsif us_switch_tlm_name == "PCDU_BATT_V12_5"
      current_name = "PCDU_BATT_V12_5_ADC_IMON"
      voltage_name = "PCDU_BATT_V12_5_ADC_VMON"
    elsif us_switch_tlm_name == "PCDU_MPPT_V12_6"
      current_name = "PCDU_MPPT_V12_6_ADC_IMON"
      voltage_name = "PCDU_MPPT_V12_2_ADC_VMON"
    end

    power_id = subscribe_packet_data([[@target, "#{@board}-POWER_PCDU_LVC_TLM"]])

    current_total = 0
    voltage_total = 0

    # Average voltage and current for 10 seconds (1 HZ (10 times = 10 seconds))
    10.times do|i|
      packet = get_packet(power_id)
      current_total += packet.read(current_name)
      voltage_total += packet.read(voltage_name)
    end

    current_avg = current_total/10
    voltage_avg = voltage_total/10

    unsubscribe_packet_data(power_id)

    return voltage_avg,current_avg
  end
  
  # ------------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  # test_QV_Telem_check
  # ------------------------------------------------------------------------------------
  def test_QV_Telem_check

    setup("QV_Telem")

    # Ask for QV
    qvt_side = combo_box("Select QVT:", "YP", "YM")

    message_box("test_QV_Telem_check test script launched successfully. Press Enter to start", "Enter")

    Cosmos::Test.puts("Using APC: #{@board} and QVT: #{qvt_side}")

    # Power QVT PCDU switches
    power_qvt_switches(qvt_side, 1) # 1 = ON

    # Send command to set the selected QVT as primary
    cmd_params = {"SIDE": qvt_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVT_SET_CURRENT_QVT", cmd_params, "COMM", 2)

    # Start test
    check_qv_telem(@board)

    # Power off QVT PCDU switches
    power_qvt_switches(qvt_side, 0) # 0 = OFF

    start_logging("ALL")
  end


  # Telemetry check
  # ------------------------------------------------------------------------------------
  def check_qv_telem(board)

    packet = "#{@board}-COMM_TLM"

    qvt_temp = tlm(@target, packet, "QVT_TEMP")
    Cosmos::Test.puts("Temperature: #{qvt_temp}")

    tx_detect = tlm(@target, packet, "QVT_TX_DETECT_LEVEL")
    Cosmos::Test.puts("TX detector level: #{tx_detect}")

    clock_detect = tlm(@target, packet, "QVT_COMPARATOR_CLK_DETECT")
    Cosmos::Test.puts("Comparator Clock Detection: #{clock_detect}")

    power_good = tlm(@target, packet, "QVT_PWR_GOOD")
    Cosmos::Test.puts("Power good?: #{power_good}")

    n5v_level = tlm(@target, packet, "QVT_N5V_LEVEL")
    Cosmos::Test.puts("Voltage -5V: #{n5v_level}")

    p12v_level = tlm(@target, packet, "QVT_P12V_LEVEL")
    Cosmos::Test.puts("Voltage +12V: #{p12v_level}")
    
    p5v_level = tlm(@target, packet, "QVT_P5V_LEVEL")
    Cosmos::Test.puts("Voltage +5V: #{p5v_level}")

    p6d5v_level = tlm(@target, packet, "QVT_P6V5_LEVEL")
    Cosmos::Test.puts("Voltage +6.5V: #{p6d5v_level}")

    Cosmos::Test.puts("PLL Lock Status:")

    h_lock = tlm(@target, packet, "QVT_PLL_HIGH_IF_LOCK")
    Cosmos::Test.puts("- HIGH IF: #{h_lock}")

    m_lock = tlm(@target, packet, "QVT_PLL_MID_IF_LOCK")
    Cosmos::Test.puts("- MID IF: #{m_lock}")

    l_lock = tlm(@target, packet, "QVT_PLL_LOW_IF_LOCK")
    Cosmos::Test.puts("- LOW IF: #{l_lock}")

    rx_lock = tlm(@target, packet, "QVT_PLL_RX_LOCK")
    Cosmos::Test.puts("- RX: #{rx_lock}")

    tx_lock = tlm(@target, packet, "QVT_PLL_TX_LOCK")
    Cosmos::Test.puts("- TX: #{tx_lock}")

  end

  def test_antenna_health()
    setup("QV_Antenna_Health")

    # Ask for QV
    qva_side = combo_box("Select QV:", "YP", "YM")

    message_box("test_antenna_health script launched successfully. Press Enter to start","Enter")

    Cosmos::Test.puts("Using APC: #{@board} and QVA: #{qva_side}")

    # Power on
    # -------------------------------------------------------------------------------
    Cosmos::Test.puts("Powering #{qva_side} on")
    power_qva_switches(qva_side, 1) # 1 = ON

    puts("Waiting for the antenna to be ready...")

    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE","== 'READY'", 10)
  
    puts("Antenna is ready, starting Self Test")

    # Send QVA_SELF_TEST command
    # -------------------------------------------------------------------------------
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_SELF_TEST", cmd_params, "COMM", 2)
    wait(3)

    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "== 'WAITING_FOR_COMMAND'", 60)

    if tlm(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE") == "WAITING_FOR_COMMAND"
      Cosmos::Test.puts("Self Test successful")
    else
      Cosmos::Test.puts("Self test failed with status: #{tlm(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE")}")
    end

    # Power off
    # -------------------------------------------------------------------------------
    Cosmos::Test.puts("Powering #{qva_side} off")
    power_qva_switches(qva_side, 0) # 0 = OFF
  end

  def power_qva_switches(qva_side, switch_state)
    # switch_state : 1 = ON, 0 = OFF
    # switch state of off only turns off the downstream switches
    
    # Use the pcdu utility to turn on the switches
    # The upstream switch is turned on first, and the name is hardcoded in the utility

    # Turn on the 28V switches 
    switch_name = "QVA_#{qva_side}_V28"
    method_name = "set_#{switch_name}"
    puts "Setting #{switch_name} to #{switch_state}"
    @pcdu.public_send(method_name, @board, switch_state) 
    wait(3)

    # Turn on the 12V switches 
    switch_name = "QVA_#{qva_side}_V12"
    method_name = "set_#{switch_name}"
    puts "Setting #{switch_name} to #{switch_state}"
    @pcdu.public_send(method_name, @board, switch_state) 
    wait(3)

    # Turn on the 5V switches 
    switch_name = "QVA_#{qva_side}_V5"
    method_name = "set_#{switch_name}"
    puts "Setting #{switch_name} to #{switch_state}"
    @pcdu.public_send(method_name, @board, switch_state) 

    if switch_state == 1
      # Send QVA_ENABLE
      cmd_name = "QVA_SET_ENABLE"
      params = {
          "STATE": "ENABLE",
          "SIDE": qva_side
      }
      @cmd_sender.send_with_cmd_count_check(@board, cmd_name, params, "COMM")

      # Send QVA RESET
      cmd_name = "QVA_RESET"
      params = {
          "SIDE": qva_side,
      }
      @cmd_sender.send_with_cmd_count_check(@board, cmd_name, params, "COMM")
    end
  end

  def power_qvt_switches(qvt_side, switch_state)
    # Turn on the 12V switches 
    switch_name = "QV_TRANSCEIVER_#{qvt_side}_12V"
    method_name = "set_#{switch_name}"
    puts "Setting #{switch_name} to #{switch_state}"
    @pcdu.public_send(method_name, @board, switch_state) 
    wait(3)

    # Turn on the 5V switches 
    switch_name = "QV_TRANSCEIVER_#{qvt_side}_5V"
    method_name = "set_#{switch_name}"
    puts "Setting #{switch_name} to #{switch_state}"
    @pcdu.public_send(method_name, @board, switch_state) 
    wait(10)
  end

end

#handle = QVATest.new
#handle.test_QV_Telem_check