load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
firmwareVersion = "5.10.0"
version_info_app =  {APP_MAJOR: 5 ,APP_MINOR: 10, APP_PATCH: 0}
version_info_bl1 = {BOOT_L1_MAJOR: 1 ,BOOT_L1_MINOR: 2, BOOT_L1_PATCH: 4}
version_info_bl2 = {BOOT_L2_MAJOR: 1 ,BOOT_L2_MINOR: 5, BOOT_L2_PATCH: 7}
ring = "A"
uploaded = false
#power_on, ring_list = power_on_ring_to_ps2(ring, ARGV[1],false)

#if(power_on)
path = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcApplication.bin"
selected_ring = convert_string_ring_to_list(ring)
all_ring_is_uploaded = true
puts "################################## SW - UPLOAD - RINGS #########################################"
for micron_id in selected_ring

    #power on and send ping to micron 
    #ping_res = ping_target_traj_off(micron_id,ARGV[1])
    ##power = set_target_ps2_traj_ps2(micron_id,ARGV[1],true,true,false)
    
    #if(power)
        #list_of_linkage = get_micron_id_list(micron_id)
        resPowerUp,index = set_target_ps2_traj_ps2(micron_id.to_i,"",true,true,false)
        #fsRes = firmware_update("MIC_LSL", "app", path, version_info_app, file_id = 12, from_golden = 0, [104], broadcast_all: false, reboot: true, use_automations: true)
        uploaded = update_firmware(micron_id,"",firmwareVersion,version_info_app, nil, false, version_info_bl1, version_info_bl2)
        all_ring_is_uploaded = all_ring_is_uploaded & uploaded
   # end
    
end
puts "SW UPLOAD - #{all_ring_is_uploaded ? "PASS" : "FAIL"}"