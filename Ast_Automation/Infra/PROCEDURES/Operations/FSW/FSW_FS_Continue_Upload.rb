load 'Operations/FSW/FSW_FS.rb'

# pass upload_filename in with single quotes so slash direction is ignored


  ## ERROR CODES
  SUCCESS = 0
  EMPTY   = 55
  BUSY    = 57
def FSW_FS_Continue_Upload(entry_size, file_id, upload_filename, board, aspect="CRC", starting_entry=1)

  # Get file info
  fs = ModuleFS.new
  file_info_hash_converted, file_info_hash_raw = fs.file_info(board, file_id, true, true)

  # check status and file_status
  info_request_status = file_info_hash_converted["STATUS"]
  if info_request_status == SUCCESS
    puts "FILE_INFO_CMD status was #{info_request_status} - status ok."
  else
    puts "FILE_INFO_CMD status was #{info_request_status} - unknown error, aborting"
    abort
  end

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

  while starting_entry < entries_quantity

     # Check for missing entries
    file_check_hash_converted = fs.file_check(board, file_id, aspect, starting_entry, entries_quantity, true, false)[0]

    file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

    missing_entries = fs.interpet_file_check_bitfield("presence", entries_quantity, file_check_bitfield)

    if missing_entries.length > 0
      cmdSend = fs.method(:file_upload)
      entry_id = 1
      missing_entry = missing_entries[0] + starting_entry - 1
      end_of_entries = missing_entries[-1] + starting_entry - 1

      # iterate over fixed length records
        open(upload_filename) do |f|
          while data_block = f.read(entry_size)
          #puts data_block
            if entry_id == missing_entry
              puts "sending #{entry_id} of #{entries_quantity}"
              this_block_length = data_block.length

              cmdSend.call(board, file_id, entry_id, this_block_length, data_block)

              missing_entries.shift()

              wait(0.05)
            end

            entry_id += 1

            if missing_entries.length == 0 && end_of_entries < entries_quantity
              starting_entry = end_of_entries

              file_check_hash_converted = fs.file_check(board, file_id, aspect, starting_entry, entries_quantity, true, false)[0]

              file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

              missing_entries = fs.interpet_file_check_bitfield("presence", entries_quantity, file_check_bitfield)

              if missing_entries.length != 0
                end_of_entries = missing_entries[-1] + starting_entry - 1
              end
            end

            if missing_entries.length != 0
              missing_entry = missing_entries[0] + starting_entry - 1
            end

          end
        end
      end

      starting_entry = starting_entry + 1840

  end

   ## STEP 5 - FILE CHECK

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
		
		file_check_hash_converted = fs.file_check(board, file_id, 1, starting_entry, end_entry, true, false)[0]

		file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

		missing_entries = fs.interpet_file_check_bitfield("presence", (end_entry-starting_entry)+1, file_check_bitfield)
		if missing_entries.length == 0
			# only check crc if entries are all present
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
end



def FSW_FS_Continue_Upload_Slim(entry_size, file_id, upload_filename, board, aspect="CRC", starting_entry=1)

  # Get file info
  fs = ModuleFS.new
  file_info_hash_converted, file_info_hash_raw = fs.file_info(board, file_id, true, true)

  # check status and file_status
  info_request_status = file_info_hash_converted["STATUS"]
  if info_request_status == SUCCESS
    puts "FILE_INFO_CMD status was #{info_request_status} - status ok."
  else
    puts "FILE_INFO_CMD status was #{info_request_status} - unknown error, aborting"
    abort
  end

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

  while starting_entry < entries_quantity

     # Check for missing entries
    file_check_hash_converted = fs.file_check(board, file_id, aspect, starting_entry, entries_quantity, true, false)[0]

    file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

    missing_entries = fs.interpet_file_check_bitfield("presence", entries_quantity, file_check_bitfield)

    if missing_entries.length > 0
      cmdSend = fs.method(:file_upload_slim)
      entry_id = 1
      missing_entry = missing_entries[0] + starting_entry - 1
      end_of_entries = missing_entries[-1] + starting_entry - 1

      # iterate over fixed length records
        open(upload_filename) do |f|
          while data_block = f.read(entry_size)
          #puts data_block
            if entry_id == missing_entry
              puts "sending #{entry_id} of #{entries_quantity}"
              this_block_length = data_block.length

              cmdSend.call(board, file_id, entry_id, this_block_length, data_block)

              missing_entries.shift()

              wait(1)
            end

            entry_id += 1

            if missing_entries.length == 0 && end_of_entries < entries_quantity
              starting_entry = end_of_entries

              file_check_hash_converted = fs.file_check(board, file_id, aspect, starting_entry, entries_quantity, true, false)[0]

              file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

              missing_entries = fs.interpet_file_check_bitfield("presence", entries_quantity, file_check_bitfield)

              if missing_entries.length != 0
                end_of_entries = missing_entries[-1] + starting_entry - 1
              end
            end

            if missing_entries.length != 0
              missing_entry = missing_entries[0] + starting_entry - 1
            end

          end
        end
      end

      starting_entry = starting_entry + 1840

  end

   ## STEP 5 - FILE CHECK

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
		
		file_check_hash_converted = fs.file_check(board, file_id, 1, starting_entry, end_entry, true, false)[0]

		file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]

		missing_entries = fs.interpet_file_check_bitfield("presence", (end_entry-starting_entry)+1, file_check_bitfield)
		if missing_entries.length == 0
			# only check crc if entries are all present
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
end
