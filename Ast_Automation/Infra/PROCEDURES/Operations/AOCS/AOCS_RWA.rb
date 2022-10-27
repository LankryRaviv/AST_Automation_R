load_utility("Operations/FSW/UTIL_CmdSender")
load_utility('Operations/EPS/EPS_PCDU')

class ModuleRWA
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @pcdu = PCDU.new
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

  def power_on_RWA(board, rwa)
    method_name = "set_#{rwa}"
    @pcdu.public_send(method_name, board, 1)
  end

  def power_off_RWA(board, rwa)
    method_name = "set_#{rwa}"
    @pcdu.public_send(method_name, board, 0)
  end

  def send_RWA_NOOP(board, rwa)

    # board = "FC_YP"
    cmd_name = "RWA_NOOP"
    accept_mnemonic = "#{rwa}_CMDACCEPTCOUNT"
    reject_mnemonic = "#{rwa}_CMDREJCOUNT"
    cmd_params = {"RW_ID":rwa}
    pkt_name = "AOCS_TLM"

    initial_accept_count = @cmd_sender.get_current_val(board, "AOCS_TLM", accept_mnemonic)
    initial_reject_count = @cmd_sender.get_current_val(board, "AOCS_TLM", reject_mnemonic)
    
    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=2)
    wait(10)

    final_reject_count = @cmd_sender.get_current_val(board, "AOCS_TLM", reject_mnemonic)
    check_expression("#{final_reject_count} == #{initial_reject_count} ")
    
    final_accept_count = @cmd_sender.get_current_val(board, "AOCS_TLM", accept_mnemonic)
    check_expression("#{final_accept_count} == #{initial_accept_count + 1} ")
  end

  def set_wheel_mode_RWA(board, rwa, mode)

    # board = "FC_YP"
    accept_mnemonic = "#{rwa}_CMDACCEPTCOUNT"
    reject_mnemonic = "#{rwa}_CMDREJCOUNT"
    cmd_name = "RWA_SET_WHEEL_MODE"
    cmd_params = {"RW_ID":rwa,
                "MODE_RWA":mode}
    pkt_name = "AOCS_TLM"

    initial_accept_count = @cmd_sender.get_current_val(board, "AOCS_TLM", accept_mnemonic)
    initial_reject_count = @cmd_sender.get_current_val(board, "AOCS_TLM", reject_mnemonic)
    
    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=2)
    
    # Wait up to 10 seconds for accept count to increment by 1

    packet_name = board +"-AOCS_TLM"
    wait_check(@target, packet_name, accept_mnemonic, " == #{initial_accept_count + 1}", 10)

    # Check that reject count has not incremented
    check(@target, packet_name, reject_mnemonic, " == #{initial_reject_count}")
    
    # Check that mode is now external
    mode_check = "#{rwa}_OPMODE"
    check(@target, packet_name, mode_check, " == 'EXTERNAL'")
  end

  def set_wheel_speed_RWA(board, rwa, speed)

    # board = "FC_YP"
    accept_mnemonic = "#{rwa}_CMDACCEPTCOUNT"
    reject_mnemonic = "#{rwa}_CMDREJCOUNT"
    pkt_name = "AOCS_TLM"
    cmd_name = "RWA_SET_WHEEL_SPEED"
    cmd_params = {"RW_ID":rwa,
                "SPEED":speed}

    initial_accept_count = @cmd_sender.get_current_val(board, "AOCS_TLM", accept_mnemonic)
    initial_reject_count = @cmd_sender.get_current_val(board, "AOCS_TLM", reject_mnemonic)
    
    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=2)
    
    # Wait up to 10 seconds for accept count to increment by 1
    packet_name = board+"-AOCS_TLM"
    wait_check(@target, packet_name, accept_mnemonic, " == #{initial_accept_count + 1}", 10)

    # Check that reject count has not incremented
    check(@target, packet_name, reject_mnemonic, " == #{initial_reject_count}")
    
  end

  def set_wheel_torque_RWA(board, rwa, torque)

    # board = "FC_YP"
    accept_mnemonic = "#{rwa}_CMDACCEPTCOUNT"
    reject_mnemonic = "#{rwa}_CMDREJCOUNT"
    pkt_name = "AOCS_TLM"
    mode = "TORQUE"
    cmd_name = "RWA_SET_WHEEL_TORQUE"
    cmd_params = {"RW_ID":rwa,
                "TORQUE":torque}

    initial_accept_count = @cmd_sender.get_current_val(board, "AOCS_TLM", accept_mnemonic)
    initial_reject_count = @cmd_sender.get_current_val(board, "AOCS_TLM", reject_mnemonic)
    
    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=2)
    
    # Wait up to 10 seconds for accept count to increment by 1
    packet_name = board+"-AOCS_TLM"
    wait_check(@target, packet_name, accept_mnemonic, " == #{initial_accept_count + 1}", 10)

    # Check that reject count has not incremented
    check(@target, packet_name, reject_mnemonic, " == #{initial_reject_count}")
  end

  def set_wheel_timeout_protection(board, rwa)

    accept_mnemonic = "#{rwa}_CMDACCEPTCOUNT"
    reject_mnemonic = "#{rwa}_CMDREJCOUNT"
    cmd_name = "RWA_SET_WHEEL_TIMEOUT_PROTECTION"
    cmd_params = {"RW_ID": rwa,
                "NUM_OF_CYCLES": 0}

    initial_accept_count = @cmd_sender.get_current_val(board, "AOCS_TLM", accept_mnemonic)
    initial_reject_count = @cmd_sender.get_current_val(board, "AOCS_TLM", reject_mnemonic)
    
    # Send command
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, cmd_params, "AOCS", wait_time=10)
    
    # Wait up to 10 seconds for accept count to increment by 1
    packet_name = board+"-AOCS_TLM"
    wait_check(@target, packet_name, accept_mnemonic, " == #{initial_accept_count + 1}", 10)

    # Check that reject count has not incremented
    check(@target, packet_name, reject_mnemonic, " == #{initial_reject_count}")
  end

end