load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'AIT/FSW/individual_tests/Sys_test_individual.rb'
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")
load("TestRunnerUtils/test_case_utils.rb")


class CPU_PERCENTAGE_TEST < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @command_sender = CmdSender.new
    @target = "BW3"
    @cpu_percentage_max = 70
    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @board = combo_box("Select board", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC", "ALL_YP", "ALL_YM")
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestSys_#{@board}")
    end
    if @board == "APC_YP"
      @collectors = [
        {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}
      ]
    elsif @board == "APC_YM"
      @collectors = [
        {board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}
      ]
    elsif @board == "FC_YP"
      @collectors = [
        {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      ]
    elsif @board == "FC_YM"
      @collectors = [
        {board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      ]
    elsif @board == "DPC"
      @collectors = [
        {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      ]
    elsif @board == "ALL_YP" 
      @collectors = [
      {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"}
    ]
    elsif @board == "ALL_YM" 
      @collectors = [
      {board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"}
    ]
    end

    if @board == "DPC"
      @module_csp.reboot("DPC_1", true)
      @module_csp.reboot("DPC_2", true)
      @module_csp.reboot("DPC_3", true)
      @module_csp.reboot("DPC_4", true)
      @module_csp.reboot("DPC_5", true)
    elsif @board == 'ALL_YP'
      @module_csp.reboot("FC_YP", true)
      @module_csp.reboot("DPC_1", true)
      @module_csp.reboot("DPC_2", true)
      @module_csp.reboot("DPC_3", true)
      @module_csp.reboot("DPC_4", true)
      @module_csp.reboot("DPC_5", true)
      @module_csp.reboot("APC_YP", true)
    elsif @board == 'ALL_YM'
      @module_csp.reboot("FC_YM", true)
      @module_csp.reboot("DPC_1", true)
      @module_csp.reboot("DPC_2", true)
      @module_csp.reboot("DPC_3", true)
      @module_csp.reboot("DPC_4", true)
      @module_csp.reboot("DPC_5", true)
      @module_csp.reboot("APC_YM", true)
    else
      @module_csp.reboot(@board, true)
    end

    wait(7)

    @collectors.each do | collector |
      # Turn on FSW telemetry for all tests
      @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)
    end
    wait(2)
    status_bar("setup")
  end

  def test_a_uptime
    check_uptimes(@collectors, @command_sender)
  end

  def test_b_cpu_percentage
    check_cpu_utilization(@collectors, @command_sender, @cpu_percentage_max)
  end

  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

end
