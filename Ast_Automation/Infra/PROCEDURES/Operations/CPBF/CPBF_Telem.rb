load 'Operations/FSW/UTIL_CmdSender.rb'

class ModuleCPBF
  def initialize
    @cmd_sender = CmdSender.new
    @target="BW3"
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

  def send_cmd_get_micron_pkt(link, micron_id, cmd_name, cmd_params, tlm_packet, timeout, wait_dur=3, retry_count=1)
    start_time = Time.now
    retries = 1
    while ((Time.now - start_time) < wait_dur) && retries <= retry_count
      # first get micron pkt recieve count starting value
      mic_pkt_rcv_cnt_curr = get_current_val(link, tlm_packet, "RECEIVED_COUNT")
      @cmd_sender.send(link, cmd_name, cmd_params)
      # not sure how long to wait, set it to 1 sec for now
      wait(2)
      if send_get_micron_pkt(micron_id, timeout)
        if get_current_val("CPBF", "CPBF_GET_MICRON_PKT_RES", "GET_MICRON_PKT_RESPONSE_CODE") == "SUCCESS"
          # success, now check micron pkt recieve count
          if mic_pkt_rcv_cnt_curr + 1 == get_current_val(link, tlm_packet, "RECEIVED_COUNT")
            return true
          else
            puts("Micron packet not received through CPBF.  Attempt #{retries} of #{retry_count}")
          end
        else
          # get micron pkt result was not success.  for now, just throw error and retry
          puts("CPBF Get Micron Pkt Result response code was not SUCCESS. Attempt #{retries} of #{retry_count}")
        end
      else
        # no response returned
        puts("No response from CPBF after sending Get Micron Pkt command. Attempt #{retries} of #{retry_count}")
      end
      retries += 1
    end
    return false
  end

  def send_get_micron_pkt(micron_id, timeout)
    board = "CPBF"
    cmd_name = "CPBF_GET_MICRON_PKT_CMD"
    params = {
      "MICRON_NUMBER": "MICRON_#{micron_id}",
      "TIMEOUT_MS": timeout
    }
    pkt_name = "CPBF_GET_MICRON_PKT_RES"
    return send_with_recv_cnt_check_res(board, cmd_name, params, pkt_name, wait_time=timeout/1000)
  end

  def get_mic_fileul_status()
    board = "CPBF"
    cmd_name = "CPBF_MIC_FILEUL_STATUS_CMD"
    pkt_name = "CPBF_MIC_FILEUL_STATUS_RES"
    params = {}
    return send_with_recv_cnt_check_res(board, cmd_name, params, pkt_name, wait_time=0.5)
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

  def send_with_recv_cnt_check_res(board, cmd_name, cmd_params, pkt_name, wait_time=3.0, no_hazardous_check=false)
    # Send command
    full_pkt_name = board + "-" + pkt_name
    current_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
    # Check for increment by one
    wait(wait_time)
    new_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")
    return new_val == current_val + 1
  end

  def get_current_val(board, pkt_name, mnemonic)
    full_pkt_name = board + "-" + pkt_name
    return tlm(@target, full_pkt_name, mnemonic)
  end

end