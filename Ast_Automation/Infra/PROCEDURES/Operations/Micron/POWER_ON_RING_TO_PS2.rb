load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
require 'date'    

# Ring A 104,118,119,120,121,107,93,79,77,78,76,90
$micron_id_ring_A = [119, 120, 77,93, 118, 76]
$micron_id_ring_B = [136, 122, 108, 94, 80, 66, 61, 75, 89, 103, 117, 131]
$micron_id_ring_C = [151, 137, 123, 109, 95, 81, 67, 53, 46, 60, 74, 88, 102, 116, 130, 144]
$micron_id_ring_D = [152,138, 124, 110, 96, 82, 68, 54, 45, 59, 73,87,101, 115,129,143]
$micron_id_ring_E = [18,25,69,83,97,111,125,139,128,114,100,86,72,58]
$micron_id_ring_F = [4,11,186,193]

def power_on_ring_to_ps2(ring, out_file, run_id = "")
    selected_ring = micron_id_ring_A
    if(ring == "B")
        selected_ring = micron_id_ring_B
    end
    if(ring == "C")
        selected_ring = micron_id_ring_C
    end
    if(ring == "D")
        selected_ring = micron_id_ring_D
    end
    if(ring == "E")
        selected_ring = micron_id_ring_E
    end
    if(ring == "F")
        selected_ring = micron_id_ring_F
    end
    all_ring_is_on = true
    
    for micron_id in selected_ring
	
        #power on and send ping to micron 
        #ping_res = ping_target_traj_off(micron_id,ARGV[1])
        power = set_target_ps2_traj_ps2(micron_id, out_file, run_id,true,true,true)
        if(power)
            all_ring_is_on = false
        end
        
    end
    return all_ring_is_on
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
micron_id = ARGV[ARGV.length()-1].strip
power_on_ring_to_ps2(ring, out_file, run_id = "")
test_status = "PASS"

out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!
