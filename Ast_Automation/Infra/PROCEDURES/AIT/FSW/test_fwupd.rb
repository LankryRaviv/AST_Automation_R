load "AIT/FSW/individual_tests/FWUPD_test_individual.rb"
load 'Operations/FSW/FSW_Firmware_Update.rb'
$stdout.sync = true

class FIRMWARE_UPGRADE_TEST < ASTCOSMOSTestFSW
  def initialize
    @FILE_ID = 4108
    @fwupdboard = "NONE"
    @module_csp = ModuleCSP.new
    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @board = combo_box("Select board", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC", "ALL_YP", "ALL_YM")
    @run_for_record = combo_box("Run for record?", "YES", "NO")
    if @run_for_record.eql?("YES")
      @test_case_util.initialize_test_case("FSW_TestFWUPD_#{@board}")
    end
    @boards = []
    if @board == "APC_YP" or @board == "ALL_YP"
      @boards <<
        {
          BOARD: 'APC_YP', FILE_APPLICATION_TEST: 'apcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'apcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'apcBL2_Test.bin',
          APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
          BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
          BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
          FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
          APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
          BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
          BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
        }
    end
    if @board == "APC_YM" or @board == "ALL_YM"
      @boards <<
      {
        BOARD: 'APC_YM', FILE_APPLICATION_TEST: 'apcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'apcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'apcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
    end
    if @board == "FC_YP" or @board == "ALL_YP"
      @boards <<
      {
        BOARD: 'FC_YP', FILE_APPLICATION_TEST: 'fcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'fcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'fcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
    end
    if @board == "FC_YM" or @board == "ALL_YM"
      @boards <<
      {
        BOARD: 'FC_YM', FILE_APPLICATION_TEST: 'fcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'fcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'fcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
    end
    if @board == "DPC" or @board == "ALL_YM" or @board == "ALL_YP"
      @boards <<
      {
        BOARD: 'DPC_1', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
      @boards <<
      {
        BOARD: 'DPC_2', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
      @boards <<
      {
        BOARD: 'DPC_3', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
      @boards <<
      {
        BOARD: 'DPC_4', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
      @boards <<
      {
        BOARD: 'DPC_5', FILE_APPLICATION_TEST: 'dpcApp_Test.bin', FILE_BOOTLOADERL1_TEST: 'dpcBL1_Test.bin', FILE_BOOTLOADERL2_TEST: 'dpcBL2_Test.bin',
        APPLICATION_MAJOR_TEST: 123, APPLICATION_MINOR_TEST: 456, APPLICATION_PATCH_TEST: 789,
        BOOTLOADERL1_MAJOR_TEST: 123, BOOTLOADERL1_MINOR_TEST: 456, BOOTLOADERL1_PATCH_TEST: 789,
        BOOTLOADERL2_MAJOR_TEST: 123, BOOTLOADERL2_MINOR_TEST: 456, BOOTLOADERL2_PATCH_TEST: 789,
        FILE_APPLICATION: '', FILE_BOOTLOADERL1: '', FILE_BOOTLOADERL2: '',
        APPLICATION_MAJOR: 1, APPLICATION_MINOR: 1, APPLICATION_PATCH: 0,
        BOOTLOADERL1_MAJOR: 1, BOOTLOADERL1_MINOR: 1, BOOTLOADERL1_PATCH: 0,
        BOOTLOADERL2_MAJOR: 1, BOOTLOADERL2_MINOR: 1, BOOTLOADERL2_PATCH: 0,
      }
    end

    board_ind = []
    if @board.eql?('APC_YP') or @board.eql?('APC_YM') or @board.eql?('ALL_YP') or @board.eql?('ALL_YM')
      board_ind << "apc"
      puts "Upgrading APC"
    end
    if @board.eql?('FC_YP') or @board.eql?('FC_YM') or @board.eql?('ALL_YP') or @board.eql?('ALL_YM')
      board_ind << "fc"
      puts "Upgrading FC"
    end
    if @board.eql?('DPC') or @board.eql?('ALL_YP') or @board.eql?('ALL_YM')
      board_ind << "dpc"
      puts "Upgrading DPC"
    end

    board_ind.each_with_index do |ind, i|
      puts @boards[i]
      #location = "C:/Users/psaripalli/Documents/repos/apc-bug/apc/Cube" #ask("Image Recovery path (CUBE FOLDER) for board #{fwupdboard[:BOARD]} (e.g.  C:/Users/psaripalli/Documents/repos/apc-bug/apc/Cube/):")
      location = open_directory_dialog("/", "Image Recovery path (CUBE FOLDER) for board #{@boards[i][:BOARD]} (e.g.  C:/repos/" + ind + "/Cube):")

      puts "location: " + location
      @boards[i][:FILE_APPLICATION]  =  location + "/APP-Debug/" + ind + 'App.bin'
      @boards[i][:FILE_BOOTLOADERL1] =   location + "/BL1-Debug/" + ind + 'BL1.bin'
      @boards[i][:FILE_BOOTLOADERL2] =  location + "/BL2-Debug/" + ind + 'BL2.bin'

      puts @boards[0][:FILE_APPLICATION]

      # Use the location to navigate to the version.def stuff.
      def_location = location + "/../src/application/versionOfApplication.def"
      if File.exist?(def_location)
        f = File.new(def_location, "r")
        line = f.readline()
        /^VERSION\(\s*(\d+),\s*(\d+),\s*(\d+)\)$/.match(line)
        @boards[i][:MAJOR] = $1.to_i()
        @boards[i][:MINOR] = $2.to_i()
        @boards[i][:PATCH] = $3.to_i()
      else
        @boards[i][:MAJOR] = ask("MAJOR version # for board #{@boards[i][:BOARD]}")
        @boards[i][:MINOR] = ask("MINOR version # for board #{@boards[i][:BOARD]}")
        @boards[i][:PATCH] = ask("PATCH version # for board #{@boards[i][:BOARD]}")
      end

      @boards[i][:APPLICATION_MAJOR]= @boards[i][:MAJOR]
      @boards[i][:APPLICATION_MINOR]= @boards[i][:MINOR]
      @boards[i][:APPLICATION_PATCH]= @boards[i][:PATCH]

      @boards[i][:BOOTLOADERL2_MAJOR] = @boards[i][:MAJOR]
      @boards[i][:BOOTLOADERL2_MINOR] = @boards[i][:MINOR]
      @boards[i][:BOOTLOADERL2_PATCH] = @boards[i][:PATCH]

      @boards[i][:BOOTLOADERL1_MAJOR] = @boards[i][:MAJOR]
      @boards[i][:BOOTLOADERL1_MINOR] = @boards[i][:MINOR]
      @boards[i][:BOOTLOADERL1_PATCH] = @boards[i][:PATCH]
    end      

    # If just doing DPC, copy over from index 0 to rest
    if @board.eql?("DPC")
      for i in 1..(@boards.length() - 1) do
        @boards[i][:FILE_APPLICATION]   = @boards[i-1][:FILE_APPLICATION]
        @boards[i][:FILE_BOOTLOADERL1]  = @boards[i-1][:FILE_BOOTLOADERL1]
        @boards[i][:FILE_BOOTLOADERL2]  = @boards[i-1][:FILE_BOOTLOADERL2]
        @boards[i][:APPLICATION_MAJOR]  = @boards[i-1][:APPLICATION_MAJOR]
        @boards[i][:APPLICATION_MINOR]  = @boards[i-1][:APPLICATION_MINOR]
        @boards[i][:APPLICATION_PATCH]  = @boards[i-1][:APPLICATION_PATCH]
        @boards[i][:BOOTLOADERL2_MAJOR] = @boards[i-1][:BOOTLOADERL2_MAJOR]
        @boards[i][:BOOTLOADERL2_MINOR] = @boards[i-1][:BOOTLOADERL2_MINOR]
        @boards[i][:BOOTLOADERL2_PATCH] = @boards[i-1][:BOOTLOADERL2_PATCH]
        @boards[i][:BOOTLOADERL1_MAJOR] = @boards[i-1][:BOOTLOADERL1_MAJOR]
        @boards[i][:BOOTLOADERL1_MINOR] = @boards[i-1][:BOOTLOADERL1_MINOR]
        @boards[i][:BOOTLOADERL1_PATCH] = @boards[i-1][:BOOTLOADERL1_PATCH]
      end
    # if Doing DPC with other boards, copy over from index 2 to reset
    elsif @board.eql? ('ALL_YP') or @board.eql?('ALL_YM')
      for i in 3..(@boards.length() - 1) do
        @boards[i][:FILE_APPLICATION]   = @boards[i-1][:FILE_APPLICATION]
        @boards[i][:FILE_BOOTLOADERL1]  = @boards[i-1][:FILE_BOOTLOADERL1]
        @boards[i][:FILE_BOOTLOADERL2]  = @boards[i-1][:FILE_BOOTLOADERL2]
        @boards[i][:APPLICATION_MAJOR]  = @boards[i-1][:APPLICATION_MAJOR]
        @boards[i][:APPLICATION_MINOR]  = @boards[i-1][:APPLICATION_MINOR]
        @boards[i][:APPLICATION_PATCH]  = @boards[i-1][:APPLICATION_PATCH]
        @boards[i][:BOOTLOADERL2_MAJOR] = @boards[i-1][:BOOTLOADERL2_MAJOR]
        @boards[i][:BOOTLOADERL2_MINOR] = @boards[i-1][:BOOTLOADERL2_MINOR]
        @boards[i][:BOOTLOADERL2_PATCH] = @boards[i-1][:BOOTLOADERL2_PATCH]
        @boards[i][:BOOTLOADERL1_MAJOR] = @boards[i-1][:BOOTLOADERL1_MAJOR]
        @boards[i][:BOOTLOADERL1_MINOR] = @boards[i-1][:BOOTLOADERL1_MINOR]
        @boards[i][:BOOTLOADERL1_PATCH] = @boards[i-1][:BOOTLOADERL1_PATCH]
      end
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

  def testing_application_layers
    update_app_layers(@boards, @FILE_ID)
  end

  def testing_bl2_layers
    update_bl2_layers(@boards, @FILE_ID)
  end

  def testing_bl1_layers
    update_bl1_layers(@boards, @FILE_ID)
  end

  def teardown
    @test_case_util.teardown_test_case()
    status_bar("teardown")
  end

end