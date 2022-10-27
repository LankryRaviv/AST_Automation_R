load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
require 'date'    
# Ring B 134, 135, 136, 122, 108, 94, 80, 66, 65, 64, 63, 62, 61, 75, 89, 103, 117, 131, 132, 133
micron_id_ring = [136, 122, 108, 94, 80, 66, 61, 75, 89, 103, 117, 131]
out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
#Read arguments
for data in ARGV
    out_file.write(data + " ")
end
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
out_file.puts(builded_string)
out_file.close
micron_id = ARGV[ARGV.length()-1].strip

test_status = "PASS"

for micron_id in micron_id_ring
	
	res = set_target_off_traj_off(micron_id,ARGV[1])
	# returned pass or fail
	if (res == true) 
		puts "The Micron " + micron_id.to_s + " ping Pass"
	else 
		puts "The Micron" + micron_id.to_s + " ping Failed"
		test_status = "FAIL"
	end
end
out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write 'Example To C# Printed Value\n\n'
puts test_status
exit!