load_utility("Operations/FSW/UTIL_CmdSender")

class ModuleGPS
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end
  
  def power_on_GPS(apc_id)
    # board = "FC_YP"
    cmd_name = "APC_LVC_OUTPUT_SINGLE"
    cmd_params = {"OUTPUT_CHANNEL": 'GPS',
                  "STATE_ONOFF": 'ON',
                  "DELAY":0
                  }

    # Send command
    @cmd_sender.send_with_cmd_count_check(apc_id, cmd_name, cmd_params, "POWER", wait_time=5)
  end

  def get_GPS_functional(fc_id)

    packet_name = fc_id +"-AOCS_TLM"
    
    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_FIX")
    wait_check(@target, packet_name, "GPS_FIX", "!= 'NOFIX'", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_SATS_TRACKED")
    wait_check(@target, packet_name, "GPS_SATS_TRACKED", "> 4", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_SATS_PVT")
    wait_check(@target, packet_name, "GPS_SATS_PVT", "> 4", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_TIME_SEC")
    wait_check(@target, packet_name, "GPS_TIME_SEC", "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_TIME_WEEK")
    wait_check(@target, packet_name, "GPS_TIME_WEEK", "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_X0")
    wait_check(@target, packet_name, "GPS_X0", "!= 0", 5)    

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_X1")
    wait_check(@target, packet_name, "GPS_X1", "!= 0", 5) 

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_X2")
    wait_check(@target, packet_name, "GPS_X2", "!= 0", 5) 

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_V0")
    wait_check(@target, packet_name, "GPS_V0", "!= 0", 5)    

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_V1")
    wait_check(@target, packet_name, "GPS_V1", "!= 0", 5) 

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_V2")
    wait_check(@target, packet_name, "GPS_V2", "!= 0", 5) 
  end

  def get_GPS_alive(fc_id)

    packet_name = fc_id +"-AOCS_TLM"
    
    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_INPUT_VOLTAGE")
    wait_check(@target, packet_name, "GPS_INPUT_VOLTAGE", "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_1_2_CORE_VOLTAGE")
    wait_check(@target, packet_name, "GPS_1_2_CORE_VOLTAGE", "> 1.1", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_1_2_CORE_VOLTAGE")
    wait_check(@target, packet_name, "GPS_1_2_CORE_VOLTAGE", "< 1.3", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_3_3_CORE_VOLTAGE_ANTENNA")
    wait_check(@target, packet_name, "GPS_3_3_CORE_VOLTAGE_ANTENNA", "> 3.2", 5)
    
    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_3_3_CORE_VOLTAGE_ANTENNA")
    wait_check(@target, packet_name, "GPS_3_3_CORE_VOLTAGE_ANTENNA", "< 3.4", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_INPUT_CURRENT")
    wait_check(@target, packet_name, "GPS_INPUT_CURRENT", "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_OUTPUT_CURRENT_2_ANTENNA")
    wait_check(@target, packet_name, "GPS_OUTPUT_CURRENT_2_ANTENNA", "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "GPS_RECEIVER_TEMPERATURE")
    wait_check(@target, packet_name, "GPS_RECEIVER_TEMPERATURE", "!= 0", 5)    

  end
  
  def GPS_reset(fc_id)

    cmd_name = "GPS_RESET"
    cmd_params = {}
    
    # Send command
    @cmd_sender.send(fc_id,cmd_name,cmd_params)  
  
  end

  def power_off_GPS(apc_id)
    # board = "FC_YP"
    cmd_name = "APC_LVC_OUTPUT_SINGLE"
    cmd_params = {"OUTPUT_CHANNEL": 'GPS',
                  "STATE_ONOFF": 'OFF',
                  "DELAY":0
                  }

    # Send command
    @cmd_sender.send_with_cmd_count_check(apc_id, cmd_name, cmd_params, "POWER", wait_time=5)
  end

end