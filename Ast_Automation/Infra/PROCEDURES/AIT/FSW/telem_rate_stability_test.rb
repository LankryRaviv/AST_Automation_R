load_utility('Operations/FSW/FSW_Telem')
load_utility('Operations/FSW/UTIL_CmdSender')  


board = "APC_YP"
pkt_name = "FSW_TLM_APC"
realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')

cmd_sender = CmdSender.new
module_telem = ModuleTelem.new

# Step 1 - Turn on live telem and set period to zero, should not get any more telem
module_telem.set_realtime(board, pkt_name, realtime_destination, 0)

# Wait for any outstanding packets to clear out and check the current count
wait(1)
full_pkt_name = CmdSender.get_full_pkt_name(board, pkt_name)
start_recv = tlm("BW3", full_pkt_name, "RECEIVED_COUNT")
puts "Starting at #{start_recv}"

# Step 3 - Set period and wait for expected number of packets
freq = 10
duration_ms = 1 * 1000 * 60 # 1 minute
expected_packets = 0
# Calculate the number of anticipated packets we should receive
for num_added_pkts in 1...200 do
    if (duration_ms - (num_added_pkts * (1000/freq)) < (1000/freq))
        expected_packets = start_recv + num_added_pkts
        break
    end
end
module_telem.set_temp_realtime(board, pkt_name, destination, freq, duration_ms)
  
# Wait a little longer than needed to be sure
wait((duration_ms / 1000.0) + 10)
end_recv = tlm("BW3", full_pkt_name, "RECEIVED_COUNT")
puts "Expected #{expected_packets} received #{end_recv-start_recv}"
check_expression("end_recv == #{expected_packets}")