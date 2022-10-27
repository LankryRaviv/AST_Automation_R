load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/ast_test_base.rb'
load_utility("Operations/FSW/FSW_CSP")
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility("Operations/FSW/FSW_Telem")
load_utility('Operations/AOCS/AOCS_RWA')
load_utility('TestRunnerUtils/test_case_utils.rb')

class RWATest_SOH < ASTCOSMOSTestAOCS
  def initialize
    @telem = ModuleTelem.new
    @RWA = ModuleRWA.new
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @realtime_destination = 'COSMOS_UMBILICAL'
    @test_util = ModuleTestCase.new
    @module_csp = ModuleCSP.new
    super()
  end

  def setup
    @rwa_num = ask("Enter the RWA NUM")
    stack = @test_util.initialize_test_case('test_case_tag')
    @apc_num = "APC_" + stack
    @fc_num = "FC_" + stack
    @module_csp.reboot(@fc_num)
    wait(7)
    @module_csp.reboot(@apc_num)
    wait(7)
    @telem.set_realtime(@apc_num, "FSW_TLM_APC", @realtime_destination, 1)
    @telem.set_realtime(@apc_num, "POWER_PCDU_LVC_TLM", @realtime_destination, 1)
    @telem.set_realtime(@apc_num, "POWER_CSBATS_TLM", @realtime_destination, 1)
    @telem.set_realtime(@fc_num, "FSW_TLM_FC", @realtime_destination, 1)
    @telem.set_realtime(@fc_num, "AOCS_TLM", @realtime_destination, 1)
    status_bar("setup")
    start_logging("ALL","RW_AIT_SOH")
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
  end

  def test_a_power_on_RWA_SOH()
    @RWA.power_on_RWA(@apc_num, @rwa_num)
  end 

  def test_b_actuator_ground_mode_SOH()
    @RWA.actuator_ground_mode(@fc_num, "GROUND")
  end

  def test_c_send_RWA_NOOP_SOH()
    @RWA.send_RWA_NOOP(@fc_num, @rwa_num)
  end

  def test_d_set_wheel_mode_RWA_SOH()
    @RWA.set_wheel_mode_RWA(@fc_num, @rwa_num, "EXTERNAL")
  end

  def test_e_power_off_RWA_SOH()
    @RWA.power_off_RWA(@apc_num, @rwa_num)
  end 

  def teardown()
    start_logging("ALL")
  end
end
  
