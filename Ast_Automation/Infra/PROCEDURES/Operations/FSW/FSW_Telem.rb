load 'Operations/FSW/UTIL_CmdSender.rb'

class ModuleTelem
  def initialize
    @cmd_sender = CmdSender.new
  end

  def set_realtime(board, pkt_name=nil, destination_csp_id, freq)
    # Formulate parameters
    cmd_name = "FSW_SET_REALTIME"
    params = {
      "TLM_PACKET_NAME": pkt_name,
      "DESTINATION_CSP_ID": destination_csp_id,
      "FREQ": freq
    }
    # Send the command with check if not turning off
    if freq != 0
      @cmd_sender.send_with_wait_check(board, cmd_name, params, pkt_name, "RECEIVED_COUNT", ">", (1 / freq.ceil) + 2)
    else
      @cmd_sender.send(board, cmd_name, params)
    end
  end

  def set_temp_realtime(board, pkt_name=nil, destination_csp_id, freq, duration_in_ms)
    # Formulate parameters
    cmd_name = "FSW_SET_TEMPORARY_REALTIME"
    params = {
      "TLM_PACKET_NAME": pkt_name,
      "DESTINATION_CSP_ID": destination_csp_id,
      "FREQ": freq,
      "DURATION_MS": duration_in_ms
    }
    # Send the command
    @cmd_sender.send(board, cmd_name, params)
  end

  def send_instantaneous_tlm(board, pkt_name=nil, destination_csp_id)
    # Formulate parameters
    cmd_name = "FSW_INSTANTANEOUS_TELEM"
    params = {
      "TLM_PACKET_NAME": pkt_name,
      "DESTINATION_CSP_ID": destination_csp_id
    }
    @cmd_sender.send_with_recv_count_check(board, cmd_name, params, pkt_name)
  end

  # func: Sets the collection (collection and saving into the file system) for the specified Harvester task
  # params: harvester_id = 'HARVESTER_0_5_HZ' or 'HARVESTER_1_HZ'
  #         collection = 0 or 1
  def set_collection(board, harvester_id, collection, no_hazardous_check=false)
    # Formulate parameters
    cmd_name = "FSW_SET_COLLECTION"
    params = {
      "HARVESTER_ID": harvester_id,
      "COLLECTION": collection
    }
    @cmd_sender.send(board, cmd_name, params, no_hazardous_check)
  end


end