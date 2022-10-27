load('Operations/FSW/FSW_FS.rb')

# pass upload_filename in with single quotes so slash direction is ignored


  ## ERROR CODES
  SUCCESS = 0
  EMPTY   = 55
  BUSY    = 57
def FSW_FS_Upload(entry_size, file_id, upload_filename, board, aspect="CRC", test_break=0)


  ##
  ## STEP 1 - FILE INFO REQUEST + RESPONSE
  fs = ModuleFS.new
  file_info_hash_converted, file_info_hash_raw = fs.file_info(board, file_id, true, true)

  # check status and file_status before continuing with step 2 (format request)
  info_request_status = file_info_hash_converted["STATUS"]
  if info_request_status == SUCCESS
    puts "FILE_INFO_CMD status was #{info_request_status} - status ok. confirming FILE_INFO_CMD file_status is 0"

    info_request_file_status = file_info_hash_raw["FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
    if info_request_file_status == SUCCESS || info_request_file_status == EMPTY
      puts "FILE_INFO_CMD file_status was #{info_request_file_status} - continuing with format request"

    else
      puts "FILE_INFO_CMD file_status was #{info_request_file_status} - unknown error, aborting"
      abort
    end

  else
    puts "FILE_INFO_CMD status was #{info_request_status} - unknown error, aborting"
    abort
  end


  ##
  ## STEP 2 - FORMAT REQUEST + RESPONSE

  # calculate available space
  info_request_sector_qty = file_info_hash_converted["SECTOR_QTY"]
  info_request_sector_size = file_info_hash_converted["SECTOR_SIZE"]

  available_space = info_request_sector_qty * info_request_sector_size

  # check the file will actually fit
  file_size = File.size(upload_filename) # bytes

  if file_size > available_space
    puts "file size [#{file_size}] larger than available space [#{available_space}], aborting"
    abort
  end

  # calculate the amount of entries this file needs to be split into

  entries_quantity = (file_size.to_f / entry_size.to_f).ceil
  puts entries_quantity
  file_format_hash_converted = fs.file_format(board, file_id, entries_quantity, entry_size, true, false)[0]

  # check status before continuing with step 3 (polling for complete format)
  format_request_status = file_format_hash_converted["STATUS"]
  if format_request_status == SUCCESS
    puts "FILE_FORMAT status was #{format_request_status} - continuing with file format"
  else
    puts "FILE_FORMAT status was #{format_request_status} - unknown error, aborting"
    abort
  end

 
 ##
  ## STEP 3 - POLL FILE INFO
  format_timeout = 5 * 60
  poll_interval = 1
  starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  status = false
  while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < format_timeout
    puts "polling file info"

    file_info_hash_converted, file_info_hash_raw = fs.file_info(board, file_id, true, true)

    # check status and file_status before continuing with step 4 (upload)
    info_request_status = file_info_hash_converted["STATUS"]
    if info_request_status == BUSY
      puts "FILE_INFO_CMD status was #{info_request_status} - file busy formatting"

    elsif info_request_status == SUCCESS
      puts "FILE_INFO_CMD status was #{info_request_status} - formatting complete. confirming file info request file status is 0"
      status =  true
      break
    
    elsif info_request_status == EMPTY
      puts "FILE_INFO_CMD status was #{info_request_status} - file empty. confirming file info request file status is 0"

      info_request_file_status = file_info_hash_raw["FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
      if info_request_file_status == SUCCESS
        status = true
        puts "FILE_INFO_CMD file_status was #{info_request_file_status} - continuing with upload"
        break
      else
        puts "FILE_INFO_CMD file_status was #{info_request_file_status} - aborting"
        break
      end
    else
      puts "FILE_INFO_CMD status was #{info_request_status} - unknown error, aborting"
      break
    end

    sleep(poll_interval)
  end

  if status != true 
    puts "formatting failed"
    check_expression("#{status} == true") 
  end

wait(2)
  ##
  ## STEP 4 - SPLIT AND SEND FILE
  cmdSend = fs.method(:file_upload)
  entry_id = 1

  # iterate over fixed length records
#   disable_instrumentation do 
  open(upload_filename) do |f|
    while data_block = f.read(entry_size)
    #   puts data_block
     #puts "sending #{entry_id} of #{entries_quantity}"
      this_block_length = data_block.length
      
      cmdSend.call(board, file_id, entry_id, this_block_length, data_block)
      
      entry_id += 1
      # wait the same amount as the pi
      wait(0.05) #10msec

      #only for testrunner test
      break if test_break == "TEST" and entry_id == 500
      #
    end

   # end
  end

  ##
  ## STEP 5 - FILE CHECK
wait(5)
	retries = 1 # try x times
	retry_pause = 5 # wait x seconds between each try
	retry_initial = retries
	starting_entry = 1
	entries_per_block = 230 * 8
	
	while starting_entry < entries_quantity
		end_entry = starting_entry + entries_per_block - 1
		if (end_entry > entries_quantity) 
			end_entry = entries_quantity
		end
		
		#file_check_hash_converted = fs.file_check(board, file_id, 1, starting_entry, end_entry, true, false)[0]

		#file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

		#missing_entries = fs.interpet_file_check_bitfield("presence", (end_entry-starting_entry)+1, file_check_bitfield)
		if (1) #missing_entries.length == 0
			# only check crc if entries are all present
                             #wait(1)
			file_check_hash_converted = fs.file_check(board, file_id, 1, starting_entry, end_entry, true, false)[0]

			file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

			incorrect_entries = fs.interpet_file_check_bitfield("crc", (end_entry-starting_entry)+1, file_check_bitfield)

			if incorrect_entries.length > 0
			  print "Entries with invalid CRC in target #{incorrect_entries}"
			  puts
			  break
			else
			  print "All checked entries are present and correct"
			  puts
			end
		else
			print "Entries with invalid CRC in target #{incorrect_entries}"
			puts
			break
		end
		starting_entry = starting_entry + entries_per_block
	end
	
  # while starting_entry < entries_quantity 
    # #file_check will only check a max 1840 entries at a time so a loop is required for larger entry quantities.
    # while retries >= 0

      # file_check_hash_converted = fs.file_check(board, file_id, aspect, starting_entry, entries_per_block, true, false)[0]

      # file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

      # missing_entries = fs.interpet_file_check_bitfield("presence", entries_per_block, file_check_bitfield)
    
      # if missing_entries.length == 0
        # # only check crc if entries are all present
        # file_check_hash_converted = fs.file_check(board, file_id, 1, starting_entry, entries_per_block, true, false)[0]

        # file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

        # incorrect_entries = fs.interpet_file_check_bitfield("crc", entries_per_block, file_check_bitfield)

        # if incorrect_entries.length > 0
          # print "Entries with invalid CRC in target #{incorrect_entries}"
          # puts
        # else
          # print "All checked entries are present and correct"
          # puts
        # end
        # break

      # elsif missing_entries.length > 0 and retries > 0
        # print "attempt #{retry_initial - retries + 1} of #{retry_initial}: Entries missing, waiting 5 seconds and checking again"
        # puts
        # sleep(retry_pause)
        # retries -= 1

      # elsif missing_entries.length > 0 and retries == 0
        # print "Entries missing in target #{missing_entries}"
        # puts
        # break
      # end
    # end
     
    # starting_entry = starting_entry + 1840

  # end
end
# CPBF Software upload
#FSW_FS_Upload(1754, 4, "C:\\Users\\CosmosUser1\\Downloads\\CPBF_0p85_0p95_0p51\\cpbf_app_target", "CPBF", aspect="CRC", test_break=0)
#FSW_FS_Upload(1754, 1, "C:\\Users\\CosmosUser1\\Downloads\\CPBF_0p85_0p95_0p51\\BOOT.zip", "CPBF", aspect="CRC", test_break=0)
#FSW_FS_Upload(1754, 5, "C:\\Users\\CosmosUser1\\Downloads\\CPBF_0p85_0p95_0p51\\vup_fpga.zip", "CPBF", aspect="CRC", test_break=0)
# Micron Software upload
#FSW_FS_Upload(1754, 12, "C:\\Users\\labuser16\\Documents\\satish\\micron_testing\\uc_cpu_app", "CPBF", aspect="CRC", test_break=0)
# Micron Firmware upload
#FSW_FS_Upload(1754, 9, "C:\\Users\\labuser16\\Documents\\satish\\micron_testing\\uc_fpga.bin", "CPBF", aspect="CRC", test_break=0)