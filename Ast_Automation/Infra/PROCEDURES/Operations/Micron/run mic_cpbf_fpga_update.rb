load_utility('Operations/Micron/MICRON_CPBF_FPGA_Update.rb')
#required parameters
# link=link CPBF will broadcast image through.  All other micron commands use LSL
cpbf_to_mic_link = 'LSL'
fpga_img = 'C:/Aviadd46/FPGA_ver/fpga_00_14_00.img'
#### AVIAD: changed FPGA version from '0.00.009' to '00.000E.00'
version_info = '00.000E.00'
micron_list = [135,64,93,79,78]
#optional parameters
entry_size = 1754
reboot = false
use_automations = true 

res = micron_cpbf_fpga_update(cpbf_to_mic_link, fpga_img, version_info, micron_list, entry_size: entry_size, reboot: reboot, use_automations: use_automations)

# res is a list, [0] = overall status boolean, [1] = status hash
# for status hash, check if res['CPBF'] exists.  If it does,
# it means the script failed on a CPBF step.  If it does not, it
# will return the same has with <MICRON_ID>:<status_message> entries
# just like the MICRON_FPGA_Update script
print(res)