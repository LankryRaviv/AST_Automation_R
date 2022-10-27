load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/EPS/EPS_PCDU')
load_utility('TestRunnerUtils/test_case_utils.rb')

# ------------------------------------------------------------------------------------

class QVAConstantMotion < ASTCOSMOSTestComm 
  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @test_util = ModuleTestCase.new
    @csp_destination = "COSMOS_UMBILICAL"
    @pcdu = PCDU.new
    @target = target
    @wait_time = 3
    @long_wait_time = 120
    super()
  end

  def setup(test_case_name = "QV_Antenna")
    stack = @test_util.initialize_test_case(test_case_name)
    @board = "APC_" + stack

    @module_telem.set_realtime(@board, "COMM_TLM", @csp_destination, 1) 

  end

  def test_continuous_home_park()
    #timeout = 60*60
    setup("QV_Continuous_HOME_PARK")

    # Ask for QV
    qva_side = combo_box("Select QV:", "YP", "YM")

    message_box("This script moves the antenna between home and park. The antenna should have already run the self test and is in a proper state to be moved. Press continue to home the antenna", "Continue")

    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_STOP", cmd_params, "COMM", @wait_time)

    wait_check(@target, "#{@board}-COMM_TLM", "QVA_#{qva_side}_STATUS_CURRENT_STATE", "=='IDLE'", 10)
   
   while true

    # Send Home Gimbal command
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_HOME_GIMBAL", cmd_params, "COMM", 2)

    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "== 'HOME'", 1800) 

    # Wait 5 seconds befor parking the antenna
    wait(10)

    # Send Park Command
    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_PARK_POS", cmd_params, "COMM", 2)

    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "== 'PARK'", 120) 

    # Wait 5 seconds until homing the antenna
    wait(10)
    end
  end

  def test_start_continuous_elevation_motion()
    setup("QV_Continuous_Elevation_Motion")

    # Ask for QV
    qva_side = combo_box("Select QV:", "YP", "YM")

    message_box("This script moves the antenna between az/el positions of 0/87 and 0/-87. The antenna should have already run the self test and is in a proper state to be moved. Press continue to move the antenna to 0 Az, 87 El.", "Continue")

    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_STOP", cmd_params, "COMM", @wait_time)

    wait_check(@target, "#{@board}-COMM_TLM", "QVA_#{qva_side}_STATUS_CURRENT_STATE", "=='IDLE'", 10)
   
   while true

    # Send set azimuth elevation to 0/87
    set_az_el_position(qva_side, 0, 87)

    wait(10)

    # Send set azimuth elevation to 0/87
    set_az_el_position(qva_side, 0, -87)

    wait(10)
   end
  end

  def set_az_el_position(qva_side, az_val, el_val)

    cmd_params = {"QVA_LOCATION": qva_side}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_STOP", cmd_params, "COMM", @wait_time)

    wait_check(@target, "#{@board}-COMM_TLM", "QVA_#{qva_side}_STATUS_CURRENT_STATE", "=='IDLE'", 10)

    var_table = 0
    # Send set azimuth elevation
    cmd_params = {"QVA_LOCATION": qva_side,
    "QVA_AZIMUTH":az_val,
    "QVA_ELEVATION": el_val,
    "QVA_TABLE_ID":var_table,
    "QVA_TABLE_IDX": 0}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_SET_AZIMUTH_ELEVATION", cmd_params, "COMM", 2)

    # Send set last index
    cmd_params = {"QVA_LOCATION": qva_side,
        "QVA_TABLE_ID":var_table,
        "QVA_TABLE_IDX": 0}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_SET_LAST_INDEX", cmd_params, "COMM", 2)

    # Send prime table
    cmd_params = {"QVA_LOCATION": qva_side,
        "QVA_TABLE_ID":var_table}
    @cmd_sender.send_with_cmd_count_check(@board, "QVA_PRIME_TABLE", cmd_params, "COMM", 2)

    # Wait until status is not TABLEZEROPRIMING
    wait_check(@target, "#{@board}-COMM_TLM","QVA_#{qva_side}_STATUS_CURRENT_STATE", "== 'TABLE_ZERO_PRIMED'", 120)

  end
end