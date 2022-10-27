load'Operations/FSW/FSW_FS.rb' 

# pass upload_filename in with single quotes so slash direction is ignored

def FSW_FS_File_Check(entry_size, file_id, file_name, board, aspect="CRC")
  
  # calculate the amount of entries this file is split into
  file_size = File.size(file_name) # bytes
  entries_quantity = (file_size.to_f / entry_size.to_f).ceil
  
  ##
  ## STEP 1 - FILE INFO REQUEST + RESPONSE
  fs = ModuleFS.new
  file_info_hash_converted, file_info_hash_raw = fs.file_info(board, file_id, true, true)  

  # check presence
  file_check_hash_converted = fs.file_check(board, file_id, aspect, 1, entries_quantity, true, false)[0]
  file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]
  missing_entries = fs.interpet_file_check_bitfield("presence", entries_quantity, file_check_bitfield)

  if missing_entries.length == 0
    # only check crc if entries are all present
    file_check_hash_converted = fs.file_check(board, file_id, 1, 1, entries_quantity, true, false)[0]

    file_check_bitfield = file_check_hash_converted["ENTRY_BITFIELD"]
    incorrect_entries = fs.interpet_file_check_bitfield("crc", entries_quantity, file_check_bitfield)

    if incorrect_entries.length > 0
      print "Entries with invalid CRC in target #{incorrect_entries}"
      puts
    elsif missing_entries.length > 0
      print "Entries missing in target #{missing_entries}"
      puts
    else
      print "All checked entries are present and correct"
      puts
    end
  end
end
