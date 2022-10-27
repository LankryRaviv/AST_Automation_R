load_utility('Operations/Micron/MICRON_FS_Download.rb')
micron_list = [4]
micron_list.each do |micron_id|
  MicronFileDownload.new(micron_id,17, "MIC_LSL","micron_maor_out","MICRON_FILE_DOWNLOAD_PACKET", 200, 100, 900 )
end