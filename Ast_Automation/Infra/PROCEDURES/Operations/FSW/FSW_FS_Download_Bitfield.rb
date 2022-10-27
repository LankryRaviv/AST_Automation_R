load 'Operations/FSW/FSW_FS.rb'

## ERROR CODES
SUCCESS = 0
EMPTY = 55

def file_download_by_bitfield(board, file_id, start_entry, end_entry, period_ms, duration_s, pkt_size, alt_stack_flag, packet_interval)
  
  fs = ModuleFS.new
  total_entries = end_entry - start_entry
  
  if total_entries < 1520
    puts("Entry range must be at least 1520 entries")
    return false
  end

  # general issue:
  # # of entries must be 1520.  If there is a remainder, how can this be downloaded?
  # Maybe create another bitfield command with a smaller range...say 60 aka 1 minute.  minimum
  # selectable time-range would be 1 minute
  # still would be many commands. Maybe split 1520/4, so three sizes - full=1520, medium = 380, small = 60
  total_loops = (total_entries / 1520).to_i
  remainder = total_entries % 1520

  total_loops.times do |i|
    start_entry += 1520 * i
    curr_end = start_entry + 1519
    res = get_dl_bitfield(packet_interval)
    download_bitfield = res[0]
    puts(download_bitfield)
    out_val = res[1]
    puts(out_val)
    #send command
    fs.file_download_by_bitfield(board, file_id, start_entry, curr_end)


  end
  start_entry


end

def get_dl_bitfield(packet_interval)
  # build up bit string
  # always grab the first bit
  disable_instrumentation do
    @bin_str = '0'
    (1..1519).each do |i|
      if i % packet_interval == 0
        @bin_str += '0'
      else
        @bin_str += '1'
      end
    end
  end
  puts(@bin_str)
  
  disable_instrumentation do
    @out_arr = []
    StringIO.open(@bin_str) do |strio|
      strio.each_line(8) do |chars|
        # @out_arr.append(chars.reverse.to_i(2))
        @out_arr.append(chars.to_i(2)) 
        # puts(chars)
        
      end
    end
  end
  # may need to reverse out array
  @out_hex = ''
  @out_arr.reverse
  @out_arr.each do |val|
    @out_hex += val.to_s(16)
  end
  return [@out_arr, @out_hex]
end