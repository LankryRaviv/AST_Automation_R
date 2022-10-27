load_utility('Operations\FSW\UTIL_CmdSender')

class ModuleMAG
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end
  
  def get_MAG_measurements(fc_id)

    packet_name = fc_id +"-AOCS_TLM"

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_PRIMARY_PRESENCE')
    wait_check(@target, packet_name, 'MAG_PRIMARY_PRESENCE', "== 'PRESENT'", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_PRIMARY_RAW_MEAS_0')
    wait_check(@target, packet_name, 'MAG_PRIMARY_RAW_MEAS_0', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_PRIMARY_RAW_MEAS_1')
    wait_check(@target, packet_name, 'MAG_PRIMARY_RAW_MEAS_1', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_PRIMARY_RAW_MEAS_2')
    wait_check(@target, packet_name, 'MAG_PRIMARY_RAW_MEAS_2', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_PRIMARY_TEMP')
    wait_check(@target, packet_name, 'MAG_PRIMARY_TEMP', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_SECONDARY_PRESENCE')
    wait_check(@target, packet_name, 'MAG_SECONDARY_PRESENCE', "== 'PRESENT'", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_SECONDARY_RAW_MEAS_0')
    wait_check(@target, packet_name, 'MAG_SECONDARY_RAW_MEAS_0', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_SECONDARY_RAW_MEAS_1')
    wait_check(@target, packet_name, 'MAG_SECONDARY_RAW_MEAS_1', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_SECONDARY_RAW_MEAS_2')
    wait_check(@target, packet_name, 'MAG_SECONDARY_RAW_MEAS_2', "!= 0", 5)

    current_val = @cmd_sender.get_current_val(fc_id, 'AOCS_TLM', 'MAG_SECONDARY_TEMP')
    wait_check(@target, packet_name, 'MAG_SECONDARY_TEMP', "!= 0", 5)

  end
  
  def MAG_reset(fc_id)
    #board = "FC"
    cmd_name = "MAG_RESET"
    cmd_params = {}

    # Send command
    @cmd_sender.send_with_cmd_count_check(fc_id, cmd_name, cmd_params, "AOCS", wait_time=5)
    
  end

end