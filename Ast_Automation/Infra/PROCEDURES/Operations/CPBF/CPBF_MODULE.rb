load('Operations/FSW/UTIL_CmdSender.rb')

class ModuleCPBF
  def initialize
    @cmd_sender = CmdSender.new("BW3")
    @target = "BW3"
  end

  def start_soh_tlm()
    board = "CPBF"
    cmd_name = "CPBF_SET_TLM_INT_CMD"
    params = {
      "PERIOD_MS": 1000
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def stop_soh_tlm()
    board = "CPBF"
    cmd_name = "CPBF_SET_TLM_INT_CMD"
    params = {
      "PERIOD_MS": 0
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def get_micron_pkt(micron_id, timeout)
    board = "CPBF"
    cmd_name = "CPBF_GET_MICRON_PKT_CMD"
    params = {
      "MICRON_NUMBER": micron_id,
      "TIMEOUT_MS": timeout
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def upload_file_to_microns(start_entry, end_entry, period, duration, file_id)
    board = "CPBF"
    cmd_name = "CPBF_BROADCAST_MICRONFW_CMD"
    params = {
      "START_ENTRY": start_entry,
      "END_ENTRY": end_entry,
      "PERIOD_MS": period,
      "DURATION_S_LONG": duration,
      "FILE_ID": file_id
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  # def cpbf_link_reset_vup_bypass(link_number)
  #   board = "CPBF"
  #   cmd_name = "CPBF_LINK_RESET_CMD"
  #   params = {
  #     "CPBF_RESET_CODE": "VUP_AGGR_BYPASS_GT_SELECT_#{link_number}"
  #   }
  #   @cmd_sender.send(board, cmd_name, params)
  # end

  def cpbf_link_reset_cmd(param)
    board = "CPBF"
    cmd_name = "CPBF_LINK_RESET_CMD"
    params = {
      "CPBF_RESET_CODE": param
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def cpbf_get_loglist(wait_check_timeout=0.5)
    board = "CPBF"
    cmd_name = "CPBF_GET_LOGLIST_CMD"
    params = {}
    pkt_name = "CPBF_GET_LOGLIST_RES"
    return send_cmd_get_response(board, cmd_name, params, pkt_name, converted=true, raw=false, wait_check_timeout)
  end

#### AVIAD - changed the cmd_name and pkt_name in the following functions to match the function name

  def cpbf_prepare_micfw(cpbf_file_id, wait_check_timeout=5)
    board = "CPBF"
    cmd_name = "CPBF_PREPARE_MICFW_UPLOAD_CMD"
    params = {
      "CPBF_FILE_ID": cpbf_file_id
    }
    pkt_name = "CPBF_PREPARE_MICFW_UPLOAD_RES"
    return send_cmd_get_response(board, cmd_name, params, pkt_name, converted=true, raw=false, wait_check_timeout)
  end

#### AVIAD - changed the cmd_name and pkt_name in the following function to match the function name

  def cpbf_prepare_logdl(file_name, wait_check_timeout=5)
    board = "CPBF"
    cmd_name = "CPBF_PREPARE_LOGDL_CMD"
    params = {
      "FILE_NAME": file_name
    }
    pkt_name = "CPBF_PREPARE_LOGDL_RES"
    return send_cmd_get_response(board, cmd_name, params, pkt_name, converted=false, raw=true, wait_check_timeout)
  end

  def cpbf_broadcast_micronfw(start_entry, end_entry, period_ms, duration, file_id, micron_link, wait_check_timeout=1)
    board = "CPBF"
    cmd_name = "CPBF_BROADCAST_MICRONFW_CMD"
    params = {
      "START_ENTRY": start_entry,
      "END_ENTRY": end_entry,
      "PERIOD_MS": period_ms,
      "DURATION_S_LONG": duration,
      "FILE_ID": file_id,
      "MICRON_LINK": micron_link
    }
    pkt_name = "CPBF_BROADCAST_MICRONFW_RES"
    return send_cmd_get_response(board, cmd_name, params, pkt_name, converted=true, raw=false, wait_check_timeout)
  end

  def cpbf_mic_fileul_status(wait_check_timeout=1)
    board = "CPBF"
    cmd_name = "CPBF_MIC_FILEUL_STATUS_CMD"
    params = {}
    pkt_name = "CPBF_MIC_FILEUL_STATUS_RES"
    return send_cmd_get_response(board, cmd_name, params, pkt_name, converted=true, raw=false, wait_check_timeout)
  end

  ######################Raviv start
    def cpbf_sw_upgrade(file_type, converted=true, raw=false, wait_check_timeout=0.5)
    board = "CPBF"
    cmd_name = "CPBF_SW_UPGRADE_CMD"
    cmd_params = {
      "FILE_TYPE": file_type
    }
    pkt_name = "CPBF_SW_UPGRADE_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end
  
  def cpbf_reboot_fpga(converted=true, raw=false, wait_check_timeout=0.5)
    board = "CPBF"
    cmd_name = "CPBF_REBOOT_FPGA_CMD"
    cmd_params = {
      }
    pkt_name = "CPBF_REBOOT_FPGA_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end


  ###################### Raviv end
  def cpbf_file_info(file_id, converted=false, raw=false, wait_check_timeout=0.5)
    # Formulate cmd and tlm parameters
    board = "CPBF"
    cmd_name = "FSW_FILE_INFO"
    cmd_params = {
      "FILE_ID": file_id
    }
    pkt_name = "FILE_INFO_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def cpbf_micron_rw_reg_cmd(micron_id, rw_flag, reg_addr,data, timeout_ms, wait_check_timeout=0.5)
    board = "CPBF"
    cmd_name = "CPBF_MICRON_RW_REG_CMD"
    params = {
      "MICRON_ID_CPBF": micron_id,
      "RW_FLAG": rw_flag,
	    "REG_ADDR": reg_addr,
      "REG_DATA": data,
      "TIMEOUT_MS": timeout_ms
    }
    pkt_name = "CPBF_MICRON_RW_REG_RES"
    return send_cmd_get_response(board, cmd_name, params, pkt_name, converted=true, raw=false, wait_check_timeout)
  end

  def cpbf_ping(wait_check_timeout=2)
    board = "CPBF"
    cmd_name = "CSP_PING"
    params = {}
    pkt_name = "CSP_PING"
    return send_with_recv_count_check_res(board, cmd_name, params, pkt_name, wait_check_timeout)
  end

  def cpbf_remote_cli_cmd(cli_cmd_str, get_response=false, wait_time=1)
    cli_res = Hash.new
    cmd_name = 'CPBF_REMOTE_CLI_CMD'
    cmd_params = {
      'CLI_COMMAND': cli_cmd_str
    }
    full_pkt_name = 'CPBF-CPBF_REMOTE_CLI_RES'
    out_str = ""
    send_with_recv_count_check_res('CPBF', cmd_name, cmd_params, 'CPBF_REMOTE_CLI_RES', wait_time)
    if get_response
      pkt_id = subscribe_packet_data([[@target, full_pkt_name]])
      begin
        while true
          packet = get_packet(pkt_id, true)
          packet_count = packet.read('RECEIVED_COUNT')
          data_str = packet.read('CPBF_CLI_RESPONSE')
          cli_res.store(packet_count, data_str)
        end
      rescue => threadError
        puts('Got cli response')
      end
      cli_sorted = cli_res.sort
      cli_sorted.each do |line|
        out_str += line[1]
      end
    end
    return out_str
  end


  ####################

  private

  def send_with_recv_count_check_res(board, cmd_name, cmd_params, pkt_name, wait_time=3, no_hazardous_check=false)
    # Send command
    current_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
    # Check for increment by one
    wait(wait_time)
    new_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")
    return new_val > current_val
  end

  def send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
    full_pkt_name = get_full_pkt_name(board, pkt_name)
    @cmd_sender.send_with_recv_count_retry_check(board, cmd_name, cmd_params, pkt_name, wait_check_timeout)
    # Send command, verify that response is received and is for this file ID
    # @cmd_sender.send_with_wait_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_check_timeout)

    # Get data to return, depending on format requested
    res = []

    if converted
      res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
      res.push(res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
    end

    if raw
      res_pkt_raw = get_tlm_packet(@target, full_pkt_name, value_types = :RAW)
      res.push(res_pkt_raw.map {|item| [item[0], item[1]]}.to_h)
    end

    return res
  end

  def get_current_val(board, pkt_name, mnemonic)
    full_pkt_name = get_full_pkt_name(board, pkt_name)
    return tlm(@target, full_pkt_name, mnemonic)
  end

  def get_full_pkt_name(board, pkt_name)
    return board+"-"+pkt_name
  end
end