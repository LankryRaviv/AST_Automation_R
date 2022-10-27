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
result = true
#result = set_target_ps2_traj_ps2(micron_id.to_i, apc, out_file, ARGV[1])
if(result)
    red = change_to_reduced_mode_microns_in_chain(micron_id_target, out_file, apc,ARGV[1], "MIC_LSL")
    #red = change_to_reduced_mode_microns_in_chain(micron_id.to_i,ARGV[1],"MIC_LSL")
end
if(!result || !red)
    testResult = "FAIL"
end

out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!