load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/ast_test_base.rb'
load_utility("Operations/FSW/FSW_CSP")
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility("Operations/FSW/FSW_Telem")
load_utility('Operations/AOCS/AOCS_MAG')
load_utility('TestRunnerUtils/test_case_utils.rb')


class MAGTest_SOH < ASTCOSMOSTestAOCS
  def initialize
    @telem = ModuleTelem.new
    @MAG = ModuleMAG.new
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @telem = ModuleTelem.new
    @realtime_destination = 'COSMOS_UMBILICAL'
    @test_util = ModuleTestCase.new
    @module_csp = ModuleCSP.new
    super()
  end

  def setup
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
    start_logging("ALL","MAG_AIT_SOH")
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
  end

  def test_a_get_MAG_measurements_SOH()
    @MAG.get_MAG_measurements(@fc_num)
    wait(300)
  end

  def test_b_MAG_reset_SOH()
    @MAG.MAG_reset(@fc_num)
  end

  def test_c_get_MAG_measurements_SOH()
    @MAG.get_MAG_measurements(@fc_num)
    wait(300)
  end

  def teardown()
    start_logging("ALL")
  end

end
  
