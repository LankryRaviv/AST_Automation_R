load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'

load_utility('Operations/THERMAL/THERM_Telem')

require 'yaml'

# This proc demonstrates the usage of the setup and teardown methods
# as well as defining tests. Notice that the setup and teardown
# methods must be called exactly that. Other test methods must start
# with 'test_' to be picked up by TestRunner.
class THERM3002 < ASTCOSMOSThermalMOPS # Thermal MOPS procs must inherit from ASTCOSMOSThermalMOPS
  def initialize
    super()
  end

  def setup
    status_bar("setup")
  end

  def test_configurable
    path = File.expand_path("./yml_conf", File.dirname(__FILE__))
    path = File.expand_path("./therm_3002_configurable.yml", path)

    therm_3002_main(path)
  end

  def therm_3002_main(yaml_path)

    valid_bcu_states = ["BCU1", "BCU2", "BCU3", "BCU4", "BCU5", "BCU6", "AGGREGATOR"]

    proc_yaml = YAML.load_file(yaml_path)

    p proc_yaml["bcu-choice"].keys

    if proc_yaml["bcu-choice"].keys == ['All'] #TODO capitalisation
      if proc_yaml["bcu-choice"]["All"]["on-threshold"]
        param_array_thr_on = valid_bcu_states.map { |item| [item, proc_yaml["bcu-choice"]["All"]["on-threshold"]]}
      else
        param_array_thr_on = []
      end
      p param_array_thr_on

      if proc_yaml["bcu-choice"]["All"]["off-threshold"]
        param_array_thr_off = valid_bcu_states.map { |item| [item, proc_yaml["bcu-choice"]["All"]["off-threshold"]]}
      else
        param_array_thr_off = []
      end
      p param_array_thr_off

    else
        invalid_states = proc_yaml["bcu-choice"].keys - valid_bcu_states
        invalid_states_provided = !(invalid_states).empty?

        p invalid_states_provided

        if invalid_states_provided
            if invalid_states == ['All']
                p "values provided for 'All' and for individual BCU's"
            else
                p "invalid BCU name provided"
            end
            param_array_thr_on = []
            param_array_thr_off = []
        else
          param_array_thr_on = proc_yaml["bcu-choice"].to_a.map { |item|
            if item[1]["on-threshold"]
              [item[0], item[1]["on-threshold"]]
            end
          }.compact
          p param_array_thr_on

          param_array_thr_off = proc_yaml["bcu-choice"].to_a.map { |item|
            if item[1]["off-threshold"]
              [item[0], item[1]["off-threshold"]]
            end
          }.compact
          p param_array_thr_off
        end
    end

    therm_telem = ModuleTelem.new
    on_threshold_param_array.each { |param|
      # p param[0], param[1]

      therm_telem.send(
          "bms_set_heater_on_threshold",
          board,
          param[0],
          param[1].to_i
      )
    }

    off_threshold_param_array.each { |param|
      # p param[0], param[1]

      therm_telem.send(
          "bms_set_heater_off_threshold",
          board,
          param[0],
          param[1].to_i
      )
    }

  end

end

