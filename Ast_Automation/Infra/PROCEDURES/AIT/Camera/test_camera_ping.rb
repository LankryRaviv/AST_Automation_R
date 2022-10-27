load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')
load_utility('Operations/Camera/Camera_Utils.rb')
load_utility('Operations/FSW/FSW_FS.rb')
load_utility('Operations/FSW/FSW_FS_Download.rb')
load_utility('AIT/CDH/failover_setup_functions.rb')

# ------------------------------------------------------------------------------------

class CameraPing < ASTCOSMOSTestCamera

  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @test_util = ModuleTestCase.new
    @file_util = ModuleFS.new
    @failover = FailoverSetup.new
    @target = target
    @csp_destination = "COSMOS_UMBILICAL"
    @module_cam = ModuleCameraUtils.new(@target, @csp_destination)
    
    @wait_time = 3
    @dpc_list = ["DPC_1", "DPC_2", "DPC_3", "DPC_4", "DPC_5"]
    #@dpc_list = ["DPC_1", "DPC_4", "DPC_5"]
    @file_id = 4099
    @entry_qty = 1200
    @entry_size = 3066
    super()

  end

  def setup(test_name = "Cameras")
    @stack = @test_util.initialize_test_case(test_name, true)

    if @stack == "YP"
      @dpc_list = ["DPC_2", "DPC_3", "DPC_4", "DPC_5"]
	  else
	    @dpc_list = ["DPC_1", "DPC_2", "DPC_3", "DPC_4", "DPC_5"]
    end
    
  end


  def test_camera_ping()
    setup("Camera_SOH")

    apc_board = "APC_" + @stack

    Cosmos::Test.puts("Starting test using stack #{@stack}")

    # Turn on LVC Output
    @module_cam.power_cameras(apc_board, "ON")

    # Loop through the 5 DPCs on this stack
    @dpc_list.each do |dpc|

      # Initalize Camera
      @module_cam.init_camera(dpc)

      # Check camera status
      @module_cam.check_camera_status(dpc)
    end
  end


end
