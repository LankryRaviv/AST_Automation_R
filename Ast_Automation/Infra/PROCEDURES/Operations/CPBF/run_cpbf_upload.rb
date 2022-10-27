load_utility('Operations/CPBF/CPBF_MODULE.rb')
load_utility('Operations/CPBF/CPBF_FS_Upload.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_file_tools.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_clogger.rb')

include FileTools
include CLogger

path_json = ARGV[0]
type = ARGV[1]
all_data = read_json_file(path_json)
data=all_data.fetch(type)

entry_size = data.fetch("entry_size")
file_id = data.fetch("file_id")
upload_filename = data.fetch("upload_filename")
board = data.fetch("board")
aspect = data.fetch("aspect")
test_break = data.fetch("test_break")
period_between_pkts = data.fetch("period_between_pkts")

puts data.inspect
puts entry_size
puts file_id
puts upload_filename
puts board
puts aspect
puts test_break
puts period_between_pkts

sleep 20
responses = []
res = FSW_FS_Upload(entry_size, file_id, upload_filename, board, aspect,test_break)
responses.push(res)

if type != "Software"{
	res1 = cpbf_reboot_fpga()
	responses.push(res1)
}

log_response(responses.inspect)