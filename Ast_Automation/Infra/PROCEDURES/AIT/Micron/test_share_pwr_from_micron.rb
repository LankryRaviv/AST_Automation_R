load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('TestRunnerUtils/test_case_utils.rb')

load_utility('Operations/Micron/MICRON_POWER_SHARE.rb')

class PowerShareFromMicron < ASTCOSMOSTestMicron
  def initialize
    @micron_power = ModuleMicronPower.new
    @test_util = ModuleTestCase.new
    super()
    
  end

  def setup()

    stack = @test_util.initialize_test_case("Power_Share_From_Micron")
    @apc_board = "APC_" + stack
  end

  def test_set_individual_PCDU_boost_switch()
    setup()
    
    # Turn off the Micron 12V switches
    @micron_power.set_all_micron_switches(@apc_board, 'OFF')

    # Turn off Upstream Switches
    @micron_power.turn_off_all_micron_12V_upstream_switches(@apc_board)

    # Enable Boost switch
    enable_state = combo_box("Select Enable Boost state", "ON", "OFF")
    @micron_power.enable_boost_control(@apc_board, enable_state)

    ask_for_input = true 
    while ask_for_input

      # Ask user for the switch and state
      switch = combo_box("Select Boost Switch", "BOOST_SWITCH_1", "BOOST_SWITCH_2", "BOOST_SWITCH_3", "BOOST_SWITCH_4", "BOOST_SWITCH_5", "BOOST_SWITCH_6", "BOOST_SWITCH_7", "BOOST_SWITCH_8", "EXIT")

      if switch == "EXIT"
        break

      else

        state = combo_box("Select switch state", "ON", "OFF")

        # Set the switch
        @micron_power.set_pcdu_boost_switch(@apc_board, switch, state)

        if state == "ON"
          adjust_duty = true
          duty_cycle = switch
          duty_cycle["SWITCH"] = "DUTY_CYCLE"

          while adjust_duty
            # Ask for the amps
            amps = ask("Enter the Amps to set boost duty cycle between 0.469 and 2.42 Amps. Enter 'Exit' to finish")
            

            if amps.is_a? String
              break

            else
              # Set the duty cycle
              @micron_power.set_duty_cycle(@apc_board, duty_cycle, amps)
            end
            
          end
        end
      end


    end

  end


end

