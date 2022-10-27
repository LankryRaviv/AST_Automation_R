load_utility('Operations/CPBF/CPBF_MODULE.rb')
load_utility('Operations/CPBF/CPBF_FS_Download.rb')


def download_logfiles()
    cpbf = ModuleCPBF.new

    # step 1 - get list of log files
    res_hash = cpbf.cpbf_get_loglist(1)[0]

    msg_arr = []
    res_hash.each do |tlm, value|
        msg_arr.append("#{tlm}:#{value}") if tlm.include?'LOGFILE'
    end

    #step 2 - user selects log file
    logfile = vertical_message_box("Select a logfile to download.", *msg_arr).split(':')[1].chomp

    # step 3 - prepare logfile
    res_hash = cpbf.cpbf_prepare_logdl(logfile, 3)[0]
    if res_hash['RESPONSE_CODE'] == 0
        puts("CPBF prepare logdl successful for #{logfile}")
    else
        puts("CPBF prepare logdl not successful for #{logfile}. Result code is #{res_hash['RESPONSE_CODE']}")
        return
    end
	wait(5)

    # step 4 - get file info for end entry
    res_hash = cpbf.cpbf_file_info(8, true, false)[0]
    end_entry = res_hash['LAST_ENTRY_ID']

    file_str = "CPBF_Logfile_#{logfile}_#{Time.now.strftime('%Y%m%d-%H%H%S')}.txt"
  
    # step 4 - initiate file download
    cpbf_dl = FileDownload.new(file_id = 8,board = 'CPBF',filename = file_str,packet_name = 'MAIN_IMAGE_DOWNLOAD',packet_size = 1754,packet_delay_ms = 50,durationS=900,start_entry = 1,end_entry = end_entry)

    cpbf_dl.process_download

    puts("File Download completed.  View logfile at: #{file_str}.")
end
