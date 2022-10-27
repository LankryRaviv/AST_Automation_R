load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
require 'date'    

def ping_rings(ring, out_file, apc, run_id = "")
    ring_list = convert_string_ring_to_list(ring)
    all_pings_successed = true
    
    for micron_id in ring_list
	
        #power on and send ping to micron 
        #ping_res = ping_target_traj_off(micron_id,ARGV[1])
        ping_res = ping_target_routing_traj_off(micron_id, out_file, apc,run_id)
        # returned pass or fail
        if (!ping_res) 
            all_pings_successed = false
        end
    end
    return all_pings_successed

end

out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
#Read arguments
for data in ARGV
    out_file.write(data + " ")
end
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
out_file.puts(builded_string)
out_file.flush
testResult = "FAIL"
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip
all_pings_successed = ping_rings(ring, out_file, apc, ARGV[1])

if(all_pings_successed)
    testResult = "PASS"
end


out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!