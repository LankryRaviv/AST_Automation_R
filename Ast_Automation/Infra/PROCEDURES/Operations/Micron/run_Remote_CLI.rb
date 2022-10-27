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

board = ARGV[0]
puts board
micron_id= ARGV[1].to_i
puts micron_id
cmd =ARGV[2]
puts "cmd before: "
puts cmd
puts "cmd after: "
newCmd = cmd.gsub('+',' ')
puts newCmd
wait 3
res = run_micron_use_CLI(board, micron_id, newCmd)
puts res 
log_response(res)
wait 5
exit!
