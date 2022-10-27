load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'AIT/FSW/individual_tests/Supervisor_test_individual.rb'
load('Operations/FSW/FSW_Telem.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
load("Operations/FSW/FSW_CSP.rb")

class SUPERVISOR_TEST < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @max_tasks = 26
    @APC_task_count = 26 # This must be manually updated
    @FC_task_count = 15  # This too
    @DPC_task_count = 11 # This three

    @APC_task_status = Array.new(@APC_task_count,0) #Length must be manually updated
    for i in 1..(@max_tasks-@APC_task_count)
      @APC_task_status.append(123)                  #Append 123 for indices without tasks
    end

    @FC_task_status = Array.new(@FC_task_count,0)
    for i in 1..(@max_tasks-@FC_task_count)
      @FC_task_status.append(123)                  #Append 123 for indices without tasks
    end

    @DPC_task_status = Array.new(@DPC_task_count, 0)
    for i in 1..(@max_tasks - @DPC_task_count)
      @DPC_task_status.append(123)
    end

    @failed_task_count = 5
    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @board = combo_box("Select board", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC","ALL_YP", "ALL_YM")
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestSupervisor_#{@board}")
    end
    if @board == "APC_YP" or  @board == "ALL_YP" 
      @collectors = [
        {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}
      ]
    elsif @board == "APC_YM" or  @board == "ALL_YM" 
      @collectors = [
        {board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}
      ]
    elsif @board == "FC_YP" or  @board == "ALL_YP" 
      @collectors = [
        {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}
    ]
    elsif @board == "FC_YM" or  @board == "ALL_YM" 
      @collectors = [
        {board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
      ]
    elsif @board == "DPC" or  @board == "ALL_YM" or  @board == "ALL_YP" 
      @collectors = [
        {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
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
      wait(10)
    status_bar("setup")
  end

  def test_a_task_count
    check_task_count(@collectors, @realtime_destination, @module_telem, @APC_task_count, @FC_task_count, @DPC_task_count)
  end

  def test_b_task_status
    check_task_status(@collectors, @module_telem, @realtime_destination, @APC_task_status, @FC_task_status, @DPC_task_status)
  end

  def test_c_failed_task_count
    check_failed_count(@collectors, @module_telem, @realtime_destination, @failed_task_count)
  end

  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end
end