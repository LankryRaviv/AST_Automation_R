load_utility('Operations/Micron/TrajectoryControlFunctions.rb')

out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
require 'date'
#Read arguments
for data in ARGV
    out_file.write(data + " ")
end
time = Time.now
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
out_file.puts(builded_string)
out_file.flush
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
micron_id = ARGV[ARGV.length()-1].strip

puts micron_id
testResult = "PASS"
result = ping_target_traj_off(micron_id.to_i, out_file, apc,ARGV[1])
if(result == false)
    testResult = "FAIL"
end

out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close

STDOUT.write '\n\n'
exit!