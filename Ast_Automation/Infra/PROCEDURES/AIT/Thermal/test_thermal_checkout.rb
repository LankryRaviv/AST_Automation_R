load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')
load_utility('Operations/EPS/EPS_PCDU')
load_utility('AIT/CDH/failover_setup_functions.rb')


class ThermalCheckout < ASTCOSMOSTestThermal
  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @csp_destination = "COSMOS_UMBILICAL"
    @test_util = ModuleTestCase.new(@csp_destination)
    @failover = FailoverSetup.new
    @pcdu = PCDU.new
    @wait_time = 3
    @target = target
    @apc_board = ""
    @stack = ""
    super()
  end


  def setup()

    # Write to test runner log
    @stack = @test_util.initialize_test_case('Thermal_Checkout')
    @apc_board = "APC_" + @stack

    # Turn on Thermal telemetry
    @module_telem.set_realtime(@apc_board, "THERMAL_TLM", @csp_destination, 1) 

  end

  def test_RTD_checkout()

    setup()

    # Ask user for the correct temperature to check against
    temp = ask("Input the true room temperature in Celcius")
    time = Time.now
    folder = Cosmos::USERPATH + "/outputs/RTD_Temp_Checks"
    Dir.mkdir "#{folder}" unless File.exists?(folder)
    file_name = "#{folder}/RTD_checkout_#{time.strftime("%m-%d-%Y %H%M%S")}.csv"
    temp_tolerance = 10 
    comparison_tolerance = 6

    # Build Hash Array
    rtd_temps = [
      {"rtd_name": "RTD Name", "APC_YP_Value": "APC YP Value", "APC_YP_Check": "APC YP Check", "APC_YM_Value": "APC YM Value", "APC_YM_Check": "APC YM Check", "APC_Comp_Check": "APC Comparison Check"},
      {"rtd_name": "RTD_YM_CAM_XM1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_CAM_YM0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_CAM_YP0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_CP_XM", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_CP_XP", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_GPS_ANT", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_XM0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_XM1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_XP0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_XP1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_YM0_IN", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_YM1_IN", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_YP0_IN", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_YP1_IN", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_ZM0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_ZM1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_ZP0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_PANEL_ZP1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_SOLAR_XM", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_SOLAR_XP", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_SOLAR_YM", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_SOLAR_YP", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_SOLAR_ZP", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YM_ASU", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_CAM_XP1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_CAM_YM1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_CAM_YP1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_CAM_Z1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_CP_XM", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_CP_XP", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_GPS_ANT", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_XM0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_XM1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_XP0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_XP1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_YM0_IN", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_YM1_IN", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_YP0_IN", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_YP1_IN", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_ZM0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_ZP0", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_PANEL_ZP1", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_SOLAR_XM", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_SOLAR_XP", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_SOLAR_YM", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_SOLAR_YP", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_SOLAR_ZM", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},
      {"rtd_name": "RTD_YP_ASU", "APC_YP_Value": 0, "APC_YP_Check": "", "APC_YM_Value": 0, "APC_YM_Check": "", "APC_Comp_Check": ""},

    ]

    # Loop through each board
    2.times do |count|

      # Loop through each RTD, get telem value and check against room temp
      48.times do |index|
        rtd_temps[index+1][:"#{@apc_board}_Value"] = tlm(@target, "#{@apc_board}-THERMAL_TLM", rtd_temps[index+1][:rtd_name])

        if rtd_temps[index+1][:"#{@apc_board}_Value"] >= temp - temp_tolerance && rtd_temps[index+1][:"#{@apc_board}_Value"] <= temp + temp_tolerance
          rtd_temps[index+1][:"#{@apc_board}_Check"] = "PASS"
        else
          rtd_temps[index+1][:"#{@apc_board}_Check"] = "FAIL"
        end


        if count == 1
          # Compare the YP and YM values
          if rtd_temps[index+1][:"APC_YM_Value"] >= rtd_temps[index+1][:"APC_YP_Value"] - comparison_tolerance && rtd_temps[index+1][:"APC_YM_Value"] <= rtd_temps[index+1][:"APC_YP_Value"] + comparison_tolerance
            rtd_temps[index+1][:"APC_Comp_Check"] = "PASS"
          else
            rtd_temps[index+1][:"APC_Comp_Check"] = "FAIL"
          end

        end


      end

      if count == 0
        # Perform a stack switchover
            # Perform a stack switchover
        if @stack == "YP"
          # Switchover to YM
          @stack = "YM"
          @module_telem.set_realtime("APC_#{@stack}", "MEDIC_LEADER_TLM", @csp_destination, 1)
          @module_telem.set_realtime("APC_#{@stack}", "FSW_TLM_APC", @csp_destination, 1)
          @module_telem.set_realtime("FC_#{@stack}", "MEDIC_FOLLOWER_TLM_FC", @csp_destination, 1)
          @failover.setup_ym_as_primary(@csp_destination)
          @apc_board = "APC_#{@stack}"
        else
          # Switchover to YP
          @stack = "YP"
          @module_telem.set_realtime("APC_#{@stack}", "MEDIC_LEADER_TLM", @csp_destination, 1)
          @module_telem.set_realtime("APC_#{@stack}", "FSW_TLM_APC", @csp_destination, 1)
          @module_telem.set_realtime("FC_#{@stack}", "MEDIC_FOLLOWER_TLM_FC", @csp_destination, 1)
          @failover.setup_yp_as_primary(@csp_destination)
          @apc_board = "APC_#{@stack}"
        end

        # Write Version numbers for other APC
        @test_util.write_apc_fsw_version(@stack)
        @test_util.write_dpc_fsw_version(@stack)

      end

    end

    # Write CSV
    CSV.open(file_name, "wb") do |csv|
      rtd_temps.each do |hash|
        csv << hash.values
      end
    end

    Cosmos::Test.puts("Check file #{file_name} for the pass/fail results for each RTD")


  end


  def test_heater_checkout() 

    setup()
    @module_telem.set_realtime(@apc_board, "POWER_PCDU_LVC_TLM", @csp_destination, 1) 
    @module_telem.set_realtime(@apc_board, "POWER_CSBATS_TLM", @csp_destination, 1) 
    @module_telem.set_realtime("FC_#{@stack}", "AOCS_TLM", @csp_destination, 1) 

    # Heater Array
    heater_array = [{"switch_name": "Heater Name", "rtd_name1": "Temp 1 Name", "rtd_1_init": "Temp 1 Initial", "rtd_1_final": "Temp 1 Final", "rtd_name2": "Temp 2 Name", "rtd_2_init": "Temp 2 Initial", "rtd_2_final": "Temp 2 Final", "turn_off_time": "Turn off Time", "check": "PASS/FAIL"},
                    {"switch_name": "HEATER_SSYPXM_SSYPXP", "rtd_name1": "FSS_YPXP_TEMP", "rtd_1_init": "", "rtd_1_final": "", "rtd_name2": "FSS_YPXM_TEMP", "rtd_2_init": "", "rtd_2_final": "", "turn_off_time": "", "check": ""},
                    {"switch_name": "HEATER_CAMYPXM_CAMYPXP","rtd_name1": "RTD_YP_CAM_YP1", "rtd_1_init": "", "rtd_1_final": "","rtd_name2": "RTD_YM_CAM_YP0", "rtd_2_init": "", "rtd_2_final": "", "turn_off_time": "", "check": ""},
                    {"switch_name": "HEATER_SSYMXM_SSYMXP","rtd_name1": "FSS_YMXP_TEMP", "rtd_1_init": "", "rtd_1_final": "","rtd_name2": "FSS_YMXM_TEMP", "rtd_2_init": "", "rtd_2_final": "", "turn_off_time": "", "check": ""},
                    {"switch_name": "HEATER_CAMYMXM_CAMYMXP", "rtd_name1": "RTD_YM_CAM_YM0", "rtd_1_init": "", "rtd_1_final": "","rtd_name2": "RTD_YP_CAM_YM1","rtd_2_init": "", "rtd_2_final": "", "turn_off_time": "", "check": ""},
                    {"switch_name": "HEATER_GPSXM_GPSYM", "rtd_name1": "FSS_ZXM_TEMP", "rtd_1_init": "", "rtd_1_final": "", "rtd_name2": "FSS_ZXP_TEMP", "rtd_2_init": "", "rtd_2_final": "", "turn_off_time": "", "check": ""}]
    heater_time_out = 120 # 2 minutes
    delta_temp = 6 # deg C
    time = Time.now
    folder = Cosmos::USERPATH + "/outputs/Heater_Checks"
    Dir.mkdir "#{folder}" unless File.exists?(folder)
    file_name = "#{folder}/Heater_checkout_#{time.strftime("%m-%d-%Y %H%M%S")}.csv"

    # Loop through each heater
    5.times do |index|
      index = index + 1

      if heater_array[index][:rtd_name1].include? "RTD"
        packet = "#{@apc_board}-THERMAL_TLM"
      else
        packet = "FC_#{@stack}-AOCS_TLM"
      end

      # Get initial temperature 
      heater_array[index][:rtd_1_init] = tlm(@target, packet, heater_array[index][:rtd_name1])
      heater_array[index][:rtd_2_init] = tlm(@target, packet, heater_array[index][:rtd_name2])

      # Turn on Heater
      method_name = "set_#{heater_array[index][:switch_name]}"
      @pcdu.public_send(method_name, @apc_board, 1)

      # Get start time
      start_time = Time.now
      temp_reached = false

      # Loop until temperature is reached or timeout is reached
      while ((Time.now- start_time) < heater_time_out || temp_reached)

        if tlm(@target, packet, heater_array[index][:rtd_name1]) >= heater_array[index][:rtd_1_init]+delta_temp && tlm(@target, packet, heater_array[index][:rtd_name2]) >= heater_array[index][:rtd_2_init]+delta_temp

          Cosmos::Test.puts("#{heater_array[index][:switch_name]} Passed: Delta temperature reached after #{(Time.now - start_time)/1000} s")
          temp_reached = true
          heater_array[index][:rtd_1_final] = tlm(@target, packet, heater_array[index][:rtd_name1])
          heater_array[index][:rtd_1_final] = tlm(@target, packet, heater_array[index][:rtd_name2])
          heater_array[index][:check] = "PASS"
          heater_array[index][:turn_off_time] = Time.now- start_time

        else
          # Temperature not reached, wait 1 second and try again
          wait(1)
        end

      end

      # Turn off Heater
      @pcdu.public_send(method_name, @apc_board, 0)

      # If temperature was not reached, write a failure
      if !temp_reached
        Cosmos::Test.puts("#{heater_array[index][:switch_name]} Failed: Delta temperature not reached after waiting #{(Time.now - start_time)/1000} s")
        heater_array[index][:rtd_1_final] = tlm(@target, packet, heater_array[index][:rtd_name1])
        heater_array[index][:rtd_2_final] = tlm(@target, packet, heater_array[index][:rtd_name2])
        heater_array[index][:check] = "FAIL"
        heater_array[index][:turn_off_time] = Time.now- start_time
      end
    end

    # Write CSV
    CSV.open(file_name, "wb") do |csv|
      heater_array.each do |hash|
        csv << hash.values
      end
    end

    Cosmos::Test.puts("Heater results also recorded in file #{file_name}")
  end

end

#handle = ThermalCheckout.new
#handle.test_heater_checkout