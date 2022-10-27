load_utility('Operations/FSW/UTIL_CmdSender')
@cmd_sender = CmdSender.new
micron_id = 104
timeout = 3

# Send Micron command
mic_results = []
100.times do
  
  # Get initial packet count
  init_route_count = tlm("BW3", "APC_YM-FSW_TLM_APC", "CSP_ROUTE_MICRON_LSL_COUNT")
  init_packet_count = tlm("BW3", "MIC_LSL-MIC_CSP_PING_RES", "RECEIVED_COUNT")
  
  cmd_param = {"MICRON_ID": "MICRON_104"}
  @cmd_sender.send("MIC_LSL", "MIC_CSP_PING", cmd_param)
  wait(0.5)
  mic_results.append([["No Route Data"], ["No Packet Data"]])
  
  start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  while Process.clock_gettime(Process::CLOCK_MONOTONIC)-start_time < timeout
  
    if tlm("BW3", "APC_YM-FSW_TLM_APC", "CSP_ROUTE_MICRON_LSL_COUNT") > init_route_count
    
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      while Process.clock_gettime(Process::CLOCK_MONOTONIC)-start_time < timeout
        if tlm("BW3", "MIC_LSL-MIC_CSP_PING_RES", "RECEIVED_COUNT") > init_packet_count
          mic_results[-1] = [["Good CSP Count"], ["Good Packet Count"]]
          break
        else
          mic_results[-1] = [["Good CSP Count"], ["Bad Packet Count"]]
        end
       end
       break
    else
      mic_results[-1] = [["Bad CSP Count"], ["Bad Packet Count"]]
    end
  
  
  end
  
  puts mic_results[-1]
  
end
csp_err_count = 0
pkt_err_count = 0
mic_results.each do |row|
  #puts row[0]
  #puts row[1]
  if row[0] == ["Bad CSP Count"]
    csp_err_count += 1
  end
   
  if row[1] == ["Bad Packet Count"]
    pkt_err_count += 1
  end
end

puts mic_results
puts "Total bad CSP Counts #{csp_err_count}"
puts "Bad CSP Counts percentage " + (csp_err_count.to_f/100).to_s
puts "Total bad Packet Counts #{pkt_err_count}"
puts "Bad Packet Counts percentage " + (pkt_err_count.to_f/100).to_s
   
  