load_utility('Operations/FSW/UTIL_CmdSender.rb')

class MICRON_IMU_MTQ
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end
  
########################

  def enable_mtq(link, micron_id, mtq_on_off, on_time_a, on_time_b, converted=true, raw=true, wait_check_timeout=2, send_only=false)
    cmd_name = "MIC_AVI_ENABLE_MTQ"
    cmd_params = {
      "MICRON_ID": micron_id,
      "MTQ_ON_OFF": mtq_on_off,
      "MTQ_ON_TIME_A": on_time_a,
      "MTQ_ON_TIME_B": on_time_b
    }
    pkt_name = "MIC_AVI_ENABLE_MTQ_RES"
    if send_only
      @cmd_sender.send(link, cmd_name, cmd_params)
      return
    end
    return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def set_mtq_off(link, micron_id, converted=true, raw=true, wait_check_timeout=2)
    cmd_name = "MIC_AVI_ENABLE_MTQ"
    cmd_params = {
      "MICRON_ID": micron_id,
      "MTQ_ON_OFF": 0,
      "MTQ_ON_TIME_A": 0,
      "MTQ_ON_TIME_B": 0
    }
    pkt_name = "MIC_AVI_ENABLE_MTQ_RES"
    return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end
  
  def get_mtq_status(link, micron_id, converted=true, raw=true, wait_check_timeout=2)
    cmd_name = "MIC_AVI_GET_MTQ_STATUS"
    cmd_params = {
      "MICRON_ID": micron_id
    }
    pkt_name = "MIC_AVI_GET_MTQ_STATUS_RES"
    return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end



########################

  def send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
    mnemonic = "RECEIVED_COUNT"
    comparison = ">"
    full_pkt_name = CmdSender.get_full_pkt_name(board, pkt_name)

    # Send command, verify that response is received and is for this Micron ID
    @cmd_sender.send_with_wait_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_check_timeout)
    check_expression("tlm('#{@target} #{full_pkt_name} MICRON_ID') == #{cmd_params[:MICRON_ID]}")

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

end
