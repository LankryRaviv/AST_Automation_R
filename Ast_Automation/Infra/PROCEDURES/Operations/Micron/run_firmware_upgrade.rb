load_utility('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Micron\MICRON_Firmware_Update.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_file_tools.rb')
include FileTools

path_json = ARGV[1]
data = read_json_file(path_json)
firmware_type_array = data.fetch("image")
micron_list = ARGV[0].strip.split(",").map(&:to_i)
responses = []


firmware_type_array.each { |firmware |
  if firmware.fetch("if_run")
    res = firmware_update(firmware.fetch("board"), firmware.fetch("type"), firmware.fetch("path"),firmware.fetch("version_info"),firmware.fetch("file_id"), firmware.fetch("from_golden"), micron_list,firmware.fetch("broadcast_all"), firmware.fetch("reboot"), firmware.fetch("use_automations"), firmware.fetch("check_version"))
    responses.push(res)
  end
}

STDOUT.write "RESPONSE=#{responses.inspect}\n"
start_new_scriptrunner_message_log()
exit!




