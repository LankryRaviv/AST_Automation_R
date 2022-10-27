load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS_Continue_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")
load("AIT/FSW/individual_tests/FS_test_individual.rb")

class FS_CLEARING_SEQUENTIAL < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @target = "BW3"
    @realtime_destination = 'COSMOS_DPC'
    @harvester_id = 'HARVESTER_1_HZ'
    @min_file_id = -1
    @max_file_id = -1
    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @board = combo_box("Select board", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC")
    @min_file_id = ask("Starting file-id to clear:")
    @max_file_id = ask("Ending file-id to clear:")
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestFS_#{@board}")
    end
    if @board == "APC_YP"
      @collectors = [
        {board: 'APC_YP'}
      ]
    elsif @board == "APC_YM"
      @collectors = [
        {board: 'APC_YM'}
      ]
    elsif @board == "FC_YP"
      @collectors = [
        {board: 'FC_YP'},
      ]
    elsif @board == "APC_YM"
      @collectors = [
        {board: 'FC_YM'},
      ]
    elsif @board == "DPC"
      @collectors = [
        {board: 'DPC_1'},
        {board: 'DPC_2'},
        {board: 'DPC_3'},
        {board: 'DPC_4'},
        {board: 'DPC_5'},
      ]
    end

    if @board == "DPC"
      @module_csp.reboot("DPC_1")
      @module_csp.reboot("DPC_2")
      @module_csp.reboot("DPC_3")
      @module_csp.reboot("DPC_4")
      @module_csp.reboot("DPC_5")
    else
      @module_csp.reboot(@board)
    end
    status_bar("setup")
  end

  def test_file_clear_specific_ids
    clear_some_files(@collectors, @min_file_id, @max_file_id, @module_fs)
  end


  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

end
