load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/ast_test_base.rb'
load_utility("Operations/FSW/FSW_CSP")

load_utility('Operations/FSW/UTIL_CmdSender')
load_utility("Operations/FSW/FSW_Telem")
load_utility('Operations/AOCS/AOCS_EMT')
load_utility('Operations/EPS/EPS_PCDU')
load_utility('TestRunnerUtils/test_case_utils.rb')

class EMTTest_ACT < ASTCOSMOSTestAOCS
  def initialize
    @EMT = ModuleEMT.new
    @PCDU = PCDU.new
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @telem = ModuleTelem.new
    @realtime_destination = 'COSMOS_UMBILICAL'
    @test_util = ModuleTestCase.new
    @module_csp = ModuleCSP.new
    super()
  end

  def setup
    @emt_id = ask("Enter the EMT ID")
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
    start_logging("ALL","EMT_AIT_ACTIVATION")
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
  end

  def test_a_set_EMT_ACTIVATION()
    @PCDU.set_ROD_POS(@apc_num,1)
    wait(5)
    @PCDU.set_ROD_NEG(@apc_num,1)
  end

  def test_b_actuator_ground_mode_ACTIVATION()
    @EMT.actuator_ground_mode(@fc_num, "GROUND")
  end

  def test_c_on_EMT_positive_ACTIVATION()
    @EMT.on_EMT_positive(@fc_num,@emt_id)
    message_box("Press Continue after measurement is complete", "Continue")
  end

  def test_d_on_EMT_negative_ACTIVATION()
    @EMT.on_EMT_negative(@fc_num,@emt_id)
    message_box("Press Continue after measurement is complete", "Continue")
  end

  def test_e_EMT_off_ACTIVATION()
    @EMT.EMT_off(@fc_num,@emt_id)
  end

  def test_f_set_EMT_ACTIVATION()
    @PCDU.set_ROD_POS(@apc_num,0)
    wait(5)
    @PCDU.set_ROD_NEG(@apc_num,0)
  end

  def teardown()
    start_logging("ALL")
  end

 end




