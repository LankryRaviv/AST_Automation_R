load_utility('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Micron\MICRON_FPGA_Update.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_file_tools.rb')
include FileTools

micron_list = ARGV[0].strip.split(",").map(&:to_i)
path_json = ARGV[1]
allData = read_json_file(path_json)
data = allData.fetch("Via_MIC_LSL")
res = micron_fpga_update(data.fetch("link"), data.fetch("image_loc"), data.fetch("version_info"), micron_list, data.fetch("file_id"), data.fetch("from_golden"), data.fetch("entry_size"), data.fetch("broadcast_all"), data.fetch("reboot"), data.fetch("do_file_check"), data.fetch("use_automations"))
STDOUT.write "RESPONSE=#{res}\n"