load_utility('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations/Micron/MICRON_CPBF_FPGA_Update.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_file_tools.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_clogger.rb')
include FileTools
include CLogger
load_utility('Operations/Micron/MICRON_CPBF_FPGA_Update.rb')
#required parameters
micron_list = ARGV[0].strip.split(",").map(&:to_i)
path_json = ARGV[1]
allData = read_json_file(path_json)
data = allData.fetch("Via_CPBF")
cpbf_to_mic_link = data.fetch("cpbf_to_mic_link")
fpga_img = data.fetch("fpga_img")
# link=link CPBF will broadcast image through.  All other micron commands use LSL
cpbf_to_mic_link = 'LSL'
fpga_img = 'C:/Aviadd46/FPGA_ver/fpga_00_15_00.img'
#### AVIAD: changed FPGA version from '0.00.009' to '00.000E.00'
version_info = data.fetch("version_info")
#optional parameters
entry_size = data.fetch("entry_size")
reboot = data.fetch("reboot")
use_automations = data.fetch("use_automations")
entry_size = 1754
reboot = false
use_automations = true 

res = micron_cpbf_fpga_update(cpbf_to_mic_link, fpga_img, version_info, micron_list, entry_size: entry_size, reboot: reboot, use_automations: use_automations)

# res is a list, [0] = overall status boolean, [1] = status hash
# for status hash, check if res['CPBF'] exists.  If it does,
# it means the script failed on a CPBF step.  If it does not, it
# will return the same has with <MICRON_ID>:<status_message> entries
# just like the MICRON_FPGA_Update script
log_response(res.inspect)



print(res)