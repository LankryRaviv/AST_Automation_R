load_utility('Operations/MICRON/MICRON_FS.rb')

# pass upload_filename in with single quotes so slash direction is ignored

def MICRON_FS_Upload(entry_size, file_id, upload_filename, link, micron_list, max_entry_size, broadcast_all, do_file_check)
  microns = []
  if !micron_list.kind_of?(Array)
    microns_temp = micron_list
    microns.append(microns_temp)
  else
    microns.concat(micron_list)
  end

  err_count = 0
  err_arr = []
  failed_microns = []

  fs = MicronFS.new

  file_size = File.size(upload_filename) # bytes
  entries_quantity = (file_size.to_f / entry_size.to_f).ceil
  puts("Entries quantity is #{entries_quantity}")
  # first loop will do a file info request followed by starting the file format
  microns.each do |micron_id|

    ##
    ## STEP 1 - FILE INFO REQUEST + RESPONSE

    file_info_hash_converted, file_info_hash_raw = fs.file_info(link, micron_id, file_id, true, true)
    if file_info_hash_converted.nil?
      err_msg = "ERROR: Micron #{micron_id} did not respond to File Info command."
      puts(err_msg)
      err_arr.append(err_msg)
      failed_microns.append([micron_id, "Step 1 File Info"])
      err_count += 1
      next
    end

    # check status and file_status before continuing with step 2 (format request)
    info_request_status = file_info_hash_converted["MIC_STATUS"]
    if info_request_status == 0
      puts "FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - status ok. confirming FILE_INFO_CMD file_status is 0"

      info_request_file_status = file_info_hash_raw["MIC_FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
      if info_request_file_status == 0 || info_request_file_status == -2
        puts "MIC_FILE_INFO_CMD file_status for Micron #{micron_id} was #{info_request_file_status} - continuing with format request"

      else
        err_msg= "ERROR: MIC_FILE_INFO_CMD file_status for Micron #{micron_id} was #{info_request_file_status} - unknown error, continuing with next micron"
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 1 File Info"])
        err_count += 1
        next
      end

    else
      err_msg = "ERROR: FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - unknown error, continuing with next micron"
      puts(err_msg)
      err_arr.append(err_msg)
      failed_microns.append([micron_id, "Step 1 File Info"])
      err_count += 1
      next
    end
    # calculate available space
    info_request_sector_qty = file_info_hash_converted["MIC_SECTOR_QTY"]
    info_request_sector_size = file_info_hash_converted["MIC_SECTOR_SIZE"]

    available_space = info_request_sector_qty * info_request_sector_size

    # check the file will actually fit
    if file_size > available_space
      err_msg = "ERROR: file size [#{file_size}] larger than available space [#{available_space}] for Micron #{micron_id}, continuing with next micron"
      puts(err_msg)
      err_arr.append(err_msg)
      failed_microns.append([micron_id, "Step 2 Format request"])
      err_count += 1
      next
    end

    file_format_hash_converted = fs.file_format(link, micron_id, file_id, entries_quantity, entry_size, true, false)[0]
    if file_format_hash_converted.nil?
      err_msg = "ERROR: Micron #{micron_id} did not respond to File Format command."
      puts(err_msg)
      err_arr.append(err_msg)
      failed_microns.append([micron_id, "Step 2 Format request"])
      err_count += 1
      next
    end

    # check status before continuing with step 3 (polling for complete format)
    format_request_status = file_format_hash_converted["MIC_STATUS"]
    if format_request_status == 0
      puts "MIC_FILE_FORMAT status for Micron #{micron_id} was #{format_request_status} - continuing with file format"
    else
      err_msg = "ERROR: MIC_FILE_FORMAT status for Micron #{micron_id} was #{format_request_status} - unknown error, continuing with next micron"
      puts(err_msg)
      err_arr.append(err_msg)
      failed_microns.append([micron_id, "Step 2 Format request"])
      err_count += 1
    end
  end
  failed_microns.each do |micron_id|
    microns.delete_if{|x| x==micron_id[0]}
  end

  ## Second loop will verify format status
  ## STEP 3 - POLL FILE INFO
  format_timeout = 10 * 60
  poll_interval = 1
  microns.each do |micron_id|
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < format_timeout
      puts "polling file info"

      file_info_hash_converted, file_info_hash_raw = fs.file_info(link, micron_id, file_id, true, true)
      if file_info_hash_converted.nil?
        err_msg = "ERROR: Micron #{micron_id} did not respond to File Info command."
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 3 Poll file info"])
        err_count += 1
        next
      end

      # check status and file_status before continuing with step 4 (upload)
      info_request_status = file_info_hash_converted["MIC_STATUS"]
      if info_request_status == -4
        puts "FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - file busy formatting"

      elsif info_request_status == 0
        puts "FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - formatting complete. confirming file info request file status is 0"

        info_request_file_status = file_info_hash_raw["MIC_FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
        if [0, -2].include?(info_request_file_status.to_i)
          puts "FILE_INFO_CMD file_status for Micron #{micron_id} was #{info_request_file_status} - continuing with upload"
          break
        else
          err_msg =  "ERROR: FILE_INFO_CMD file_status for Micron #{micron_id} was #{info_request_file_status} - continuing with next micron"
          puts(err_msg)
          err_arr.append(err_msg)
          failed_microns.append([micron_id, "Step 3 Poll file info"])
          err_count += 1
        end

      else
        err_msg = "FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - unknown error, continuing with next micron"
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 3 Poll file info"])
        err_count += 1
      end

      sleep(poll_interval)
    end
  end
  failed_microns.each do |micron_id|
    microns.delete_if{|x| x==micron_id[0]}
  end


  ## 3rd loop will perform file upload
  ## STEP 4 - SPLIT AND SEND FILE

  if broadcast_all
    microns_to_upload = ["BROADCAST_ALL"]
  else
    microns_to_upload = microns.clone
  end
  microns_to_upload.each do |micron_id|
    cmdSend = fs.method(:file_upload)
    entry_id = 1

    # iterate over fixed length records
    disable_instrumentation do
      open(upload_filename) do |f|
        while data_block = f.read(entry_size)
          #   puts data_block
          puts "sending #{entry_id} of #{entries_quantity} for #{micron_id}"
          this_block_length = data_block.length

          cmdSend.call(link, micron_id, file_id, entry_id, this_block_length, data_block)

          entry_id += 1
          # wait the same amount as the pi
          wait(0.05)
        end
      end
    end
  end


  ## 4th loop will perform file check
  ## STEP 5 - FILE CHECK
  if !do_file_check
    return
  end
  retries = 2 # try x times
  retry_pause = 1 # wait x seconds between each try
  entries_per_block = max_entry_size * 8

  microns.each do |micron_id|
    retry_initial = retries
    starting_entry = 1

    while (starting_entry <= entries_quantity) && (retries >= 0)
      end_entry = starting_entry + entries_per_block - 1
      if (end_entry > entries_quantity)
        end_entry = entries_quantity
      end
      # check presence
      file_check_hash_converted = fs.file_check(link, micron_id, file_id, 0, starting_entry, end_entry, true, false, wait_check_timeout=0.5)[0]
      if file_check_hash_converted.nil?
        err_msg = "ERROR: Micron #{micron_id} did not respond to File Check command."
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 5 File check"])
        err_count += 1
        next
      end

      file_check_bitfield = file_check_hash_converted["MIC_ENTRY_BITFIELD"]

      missing_entries = fs.interpet_file_check_bitfield("presence", (end_entry-starting_entry)+1, file_check_bitfield)

      if missing_entries.length == 0
        # only check crc if entries are all present
        file_check_hash_converted = fs.file_check(link, micron_id, file_id, 1, starting_entry, end_entry, true, false, wait_check_timeout=0.5)[0]
        puts file_check_hash_converted
        file_check_bitfield = file_check_hash_converted["MIC_ENTRY_BITFIELD"]

        incorrect_entries = fs.interpet_file_check_bitfield("crc", (end_entry-starting_entry)+1, file_check_bitfield)

        if incorrect_entries.length > 0
          err_msg = "Entries with invalid CRC in target #{incorrect_entries} for Micron #{micron_id}"
          puts(err_msg)
          err_arr.append(err_msg)
          failed_microns.append([micron_id, "Step 5 File check"])
          err_count += 1
        else
          puts "All checked entries are present and correct for Micron #{micron_id}"
        end

      elsif missing_entries.length > 0 and retries > 0
        print "attempt #{retry_initial - retries + 1} of #{retry_initial}: Entries missing, waiting 5 seconds and checking again for Micron #{micron_id}"
        puts
        sleep(retry_pause)
        retries -= 1

      elsif missing_entries.length > 0 and retries == 0
        print "Entries missing in target #{missing_entries} for Micron #{micron_id}"
        puts
        break
      end
      starting_entry = starting_entry + entries_per_block
    end
  end

  failed_microns.each do |failed_micron|
    puts("Micron #{failed_micron[0]} installation failed: #{failed_micron[1]}")
  end

  mic_status_hash = get_status_hash(microns, failed_microns)
  if err_count > 0
      return false, mic_status_hash
  end
  return true, mic_status_hash

end

def get_status_hash(microns, failed_microns)
  mic_status_hash = Hash.new
  microns.each do |micron_id|
      mic_status_hash["MICRON_#{micron_id}".to_sym] = "PASS"
  end
  failed_microns.each do |micron_arr|
      mic_status_hash["MICRON_#{micron_arr[0]}".to_sym] = "FAILED at #{micron_arr[1]}"
  end
  return mic_status_hash
end
