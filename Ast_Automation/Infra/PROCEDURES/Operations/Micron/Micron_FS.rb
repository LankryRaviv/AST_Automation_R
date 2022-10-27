load_utility('Operations/FSW/UTIL_CmdSender')

class MicronFS
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end

  def get_last_entry(link, file_id)
    full_pkt_name = CmdSender.get_full_pkt_name(link, "MIC_FILE_INFO_RES")
    return tlm(@target, full_pkt_name, "MIC_LAST_ENTRY_ID")
  end


  def get_total_entries(link, file_id)
    full_pkt_name = CmdSender.get_full_pkt_name(link, "MIC_FILE_INFO_RES")
    return tlm(@target, full_pkt_name, "MIC_TOTAL_ENTRIES")
  end

  def file_format_req(link, micron_id, file_id, entries_qty, entry_size)
    cmd_name = "MIC_FILE_FORMAT"
    params = {
      "MICRON_ID": micron_id,
      "FILE_ID": file_id,
      "STATUS": 0,
      "ENTRIES_QTY": entries_qty,
      "ENTRY_SIZE": entry_size
    }
    @cmd_sender.send(link, cmd_name, params)
  end

  def file_check(link, micron_id, file_id, aspect, start_entry, end_entry, converted=false, raw=false, wait_check_timeout=2)
    cmd_name = "MIC_FILE_CHECK"
    params = {
      "MICRON_ID": micron_id,
      "FILE_ID": file_id,
      "STATUS": 0,
      "ASPECT": aspect,
      "START_ENTRY_ID": start_entry,
      "END_ENTRY_ID": end_entry
    }
    pkt_name = "MIC_FILE_CHECK_RES"
    return send_cmd_get_response(link, cmd_name, params, pkt_name, converted, raw, wait_check_timeout)
  end

  def file_info(link, micron_id, file_id, converted=false, raw=false, wait_check_timeout=2)
    cmd_name = "MIC_FILE_INFO"
    params = {
      "MICRON_ID": micron_id,
      "FILE_ID": file_id
    }

    pkt_name = "MIC_FILE_INFO_RES"
    return send_cmd_get_response(link, cmd_name, params, pkt_name, converted, raw, wait_check_timeout)
  end

  def wait_for_file_ok(link, micron_id, file_id, timeout=10, poll_interval = 1)
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < timeout
      file_info_hash_converted, file_info_hash_raw = file_info(link, micron_id, file_id, true, true)
      info_request_status = file_info_hash_converted["MIC_STATUS"]
      if info_request_status == -4
        # File still busy, that's OK
      elsif info_request_status == 0
        # File operation complete
        return file_info_hash_raw["MIC_FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
      else
        # Got some error
        return nil
      end

      sleep(poll_interval)
    end
  end

  def file_format(link, micron_id, file_id, num_entries, entry_size, converted=false, raw=false, wait_check_timeout=2)
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_FILE_FORMAT"
    cmd_params = {
	    "MICRON_ID": micron_id,
      "FILE_ID": file_id,
      "STATUS": 0, # Unused
      "ENTRIES_QTY": num_entries,
      "ENTRY_SIZE": entry_size
    }
    pkt_name = "MIC_FILE_FORMAT_RES"
    return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def file_clear(link, micron_id, file_id, converted=false, raw=false, wait_check_timeout=2)
    # Formulate cmd and tlm parameters
    cmd_name = "MIC_FILE_CLEAR"
    cmd_params = {
      "MICRON_ID": micron_id,
      "FILE_ID": file_id,
      "STATUS": 0, #unused
    }
    pkt_name = "MIC_FILE_CLEAR_RES"
    return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
  end

  def file_upload(link, micron_id, data_file_id, entry_id, block_length, data_block, no_hazardous_check = false)
    cmd_name = "MIC_FILE_UPLOAD"
    cmd_params = {
	    "MICRON_ID": micron_id,
      "DATA_FILE_ID": data_file_id,
      "DATA_ENTRY_ID": entry_id,
      "DATA_OFFSET": 0, # fixed
      "DATA_LEN": block_length,
      "DATA_BLOCK": data_block
    }
    @cmd_sender.send(link, cmd_name, cmd_params, no_hazardous_check)
  end

  # If no start_entry or end_entry are provided, then download the entire file
  def file_download(link, micron_id, file_id, start_entry=nil, end_entry=nil, first_offset=0, period_ms=50, duration_s=900, pkt_size=240)
    # If no start_entry or end_entry provided, send file info
    if start_entry.nil? or end_entry.nil?
      file_info(link, micron_id, file_id)
    end

    if start_entry.nil?
      start_entry = get_last_entry() - get_total_entries() + 1
    end

    if end_entry.nil?
      end_entry = get_last_entry()
    end

    # Formulate command
    cmd_name = "MIC_FILE_DWNLD_BY_RANGE"
    cmd_params = {
      "MICRON_ID": micron_id,
      "FILE_ID": file_id,
      "STATUS": 0, # Unused
      "START": start_entry,
      "END": end_entry,
      "FIRST_OFFSET": first_offset,
      "PERIOD_MS_DWNLD": period_ms,
      "DURATION_S": duration_s,
      "PKT_SIZE": pkt_size
    }

    @cmd_sender.send(link, cmd_name, cmd_params)
  end

  # Unpack the bitfield into individual items
  def interpet_file_check_bitfield(aspect_str, entries_quantity, bitfield)

    blocks_quant = (entries_quantity / 8.0).ceil
    puts "blocks to check: #{blocks_quant}"

    incorrect_entries = []
    print_output = []

    file_check_bitfield = bitfield[0..(blocks_quant - 1)]

    file_check_bitfield.each_with_index {|item, block_number|

      bit_field_reversed = item.to_s(2).split("")
      bit_field = bit_field_reversed.reverse()

      #print "#{aspect_str} bitfield #{block_number}: "
      #print bit_field.fill("0", bit_field.length...8)
      #puts
      print_output.append("#{aspect_str} bitfield #{block_number}: ")
      print_output.append(bit_field.fill("0", bit_field.length...8).join(","))

      if block_number == blocks_quant - 1
        bit_field = bit_field[0..((entries_quantity % 8) - 1)]
      end

      block_incorrect = bit_field.each_with_index.map {|x, i| x == "0" ? (block_number * 8) + i + 1 : nil}.compact
      incorrect_entries.push(*block_incorrect)
    }
    puts(print_output.join("\n"))

    return incorrect_entries
  end

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
    res = []
    full_pkt_name = get_full_pkt_name(board, pkt_name)
    if !@cmd_sender.send_with_recv_count_retry_check(board, cmd_name, cmd_params, pkt_name, wait_check_timeout)
      return res
    end

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