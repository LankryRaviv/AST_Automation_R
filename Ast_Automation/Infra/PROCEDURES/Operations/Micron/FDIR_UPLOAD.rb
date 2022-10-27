load('Operations/Micron/TrajectoryControlFunctions.rb')
require 'date'    

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

#power_on = power_on_ring_to_ps2(ring, apc, out_file, ARGV[1],false)

microns_list = get_specific_ring(ring)
if !ring.match?(/[[:alpha:]]/)
    microns_list = get_micron_id_list(ring.to_i).reverse()
end
status = fdir_upload(microns_list, ARGV[1], out_file)
#power_off = power_off_ring(ring, out_file, apc, ARGV[1])

if(status)
    testResult = "PASS"
end


out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
start_new_scriptrunner_message_log()
exit!
