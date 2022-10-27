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

class CameraTestOneStack < ASTCOSMOSTestCamera

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

  def test_camera_state_of_health_one_stack()
    setup("Camera_SOH")
    
    # Video time
    vid_time = 10 #(s)
  
    # Perform Camera test using the initial stack
    camera_SOH(@stack, vid_time)

    # Perform a stack switchover
    # if @stack == "YP"
    #   # Switchover to YM
    #   @stack = "YM"
    #   @module_telem.set_realtime("APC_#{@stack}", "MEDIC_LEADER_TLM", @csp_destination, 1)
    #   @module_telem.set_realtime("APC_#{@stack}", "FSW_TLM_APC", @csp_destination, 1)
    #   @module_telem.set_realtime("FC_#{@stack}", "MEDIC_FOLLOWER_TLM_FC", @csp_destination, 1)
    #   @failover.setup_ym_as_primary(@csp_destination)
    # else
    #   # Switchover to YP
    #   @stack = "YP"
    #   @module_telem.set_realtime("APC_#{@stack}", "MEDIC_LEADER_TLM", @csp_destination, 1)
    #   @module_telem.set_realtime("APC_#{@stack}", "FSW_TLM_APC", @csp_destination, 1)
    #   @module_telem.set_realtime("FC_#{@stack}", "MEDIC_FOLLOWER_TLM_FC", @csp_destination, 1)
    #   @failover.setup_yp_as_primary(@csp_destination)
    # end
    
    # # Write new stack's FSW Versions to the log
    # @test_util.write_apc_fsw_version(@stack)
    # @test_util.write_dpc_fsw_version(@stack)

    # # Repeat Camera test for other stack
    # camera_SOH(@stack, vid_time)


  end

  def camera_SOH(stack, vid_time)
    apc_board = "APC_" + stack

    Cosmos::Test.puts("Starting test using stack #{stack}")

    # Turn on LVC Output
    @module_cam.power_cameras(apc_board, "ON")

    # Loop through the 5 DPCs on this stack
    @dpc_list.each do |dpc|

      Cosmos::Test.puts("Starting test with #{dpc}")
    
      # Send I2C Commands changing the resgister value
      #@module_cam.set_I2C(dpc, 0x3500, 0xf)

      # Send I2C Command changing the register value
      #@module_cam.set_I2C(dpc, 0x3500, 0x00)

      # Send SPI write command
      #@module_cam.set_SPI(dpc, 0x00, 77)

      # Initalize Camera
      @module_cam.init_camera(dpc)

      # Set Camera Mode to 720 (2)
      @module_cam.set_mode(dpc, 720)

      # Format File
      @module_cam.clear_and_format_file(dpc, @file_id, @entry_qty, @entry_size)
      #@module_cam.prep_file(dpc, @file_id)

      # Take Picture
      @module_cam.take_picture(dpc)

      # Get Camera Status
      @module_cam.get_camera_tlm(dpc)
      wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)

      # Save the Picture to DPC
      @module_cam.save_picture(dpc, @file_id, 0)

      # Download the picture
      save_file_name = "#{stack}_#{dpc}-SOH_Single_Pic_" + Time.now.strftime('%Y%m%d-%H%H%S')
      @module_cam.download_pictures(dpc, @file_id, save_file_name, false)

      # Format the file
      @module_cam.clear_and_format_file(dpc, @file_id, @entry_qty, @entry_size)
      #@module_cam.prep_file(dpc, @file_id)

      # Take video and save
      init_pics = tlm(@target, "#{dpc}-CAMERA_TLM", "CAM_TOTAL_PICS_TAKEN")
      @module_cam.take_vid(dpc, vid_time, @file_id, 0)
      wait(vid_time)
      #check(@target, "#{dpc}-CAMERA_TLM", "CAM_TOTAL_PICS_TAKEN", "> #{init_pics}")

      # Get Camera Status
      @module_cam.get_camera_tlm(dpc)
      wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)

      # Download the video
      save_file_name = "#{stack}_#{dpc}-SOH_Multiple_Pics_" + Time.now.strftime('%Y%m%d-%H%H%S')
      @module_cam.download_pictures(dpc, @file_id, save_file_name, false)

    end
  end

  def test_image_quality_one_stack()
    setup("Camera_Image_Quality")

    # Video time
    vid_time = 10 #(s)
  
    # Perform Camera Quality test using the initial stack for all 5 Cameras
    image_quality(@stack, vid_time)
    
    # # Perform a stack switchover
    # stack_switchover()
    
    # # Write new stack's FSW Versions to the log
    # @test_util.write_apc_fsw_version(@stack)
    # @test_util.write_dpc_fsw_version(@stack)

    # # Repeat Camera test for other stack for all 5 cameras
    # image_quality(@stack, vid_time)
    
  end

  def image_quality(stack, vid_time)
    apc_board = "APC_" + stack

    Cosmos::Test.puts("Starting image quality test using stack #{stack}")

    # Turn on LVC Output + verify DPC power is on
    @module_cam.power_cameras(apc_board, "ON")

    # Loop through the 5 DPCs on this stack
    @dpc_list.each do |dpc|

      Cosmos::Test.puts("Starting test using camera on #{dpc}")
      message_box("Move Snellen Chart 0.5m from the camera on #{dpc}. Press continue when complete to start the video","Continue")
    
      # Initalize Camera
      @module_cam.init_camera(dpc)

      # Get Camera Status
      @module_cam.get_camera_tlm(dpc)
      wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)

      # Set Camera Mode to 720 (2)
      @module_cam.set_mode(dpc, 720)

      # Format File
      @module_cam.clear_and_format_file(dpc, @file_id, @entry_qty, @entry_size)
      #@module_cam.prep_file(dpc, @file_id)

      # Take video and save
      @module_cam.take_vid(dpc, vid_time, @file_id, 0)
      wait(vid_time)

      # Get Camera Status
      @module_cam.get_camera_tlm(dpc)
      wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)

      # Download the video
      save_file_name = "#{stack}_#{dpc}-Image_Quality_Test_" + Time.now.strftime('%Y%m%d-%H%H%S')
      @module_cam.download_pictures(dpc, @file_id, save_file_name, false)
    end

  end

  def test_multiple_camera_video_one_stack()
    setup("Multi_Camera_Test")

    apc_board = "APC_" + @stack
    vid_time = 10 #(s)

    # Turn on LVC Output + verify DPC power is on
    @module_cam.power_cameras(apc_board, "ON")

    # Setup Cameras
    # ---------------------------------------------------------

    # Setup for each camera for the primary stack
    @module_cam.init_and_format_dpcs(@dpc_list, @file_id, @entry_qty, @entry_size)

    # stack_switchover()

    # # Setup for each camera for the secondary stack
    # @module_cam.init_and_format_dpcs(@file_id, @entry_qty, @entry_size)

    # Start taking video for each camera
    # ---------------------------------------------------------
    
    # Primary Stack
    @dpc_list.each do |dpc|
      @module_cam.take_vid(dpc, vid_time, @file_id, 0)
    end
  
    # Secondary Stack
    # @dpc_list.each do |dpc|
    #   @module_cam.take_vid_alt_stack(dpc, vid_time, @file_id, 0, @stack)
    # end

    # wait for video to finish
    wait(vid_time)

    # Download Videos
    # ---------------------------------------------------------

    # Primary Stack
    @dpc_list.each do |dpc|
      # Get Camera Status
      @module_cam.get_camera_tlm(dpc)
      wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)

      # Download the video
      save_file_name = "#{@stack}_#{dpc}-Multi_Camera_Test_" + Time.now.strftime('%Y%m%d-%H%H%S')
      @module_cam.download_pictures(dpc, @file_id, save_file_name, false)
    end

    # Perform stack switchover
    # stack_switchover()

    # # Secondary Stack
    # @dpc_list.each do |dpc|
    #   # Get Camera Status
    #   @module_cam.get_camera_tlm_alt_stack(dpc)
    #   wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)

    #   # Download the video
    #   save_file_name = "#{@stack}_#{dpc}-Multi_Camera_Test_" + Time.now.strftime('%Y%m%d-%H%H%S')
    #   @module_cam.download_pictures_alt_stack(dpc, @file_id, save_file_name)
    # end

  end

  def stack_switchover()
    if @stack == "YP"
      # Switchover to YM
      @stack = "YM"
      @module_telem.set_realtime("APC_#{@stack}", "MEDIC_LEADER_TLM", @csp_destination, 1)
      @module_telem.set_realtime("APC_#{@stack}", "FSW_TLM_APC", @csp_destination, 1)
      @module_telem.set_realtime("FC_#{@stack}", "MEDIC_FOLLOWER_TLM_FC", @csp_destination, 1)
      @failover.setup_ym_as_primary(@csp_destination)
    else
      # Switchover to YP
      @stack = "YP"
      @module_telem.set_realtime("APC_#{@stack}", "MEDIC_LEADER_TLM", @csp_destination, 1)
      @module_telem.set_realtime("APC_#{@stack}", "FSW_TLM_APC", @csp_destination, 1)
      @module_telem.set_realtime("FC_#{@stack}", "MEDIC_FOLLOWER_TLM_FC", @csp_destination, 1)
      @failover.setup_yp_as_primary(@csp_destination)
    end
  end

  
end

#handle = CameraTest.new
#handle.test_multiple_camera_video