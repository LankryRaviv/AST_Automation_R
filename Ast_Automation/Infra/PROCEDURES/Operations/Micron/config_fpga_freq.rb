$LOAD_PATH << File.expand_path('../../',__dir__) #PROCEDURES folder
$LOAD_PATH << File.expand_path('../',__dir__) #Operations folder
$LOAD_PATH << File.expand_path('./',__dir__) #Micron folder
load('TrajectoryControlFunctions.rb')
load '../Tools/module_file_tools.rb'
load '../Tools/module_clogger.rb'

include FileTools
include CLogger

json_path = ARGV[0].strip
log_message("json path received: #{json_path}")
data = read_json_file(json_path)
log_message(data)

#micron_list = ARGV[0].strip.split(",").map(&:to_i)
microns_list = data.fetch("RubyScripts").fetch("ConfigFpgaFreq").fetch("Parameters").fetch("MicronList")
dl_freq = data.fetch("RubyScripts").fetch("ConfigFpgaFreq").fetch("Parameters").fetch("DL_Freq")
ul_freq = data.fetch("RubyScripts").fetch("ConfigFpgaFreq").fetch("Parameters").fetch("UL_Freq")
log_message("dl= #{dl_freq}, #{dl_freq.class}")
log_message("ul= #{ul_freq}, #{ul_freq.class}")
#Config micron fpga to cw
responses = config_fpga_w_params(microns_list, dl_freq, ul_freq)
log_response(responses)


exit!
