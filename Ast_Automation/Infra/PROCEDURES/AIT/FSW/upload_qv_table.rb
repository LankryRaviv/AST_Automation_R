load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/FSW_FS_Upload.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'
load 'Operations/FSW/FSW_Telem.rb'
load 'Operations/FSW/FSW_CSP.rb'

module_csp = ModuleCSP.new
module_fs = ModuleFS.new
cmd_sender = CmdSender.new
      
board = 'APC_YP' 
tableFileId = 1032
entrySize = 8
filePath = "#{__dir__}\\QV_table.bin"
check_aspect = "CRC"
    
# Clear the file
module_fs.file_clear(board, tableFileId)
file_status = module_fs.wait_for_file_ok(board, tableFileId, 30)
# Check for nil first
if file_status == nil
  check_expression("false")
end
check_expression("#{file_status} != ''")
check_expression("#{file_status} == 55")
# Upload the file to the board's file system
FSW_FS_Upload(entrySize, tableFileId, filePath, board, check_aspect)
