load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load_utility('Operations/Micron/MICRON_Firmware_Update.rb')
load_utility('Operations/Micron/MICRON_FPGA_Update.rb')
load_utility('Operations/MICRON/MICRON_FS_Upload.rb')
load('Operations/MICRON/MICRON_FS.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/CPBF/CPBF_MODULE.rb')
load('Operations/Micron/turn_on_off_CPBF.rb')
load 'Operations/FSW/FSW_FWUPD.rb'
load 'Operations/FSW/FSW_CSP.rb'

version_hash = get_micron_version()
puts version_hash['golden_image_version']
firmwareVersionCorrupted = version_hash['main_image_corrupted']
version_info_app_corrupted = version_hash['main_image_corrupted_info']
#Read argument
#v1 = ARGV[0].to_i
#power_on_power_supply(78,"APC_YP")
#ret = get_micron_default_routing("MICRON_78","",true)
#ret = set_target_ps2_traj_ps2(78,"APC_YP","",true,true,true)
#ret = power_off_ring("A", "APC_YP")
#ret = power_on_ring_to_ps2('A','APC_YP', file_info)
file_info = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
microns_list = [119, 77,76,90,118,104,93,79,78]
fs = MICRON_MODULE.new
pc = fs.fpga_info("MIC_LSL", 119, "MAIN","DESCRIPTOR", converted=false, raw=false, wait_check_timeout=2)
ret = update_FPGA(119,file_info, "APC_YP","", microns_list, true)
update_FPGA(micron_id,file_info, "APC_YP","119_120_FPGA_UPDLOAD", microns_list = nil, true)
id = [107,78,104,90,77,119]
for i in  id
  power_off_power_supply(i,"APC_YP")
#power_on_power_supply(119)
sleep(1)
end

power_off_power_supply(107,"APC_YP")

ret = power_on_ring_to_ps2('A','APC_YP', file_info)
res = power_off_ring('A', file_info, 'APC_YP')

run_id = "123"
time = Time.new
micron_id = "MICRON_1"
mode = "REDUCED"

        write_to_log_file(run_id, time, "SET_POWER_MODE_PS2_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE", true, "BOOLEAN", "PASS", "BW3_COMP_SAFETY", file_info)
id = [107,78,104,90,77,119]
#for i in  id
 # power_on_power_supply(i,"APC_YP")
#power_on_power_supply(119)
sleep(1)
#end
#sleep(300)
#puts ret
firmwareVersion = "5.10.1" 
path = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcApplication.bin"
#fwupd = ModuleFWUPD.new
#file_size = fwupd.firmware_size(path)

version_info_bl1 = {BOOT_L1_MAJOR: 1, BOOT_L1_MINOR: 2, BOOT_L1_PATCH: 4}
version_info_bl2 = {BOOT_L2_MAJOR: 1, BOOT_L2_MINOR: 5, BOOT_L2_PATCH: 7}
version_info_app = {APP_MAJOR: 5, APP_MINOR: 10, APP_PATCH: 1}
pathBootl2 = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcBootloaderL2.bin"
pathBootl1 = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcBootloaderL1.bin"
path = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcApplication.bin"

#firmware_update("MIC_LSL", "bl1", pathBootl1, version_info_bl1, file_id = 12, from_golden = 0, [78], broadcast_all: false, reboot: false, use_automations: true)
#firmware_update("MIC_LSL", "bl2", pathBootl2, version_info_bl2, file_id = 12, from_golden = 0, [78], broadcast_all: false, reboot: false, use_automations: true)
res = firmware_update("MIC_LSL", "app", path, version_info_app, file_id = 12, from_golden = 0, [107,104,77,78,90, 119], broadcast_all: true, reboot: true, use_automations: true)
puts("Result from firmware update is: #{res}")
wait(300)
#puts "Result - #{set_target_ps2_traj_ps2(120,"APC_YP")}"
#pcdu = TurnOnOffCPBF.new
#pcdu.set_BFCP_XM("APC_YM", 1,true)
#sleep 300
#check_batteries_soc(104,"") 
get_micron_default_routing("MICRON_120","",true)
red = change_to_reduced_broadcast("", "APC_YP","", false,118)
puts red
power_off = power_off_ring("A", "APC_YP", "")
#power_on_power_supply(104,"APC_YP")
id = [107,78,120,93,104,90,77,119]
for i in  id
power_on_power_supply(i)
#power_on_power_supply(119)
sleep(1)
end
sleep 300
#check_batteries_soc(104,"")
micron_id = 104
limit_x = -2708964.3762239213
limit_y = -4255744.722879422
limit_z = 3889666.8870914383
retGPS = gps_fast(micron_id, limit_x, limit_y, limit_z)
puts "GPS FINAL RESULT = #{retGPS}"


#
#update_firmware(116,"","5.6.2",{APP_MAJOR: 5 ,APP_MINOR: 6, APP_PATCH: 2},  [161, 162, 35, 36, 130, 116, 102, 88, 74, 60, 67, 81, 95, 109, 123, 137, 35, 36],true, {BOOT_L1_MAJOR: 1 ,BOOT_L1_MINOR: 2, BOOT_L1_PATCH: 3},{BOOT_L2_MAJOR: 1 ,BOOT_L2_MINOR: 5, BOOT_L2_PATCH: 6})
#fsRes = false
#sleep(20)
#power, index = set_target_ps2_traj_ps2(118, "", true, true, true)
#fs = MICRON_MODULE.new 
#id_list = get_micron_id_list(104).reverse()


    #for id in id_list
       #micronID = "MICRON_" + 104.to_s
       #ret_cw_dl = cw_pd_ul_test(micronID,"")
       #if(!ret_cw_dl)
        #   all_cw_dl_pass = false
       #end
       # reboot = fs.sys_reboot("MIC_LSL", micronID)
      #  puts "SYS REBOOT - MICRON_ID = #{micronID}"
     #   sleep 15
    #end

#if(!power_off_power_supply(116))
 #   testResult = "FAIL"
#end

#if(power && all_cw_dl_pass)
 #   testResult = "PASS"
#end
#testResult = "FAIL"
#firmwareVersion = "5.6.2"
#firmwareVersion = "5.8.x"
#microns_list = [104]
#path = "C:\\Cosmos\\ATE\\FPGA_VERSION\\" + "00.0009.00" + "\\fpga_900_1.img"
#version_info_app = {APP_MAJOR: 5 ,APP_MINOR: 6, APP_PATCH: 2}
#version_info_bl2 = {BOOT_L2_MAJOR: 1 ,BOOT_L2_MINOR: 5, BOOT_L2_PATCH: 5}
#pathBootl2 = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcBootloaderL2.bin"
#   path = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcApplication.bin"
#firmwareStatus = "FAIL"
#pingRes = ping_target_routing_safety_traj_off(116,"", false)
#resSW = update_firmware(104,"",firmwareVersion,{APP_MAJOR: 5 ,APP_MINOR: 8, APP_PATCH: 'x'})
#resSW = update_firmware(116)

#resFPGA = update_FPGA(116,"","00.0009.00")
#fsResBootl2 = firmware_update("MIC_LSL", "bl2", pathBootl2, version_info_bl2, file_id = 12, from_golden = 0, microns_list,
                #broadcast_all: false, reboot: true, use_automations: true)
#fsRes = firmware_update("MIC_LSL", "app", path, version_info_app, file_id = 12, from_golden = 0, microns_list,
              #  broadcast_all: false, reboot: true, use_automations: true)
#fpgaRes = micron_fpga_update("MIC_LSL", path, "00.0009.00", microns_list, file_id: 25, entry_size: 1754, broadcast_all: false, reboot: true, do_file_check: false, use_automations: true)
#if(resSW)
 #  testResult = "PASS"
#end
#puts "TEST RESULT - #{testResult}"
#resPowerUp = set_ps2_and_operational_all_linkage(104,"",true)
#if(resPowerUp)
 #   fsRes = firmware_update("MIC_LSL", "app", path, version_info_app, file_id = 12, from_golden = 0, micron_id.to_i)
 #   if(fsRes)
#        firmwareStatus = "PASS"
#    end
#end
#resReboot = set_target_off_traj_off(104,"", true,true,false)
#if(resPowerUp && fsRes && resReboot)
#    testResult = "PASS"
#end
#puts "TEST RESULT - #{testResult}"
#puts "FSW STATUS - #{firmwareStatus}"
#puts "Result - #{ping_target_traj_off(118)}"
#puts "Result - #{ping_target_routing_traj_off(118)}"
#puts "Result - #{ping_target_routing_safety_traj_off(104)}"
#STDOUT.write 'Example To C# Printed Value\n\n'
