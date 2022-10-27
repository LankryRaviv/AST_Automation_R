load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_FWUPD.rb')
load('Operations/FSW/FSW_CSP.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS_Continue_Upload.rb')



class RF_MANUAL_DOWNLOAD < ASTCOSMOSTestFSW
  def initialize(target = "BW3")
    super()
  end

  def setup
    @fsw_tlm_file_id = 4122
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @module_telem = ModuleTelem.new
    @target = "BW3"
    @board = {}
    @board = combo_box("Select board for image upload", "APC_YP", "APC_YM")
    @collectors = {}

    if @board == "APC_YP"
      @collectors = 
          {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}
    elsif @board == "APC_YM"
        @collectors = 
      {board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"}
    end
    
  end

  
  def test_download_test_file()
      full_pkt_name = CmdSender.get_full_pkt_name(@collectors[:board], @collectors[:pkt_name])
      current_recv = tlm(@target, full_pkt_name, "RECEIVED_COUNT")
      @module_fs.file_clear(@collectors[:board], @fsw_tlm_file_id)
      wait(10)
      

      @module_fs.file_download(@collectors[:board], @fsw_tlm_file_id, 1, 5, 0,500, 900,186)
      wait(25)
      # Check that we have exactly 100 more packets
      wait_check(@target, full_pkt_name, "RECEIVED_COUNT", "== #{current_recv+5}", 3)
    status_bar("test_file_download")
  end
end


  

