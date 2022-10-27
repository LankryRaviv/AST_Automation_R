load('Operations/FSW/UTIL_CmdSender.rb')

class MICRON_MODULE
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end

########################

  def get_system_power_mode(board, micron_id, converted=false, raw=false, wait_check_timeout=1)#was 2 sec
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_GET_SYSTEM_POWER_MODE"
    cmd_params = {
	  "MICRON_ID": micron_id
    }
    pkt_name = "MIC_GET_SYS_PWR_MODE_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def set_system_power_mode(board, micron_id, next_power_mode, converted=false, raw=false, wait_check_timeout=0.1)#was 2 sec
   # Formulate cmd and tlm parameters
   cmd_name = "MIC_SET_SYSTEM_POWER_MODE"
   cmd_params = {
	  "MICRON_ID": micron_id,
	  "NEXT_POWER_MODE": next_power_mode
   }
   pkt_name = "MIC_SET_SYS_PWR_MODE_RES"
   return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def set_system_ps2_auto(board, micron_id, auto_transition, converted=false, raw=false, wait_check_timeout=2)
   # Formulate cmd and tlm parameters
   cmd_name = "MIC_SET_SYSTEM_PS2_AUTO_TRANSITION"
   cmd_params = {
	  "MICRON_ID": micron_id,
	  "PS2_AUTO_TRANSITION": auto_transition
   }
   pkt_name = "MIC_SET_SYS_PS2_AUTO_TRANSITION_RES"
   return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def ping_micron(board, micron_id, converted=false, raw=false, wait_check_timeout=0.5, num_tries=5)
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_CSP_PING"
    cmd_params = {
     "MICRON_ID": micron_id
    }
    pkt_name = "MIC_CSP_PING_RES"
    return send_with_recv_count_check_res(board, cmd_name, cmd_params, pkt_name, wait_check_timeout, false, num_tries)
   end

   def set_power_sharing(board, micron_id, direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=1)#was 10 sec
   # Formulate cmd and tlm parameters
   cmd_name = "MIC_EPS_SET_PWR_SHARING_CFG"
   cmd_params = {
	  "MICRON_ID": micron_id,
	  "DIRECTION_SWITCH": direction_switch,
	  "SHARE_MODE": share_mode
   }
   pkt_name = "MIC_EPS_SET_PWR_SHARING_CFG_RES"
   return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_power_sharing(board, micron_id, direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=2)#was 10 sec
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_EPS_GET_PWR_SHARING_STATUS"

    cmd_params = {
     "MICRON_ID": micron_id
    }
    pkt_name = "MIC_EPS_GET_PWR_SHARING_STAT_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
   end

  def sys_reboot(board, micron_id, converted=false, raw=false, wait_check_timeout=5)#was 10 sec
    cmd_name = "MIC_CSP_REBOOT"
    cmd_params = {
     "MICRON_ID": micron_id,
     "CSP_REBOOT_MAGIC_VALUE": "REBOOT"
    }
    pkt_name = "MIC_CSP_REBOOT"
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check=true)
  end

  def get_tlm_slim(board, micron_id, slim_mode, converted=false, raw=false, wait_check_timeout=0.2)
    cmd_name = "MIC_GET_TLM_SLIM"
    cmd_params = {
      "MICRON_ID": micron_id,
      "MIC_SLIM_MODE": slim_mode,
    }
    pkt_name = "MIC_PERIODIC_SLIM_PACKET"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def fpga_check(board, micron_id, destination, image_type, file_id, converted=false, raw=false, wait_check_timeout=3)
    cmd_name = "3CHECK"
    cmd_params = {
      "MICRON_ID": micron_id,
      "CRC_CHECK_DEST": destination,
      "FPGA_IMAGE_TYPE": image_type,
      "FILE_ID": file_id
    }
    pkt_name = "MIC_FPGA_CHECK_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def fpga_check_status(board, micron_id, destination, image_type, converted=false, raw=false, wait_check_timeout=2)
    cmd_name = "MIC_FPGA_CHECK_STATUS"
    cmd_params = {
      "MICRON_ID": micron_id,
      "CRC_CHECK_DEST": destination,
      "FPGA_IMAGE_TYPE": image_type,
    }
    pkt_name = "MIC_FPGA_CHECK_STATUS_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_micron_sw_version(board, micron_id, converted=false, raw=false, wait_check_timeout=1)#was 2 sec
    cmd_name = "MIC_FIRMWARE_INFO"
    cmd_params = {
      "MICRON_ID": micron_id
    }
    pkt_name = "MIC_FIRMWARE_INFO_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def fpga_install(board, micron_id, file_id, image_type, converted=false, raw=false, wait_check_timeout=3)
    cmd_name = "MIC_FPGA_INSTALL"
    cmd_params = {
      "MICRON_ID": micron_id,
      "MIC_FPGA_FILE_ID": file_id,
      "FPGA_IMAGE_TYPE": image_type,
    }
    pkt_name = "MIC_FPGA_INSTALL_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def fpga_info(board, micron_id, image_type, reading_source="DESCRIPTOR", converted=false, raw=false, wait_check_timeout=2)
    cmd_name = "MIC_FPGA_INFO"
    cmd_params = {
      "MICRON_ID": micron_id,
      "FPGA_IMAGE_TYPE": image_type,
      "READING_SOURCE": reading_source
    }
    pkt_name = "MIC_FPGA_INFO_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_micron_detailed_telemetry_eps(board, micron_id, subsystem_id="EPS", converted=true, raw=false, wait_check_timeout=1)#was 2 sec
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_DETAILED_TELEMETRY"
    cmd_params = {
        "MICRON_ID": micron_id,
        "SUBSYSTEM_ID": subsystem_id
    }
    pkt_name = "MIC_EPS_TLM"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_micron_detailed_telemetry_thermal(board, micron_id, subsystem_id="THERMAL", converted=true, raw=false, wait_check_timeout=0.5)
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_DETAILED_TELEMETRY"
    cmd_params = {
        "MICRON_ID": micron_id,
        "SUBSYSTEM_ID": subsystem_id
    }
    pkt_name = "MIC_THERMAL_TLM"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_micron_detailed_telemetry_fdir(board, micron_id, subsystem_id="FDIR", converted=true, raw=false, wait_check_timeout=0.5)
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_DETAILED_TELEMETRY"
    cmd_params = {
        "MICRON_ID": micron_id,
        "SUBSYSTEM_ID": subsystem_id
    }
    pkt_name = "MIC_FDIR_TLM"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_micron_sw_version(board, micron_id, converted=true, raw=false, wait_check_timeout=0.5)#was 2 sec
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_FIRMWARE_INFO"
    cmd_params = {
        "MICRON_ID": micron_id
    }
    pkt_name = "MIC_FIRMWARE_INFO_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end


  def get_micron_default_routing(board, micron_id, converted=true, raw=false, wait_check_timeout=0.5)#was 2 sec
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_GET_ROUTING_PARAMETERS"
    cmd_params = {
        "MICRON_ID": micron_id
    }
    pkt_name = "MIC_GET_ROUTING_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def set_fpga_freq_param(board, micron_id, converted=true, raw=false, wait_check_timeout=0.2,dl_ban = "10MHz",dl_freq = 881500, ul_ban = "10MHz", ul_freq = 836500)#was 2 sec
    # fpga params

    cmd_name = "MIC_SET_FPGA_FREQ_PARAM"
    cmd_params = {
        "MICRON_ID": micron_id,
        "DOWNLINK_BANDWIDTH": dl_ban,
        "DOWNLINK_FREQUENCY": dl_freq,
        "UPLINK_BANDWIDTH": ul_ban,
        "UPLINK_FREQUENCY": ul_freq
    }
    pkt_name = "MIC_SET_FPGA_FREQ_PARAM_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  # raviv


  def get_fpga_freq_param(board, micron_id, converted=true, raw=false, wait_check_timeout=0.2)#was 2 sec
    # fpga params

    cmd_name = "MIC_GET_FPGA_FREQ_PARAM"
    cmd_params = {
        "MICRON_ID": micron_id
    }
    pkt_name = "MIC_GET_FPGA_FREQ_PARAM_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_fpga_jc_status(board, micron_id, converted=true, raw=false, wait_check_timeout=0.2)#was 2 sec
    # fpga params

    cmd_name = "MIC_FPGA_GET_JC_STATUS"
    cmd_params = {
        "MICRON_ID": micron_id
    }
    pkt_name = "MIC_FPGA_GET_JC_STATUS_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end
  #raviv

  def set_mic_time(board, micron_id, converted_time, converted=true, raw=true, wait_check_timeout=0.2)
    cmd_name = "MIC_SET_TIME"
    cmd_params = {
        "MICRON_ID": micron_id,
        "UNIX_TIME_STAMP": converted_time,
    }
    pkt_name = "MIC_SET_TIME_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_mic_time(board, micron_id, converted=true, raw=true, wait_check_timeout=0.2)
    cmd_name = "MIC_GET_TIME"
    cmd_params = {
        "MICRON_ID": micron_id
    }
    pkt_name = "MIC_GET_TIME_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_det_meas(board, micron_id, converted=true, raw=false, wait_check_timeout=1,fem_id = 0x1)#was 2 sec
    # fpga params
    cmd_name = "MIC_GET_DET_MEAS"
    cmd_params = {
        "MICRON_ID": micron_id,
        "FEM_ID": fem_id
    }
    pkt_name = "MIC_GET_DET_MEAS_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def set_dsa_val(board, micron_id, converted=true, raw=false, wait_check_timeout=0.5,fem_id = 0,rf_path = "TX", dsa_value = 10)#was 2 sec
    # fpga params
    cmd_name = "MIC_FEM_SET_DSA_VAL"
    cmd_params = {
        "MICRON_ID": micron_id,
        "FEM_ID": fem_id,
        "RF_PATH": rf_path,
        "DSA_VALUE": dsa_value
    }
    pkt_name = "MIC_SET_DSA_VAL_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def remote_cli(board, micron_id, packet_delay, input_data, message_completed, wait_time=1)# was wait_time=2
    # message_completed should be "COMPLETED" or "CONTINUE"
    cmd_name = "MIC_REMOTE_CLI"
    cmd_params = {
      "MICRON_ID": micron_id,
      "DELAY_BETWEEN_PACKETS": packet_delay,
      "INPUT_DATA": input_data,
      "MESSAGE_COMPLETED": message_completed
    }
    pkt_name = "MIC_REMOTE_CLI_RES"
    if message_completed.eql? "COMPLETED"
      return send_cmd_get_cli_response(board, cmd_name, cmd_params, pkt_name, wait_time)
    else
      send_with_recv_count_check_res(board,cmd_name,cmd_params,pkt_name,wait_time)
      return []
    end
  end

  def remote_cli_body(board, micron_id, packet_delay, input_data, wait_time=1)# was wait_time=2
    cmd_name = "MIC_REMOTE_CLI_BODY"
    cmd_params = {
      "MICRON_ID": micron_id,
      "DELAY_BETWEEN_PACKETS": packet_delay,
      "INPUT_BODY_DATA": input_data
    }
    pkt_name = "MIC_REMOTE_CLI_RES"
    send_with_recv_count_check_res(board,cmd_name,cmd_params,pkt_name,wait_time)
    return []
  end

  def send_cmd_get_cli_response(board, cmd_name, cmd_params, pkt_name, wait_time=1)
    cli_res = Hash.new
    full_pkt_name = get_full_pkt_name(board, pkt_name)
    pkt_id = subscribe_packet_data([[@target, full_pkt_name]])
    send_with_recv_count_check_res(board, cmd_name, cmd_params, pkt_name, wait_time)
    begin
      while true
        packet = get_packet(pkt_id, true)
        mic_packet_id = packet.read('MIC_PACKET_ID')
        data_str = packet.read('MIC_OUTPUT_DATA')
        cli_res.store(mic_packet_id, data_str)
      end
    rescue => threadError
      puts("got cli response")
    end
    cli_sorted = cli_res.sort
    out_str = ""
    cli_sorted.each do |line|
      out_str += line[1]
    end
    return out_str
  end

  def gps_fast(board, micron_id, converted=true, raw=false, wait_check_timeout=1)#was 2 sec
    # fpga params
    cmd_name = "MIC_GPS_FAST"
    cmd_params = {
        "MICRON_ID": micron_id
    }
    pkt_name = "MIC_GPS_FAST_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  # def set_default_routing_param(board, micron_id, converted=true, raw=false, wait_check_timeout=2)

  #   cmd_name = "MIC_SET_DEFAULT_ROUTING_PARAMETERS"
  #   cmd_params = {
  #       "MICRON_ID": micron_id
  #   }
  #   pkt_name = "MIC_SET_DEFAULT_ROUTING_RES"
  #   return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  # end

  def set_micron_routing_param(board, micron_id, chain_id, routing_ls, routing_hs, wfd, ttd, converted=true, raw=false, wait_check_timeout=0.1) # was wait_time=2
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_SET_ROUTING_PARAMETERS"
    cmd_params = {
      "MICRON_ID": micron_id,
      "CHAIN_ID": chain_id,
      "ROUTING_LS": routing_ls,
      "ROUTING_HS": routing_hs,
      "WHOLE_FRAME_DELAY": wfd,
      "TIME_TAG_DELAY": ttd
    }
    pkt_name = "MIC_SET_ROUTING_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def set_micron_default_routing_param(board, micron_id, converted=true, raw=false, wait_check_timeout=0.1)# was wait_time=2
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_SET_DEFAULT_ROUTING_PARAMETERS"
    cmd_params = {
        "MICRON_ID": micron_id
    }
    pkt_name = "MIC_SET_DEFAULT_ROUTING_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def get_micron_default_routing(board, micron_id, converted=true, raw=false, wait_check_timeout=0.1)# was wait_time=2
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_GET_ROUTING_PARAMETERS"
    cmd_params = {
        "MICRON_ID": micron_id
    }
    pkt_name = "MIC_GET_ROUTING_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end


  ####################

  private

  def send_with_recv_count_check_res(board, cmd_name, cmd_params, pkt_name, wait_time=3, no_hazardous_check=false, num_tries = 5)

    try_count = 1
    while try_count <= num_tries

      # Send command
      current_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")
      @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
      # Check for increment by one
      wait(wait_time)
      new_val = get_current_val(board, pkt_name, "RECEIVED_COUNT")

      if new_val > current_val
        return true
      else
        try_count = try_count + 1
      end

    end
    return false
  end

  def send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
    full_pkt_name = get_full_pkt_name(board, pkt_name)
    res = []
    if !@cmd_sender.send_with_recv_count_retry_check(board, cmd_name, cmd_params, pkt_name, wait_check_timeout,false,5)
      return res
    end
    # Send command, verify that response is received and is for this file ID
    # @cmd_sender.send_with_wait_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_check_timeout)

    # Get data to return, depending on format requested
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
