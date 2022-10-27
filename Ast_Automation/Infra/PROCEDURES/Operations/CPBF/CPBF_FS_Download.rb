 load('Operations/FSW/FSW_FS.rb')

## ERROR CODES
SUCCESS = 0
EMPTY = 55

class FileDownload
  def initialize(
      file_id,board, filename, packet_name, packet_size=186, packet_delay_ms=100, durationS=900,
      start_entry=1, end_entry=18,
      sub_q_size=5000,
      first_offset=0,
      output_dir=Cosmos::USERPATH,
      target="BW3")
    @fs = ModuleFS.new

    @file_id = file_id
    @packet_name = packet_name
    @packet_size = packet_size
    @packet_delay_ms = packet_delay_ms
    @durationS = durationS 
    @board = board
    @sub_q_size = sub_q_size
    @filename = filename
    @first_offset = first_offset
    @output_dir = output_dir
    @target = target # this isnt being passed through to ModuleFS, but should be

    @start_entry = start_entry
    @end_entry = end_entry
    @total_entries = nil

    @non_telem_sub_id = nil
    @dl_info_sub_id = nil

    @file_entry_errors_hash = {
      "incomplete" => 0,
      "error" => 0,
      "integrity" => 0,
      "other" => 0
    }
    @file_collate_hash = {}
  end

  def process_download
    # Step 1. Check file info, get download params
    get_file_info()

    # Step 2. Subscribe, start download, collate, unsubscribe
    run_file_download()

    # Step 3. Check file entries and create file
    create_file()

  end

  def get_file_info
    file_info_hash_converted, file_info_hash_raw = @fs.file_info(@board, @file_id, true, true)

    # check status and file_status before continuing with step 2 (format request)
    info_request_status = file_info_hash_converted["STATUS"]
    if info_request_status == SUCCESS
      puts "FILE_INFO_CMD status was #{info_request_status} - status ok. confirming FILE_INFO_CMD file_status is 0"

      info_request_file_status = file_info_hash_raw["FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
      if info_request_file_status == SUCCESS || info_request_file_status == EMPTY
        puts "FILE_INFO_CMD file_status was #{info_request_file_status} - continuing"

      else
        puts "FILE_INFO_CMD file_status was #{info_request_file_status} - unknown error, aborting"
        abort
      end

    else
      puts "FILE_INFO_CMD status was #{info_request_status} - unknown error, aborting"
      abort
    end

    @start_entry, @end_entry, @total_entries = calculate_start_end_total_entry(
      file_info_hash_converted['LAST_ENTRY_ID'],
      file_info_hash_converted['TOTAL_ENTRIES'])

  end

  def calculate_start_end_total_entry(in_last_entry_id, in_total_entries)
    # doesnt yet account for complex case, rollover etc

    out_start_entry = nil
    out_end_entry = nil
    out_total_entries = nil

    if (@start_entry && @end_entry)
      # both provided
      out_start_entry = @start_entry
      out_end_entry = @end_entry

    elsif (@start_entry && !@end_entry)
      # only start provided
      out_start_entry = @start_entry
      out_end_entry = in_last_entry_id

    elsif (!@start_entry && @end_entry)
      # only end provided
      out_start_entry = in_last_entry_id - in_total_entries + 1
      out_end_entry = @end_entry

    else
      # neither provided
      out_start_entry = in_last_entry_id - in_total_entries + 1
      out_end_entry = in_last_entry_id

    end

    out_total_entries = out_end_entry - out_start_entry + 1 # start and end inclusive

    return out_start_entry, out_end_entry, out_total_entries
  end

  def run_file_download
    @non_telem_sub_id = subscribe_packet(@packet_name)
    @dl_info_sub_id = subscribe_packet("DOWNLOAD_INFO_MESSAGE")

    @fs.file_download(
      @board, # board
      @file_id, # file_id
      @start_entry, #  start_entry
      @end_entry, # end_entry
      @first_offset, # first_offset
      @packet_delay_ms, #delay between packets
      @durationS, #duration of total
      @packet_size) #packet size 

    # sleep(5)
    wait_dl_info_termination()

    collate_payload()

    unsubscribe_packet_data(@non_telem_sub_id)
    unsubscribe_packet_data(@dl_info_sub_id)

  end

  def subscribe_packet(packet)
    subscribe_packet_data([[@target, "#{@board}-#{packet}"]], @sub_q_size)
  end

  def wait_dl_info_termination
    while true # change to timeout? but should always get termination..?
      this_packet = get_packet(@dl_info_sub_id)

      case this_packet.read('DOWNLOAD_INFO_CODE')
      when 'DL_IN_PROGRESS'
        puts "DL_IN_PROGRESS received."
      when 'FILE_ENTRY_INCOMPLETE'
        # FILE_ENTRY_INCOMPLETE
        puts "INCOMPLETE received"
        @file_entry_errors_hash["incomplete"] += 1
      when 'FILE_ENTRY_ERROR'
        # FILE_ENTRY_ERROR
        puts "FILE_ENTRY_ERROR received"
        @file_entry_errors_hash["error"] += 1
      when 'FILE_ENTRY_INTEGRITY_FAIL'
         # FILE_ENTRY_INTEGRITY_FAIL
         puts "FILE_ENTRY_INTEGRITY_FAIL received"
         @file_entry_errors_hash["integrity"] += 1
      when 'DL_TERMINATE'
        # DL_TERMINATE
        break
      when 'DL_SUMMARY'
         puts "File download complete."
        # DL_TERMINATE
        break
      else
        # other error
        puts "Other error was #{this_packet.read('DOWNLOAD_INFO_CODE')}"
        @file_entry_errors_hash["other"] += 1
      end
    end
  end

  def collate_payload
    loop_count = @total_entries - @file_entry_errors_hash.values.sum
    seq = 0
    loop_count.times {
      this_packet = get_packet(@non_telem_sub_id)
      #seq = this_packet.read('NON_TELEM_SEQ_NUM')
      actual_size = this_packet.read('LENGTH')-8-2 # 8 for Csp header, 2 for length
      @file_collate_hash[seq] = this_packet.read('NON_TELEM_PAYLOAD')[0..actual_size]
      #@file_collate_hash[seq] = this_packet.read('NON_TELEM_PAYLOAD')[0..1753]

      #@file_collate_hash[seq] = payload
      seq = seq+1
    }
  end

  def create_file
    if @file_entry_errors_hash.values.any? { |n| n > 0 }
      p "File entry errors found: Incomplete: #{@file_entry_errors_hash["incomplete"]}, Error: #{@file_entry_errors_hash["incomplete"]}, CRC: #{@file_entry_errors_hash["integrity"]}"
    end

    # ask user if they want the file anyway?

    out_filename = File.join(@output_dir, @filename)
    p "Creating file: #{out_filename}"

    File.open(out_filename, 'wb') {|f| f.write(@file_collate_hash.values.join()) }
  end

end
#FileDownload.new(25, "APC_YP","out","MAIN_IMAGE_DOWNLOAD", 1754, 10, 900)
#FileDownload.new(4, "CPBF","out","MAIN_IMAGE_DOWNLOAD", 1754, 10, 900)
#FileDownload.new(8, "CPBF","out","MAIN_IMAGE_DOWNLOAD", 1754, 10, 900)
#FileDownload.new(25, "CPBF","out","MAIN_IMAGE_DOWNLOAD", 1754, 10, 900)