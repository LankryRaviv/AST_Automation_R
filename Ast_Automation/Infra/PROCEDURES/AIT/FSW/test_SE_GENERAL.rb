load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
load('Operations/FSW/FSW_Telem.rb')
load('Operations/FSW/FSW_SE.rb')
load('Operations/FSW/FSW_CSP.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')


class SCRIPT_ENGINE_BASIC_TEST < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @module_SE = ModuleSE.new
    @target = "BW3"
    @exec_file_id_0 = 4610
    @exec_file_id_1 = 4611
    @exec_file_id_2 = 4612
    @log_tlm_file_id = 4613
    @entry_size = 744
    #@entry_size = 186
    @check_aspect = "CRC"
    @script_id_0 = 69
    @script_id_1 = 70
    @script_id_2 = 71
    @test_file_name_0  = "#{__dir__}\\Script2_exe.txt"
    @test_file_name_1  = "#{__dir__}\\Script3_exe.txt"
    @test_file_name_2  = "#{__dir__}\\Script7_exe.txt"
    @wait_time = 100
    @realtime_destination = 'COSMOS_DPC'

    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @board = combo_box("Select Side", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC", "ALL_YP", "ALL_YM")
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestSE")
    end

    if @board == "APC_YP"
      @collectors = [{board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}]

      @module_csp.reboot("APC_YP", true)
    elsif @board == "APC_YM"
      @collectors = [{board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}]

      @module_csp.reboot("APC_YM", true)
    elsif @board == "FC_YP"
      @collectors = [{board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}]

      @module_csp.reboot("FC_YP", true)
    elsif @board == "FC_YM"
      @collectors = [{board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}]

      @module_csp.reboot("FC_YM", true)
    elsif @board == "DPC"
      @collectors = [
        {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"}
        ]

      @module_csp.reboot("DPC_1", true)
      @module_csp.reboot("DPC_2", true)
      @module_csp.reboot("DPC_3", true)
      @module_csp.reboot("DPC_4", true)
      @module_csp.reboot("DPC_5", true)
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

        @module_csp.reboot("APC_YP", true)
        @module_csp.reboot("FC_YP", true)
        @module_csp.reboot("DPC_1", true)
        @module_csp.reboot("DPC_2", true)
        @module_csp.reboot("DPC_3", true)
        @module_csp.reboot("DPC_4", true)
        @module_csp.reboot("DPC_5", true)
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

        @module_csp.reboot("APC_YM", true)
        @module_csp.reboot("FC_YM", true)
        @module_csp.reboot("DPC_1", true)
        @module_csp.reboot("DPC_2", true)
        @module_csp.reboot("DPC_3", true)
        @module_csp.reboot("DPC_4", true)
        @module_csp.reboot("DPC_5", true)

    end
    
    wait(10)
    status_bar("setup")
  end

  def test_a_basic_functions
    @collectors.each do | collector |
      @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)

      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
      #Upload the script text files
      FSW_FS_Upload(@entry_size, @exec_file_id_0, @test_file_name_0, collector[:board], @check_aspect) #9 payload commands, 1 call
      FSW_FS_Upload(@entry_size, @exec_file_id_1, @test_file_name_1, collector[:board], @check_aspect) #9 payload commands, 2 waits

      # Get current values for script engine
      current_subsystem_rec = tlm(@target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
      current_subsystem_err = tlm(@target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

      ## Setting Log File ID
      @module_SE.script_set_log_file_id(collector[:board], 0, @log_tlm_file_id)          

      wait_check(@target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_69", "== 4610", @wait_time)
      wait_check(@target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_70", "== 4611", @wait_time)
      wait_check(@target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_71", "== 4612", @wait_time)

      #check to see if script engine is in the ready state
      wait_check(@target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", @wait_time) #SE_STATE_READY = 0

      #Wait to make sure there's no error than the one we trigger
      wait_check(@target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+1}", @wait_time)   
      wait_check(@target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", @wait_time)

      # Clear the log file and wait for operation to be complete
      @module_fs.file_clear(collector[:board], @log_tlm_file_id)
      file_status = @module_fs.wait_for_file_ok(collector[:board], @log_tlm_file_id)
      check_expression("#{file_status} == 55")

      ##
      #   SINGLE SCRIPT EXEC
      ##
      @module_SE.script_run(collector[:board], @exec_file_id_0, 1, 0, "*", "*", "*", "*", "*")            # 5 cmds + 1 RUN

      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 1", @wait_time)                    ## SE_STATE_ARMED = 1
      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 2", @wait_time)                    ## SE_STATE_BUSY = 2
      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 4", @wait_time)                    ## SE_STATE_DONE = 4
      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 0", @wait_time)                    ## SE_STATE_READY = 0

      ##
      #   SCRIPT ABORT
      ##
      @module_SE.script_run(collector[:board], @exec_file_id_0, 1, 0, "*", "*", "*", "*", "*")            # 1 RUN

      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== #{1}", @wait_time)     #SE_STATE_ARMED = 1

      @module_SE.script_abort(collector[:board], @exec_file_id_0)  # 1 ABORT

      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_ABORT_69", "== #{1}", @wait_time) #SE_STATE_ABORTED = 5

      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 0", @wait_time)                    ## SE_STATE_READY = 0

      ##
      #   RUN NON-EXISTING SCRIPTS
      ##
      @module_SE.script_run(collector[:board], 3, 1, 0, "*", "*", "*", "*", "*")

      ##
      #   MULTI-SCRIPT EXECUTION, SCRIPT TIME TAG, & INVALID CMDS
      ##
      script_done_counter_69 = tlm(@target, full_pkt_name, "SCRIPT_DONE_69")
      script_done_counter_70 = tlm(@target, full_pkt_name, "SCRIPT_DONE_70")
      script_done_counter_71 = tlm(@target, full_pkt_name, "SCRIPT_DONE_71")
      
      se_now_time = tlm(@target, full_pkt_name, "RTC_TIME")   # Get current time

      file = File.new(@test_file_name_2, "w")
      file << "@4610 ##{se_now_time+30}\n@4611 ##{se_now_time+45}\nscript stat 60\n"
      file.close

      # Upload edited script
      FSW_FS_Upload(@entry_size, @exec_file_id_2, @test_file_name_2, collector[:board], @check_aspect)

      # Run script12
      @module_SE.script_run(collector[:board], @exec_file_id_2, 1, 0, "*", "*", "*", "*", "*")

      wait_check(@target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71 + 1}", @wait_time)                    ## SE_STATE_DONE = 4
      wait_check(@target, full_pkt_name, "SCRIPT_DONE_69", "== #{script_done_counter_69 + 1}", @wait_time)                    ## SE_STATE_DONE = 4
      wait_check(@target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70 + 1}", @wait_time)                    ## SE_STATE_DONE = 4

      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== 0", @wait_time)                    ## SE_STATE_READY = 0
      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 0", @wait_time)                    ## SE_STATE_READY = 0
      wait_check_raw(@target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== 0", @wait_time)                    ## SE_STATE_READY = 0

      # Wait to make sure there's no error at subsystem
      wait_check(@target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+23}", @wait_time)   # cmds = 17 cmds+(6xRUN/SET/ABORT)
      wait_check(@target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err+1}", @wait_time)
    end
    status_bar("test_basic_functions")
  end

  def teardown
    status_bar("teardown")
  end
end
