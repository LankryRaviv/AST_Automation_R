

class CmdSender
  def initialize(target="BW3")
    @target = target
  end

  def send(board, cmd_name, cmd_params, no_hazardous_check=false)
    full_cmd_name = board+"-"+cmd_name
    if no_hazardous_check == false
      cmd(@target, full_cmd_name, cmd_params)
    else
      cmd_no_hazardous_check(@target, full_cmd_name, cmd_params)
    end
  end

  def send_with_crc_poll(board, cmd_name, cmd_params, no_hazardous_check=false, wait_time = 1.0)
    full_cmd_name = board+"-"+cmd_name
    if no_hazardous_check == false
      cont_poll = true
      while(cont_poll)
        init_val = get_current_val("CSP", "CSP_INFO_MESSAGE", "RECEIVED_COUNT")
        cmd(@target, full_cmd_name, cmd_params)
        wait(wait_time)
        curr_val = get_current_val("CSP", "CSP_INFO_MESSAGE", "RECEIVED_COUNT")
        if (init_val == curr_val)
          cont_poll = false
        end
      end
    else
      cont_poll = true
      while(cont_poll)
        init_val = get_current_val("CSP", "CSP_INFO_MESSAGE", "RECEIVED_COUNT")
        cmd_no_hazardous_check(@target, full_cmd_name, cmd_params)
        wait(wait_time)
        curr_val = get_current_val("CSP", "CSP_INFO_MESSAGE", "RECEIVED_COUNT")
        if (init_val == curr_val)
          cont_poll = false
        end
      end
    end
  end


  def send_with_wait_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_time, no_hazardous_check=false)
    # Get current value
    full_pkt_name = self.class.get_full_pkt_name(board, pkt_name)
    current_val = get_current_val(board, pkt_name, mnemonic)

    # Send command
    send(board, cmd_name, cmd_params, no_hazardous_check)

    # Wait for condition to be met
    wait_check(@target, full_pkt_name, mnemonic, "#{comparison} #{current_val}", wait_time)
  end

  def send_with_wait_then_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_time=1, no_hazardous_check=false)
    # Send command
    full_pkt_name = self.class.get_full_pkt_name(board, pkt_name)
    send(board, cmd_name, cmd_params, no_hazardous_check)

    # Wait for command to be processed
    wait(1)

    # Check current value and wait passed in time to make sure no more packets are received
    current_val = get_current_val(board, pkt_name, mnemonic)
    wait(wait_time)
    check(@target, full_pkt_name, mnemonic, "#{comparison} #{current_val}")
  end

  def send_with_recv_count_check(board, cmd_name, cmd_params, pkt_name, wait_time=4, no_hazardous_check=false)
    # Send command
    full_pkt_name = self.class.get_full_pkt_name(board, pkt_name)
    current_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")
    send(board, cmd_name, cmd_params, no_hazardous_check)
    # Check for increment by one
    wait_check(@target, full_pkt_name, "RECEIVED_COUNT", ">= #{current_val+1}", wait_time)
  end

  def send_with_recv_count_retry_check(board, cmd_name, cmd_params, pkt_name, wait_time=2, no_hazardous_check=false, retry_count=3)
    full_cmd_name = board+"-"+cmd_name
    retries = 0
    status = false
    init_val = get_current_val(board, pkt_name, "RECEIVED_COUNT") 
    while(retries < retry_count)   
      if no_hazardous_check
        cmd_no_hazardous_check(@target, full_cmd_name, cmd_params)
      else
        cmd(@target, full_cmd_name, cmd_params)
      end
      wait(wait_time)
      curr_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")
      if (curr_val >= init_val + 1)
        retries = retry_count
        status = true
      end
      retries += 1
    end
    return status
  end

  def send_with_recv_count_retry_check_mic(board, cmd_name, cmd_params, pkt_name, micron_id, wait_time=2, no_hazardous_check=false, retry_count=3)
    full_cmd_name = board+"-"+cmd_name
    retries = 0
    status = false
    init_val = get_current_val(board, pkt_name, "RECEIVED_COUNT") 
    while(retries < retry_count)   
      if no_hazardous_check
        cmd_no_hazardous_check(@target, full_cmd_name, cmd_params)
      else
        cmd(@target, full_cmd_name, cmd_params)
      end
      wait(wait_time)
      curr_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")
      curr_mic = get_current_val(board, pkt_name, "MICRON_ID")
      if (curr_val >= init_val + 1) && (curr_mic.to_i == micron_id)
        retries = retry_count
        status = true
      end
      retries += 1
    end
    return status
  end

  def send_with_cmd_count_check(board, cmd_name, cmd_params, subsystem_name, wait_time=4, no_hazardous_check=false)
    # Get mnemonics
    cmd_rec_mnemonic = "#{subsystem_name}_CMD_REC_COUNTER"
    cmd_err_mnemonic = "#{subsystem_name}_CMD_ERROR_COUNTER"

    pkt_name = ""
    if board == "FC_YP" or board == "FC_YM"
      pkt_name = "FSW_TLM_FC"
    elsif board == "APC_YP" or board == "APC_YM"
      pkt_name = "FSW_TLM_APC"
    elsif board.include?("DPC")
      pkt_name = "FSW_TLM_DPC"
    else
      wait
    end

    # Get current values
    full_pkt_name = self.class.get_full_pkt_name(board, pkt_name)
    current_err_count = get_current_val(board, pkt_name, cmd_err_mnemonic)
    current_recv_count = get_current_val(board, pkt_name, cmd_rec_mnemonic)
    current_csp_err_count = get_current_val(board, pkt_name, "CSP_CMD_ERROR_COUNTER")
    current_csp_recv_count = get_current_val(board, pkt_name, "CSP_CMD_REC_COUNTER")
    send(board, cmd_name, cmd_params, no_hazardous_check)

    # Check for receive increment by one
    wait_check(@target, full_pkt_name, "CSP_CMD_REC_COUNTER", ">= #{current_csp_recv_count+1}", wait_time)
    wait_check(@target, full_pkt_name, cmd_rec_mnemonic, "== #{current_recv_count+1}", wait_time)

    # Check for error not incrementing
    wait_check(@target, full_pkt_name, "CSP_CMD_ERROR_COUNTER", "== #{current_csp_err_count}", wait_time)
    wait_check(@target, full_pkt_name, cmd_err_mnemonic, "== #{current_err_count}", wait_time)
  end

  def get_current_val(board, pkt_name, mnemonic)
    full_pkt_name = self.class.get_full_pkt_name(board, pkt_name)
    return tlm(@target, full_pkt_name, mnemonic)
  end

  def self.get_full_pkt_name(board, pkt_name)
    return board+"-"+pkt_name
  end

end