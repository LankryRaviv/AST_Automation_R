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
ring = ARGV[ARGV.length()-1].strip
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
#moveToOperational = false
testResult = "PASS"

microns_list = get_specific_ring(ring)
if !ring.match?(/[[:alpha:]]/)
    microns_list = get_micron_id_list(ring.to_i).reverse()
    if(!power_off_power_supply(ring.to_i,apc))
        testResult = "FAIL"
    end
    power_off = reboot_microns_in_chain(ring.to_i, out_file, true,"MIC_LSL",ARGV[1],1,true)
else
    power_off = power_off_ring(ring, out_file, apc, ARGV[1])
end


if(!power_off)
    testResult = "FAIL"
end
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
start_new_scriptrunner_message_log()
exit!