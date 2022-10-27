load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'AIT/FSW/individual_tests/Timesync_test_individual.rb'
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")


class TIMESYNC_STACK_TEST < ASTCOSMOSTestFSW
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
    @startup_tlm_file_id = 4119
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
    @collectors[0, 2].each do |collector|
      # Clear startup telem so that boot count will be properly read. This can take a while
      @module_fs.file_clear(collector[:board], @startup_tlm_file_id)
      file_status = @module_fs.wait_for_file_ok(collector[:board], @startup_tlm_file_id, 30)
    end
    wait(7)

    @module_csp.reboot("DPC_1", true)
    @module_csp.reboot("DPC_2", true)
    @module_csp.reboot("DPC_3", true)
    @module_csp.reboot("DPC_4", true)
    @module_csp.reboot("DPC_5", true)
    if @boards == "ALL_YP"
      @module_csp.reboot("FC_YP", true)
      @module_csp.reboot("APC_YP", true)
    else
      @module_csp.reboot("FC_YM", true)
      @module_csp.reboot("APC_YM", true)
    end 

    wait(12)
    status_bar("setup")
  end

  # Gets the timestamp for each board to verify timeSyncService is running properly.
  def test_get_timestamp
    get_board_timestamps(@collectors, @command_sender)
  end

  # Nearly the same as the second-accuracy test, but this time uses the RTC_TIME field of the
  # packet to compare millisecond accuracy.
  def test_timesync_msec
    measure_timesync_accuracy(@collectors, @command_sender, @target)
  end

  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

  # def test_timesync_logging
  #   curr_times = [0, 0]
  #   time_index = 0
  #   total_iterations = 0

  #   log_file = File.open("timelog.csv", 'w')
  #   log_file.write("APC Time,FC Time,\% Diff,AbsoluteDiff\n")

  #   while total_iterations < 120
  #     @rtc_collectors.each do | collector |
  #       curr_times[time_index] = @command_sender.get_current_val(collector[:board], collector[:pkt_name], "RTC_TIME")
  #       time_index += 1
  #     end

  #     log_file.write("#{curr_times[0]},#{curr_times[1]},#{(curr_times[0] - curr_times[1])/curr_times[0] * 100},#{curr_times[0] - curr_times[1]}\n")

  #     time_index = 0
  #     total_iterations += 1
  #     wait(1)
  #   end

  #   log_file.close()
  # end

  # Set the internal RTC for each board to 0, then check for proper changes with get.
  # def test_set_timestamp
  # @collectors.each do |collector|
  #   @command_sender.send(collector[:board], "GET_TIMESTAMP", {})
  #   prev_time = @command_sender.get_current_val(collector[:board], collector[:pkt_name], "UNIX_TIMESTAMP")
  #   wait(1)
  #   @command_sender.send(collector[:board], "SET_TIMESTAMP", {"UNIX_TIMESTAMP": 0})
  #    wait(1)
  #   @command_sender.send(collector[:board], "GET_TIMESTAMP", {})
      # Time is being reset to zero, so check that the prev time is greater.
  #   full_pkt_name = collector[:board] + "-" + collector[:pkt_name]
  #   check(@target, full_pkt_name, "UNIX_TIMESTAMP", "< #{prev_time}")
  # end
  # status_bar("test_set_timestamp")
  #end
end
