load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/UTIL_ByteString.rb'
load 'Operations/FSW/FSW_Config_Types.rb'
load 'Operations/FSW/FSW_Config_Properties.rb'
load 'AIT/FSW/individual_tests/Config_test_individual.rb'

load 'Operations/FSW/FSW_CSP.rb'
load 'Operations/FSW/FSW_FDIR.rb'

class CONFIG_STACK_TEST < ASTCOSMOSTestFSW

  def initialize
    super
    @target = 'BW3'
    @module_csp = ModuleCSP.new
    @cmd_sender = CmdSender.new
    @boards = ['APC_YP', 'FC_YP', 'DPC_1', 'DPC_2', 'DPC_3', 'DPC_4', 'DPC_5']
  end

  def setup
    status_bar('setup')
    @board = combo_box("Select Side", "ALL_YP", "ALL_YM")
    if @board == "ALL_YP"
      @boards = ['FC_YP', 'DPC_1', 'DPC_2', 'DPC_3', 'DPC_4', 'DPC_5','APC_YP',]
    elsif @board == "ALL_YM"
      @boards = ['FC_YM', 'DPC_1', 'DPC_2', 'DPC_3', 'DPC_4', 'DPC_5','APC_YM',]
    end
    reboot_boards(@boards, @module_csp)

    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestSE")
    end
    # Uncomment this to print out the entire properties table at the beginning of the test to validate it is in it's proper form
    # board = 'APC_YP'
    # puts "Listing all properties for #{board}:"
    # ConfigProperty.all_properties(board).each_with_index { |i,v| puts "#{i}\t\t#{v}" }

    # Uncomment this to view parameters for each property
    # puts ConfigProperty.properties_info(board)
    @orig_values = retrieve_original_values(@boards, @cmd_sender)
  end

  def test_a_update_bounded_configs
    check_update_bounded_configs(@boards, @cmd_sender, @orig_values, @target)
  end

  def test_b_update_config_rows
    check_update_config_rows(@boards, @cmd_sender, @orig_values, @target)
  end

  # Tests properties can be saved and read back from MAIN and FALLBACK config files on all boards
  def test_c_main_config_saving
    check_main_config_save(@boards, @cmd_sender, @target, @module_csp, @orig_values)
  end

  def test_d_fallback_config_updating
    check_fallback_config_update(@boards, @cmd_sender, @target, @orig_values)
  end

  def teardown
    @test_case_util.teardown_test_case()
    status_bar('teardown')
  end
end

