load_utility('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\MICRON\Power_Modes_Switching.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_file_tools.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_clogger.rb')
include FileTools
include CLogger

micron_list = ARGV[0].strip.split(',').map(&:to_i)
path_json = ARGV[1]
generalData = read_json_file(path_json)
data = generalData.fetch("Power_Modes_Switching")



res = Power_Modes_Switching(data.fetch("Board"), micron_list, data.fetch("Auto_Reboot"),data.fetch("Number_Of_Cycles") )
log_response(res)
exit!
