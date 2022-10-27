load("C:\\cosmos-fuHSL\\PROCEDURES\\Operations\\Micron\\Micron_FS.rb")

microns_to_upload = [120,104,96,95,94,93,78]
fs = MicronFS.new

entries_per_block = 80 * 8
entries_quantity = 1200
mic_fc_status_dict = microns_to_upload.map {|item| [item, []]}.to_h

pkt_id = subscribe_packet_data([["BW3", "MIC_LSL-MIC_FILE_CHECK_RES"]])
micron_id = "BROADCAST_ALL"
  starting_entry = 1
  while (starting_entry < entries_quantity)
    end_entry = starting_entry + entries_per_block - 1
    if (end_entry > entries_quantity)
      end_entry = entries_quantity
    end
      # check presence
      # broadcast file info to all microns
    fs.file_check("MIC_LSL", "BROADCAST_ALL", 25, 0, starting_entry, end_entry, false, false, wait_check_timeout=0.5)


      total_entries = (end_entry-starting_entry)+1
      # collect all responses from subscribe packet queue
    begin
      while true
        packet = get_packet(pkt_id, true)
        micron = packet.read('MICRON_ID')
        puts micron
        entry = {total_entries:total_entries, starting_entry:starting_entry, end_entry:end_entry,bitfield:packet.read("MIC_ENTRY_BITFIELD")}
        puts
        puts(mic_fc_status_dict[micron])        
        mic_fc_status_dict[micron].append(entry:[entry])
      end
    rescue => ThreadError
      puts "Continuing"
    end
    starting_entry = starting_entry + entries_per_block
  end
  
  puts(mic_fc_status_dict)
  
  mic_fc_status_dict.each do |key, entry|
    #puts entry
    puts key
    entry.each do |subentry|
      puts subentry
      final_entry = subentry[:entry]
      real_entry = final_entry[0]
      starting_entry = real_entry[:starting_entry]
      bitfield = real_entry[:bitfield] 
      end_entry = real_entry[:end_entry]
      puts("end_entry=#{end_entry} starting_entry=#{starting_entry}")     
      missing_entries = fs.interpet_file_check_bitfield("presence", (end_entry-starting_entry)+1, bitfield)

      if missing_entries.length == 0
        # only check crc if entries are all present
        

        puts("check was good")

      elsif missing_entries.length > 0 and retries == 0
        puts "Entries missing in target #{missing_entries} for Micron #{key}"
      end
    end
    puts("finished one entry")
  end