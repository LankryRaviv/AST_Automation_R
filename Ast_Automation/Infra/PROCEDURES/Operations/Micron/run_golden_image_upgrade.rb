load_utility('../../../../../../Ast_Automation/AST_Automation/bin/Debug/PROCEDURES/Operations/Micron/micron_golden_image.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_file_tools.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_clogger.rb')

include FileTools
include CLogger



path_json = ARGV[1]
data = read_json_file(path_json)
golden_file_arr = data.fetch("golden_file")
micron_list = ARGV[0].strip.split(",").map(&:to_i)
responses = []


golden_file_arr.each do |firmware |
  if firmware.fetch("if_run")
    res = golden_image_update(firmware.fetch("board"), firmware.fetch("type"), firmware.fetch("path"),micron_list,firmware.fetch("file_id"),firmware.fetch("file_descriptor_id"),firmware.fetch("broadcast_all"),firmware.fetch("reboot"), firmware.fetch("use_automations"))
    responses.push(res)
  end
end

STDOUT.write "RESPONSE=#{responses.inspect}\n"
start_new_scriptrunner_message_log()
exit!
