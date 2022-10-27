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
out_file.close
testResult = "FAIL"
firmware_version = version_hash['fw_version']
version_info_app = version_hash['post_sw_app']
version_info_bl1 = version_hash['post_sw_bl1']
version_info_bl2 = version_hash['post_sw_bl2']

#firmware_version = "5.8.99"
#version_info_app =  {APP_MAJOR: 5 ,APP_MINOR: 8, APP_PATCH: 99}
#version_info_bl1 = {BOOT_L1_MAJOR: 1 ,BOOT_L1_MINOR: 2, BOOT_L1_PATCH: 4}
#version_info_bl2 = {BOOT_L2_MAJOR: 1 ,BOOT_L2_MINOR: 5, BOOT_L2_PATCH: 7}
ring = ARGV[ARGV.length()-1].strip
uploaded = false
#power_on, ring_list = power_on_ring_to_ps2(ring, ARGV[1],false)

#if(power_on)
selected_ring = convert_string_ring_to_list(ring)
all_ring_is_uploaded = true
puts "################################## SW - UPLOAD - RINGS #########################################"
for micron_id in selected_ring

    #power on and send ping to micron 
    #ping_res = ping_target_traj_off(micron_id,ARGV[1])
    ##power = set_target_ps2_traj_ps2(micron_id,ARGV[1],true,true,false)
    
    #if(power)
        #list_of_linkage = get_micron_id_list(micron_id)
    uploaded = update_firmware(micron_id,ARGV[1],firmware_version,version_info_app, nil, false, version_info_bl1, version_info_bl2)
    all_ring_is_uploaded = all_ring_is_uploaded & uploaded
   # end
    
end
# if(power)
#     list_of_linkage = get_micron_id_list(micron_id)
#     uploaded = update_firmware(list_of_linkage[0],ARGV[1],firmware_version,version_info_app, list_of_linkage, true, version_info_bl1, version_info_bl2)
# end

#end

#power_off = power_off_ring(ring, ARGV[1])

# if(power && uploaded && power_off)
#     testResult = "PASS"
# end

puts "################################## FPGA - UPLOAD - RINGS #########################################"
fpga_version = version_hash['post_fpga']

uploaded = false
power_on, ring_list = power_on_ring_to_ps2(ring, ARGV[1])
if(power_on)
    uploaded = update_FPGA(ring_list[0], ARGV[1],fpga_version ,ring_list,true)
end
power_off = power_off_ring(ring, ARGV[1])

if(power_on && uploaded && power_off && all_ring_is_uploaded)
    testResult = "PASS"
end


out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!
