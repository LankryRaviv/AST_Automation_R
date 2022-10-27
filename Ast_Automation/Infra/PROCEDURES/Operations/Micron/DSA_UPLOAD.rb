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

run_id = ARGV[1]

folder_path = "C:\\cosmos\\ATE\\OutputDSA\\"
testResult = "FAIL"
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip

mcf_micron_id_filename = "C:\\cosmos\\ATE\\MicronSNID.csv"
microns_list = get_specific_ring(ring)
if !ring.match?(/[[:alpha:]]/)
    microns_list = get_micron_id_list(ring.to_i).reverse()
end

result = Array.new(microns_list.length){false}
microns_list.each_with_index do |micron, i|
    result[i] = dsa_upload(micron, run_id, out_file, folder_path, mcf_micron_id_filename)
end

#power_off = power_off_ring(ring, out_file, apc, ARGV[1])

if(result.all?)
    testResult = "PASS"
end


out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
start_new_scriptrunner_message_log()
exit!




