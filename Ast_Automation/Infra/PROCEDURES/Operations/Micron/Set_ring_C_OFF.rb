load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
require 'date'    
# Ring C 148, 149, 150, 151, 137, 123, 109, 95, 81, 67, 53, 52, 51, 50, 49, 48, 47, 46, 60, 74, 88, 102, 116, 130, 144, 145, 146, 147
micron_id_ring = [151, 137, 123, 109 95, 81, 67, 53, 46, 60, 74, 88, 102, 116, 130, 144]
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