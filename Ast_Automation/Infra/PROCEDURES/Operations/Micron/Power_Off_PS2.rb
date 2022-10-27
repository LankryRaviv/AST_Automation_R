load_utility('Operations/Micron/TrajectoryControlFunctions.rb')

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
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
#moveToOperational = false
testResult = "PASS"
if(!power_off_power_supply(micron_id.to_i,apc))
    testResult = "FAIL"
end
result = reboot_microns_in_chain(micron_id.to_i, out_file, true,"MIC_LSL",ARGV[1],1,true)
if(result == "FAIL")
    testResult = "FAIL"
end

out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!