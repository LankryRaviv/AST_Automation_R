load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS_Continue_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")
load('AIT/FSW/individual_tests/FS_test_individual.rb')

class FILESYSTEM_TEST < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @target = "BW3"
    @firmware_file_id = 4108
    @fsw_tlm_file_id = 4116
    @entry_size = 1754
    @download_time_s = 90
    @check_aspect = "CRC"
    @test_bin_name  = "#{__dir__}\\testImg.bin"
    @realtime_destination = 'COSMOS_DPC'
    @harvester_id = 'HARVESTER_1_HZ'
    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @board = combo_box("Select board", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC", "ALL_YP", "ALL_YM")
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestFS_#{@board}")
    end
    @collectors = []
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
        {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}
    ]
    elsif @board == "FC_YM"
      @collectors = [
        {board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}
    ]
    elsif @board == "DPC"
      @collectors = [
        {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
        {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"}
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
    wait(10)
    # Turn off realtime so that we only get packets from downloads
    @collectors.each do | collector |
      @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 0)
    end
    wait(3)
    status_bar("setup")
  end

  def test_a_file_clear
    clear_file_on_boards(@collectors, @module_telem, @module_fs, @harvester_id, @fsw_tlm_file_id, @realtime_destination)
  end

  def test_b_file_download
    download_test_file(@collectors, @module_telem, @module_fs, @target, @download_time_s, @realtime_destination, @fsw_tlm_file_id)
  end

  def test_c_file_upload
    upload_test_file(@collectors, @entry_size, @firmware_file_id, @test_bin_name, @check_aspect)
  end

  def test_d_file_continue_upload
    continue_upload_test_file(@collectors, @entry_size, @firmware_file_id, @test_bin_name, @check_aspect)
  end

  def teardown
    @collectors.each do | collector |
      # Re-enable collection
      @module_telem.set_collection(collector[:board], @harvester_id, 1, true)
    end
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

end
