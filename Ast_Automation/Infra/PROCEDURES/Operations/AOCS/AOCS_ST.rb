load_utility("Operations/FSW/UTIL_CmdSender")

class ModuleST
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @pcdu = PCDU.new
  end

  def power_on_ST(board, st_id)
    method_name = "set_#{st_id}"
    @pcdu.public_send(method_name, board, 1)
  end

  def power_off_ST(board, st_id)
    method_name = "set_#{st_id}"
    @pcdu.public_send(method_name, board, 0)
  end
  
  def get_ST_mode(st_id, fc_id)

    packet_name = fc_id +"-AOCS_TLM"

    st_id.to_s
    st_id = st_id[3..4]
    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "ST_MODE_#{st_id}")
    wait_check(@target, packet_name, "ST_MODE_#{st_id}", " == 'MODE_A'", 60)

  end

  def get_ST_time_measurements(st_id, fc_id)

    packet_name = fc_id +"-AOCS_TLM"

    st_id.to_s
    st_id = st_id[3..4]
    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "ST_SEC_#{st_id}")
    wait_check(@target, packet_name, "ST_SEC_#{st_id}", "> 0", 60)

    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "ST_MSEC_#{st_id}")
    wait_check(@target, packet_name, "ST_MSEC_#{st_id}", "> 0", 60)

  end

  def get_ST_temp_measurements(st_id, fc_id)

    packet_name = fc_id +"-AOCS_TLM"

    st_id.to_s
    st_id = st_id[3..4]
    current_val = @cmd_sender.get_current_val(fc_id, "AOCS_TLM", "ST_TEMP_#{st_id}")
    wait_check(@target, packet_name, "ST_TEMP_#{st_id}", "> 0", 60)

  end

end