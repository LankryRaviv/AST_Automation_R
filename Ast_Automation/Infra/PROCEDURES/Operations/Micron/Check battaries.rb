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

######## Check Battery SOC #########
microns = [93]
verify_battries(microns, "", file_info, 50, 100)