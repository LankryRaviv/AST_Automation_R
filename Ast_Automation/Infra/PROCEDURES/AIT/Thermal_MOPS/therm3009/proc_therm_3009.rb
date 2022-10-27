load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'

load_utility('Operations/THERMAL/THERM_Telem')

require 'yaml'

# This proc demonstrates the usage of the setup and teardown methods
# as well as defining tests. Notice that the setup and teardown
# methods must be called exactly that. Other test methods must start
# with 'test_' to be picked up by TestRunner.
class THERM3009 < ASTCOSMOSThermalMOPS # Thermal procs must inherit from ASTCOSMOSThermalMOPS
  def initialize
    super()
  end

  def setup
    status_bar("setup")
  end

  def test_on
    path = File.expand_path("./yml_conf", File.dirname(__FILE__))
    path = File.expand_path("./therm_3009_auto.yml", path)

    therm_3009_main(path)
  end

  def test_off
    path = File.expand_path("./yml_conf", File.dirname(__FILE__))
    path = File.expand_path("./therm_3009_manual.yml", path)

    therm_3009_main(path)
  end

  def therm_3009_main()

    valid_modes = ["ON", "OFF"]

    proc_yaml = YAML.load_file(yaml_path)

    invalid_states = [proc_yaml["mode"]] - valid_modes
    invalid_states_provided = !(invalid_states).empty?

    if invalid_states_provided
      p "invalid mode provided"
    else
      therm_telem = ModuleTelem.new
      therm_telem.send(
          "lvc_battery_heater_mode",
          board,
          "MANUAL"
      )

      therm_telem.send(
          "lvc_battery_heater_state",
          board,
          proc_yaml["mode"]
      )

    end

  end

end

