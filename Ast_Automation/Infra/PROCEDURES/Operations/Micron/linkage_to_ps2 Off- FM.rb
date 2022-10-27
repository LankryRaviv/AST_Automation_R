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

file_info = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
micron_id = 93
apc = "APC_YM"
######## POWER ON TRAJ #######
#ret_ps2 = set_target_ps2_traj_ps2(micron_id, apc, file_info, "", true, true, true)

#puts "Move to PS2 - #{ret_ps2[0]}"

######## POWER OFF TRAJ #######
if(!power_off_power_supply(micron_id.to_i,apc))
    testResult = "FAIL"
end
result = reboot_microns_in_chain(micron_id.to_i, file_info, true,"MIC_LSL","",1,true)
puts "Reboot - #{result}"
######## Check Battery SOC #########
microns = [93]
microns.each do |micron_id|
  check_batteries_soc(micron_id, nil, "TEST")
end