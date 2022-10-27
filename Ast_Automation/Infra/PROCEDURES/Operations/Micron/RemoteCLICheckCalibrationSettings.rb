$LOAD_PATH << File.expand_path('../../',__dir__) #PROCEDURES folder
$LOAD_PATH << File.expand_path('../',__dir__) #Operations folder
$LOAD_PATH << File.expand_path('./',__dir__) #Micron folder
load_utility('MICRON_FS_Upload.rb')
load_utility('Tools\module_file_tools.rb')
load('Operations\Tools\module_clogger.rb')
include FileTools
include CLogger
load_utility('MICRON_MODULE.rb')
load_utility('run_micron_use_CLI.rb')

responses = []
board = ARGV[0]
puts board

micron_id= ARGV[1].to_i
puts micron_id

pathForValuesFile =ARGV[2]
puts pathForValuesFile

pathForCommandsFile =ARGV[3]
puts pathForCommandsFile

index = 0
valueArr = read_text_file_as_array(pathForValuesFile)
commandsArr = read_text_file_as_array(pathForCommandsFile)

commandsArr.each do |cmd|
	if cmd.include?("get")
		puts cmd
		wait 5
		res = run_micron_use_CLI(board, micron_id, cmd)
		puts res.inspect
		wait 10
		responses.push(res.inspect)
		log_message(res.inspect)
		if res.inspect.include?(valueArr[index]) == false
			log_error("#{valueArr[index]} isn`t config")
			exit!
		end
		index+=1
	end
end

log_response(responses.inspect)
exit!
