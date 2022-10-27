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
# version_info_bl1 = {BOOT_L1_MAJOR: 1 ,BOOT_L1_MINOR: 2, BOOT_L1_PATCH: 4}
# version_info_bl2 = {BOOT_L2_MAJOR: 1 ,BOOT_L2_MINOR: 5, BOOT_L2_PATCH: 5}
# version_info_app = {APP_MAJOR: 5 ,APP_MINOR: 6, APP_PATCH: 2}
# firmwareVersion = "5.8.99"

testResult = "FAIL"
#Firmware upload
retRes = update_firmware(micron_id.to_i, apc, out_file, ARGV[1])
if(retRes)
    testResult = "PASS"
end

#write final status result
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!