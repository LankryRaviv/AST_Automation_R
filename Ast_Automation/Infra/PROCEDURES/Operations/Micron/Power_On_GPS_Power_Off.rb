load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')

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
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
micron_id = ARGV[ARGV.length()-1].strip
testResult = "FAIL"
limit_x = -2708964.3762239213
limit_y = -4255744.722879422
limit_z = 3889666.8870914383
fs = MICRON_MODULE.new 
#GPS
res_gps = gps_fast(micron_id.to_i, file_info, apc, limit_x, limit_y, limit_z, ARGV[1], nil, false)

if(res_gps)
    testResult = "PASS"
end

#write final status result

out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!