load_utility('Operations\FSW\UTIL_CmdSender')

class ModuleEMT
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end

  def actuator_ground_mode(board, mode)

    # board = "FC_YP"
    cmd_name = "AOCS_ACTUATOR_CMD_MODE"
    cmd_params = {"MODE_AOCS": mode}

    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=2)
    packet_name = board+"-AOCS_TLM"
    wait_check(@target, packet_name, "ADCS_ACTUATOR_CMD_MODE", "== 'GROUND'", 10)
   
  end

  
  def on_EMT_positive(board, emt_id)
    #board = "FC"
    cmd_name = "EMT_ON_POSITIVE"
    cmd_params = {"EMT_ID": emt_id}

    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=5)
     
  end

  def on_EMT_negative(board, emt_id)
    #board = "FC"
    cmd_name = "EMT_ON_NEGATIVE"
    cmd_params = {"EMT_ID": emt_id}

    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=5)
   
  end
  
  def EMT_off(board, emt_id)
    #board = "FC"
    cmd_name = "EMT_OFF"
    cmd_params = {"EMT_ID": emt_id}

    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=5)
   
  end

end