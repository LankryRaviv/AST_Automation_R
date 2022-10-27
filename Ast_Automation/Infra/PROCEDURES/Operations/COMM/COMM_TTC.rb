load_utility('Operations/FSW/UTIL_CmdSender')


class ModuleTTC
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @wait_time = 3
  end
 
  # ------------------------------------------------------------------------------------
  def get_sband_diagnostic_packet(board)

    # Get current packet received count
    orig_rec_count = tlm(@target, "#{board}-SBAND_DIAGNOSTIC", "RECEIVED_COUNT")

    # Request Diagnostics packet
    @cmd_sender.send_with_crc_poll(board, "SBAND_SEND_DIAGNOSTIC_PKT", {})

    # Verify the packet count increased
    wait_check(@target, "#{board}-SBAND_DIAGNOSTIC", "RECEIVED_COUNT", "==#{orig_rec_count + 1}", @wait_time)
  end
  
  # ------------------------------------------------------------------------------------
  def get_uhf_diagnostic_packet(board)

    # Get current packet received count
    orig_rec_count = tlm(@target, "#{board}-UHF_DIAGNOSTIC", "RECEIVED_COUNT")

    # Request Diagnostics packet
    @cmd_sender.send_with_crc_poll(board, "UHF_REQUEST_DIAGNOSTIC", {})

    # Verify the packet count increased
    wait_check(@target, "#{board}-UHF_DIAGNOSTIC", "RECEIVED_COUNT", "==#{orig_rec_count + 1}", @wait_time)
  end

  # ------------------------------------------------------------------------------------
  def sband_config_param_save_to_boot(board, group_type)
    sband_config_parameter_save(board, group_type, "FALSE")
  end

  # ------------------------------------------------------------------------------------
  def sband_config_param_save_to_fallback(board, group_type)
    sband_config_parameter_save(board, group_type, "TRUE")
  end

  # ------------------------------------------------------------------------------------
  def sband_config_parameter_save(board, group_type,fallback = "FALSE")

    # PROPERTY_ID =  SL_CS_TX_GROUP_ID = 3, SL_CS_RX_GROUP_ID = 4,  SL_CS_SYS_GROUP_ID = 5

    cmd_params = {"PROPERTY_ID": group_type,
                "FALLBACK": fallback}

    if group_type == "SL_CS_SYS_GROUP_ID" or fallback == 'TRUE'
      # Unlock
      @cmd_sender.send_with_cmd_count_check(board, "SBAND_UNLOCK_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    end

    # Save
    @cmd_sender.send_with_cmd_count_check(board, "SBAND_SAVE_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)

    if group_type == "SL_CS_SYS_GROUP_ID"
      # Lock
      @cmd_sender.send_with_cmd_count_check(board, "SBAND_LOCK_PROPERTY_GROUP", cmd_params, "COMM", @wait_time)
    end

    

  end

end 