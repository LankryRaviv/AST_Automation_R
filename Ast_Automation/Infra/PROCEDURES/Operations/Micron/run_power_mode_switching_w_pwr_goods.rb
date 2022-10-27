$LOAD_PATH << File.expand_path('../../',__dir__) #PROCEDURES folder
$LOAD_PATH << File.expand_path('../',__dir__) #Operations folder
$LOAD_PATH << File.expand_path('./',__dir__) #Micron folder
load 'Read_Power_Goods_W_Power_Modes_Switching.rb'
load 'Tools/module_file_tools.rb'
load 'Tools/module_clogger.rb'

include FileTools
include CLogger

data_path = ARGV[0].strip
data = read_json_file(data_path)
log_message("path to data json data file received: #{data_path}")

micron_list = data.fetch("micron_ids").strip.split(',').map(&:to_i)
path_json = data.fetch("output_path")
report_file_name = data.fetch("output_file_name")

result = Power_Modes_Switching("MIC_LSL", micron_list, data, auto_reboot: true)
log_message("read power goods with power modes switching - #{result}")

final_status = {"final_status" => result}
log_response(final_status)

exit!
