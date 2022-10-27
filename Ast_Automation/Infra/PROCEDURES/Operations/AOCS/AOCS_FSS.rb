load_utility("Operations/FSW/UTIL_CmdSender")

class ModuleFSS
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end

  def power_on_FSS(apc_id)
    # board = "FC_YP"
    cmd_name = "APC_LVC_OUTPUT_SINGLE"
    cmd_params = {"OUTPUT_CHANNEL": 'SUN_SENSOR',
                  "STATE_ONOFF": 'ON',
                  "DELAY":0
                  }

    # Send command
    @cmd_sender.send_with_cmd_count_check(apc_id, cmd_name, cmd_params, "POWER", wait_time=5)
  end
  
  def get_FSS_data(fss_id,fc_id)

    fss_id.to_s
    full_pkt_name = CmdSender.get_full_pkt_name(fc_id, "AOCS_TLM")

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "#{fss_id}_PRESENCE")
    wait_check(@target, full_pkt_name, "#{fss_id}_PRESENCE", "== 'PRESENT'", 10)
    
    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "#{fss_id}_A")
    wait_check(@target, full_pkt_name, "#{fss_id}_A", "!= 0", 10)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "#{fss_id}_B")
    wait_check(@target, full_pkt_name, "#{fss_id}_B", "!= 0", 10)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "#{fss_id}_C")
    wait_check(@target, full_pkt_name, "#{fss_id}_C", "!= 0", 10)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "#{fss_id}_D")
    wait_check(@target, full_pkt_name, "#{fss_id}_D", "!= 0", 10)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "#{fss_id}_TEMP")
    wait_check(@target, full_pkt_name, "#{fss_id}_TEMP", "!= 0", 10)

  end

  def power_off_FSS(apc_id)
    # board = "FC_YP"
    cmd_name = "APC_LVC_OUTPUT_SINGLE"
    cmd_params = {"OUTPUT_CHANNEL": 'SUN_SENSOR',
                  "STATE_ONOFF": 'OFF',
                  "DELAY":0
                  }

    # Send command
    @cmd_sender.send_with_cmd_count_check(apc_id, cmd_name, cmd_params, "POWER", wait_time=5)
  end

end