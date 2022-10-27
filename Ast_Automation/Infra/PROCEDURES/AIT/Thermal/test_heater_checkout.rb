load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')
load_utility('Operations/EPS/EPS_PCDU')
load_utility('Operations/THERMAL/set_heater_config.rb')


class HeaterCheckout < ASTCOSMOSTestThermal
  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @csp_destination = "COSMOS_UMBILICAL"
    @test_util = ModuleTestCase.new(@csp_destination)
    @heater_config = SetHeaterConfig.new
    @pcdu = PCDU.new
    @wait_time = 5
    @target = target
    @apc_board = ""
    @stack = ""
    super()
  end


  def setup()

    # Write to test runner log
    @stack = @test_util.initialize_test_case('Thermal_Checkout')
    @apc_board = "APC_" + @stack
    @fc_board = "FC_" + @stack

    # Turn on Thermal telemetry
    @module_telem.set_realtime(@apc_board, "FSW_TLM_APC", @csp_destination, 1) 
    @module_telem.set_realtime(@apc_board, "POWER_PCDU_LVC_TLM", @csp_destination, 1) 
    @module_telem.set_realtime(@apc_board, "POWER_CSBATS_TLM", @csp_destination, 1) 
    @module_telem.set_realtime(@apc_board, "THERMAL_TLM", @csp_destination, 1) 
    @module_telem.set_realtime(@fc_board, "AOCS_TLM", @csp_destination, 1) 

    # Turn on the FSS (comment out if using pseudo)
    cmd_params = {"OUTPUT_CHANNEL": "SUN_SENSOR",
                  "STATE_ONOFF": "ON",
                  "DELAY": 0}
    @cmd_sender.send_with_cmd_count_check(@apc_board, "APC_LVC_OUTPUT_SINGLE", cmd_params, "POWER", @wait_time)

  end

  
  def test_heater_checkout() 

    # Setup 
    # --------------------------------------------------------
    setup()
    
    # Define Heater Settings
    heater_test_hot_setpoint = 35
    heater_test_cold_setpoint = 30
    heater_mode = "AUTO"

    # Heater Array (flight)
    heater_array = [{"switch_name": "HEATER_SSYPXM_SSYPXP", "switch_telem_name": "PCDU_BATT_HEATER_SSYPXM", "rtd_name1": "SUN_SENSOR_YPXP", "rtd1_telem_name": "FSS_YPXP_TEMP", "rtd_name2": "SUN_SENSOR_YPXM", "rtd2_telem_name": "FSS_YPXM_TEMP"},
                    {"switch_name": "HEATER_CAMYPXM_CAMYPXP", "switch_telem_name": "PCDU_BATT_HEATER_CAMYPXM", "rtd_name1": "RTD_YP_CAM_YP1","rtd1_telem_name": "RTD_YP_CAM_YP1", "rtd_name2": "RTD_YM_CAM_YP0", "rtd2_telem_name": "RTD_YM_CAM_YP0"},
                    {"switch_name": "HEATER_SSYMXM_SSYMXP", "switch_telem_name": "PCDU_BATT_HEATER_SSYMXM_SSYMXP", "rtd_name1": "SUN_SENSOR_YMXP","rtd1_telem_name": "FSS_YMXP_TEMP", "rtd_name2": "SUN_SENSOR_YMXM", "rtd2_telem_name": "FSS_YMXM_TEMP"},
                    {"switch_name": "HEATER_CAMYMXM_CAMYMXP", "switch_telem_name": "PCDU_BATT_HEATER_CAMYMXM","rtd_name1": "RTD_YM_CAM_YM0", "rtd1_telem_name": "RTD_YM_CAM_YM0", "rtd_name2": "RTD_YP_CAM_YM1", "rtd2_telem_name": "RTD_YP_CAM_YM1"},
                    {"switch_name": "HEATER_EIGHT", "switch_telem_name": "PCDU_BATT_HEATER_CAMYMXP", "rtd_name1": "RTD_YM_GPS_ANT", "rtd1_telem_name": "RTD_YM_GPS_ANT", "rtd_name2": "RTD_YP_GPS_ANT", "rtd2_telem_name": "RTD_YP_GPS_ANT"}] # HEATER_GPSXM_GPSYM, PCDU_BATT_HEATER_GPSXM_GPSYM
    # heater array (pseudo)
    # heater_array = [{"switch_name": "HEATER_SSYPXM_SSYPXP", "switch_telem_name": "PCDU_BATT_HEATER_SSYPXM", "rtd_name1": "RTD_YP_PANEL_XP1", "rtd1_telem_name": "RTD_YP_PANEL_XP1", "rtd_name2": "RTD_YM_PANEL_XP1", "rtd2_telem_name": "RTD_YM_PANEL_XP1"},
    #                 {"switch_name": "HEATER_CAMYPXM_CAMYPXP", "switch_telem_name": "PCDU_BATT_HEATER_CAMYPXM", "rtd_name1": "RTD_YP_CAM_YP1","rtd1_telem_name": "RTD_YP_CAM_YP1", "rtd_name2": "RTD_YM_CAM_YP0", "rtd2_telem_name": "RTD_YM_CAM_YP0"},
    #                 {"switch_name": "HEATER_SSYMXM_SSYMXP", "switch_telem_name": "PCDU_BATT_HEATER_SSYMXM_SSYMXP", "rtd_name1": "RTD_YP_PANEL_XP0","rtd1_telem_name": "RTD_YP_PANEL_XP0", "rtd_name2": "RTD_YM_PANEL_XP0", "rtd2_telem_name": "RTD_YM_PANEL_XP0"},
    #                 {"switch_name": "HEATER_CAMYMXM_CAMYMXP", "switch_telem_name": "PCDU_BATT_HEATER_CAMYMXM","rtd_name1": "RTD_YP_CAM_YM1", "rtd1_telem_name": "RTD_YP_CAM_YM1", "rtd_name2": "RTD_YM_CAM_YM0", "rtd2_telem_name": "RTD_YM_CAM_YM0"},
    #                 {"switch_name": "HEATER_EIGHT", "switch_telem_name": "PCDU_BATT_HEATER_CAMYMXP", "rtd_name1": "RTD_YP_GPS_ANT", "rtd1_telem_name": "RTD_YP_GPS_ANT", "rtd_name2": "RTD_YM_GPS_ANT", "rtd2_telem_name": "RTD_YM_GPS_ANT"}]

    # Loop through each heater
    # --------------------------------------------------------
    heater_array.each do |heater|

      # Define the packet for the temperature data
      if heater[:rtd_name1].include? "RTD"
        packet = "#{@apc_board}-THERMAL_TLM"
      else
        packet = "#{@fc_board}-AOCS_TLM"
      end

      Cosmos::Test.puts("Starting test for #{heater[:switch_name]}")
      
      # Get initial temperature 
      Cosmos::Test.puts("Initial temp for #{heater[:rtd_name1]}: #{tlm(@target, packet, heater[:rtd1_telem_name])}")
      Cosmos::Test.puts("Initial temp for #{heater[:rtd_name2]}: #{tlm(@target, packet, heater[:rtd2_telem_name])}")

      # Set the heater config settings
      message_box("Ready to start test for heater #{heater[:switch_name]}. Press Continue to load the configuration", "Continue")
      @heater_config.set_heater_row(@apc_board, heater[:switch_name], heater_test_cold_setpoint, heater_test_hot_setpoint, heater_mode, heater[:rtd_name1], heater[:rtd_name2])

      wait_check("BW3","#{@apc_board}-POWER_PCDU_LVC_TLM", heater[:switch_telem_name], "=='ON'", 60)

      # Get start time
      start_time = Time.now
      temp_reached = false

      # Loop until temperature is reached or timeout is reached
      while true 

        if (tlm(@target, packet, heater[:rtd1_telem_name]) >= 45 || tlm(@target, packet, heater[:rtd2_telem_name]) >= 45)

          # The temperatrue is too high, turn off the heater
          Cosmos::Test.puts("WARNING!:Temperature is TOO HIGH. Turning off heater PCDU switch")
          Cosmos::Test.puts("#{heater[:rtd1_telem_name]}: #{tlm(@target, packet, heater[:rtd1_telem_name])}")
          Cosmos::Test.puts("#{heater[:rtd2_telem_name]}: #{tlm(@target, packet, heater[:rtd2_telem_name])}")

          # Turn off Heater - ignore hazardous warning
          cmd_params = {"SWITCH_NUM": heater[:switch_name],
                        "SWITCH_STATE": "OFF"}
          @cmd_sender.send_with_cmd_count_check(@apc_board, "PCDU_SET_DS_SWITCH", cmd_params, "POWER", @wait_time, true)

          # Break loop
          break

        elsif tlm(@target, "#{@apc_board}-POWER_PCDU_LVC_TLM", heater[:switch_telem_name]) == "OFF"

          Cosmos::Test.puts("#{heater[:switch_name]} turned off after #{Time.now - start_time} seconds")
          Cosmos::Test.puts("#{heater[:rtd1_telem_name]}: #{tlm(@target, packet, heater[:rtd1_telem_name])}")
          Cosmos::Test.puts("#{heater[:rtd2_telem_name]}: #{tlm(@target, packet, heater[:rtd2_telem_name])}")

          # Break Loop
          break

        else
          # Temperature not reached and heater is still on, wait 0.25 second and try again
          wait(0.25)
        end
      end

      # Reset the config to flight settings
      # --------------------------------------------------------
      @heater_config.set_heater_row(@apc_board, heater[:switch_name], -35, -30, heater_mode, heater[:rtd_name1], heater[:rtd_name2])
      #@heater_config.load_heater_config(@apc_board)

    end


    # Turn off Sun Sensor (comment out if using pseudo)
    # --------------------------------------------------------
    answer = combo_box("Turn off Sun Sensors?", "Yes", "No")

    if answer == "Yes"
      cmd_params = {"OUTPUT_CHANNEL": "SUN_SENSOR",
                  "STATE_ONOFF": "OFF",
                  "DELAY": 0}
      @cmd_sender.send_with_cmd_count_check(@apc_board, "APC_LVC_OUTPUT_SINGLE", cmd_params, @wait_time)
    end

  end

end

#handle = HeaterCheckout.new
#handle.test_heater_checkout