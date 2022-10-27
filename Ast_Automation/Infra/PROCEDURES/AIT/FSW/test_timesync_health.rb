load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'AIT/FSW/individual_tests/Timesync_test_individual.rb'
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")

class TIMESYNC_LONG_TEST < ASTCOSMOSTestFSW
 def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @command_sender = CmdSender.new
    @target = "BW3"
    @collectors = [
      {board: 'APC_YP', pkt_name: 'GET_TIMESTAMP_RESP',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YP',  pkt_name: 'GET_TIMESTAMP_RESP',  sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_1', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
      {board: 'DPC_2', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
      {board: 'DPC_3', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: "NORMAL"},
      {board: 'DPC_4', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
      {board: 'DPC_5', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
    ]
    @boards = {}
    super()
   end

   def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestTimeSync")
    end
    @boards = combo_box("Select board", "ALL_YP", "ALL_YM")
    if @boards == "ALL_YM"
      @collectors = [
        {board: 'APC_YM', pkt_name: 'GET_TIMESTAMP_RESP',  sid: "FSW", tid: "NORMAL"},
        {board: 'FC_YM',  pkt_name: 'GET_TIMESTAMP_RESP',  sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_1', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
        {board: 'DPC_2', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
        {board: 'DPC_3', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_4', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
        {board: 'DPC_5', pkt_name: 'GET_TIMESTAMP_RESP', sid: "FSW", tid: 'NORMAL'},
      ]
    end

    wait(7)
    status_bar("setup")
  end

  def test_timesync_health_long()
  	timesync_health_test_12hr(@collectors, @command_sender, @target)
  end


end