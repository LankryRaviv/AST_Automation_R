load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
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
image = 'app'
version_hash = get_micron_version()
firmwareVersion = version_hash['fw_version']
version = version_hash['pre_sw_app']
pathApp = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcApplication.bin"
micron = ControlMicron.new
#power_on = power_on_ring_to_ps2(ring, apc, out_file, ARGV[1],false)

microns_list = get_specific_ring(ring)
if !ring.match?(/[[:alpha:]]/)
    microns_list = get_micron_id_list(ring.to_i).reverse()
end
version = "#{version[:APP_MAJOR]}.#{version[:APP_MINOR]}.#{version[:APP_PATCH]}"
res, status = micron.upload_sw(microns_list, image, pathApp, version, ARGV[1], out_file)

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
