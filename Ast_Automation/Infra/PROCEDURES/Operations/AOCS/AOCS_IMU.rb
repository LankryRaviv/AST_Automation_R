load_utility('Operations\FSW\UTIL_CmdSender')

class ModuleIMU
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end

  def power_on_IMU(apc_id)
    # board = "FC_YP"
    cmd_name = "APC_LVC_OUTPUT_SINGLE"
    cmd_params = {"OUTPUT_CHANNEL": 'IMU',
                  "STATE_ONOFF": 'ON',
                  "DELAY":0
                  }

    # Send command
    @cmd_sender.send_with_cmd_count_check(apc_id, cmd_name, cmd_params, "POWER", wait_time=5)
  end
  
  def get_IMU_mode(fc_id)

    packet_name = fc_id +"-AOCS_TLM"
    
    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_MODE')
    wait_check(@target, packet_name, 'IMU_MODE', " == 'NORMAL'", 10)

  end

  def get_IMU_status(fc_id)
    
    packet_name = fc_id +"-AOCS_TLM"

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_XCHANNEL')
    wait_check(@target, packet_name, 'IMU_STATUS_XCHANNEL', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_YCHANNEL')
    wait_check(@target, packet_name, 'IMU_STATUS_YCHANNEL', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_ZCHANNEL')
    wait_check(@target, packet_name, 'IMU_STATUS_ZCHANNEL', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_ERROR_GYRO_CHANNEL')
    wait_check(@target, packet_name, 'IMU_STATUS_ERROR_GYRO_CHANNEL', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_OVERLOAD')
    wait_check(@target, packet_name, 'IMU_STATUS_OVERLOAD', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_OUTSIDE_OPERATING_CONDITIONS')
    wait_check(@target, packet_name, 'IMU_STATUS_OUTSIDE_OPERATING_CONDITIONS', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_STARTUP')
    wait_check(@target, packet_name, 'IMU_STATUS_STARTUP', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_SYSTEM_INTEGRITY_ERROR')
    wait_check(@target, packet_name, 'IMU_STATUS_SYSTEM_INTEGRITY_ERROR', "== 'OK'", 10)

  end

  def get_IMU_measurements(fc_id)

    packet_name = fc_id +"-AOCS_TLM"

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_XCHANNEL')
    wait_check(@target, packet_name, 'IMU_STATUS_XCHANNEL', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_YCHANNEL')
    wait_check(@target, packet_name, 'IMU_STATUS_YCHANNEL', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_ZCHANNEL')
    wait_check(@target, packet_name, 'IMU_STATUS_ZCHANNEL', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_ERROR_GYRO_CHANNEL')
    wait_check(@target, packet_name, 'IMU_STATUS_ERROR_GYRO_CHANNEL', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_OVERLOAD')
    wait_check(@target, packet_name, 'IMU_STATUS_OVERLOAD', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_OUTSIDE_OPERATING_CONDITIONS')
    wait_check(@target, packet_name, 'IMU_STATUS_OUTSIDE_OPERATING_CONDITIONS', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_STARTUP')
    wait_check(@target, packet_name, 'IMU_STATUS_STARTUP', "== 'OK'", 10)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_STATUS_SYSTEM_INTEGRITY_ERROR')
    wait_check(@target, packet_name, 'IMU_STATUS_SYSTEM_INTEGRITY_ERROR', "== 'OK'", 10)
    
    # Check to see if IMU outputs are legit. Need to determine what legit means
    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_RAW_RATE_0')
    wait_check(@target, packet_name, 'IMU_RAW_RATE_0', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_RAW_RATE_1')
    wait_check(@target, packet_name, 'IMU_RAW_RATE_1', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_RAW_RATE_2')
    wait_check(@target, packet_name, 'IMU_RAW_RATE_2', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_TEMPERATURE_0')
    wait_check(@target, packet_name, 'IMU_TEMPERATURE_0', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_TEMPERATURE_1')
    wait_check(@target, packet_name, 'IMU_TEMPERATURE_1', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'IMU_TEMPERATURE_2')
    wait_check(@target, packet_name, 'IMU_TEMPERATURE_2', "!= 0", 5)

  end
  
  def IMU_reset(fc_id)
    #board = "FC"
    cmd_name = "IMU_RESET"
    cmd_params = {}

    # Send command
    @cmd_sender.send_with_cmd_count_check(fc_id, cmd_name, cmd_params, "AOCS", wait_time=5)
    
  end

  def power_off_IMU(apc_id)
    # board = "FC_YP"
    cmd_name = "APC_LVC_OUTPUT_SINGLE"
    cmd_params = {"OUTPUT_CHANNEL": 'IMU',
                  "STATE_ONOFF": 'OFF',
                  "DELAY":0
                  }

    # Send command
    @cmd_sender.send_with_cmd_count_check(apc_id, cmd_name, cmd_params, "POWER", wait_time=5)
  end

end