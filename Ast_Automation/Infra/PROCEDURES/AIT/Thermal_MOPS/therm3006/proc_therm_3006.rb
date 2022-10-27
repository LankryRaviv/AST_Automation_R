load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'

load_utility('Operations/THERMAL/THERM_Telem')

require 'yaml'

# This proc demonstrates the usage of the setup and teardown methods
# as well as defining tests. Notice that the setup and teardown
# methods must be called exactly that. Other test methods must start
# with 'test_' to be picked up by TestRunner.
class THERM3006 < ASTCOSMOSThermalMOPS # Thermal procs must inherit from ASTCOSMOSThermalMOPS
  def initialize
    super()
  end

  def setup
    status_bar("setup")
  end

  def test_all_on
    path = File.expand_path("./yml_conf", File.dirname(__FILE__))
    path = File.expand_path("./therm_3006_all_on.yml", path)

    therm_3001_main(path)
  end

  def test_all_off
    path = File.expand_path("./yml_conf", File.dirname(__FILE__))
    path = File.expand_path("./therm_3006_all_off.yml", path)

    therm_3001_main(path)
  end

  def test_configurable
    path = File.expand_path("./yml_conf", File.dirname(__FILE__))
    path = File.expand_path("./therm_3006_configurable.yml", path)

    therm_3001_main(path)
  end

  def therm_3006_main(yaml_path)

    valid_heater_states = [
      "HEATER_SSYPXM",
      "HEATER_CAMYPXM",
      "HEATER_SSYPXP",
      "HEATER_CAMYPXP",
      "HEATER_SSYMXM_SSYMXP",
      "HEATER_CAMYMXM",
      "HEATER_GPSXM_GPSYM",
      "HEATER_CAMYMXP",]

    proc_yaml = YAML.load_file(yaml_path)

    if proc_yaml["heater-choice"].keys == ['All']
        param_array = valid_heater_states.map { |item| [item, proc_yaml["heater-choice"]["All"]]}

    else
        invalid_states = proc_yaml["heater-choice"].keys - valid_heater_states
        invalid_states_provided = !(invalid_states).empty?

        if invalid_states_provided
            if invalid_states == ['All']
                p "values provided for 'All' and for individual Heaters"
            else
                p "invalid heater name provided"
            end
            param_array = []
        else
            param_array = proc_yaml["heater-choice"].to_a
        end

    end

    p param_array

    therm_telem = ModuleTelem.new
    param_array.each { |param|
        # p param[0], param[1]

        therm_telem.send(
            "bms_set_heater_auto",
            proc_yaml["apc-choice"],
            param[0],
            param[1]
        )
    }

  end

end

