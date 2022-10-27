load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/ast_test_base.rb'
load_utility("Operations/FSW/FSW_CSP")
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility("Operations/FSW/FSW_Telem")
load_utility('Operations/AOCS/AOCS_FSS')
load_utility('TestRunnerUtils/test_case_utils.rb')

class FSSTest_SOH < ASTCOSMOSTestAOCS
  def initialize
    @telem = ModuleTelem.new
    @FSS = ModuleFSS.new
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @realtime_destination = 'COSMOS_UMBILICAL'
    @test_util = ModuleTestCase.new
    @module_csp = ModuleCSP.new
    super()
  end

  def setup
    @fss_num = ask("Enter the FSS ID")
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
    start_logging("ALL","FSS_AIT_SOH")
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
  end

  def test_a_power_on_FSS_SOH()
    @FSS.power_on_FSS(@apc_num)
  end

  def test_b_get_FSS_data_SOH()
    @FSS.get_FSS_data(@fss_num,@fc_num)
  end 

  def test_c_power_off_FSS_OUT()
    @FSS.power_off_FSS(@apc_num)
  end
  
  def teardown()
    start_logging("ALL")
  end
 
 end




