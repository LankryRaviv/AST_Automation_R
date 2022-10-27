load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('TestRunnerUtils/test_case_utils.rb')

load_utility('Operations/Micron/MICRON_POWER_SHARE.rb')

class PowerShareToMicron < ASTCOSMOSTestMicron
  def initialize
    @micron_power = ModuleMicronPower.new
    @test_util = ModuleTestCase.new
    super()
    
  end

  def setup()
    plot_config_file = "./config/tools/tlm_grapher/micron_power.txt"
    spawn("./tools/TLMGrapher --start --config #{plot_config_file}")
    stack = @test_util.initialize_test_case("Power_Share_From_Micron")
    @apc_board = "APC_" + stack
  end

  def test_power_ON_micron_PCDU_APC_YP()
    setup()
    @micron_power.set_all_micron_switches("APC_YP", "ON")
  end

  def test_power_OFF_micron_PCDU_APC_YP()
    @micron_power.set_all_micron_switches("APC_YP", "OFF")
  end

  def test_power_ON_micron_PCDU_APC_YM()
    setup()
    @micron_power.set_all_micron_switches("APC_YM", "ON")
  end

  def test_power_OFF_micron_PCDU_APC_YM()
    @micron_power.set_all_micron_switches("APC_YM", "OFF")
  end

  def test_set_individual_micron_switch()
    setup()

    ask_for_input = true 
    while ask_for_input
      switch_name = combo_box("Select component name", "POWER_SHARE_MICRON_104", "POWER_SHARE_MICRON_107", "POWER_SHARE_MICRON_78", "POWER_SHARE_MICRON_120", "POWER_SHARE_MICRON_77", "POWER_SHARE_MICRON_119", "POWER_SHARE_MICRON_90", "POWER_SHARE_MICRON_93", "EXIT")
      
      if switch_name == "EXIT"
        break
      else
        val = combo_box("Turn on or off?", "ON", "OFF")

        @micron_power.set_individual_micron_power_share_switch(@apc_board, switch_name, val)
      end
    end
  end

end