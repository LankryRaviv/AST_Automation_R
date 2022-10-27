load'Operations/FSW/UTIL_CmdSender.rb'

class ModuleFS
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end


  def get_last_entry(board, file_id)
    full_pkt_name = CmdSender.get_full_pkt_name(board, "FILE_INFO_RES")
    return tlm(@target, full_pkt_name, "LAST_ENTRY_ID")
  end

  def get_total_entries(board, file_id)
    full_pkt_name = CmdSender.get_full_pkt_name(board, "FILE_INFO_RES")
    return tlm(@target, full_pkt_name, "TOTAL_ENTRIES")
  end


  def file_info(board, file_id, converted=false, raw=false, wait_check_timeout=5)
    # Formulate cmd and tlm parameters
    cmd_name = "FSW_FILE_INFO"
    cmd_params = {
      "FILE_ID": file_id
    }
    pkt_name = "FILE_INFO_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def file_info_altstack(board, csp_id_target, file_id, converted=false, raw=false, wait_check_timeout=5)
    # Formulate cmd and tlm parameters
    cmd_name = "FSW_FILE_INFO_ALT_STACK"
    cmd_params = {
      "FILE_CSP_NODE_ALT_STACK": csp_id_target,
      "FILE_CSP_PORT_ALT_STACK": 10,
      "FILE_ID": file_id
    }
    pkt_name = "FILE_INFO_RES"
    return send_cmd_get_response_altstack(board, csp_id_target, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def wait_for_file_ok(board, file_id, timeout=10, poll_interval = 0.5)
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < timeout
      file_info_hash_converted, file_info_hash_raw = file_info(board, file_id, true, true)
      info_request_status = file_info_hash_converted["STATUS"]
      if info_request_status == 57
        # File still busy, that's OK
      elsif info_request_status == 0
        # File operation complete
        return file_info_hash_raw["FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
      else
        # Got some error
        return info_request_status
      end

      sleep(poll_interval)
    end
    # In case of a timeout
    return nil
  end


  def file_format(board, file_id, num_entries, entry_size, converted=false, raw=false, wait_check_timeout=5)
    # Formulate cmd and tlm parameters
    cmd_name = "FSW_FILE_FORMAT"
    cmd_params = {
      "FILE_ID": file_id,
      "STATUS": 0, # Unused
      "ENTRIES_QTY": num_entries,
      "ENTRY_SIZE": entry_size
    }
    pkt_name = "FILE_FORMAT_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end


  def file_check(board, file_id, aspect, start_entry, end_entry, converted=false, raw=false, wait_check_timeout=5)
    # Formulate cmd and tlm parameters
    cmd_name = "FSW_FILE_CHECK"
    cmd_params = {
      "FILE_ID": file_id,
      "STATUS": 0, #unused
      "ASPECT": aspect,
      "START_ENTRY_ID": start_entry,
      "END_ENTRY_ID": end_entry
    }
    pkt_name = "FILE_CHECK_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def file_check_altstack(board, csp_id_target, file_id, apspect, start_entry, end_entry, converted=false, raw=false, wait_check_timeout=5)
    # Formulate cmd and tlm parameters
    cmd_name = "FSW_FILE_CHECK_ALT_STACK"
    cmd_params = {
      "FILE_CSP_NODE_ALT_STACK": csp_id_target,
      "FILE_CSP_PORT_ALT_STACK": 10,
      "FILE_ID": file_id,
      "STATUS": 0, #unused,
      "ASPECT": aspect,
      "START_ENTRY_ID": start_entry,
      "END_ENTRY_ID": end_entry
    }
  end

  def file_clear(board, file_id, converted=false, raw=false, wait_check_timeout=5)
    # Formulate cmd and tlm parameters
    cmd_name = "FSW_FILE_CLEAR"
    cmd_params = {
      "FILE_ID": file_id,
      "STATUS": 0, #unused
    }
    pkt_name = "FILE_CLEAR_RES"
    return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end


  def file_upload(board, data_file_id, entry_id, block_length, data_block, no_hazardous_check = false)
    cmd_name = "FSW_FILE_UPLOAD"
    cmd_params = {
      "DATA_FILE_ID": data_file_id,
      "DATA_ENTRY_ID": entry_id,
      "DATA_OFFSET": 0, # fixed
      "DATA_LEN": block_length,
      "DATA_BLOCK": data_block
    }
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end

  def file_upload_slim(board, data_file_id, entry_id, block_length, data_block, no_hazardous_check = false)
    cmd_name = "FSW_FILE_UPLOAD_SLIM"
    cmd_params = {
      "DATA_FILE_ID": data_file_id,
      "DATA_ENTRY_ID": entry_id,
      "DATA_OFFSET": 0, # fixed
      "DATA_LEN_SLIM": block_length,
      "DATA_BLOCK_SLIM": data_block
    }
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end


  # If no start_entry or end_entry are provided, then download the entire file
  def file_download(board, file_id, start_entry=nil, end_entry=nil, first_offset=0, period_ms=100, duration_s=900, pkt_size=1754)
    # If no start_entry or end_entry provided, send file info
    if start_entry.nil? or end_entry.nil?
      file_info(board, file_id)
    end

    if start_entry.nil?
      start_entry = get_last_entry() - get_total_entries() + 1
    end

    if end_entry.nil?
      end_entry = get_last_entry()
    end

    # Formulate command
    cmd_name = "FSW_FILE_DWNLD_BY_RANGE"
    cmd_params = {
      "FILE_ID": file_id,
      "STATUS": 0, # Unused
      "START": start_entry,
      "END": end_entry,
      "FIRST_OFFSET": first_offset,
      "PERIOD_MS_DWNLD": period_ms,
      "DURATION_S": duration_s,
      "PKT_SIZE": pkt_size,
      "ALT_STACK_FLAG": 0
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  def file_download_altstack(board, csp_target_id, file_id, start_entry=nil, end_entry=nil, first_offset=0, period_ms=100, duration_s=900, pkt_size=1754)
    # If no start entry or end entry providd, send file info
    if start_entry.nil? or end_entry.nil?
      file_info_altstack(board, file_id)
    end

    if start_entry.nil?
      start_entry = get_last_entry() - get_total_entries() + 1
    end

    if end_entry.nil?
      end_entry = get_last_entry()
    end

    # Formulate command
    cmd_name = "FSW_FILE_DWNLD_BY_RANGE_ALT_STACK"
    cmd_params = {
      "FILE_CSP_NODE_ALT_STACK": csp_target_id,
      "FILE_CSP_PORT_ALT_STACK": 10,
      "FILE_ID": file_id,
      "STATUS": 0, # Unused
      "START": start_entry,
      "END": end_entry,
      "FIRST_OFFSET": first_offset,
      "PERIOD_MS_DWNLD": period_ms,
      "DURATION_S": duration_s,
      "PKT_SIZE": pkt_size,
      "ALT_STACK_FLAG": 1
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  # Unpack the bitfield into individual items
  def interpet_file_check_bitfield(aspect_str, entries_quantity, bitfield)

    blocks_quant = (entries_quantity / 8.0).ceil
    puts "blocks to check: #{blocks_quant}"

    incorrect_entries = []

    file_check_bitfield = bitfield[0..(blocks_quant - 1)]

    file_check_bitfield.each_with_index {|item, block_number|

      bit_field_reversed = item.to_s(2).split("")
      bit_field = bit_field_reversed.reverse()

      print "#{aspect_str} bitfield #{block_number}: "
      print bit_field.fill("0", bit_field.length...8)
      puts

      if block_number == blocks_quant - 1
        bit_field = bit_field[0..((entries_quantity % 8) - 1)]
      end

      block_incorrect = bit_field.each_with_index.map {|x, i| x == "0" ? (block_number * 8) + i + 1 : nil}.compact
      incorrect_entries.push(*block_incorrect)
    }

    return incorrect_entries
  end


  private

  def send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check = false)
    # Send command, verify that response is received and is for this file ID, try twice if necessary
    mnemonic = "RECEIVED_COUNT"
    comparison = ">"
    # Try once
    full_pkt_name = CmdSender.get_full_pkt_name(board, pkt_name)
    current_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)
    @cmd_sender.send_with_crc_poll(board, cmd_name, cmd_params, no_hazardous_check)
    wait(wait_check_timeout)
    new_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)
    if new_val == current_val
      # Try twice
      current_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)
      @cmd_sender.send_with_crc_poll(board, cmd_name, cmd_params, no_hazardous_check)
      wait(wait_check_timeout)
      new_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)
      if new_val == current_val
        # Try three times
        @cmd_sender.send_with_wait_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_check_timeout, no_hazardous_check)
      end
    end

    check_expression("tlm('#{@target} #{full_pkt_name} FILE_ID') == #{cmd_params[:FILE_ID]}")

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

  def send_cmd_get_response_altstack(board, target_id, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check = false)
    # Send command, verify that response is received and is for this file ID, try twice if necessary
    mnemonic = "RECEIVED_COUNT"
    comparison = ">"
    # Try once
    full_pkt_name = CmdSender.get_full_pkt_name(board, pkt_name)
    current_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)

    node_ids_to_str = ["", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "LVC_YP", "LVC_YM", "", "", "", "", "", "", "", "", "DPC_1", "DPC_2", "DPC_3", "DPC_4", "DPC_5"]
    target_board = node_ids_to_str[target_id]
    altstack_pkt_name = CmdSender.get_full_pkt_name(target_board, pkt_name)

    @cmd_sender.send_with_crc_poll(board, cmd_name, cmd_params, no_hazardous_check)
    wait(wait_check_timeout)
    new_val = @cmd_sender.get_current_val(target_board, pkt_name, mnemonic)
    if new_val == current_val
      # Try twice
      current_val = @cmd_sender.get_current_val(target_board, pkt_name, mnemonic)
      @cmd_sender.send_with_crc_poll(board, cmd_name, cmd_params, no_hazardous_check)
      wait(wait_check_timeout)
      new_val = @cmd_sender.get_current_val(target_board, pkt_name, mnemonic)
      if new_val == current_val
        # Try three times
        @cmd_sender.send_with_wait_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_check_timeout, no_hazardous_check)
      end
    end

    check_expression("tlm('#{@target} #{altstack_pkt_name} FILE_ID') == #{cmd_params[:FILE_ID]}")

    # Get data to return, depending on format requested
    res = []

    if converted
      res_pkt_converted = get_tlm_packet(@target, altstack_pkt_name, value_types = :CONVERTED)
      res.push(res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
    end

    if raw
      res_pkt_raw = get_tlm_packet(@target, altstack_pkt_name, value_types = :RAW)
      res.push(res_pkt_raw.map {|item| [item[0], item[1]]}.to_h)
    end
    return res
  end

end
