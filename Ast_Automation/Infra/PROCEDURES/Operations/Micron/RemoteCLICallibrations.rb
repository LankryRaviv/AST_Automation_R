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
path_file =ARGV[2]
puts path_file
path_to_write = ARGV[3]
puts path_to_write
setCommands=[]
File.open(path_file).each do |line|
	if line.include? "get" or line.include? "set"
		puts line
		res = run_micron_use_CLI(board, micron_id, line)
		log_message(res)
		if line.include? "set"
			val=line.split(' ')
			setCommands.push(val.last)
		end
		responses.push(res)
	end
end

myPath = read_text_file_as_array(path_to_write)
write_text_file_as_array(myPath[0], setCommands)
log_response(responses)
exit!
