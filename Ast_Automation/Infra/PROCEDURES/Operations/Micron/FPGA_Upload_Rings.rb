load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load('Operations/Micron/get_micron_version.rb')

require 'date'    
# Ring A 104,118,119,120,121,107,93,79,77,78,76,90

version_hash = get_micron_version()

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
fpga_version = version_hash['post_fpga']
#fpga_version = "00.0009.00"
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip
uploaded = false
power_on = true
power_off = true

microns_list = get_specific_ring(ring)
if !ring.match?(/[[:alpha:]]/)
    microns_list = get_micron_id_list(ring.to_i).reverse()
end

uploaded = update_FPGA(microns_list[0], out_file, apc, ARGV[1], microns_list, true)

if(uploaded)
    testResult = "PASS"
end


out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
start_new_scriptrunner_message_log()
exit!
