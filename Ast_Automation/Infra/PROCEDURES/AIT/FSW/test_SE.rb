load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
load('Operations/FSW/FSW_Telem.rb')
load('Operations/FSW/FSW_SE.rb')
load('Operations/FSW/FSW_CSP.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')
load('AIT/FSW/individual_tests/SE_test_individual.rb')


class SCRIPT_ENGINE_FULL_TEST < ASTCOSMOSTestFSW
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
    @check_aspect = "CRC"
    @script_id_0 = 46
    @script_id_1 = 47
    @script_id_2 = 48
    @test_file_name_0  = "#{__dir__}\\Script3_exe.txt"
    @test_file_name_1  = "#{__dir__}\\Script1_exe.txt"
    @test_file_name_2  = "#{__dir__}\\Script2_exe.txt"
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

  def test_a_setup
    SE_test_setup(@collectors, @module_telem, @module_fs, @module_SE, @target, @realtime_destination, @check_aspect, @wait_time, @entry_size, @log_tlm_file_id, @exec_file_id_0, @exec_file_id_1, @exec_file_id_2, @test_file_name_0, @test_file_name_1, @test_file_name_2)
  end

  def test_b_trigger_multiple_script_time_based
    try_multiple_time_based_scripts(@collectors, @target, @module_SE, @wait_time, @exec_file_id_0, @exec_file_id_1, @exec_file_id_2)
  end

  def test_c_manual_abort
    try_manual_abort(@collectors, @module_SE, @target, @wait_time, @exec_file_id_1, @exec_file_id_2)
  end

  def test_d_run_ten_scripts
    #@collectors.each do | collector |
      #@module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)
      #full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

      # Get current values for script engine
      #current_subsystem_rec = tlm(@target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
      #current_subsystem_err = tlm(@target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

      #Manual Run
      #for i in 0..9
      #  @module_SE.script_run(collector[:board], @exec_file_id_0+i, 1, 0, "*", "*", "*", "*", "*")
      #end

      # Checking that the cli commands were correctly recieved and cmd counter increases, only works for APC currently
      #check(@target, full_pkt_name, "PAYLOAD_CMD_REC_COUNTER", "== #{current_cmd_count+50}")
      #check(@target, full_pkt_name, "PAYLOAD_CMD_ERROR_COUNTER", "== #{current_cmd_err_count}")

      # Wait to make sure there's no error at subsystem
      #check(@target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}")

    #end
    status_bar("test_run_ten_scripts")
  end

  def test_e_ManRun_Parameterized_Scripts
    try_manrun_parameterized_scripts(@collectors, @module_SE, @target, @entry_size, @wait_time, @check_aspect, @exec_file_id_0, @exec_file_id_1, @exec_file_id_2)
  end

  def test_f_Timetag_Parameterized_Scripts 
     try_parameterized_timetag_scripts(@collectors, @module_SE, @target, @entry_size, @wait_time, @check_aspect, @exec_file_id_0)
  end

  def test_g_Abort_Parameterized_Script 
    try_abort_param_script(@collectors, @module_SE, @target, @entry_size, @wait_time, @check_aspect, @exec_file_id_0)
  end

  def test_h_Invalid_Num_of_Parameters_and_Commands 
    try_invalid_num_param_cmd(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_0, @exec_file_id_1)
  end

  def test_i_Script_Multi_Time_Tagging
    try_multi_time_tagging_script(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_2)
  end

  def test_j_Script_Multi_Time_Tagging_Error_Checking
    try_adding_6th_time_tag_to_script(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_2)
  end

  def test_k_Out_Of_Order_Script_Time_Tagging
    try_out_of_order_script_time_tagging(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_2, @realtime_destination)
  end

  def test_l_Abort_Multi_Time_Tagged_Script
    abort_multi_time_tagged_script(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_1, @exec_file_id_2, @realtime_destination)
  end

  def test_m_Delete_Single_Script_Time_tag
    delete_single_script_time_tag(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_1, @exec_file_id_2, @realtime_destination)
  end

  def test_n_Run_Multi_Time_Tagged_Script_With_Params
    multi_time_tagged_script_with_params(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_1, @exec_file_id_2, @realtime_destination)
  end

  # Tests ability to execute script from each board to the APC, FC, and DPC_1
  def test_o_exec_script_on_other_boards 
    try_exec_script_on_other_boards(@collectors, @module_SE, @target, @entry_size, @check_aspect, @wait_time, @exec_file_id_1, @exec_file_id_2)
  end

  def test_p_Loop_All
    iteration_count = 0
    loop do
      SE_test_setup(@collectors, @module_telem, @module_fs, @module_SE, @target, @realtime_destination, @check_aspect, @wait_time, @entry_size, @log_tlm_file_id, @exec_file_id_0, @exec_file_id_1, @exec_file_id_2, @test_file_name_0, @test_file_name_1, @test_file_name_2)
      status_bar("\nSE_test_setup complete\n")
      try_multiple_time_based_scripts(@collectors, @target, @module_SE, @wait_time, @exec_file_id_0, @exec_file_id_1, @exec_file_id_2)
      status_bar("\nmultiple_time_based_scripts complete\n")
      try_manual_abort(@collectors, @module_SE, @target, @wait_time, @exec_file_id_1, @exec_file_id_2)
      status_bar("\nmanual_abort complete\n")
      try_manrun_parameterized_scripts(@collectors, @module_SE, @target, @entry_size, @wait_time, @check_aspect, @exec_file_id_0, @exec_file_id_1, @exec_file_id_2)
      status_bar("\nmanrun_parameterized_scripts complete\n")
      try_parameterized_timetag_scripts(@collectors, @module_SE, @target, @entry_size, @wait_time, @check_aspect, @exec_file_id_0)
      status_bar("\nparameterized_timetag_scripts complete\n")
      try_abort_param_script(@collectors, @module_SE, @target, @entry_size, @wait_time, @check_aspect, @exec_file_id_0)
      status_bar("\nabort_param_script complete\n")
      try_invalid_num_param_cmd(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_0)
      status_bar("\ninvalid_num_param_cmd complete\n")
      try_multi_time_tagging_script(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_2)
      status_bar("\nmulti_time_tagging_script complete\n")
      try_adding_6th_time_tag_to_script(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_2)
      status_bar("\nadding_6th_time_tag_to_script complete\n")
      try_out_of_order_script_time_tagging(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_2, @realtime_destination)
      status_bar("\nout_of_order_script_time_taggin complete\n")
      abort_multi_time_tagged_script(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_1, @exec_file_id_2, @realtime_destination)
      status_bar("\nmulti_time_tagged_script complete\n")
      delete_single_script_time_tag(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_1, @exec_file_id_2, @realtime_destination)
      status_bar("\ndelete_single_script_time_tag complete\n")
      multi_time_tagged_script_with_params(@collectors, @module_SE, @entry_size, @target, @wait_time, @check_aspect, @exec_file_id_1, @exec_file_id_2, @realtime_destination)
      status_bar("\nmulti_time_tagged_script_with_params complete\n")
      iteration_count = iteration_count + 1
      status_bar("\nIteration Count: #{iteration_count}\n")
    end
  end

  def teardown
    status_bar("teardown")
  end

end