load_utility('Operations/Micron/MICRON_MODULE.rb')

# Script will ping all microns over LSL, and return a list of responding microns
def micron_knock_knock()
  fs = MICRON_MODULE.new 

  pkt_id = subscribe_packet_data([["BW3", "MIC_LSL-MIC_CSP_PING_RES"]])
  wait(1)
  micron_id = "BROADCAST_ALL"

  fs.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=1, num_tries=1)

  wait(5)
  mic_response_list = []
  begin
    while true
      packet = get_packet(pkt_id, true)
      micron = packet.read('MICRON_ID')
      puts("Received response from Micron #{micron}")
      mic_response_list.append(micron)
    end
  rescue => threadError
    puts "Continuing"
  end

  prompt("List of Microns responding to ping: #{mic_response_list.join(", ")}")

  return mic_response_list
end

micron_knock_knock()
