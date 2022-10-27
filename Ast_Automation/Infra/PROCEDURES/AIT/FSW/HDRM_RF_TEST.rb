load 'Operations/FSW/FSW_FS_Upload.rb'
load 'Operations/FSW/FSW_Telem.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'
load 'Operations/FSW/FSW_CSP.rb'
load 'Operations/FSW/FSW_SE.rb'

@module_telem = ModuleTelem.new
@module_csp = ModuleCSP.new
@module_fs = ModuleFS.new
@module_SE = ModuleSE.new

@entry_size = 186
@deployment_2_script_file_id = 4620
@fire_bottom_and_top_lva_script_file_id = 4621
@deployment_1_script_file_id = 4622
@check_aspect = "CRC"
@target = "BW3"
@board = combo_box("Select Side", "APC_YP", "APC_YM")


# Deployment 2 Scrumption
@module_fs.file_clear(@board, @deployment_2_script_file_id)
wait()
script_file_location = open_file_dialog("/", "Select the script file for the deploy 2 test", "*.txt")
FSW_FS_Upload_Slim(@entry_size, @deployment_2_script_file_id, script_file_location, @board, @check_aspect)
wait()
@module_SE.script_run(@board, @deployment_2_script_file_id, 1, 0, "*", "*", "*", "*", "*")
wait()
@module_fs.file_clear(@board, @deployment_2_script_file_id)
wait()

# Deployment top and bottom
@module_fs.file_clear(@board, @fire_bottom_and_top_lva_script_file_id)
wait()
script_file_location = open_file_dialog("/", "Select the script file for the deploy bottom and top bands of lva test", "*.txt")
FSW_FS_Upload(@entry_size, @fire_bottom_and_top_lva_script_file_id, script_file_location, @board, @check_aspect)
wait()
@module_SE.script_run(@board, @fire_bottom_and_top_lva_script_file_id, 1, 0, "*", "*", "*", "*", "*")
wait()
@module_fs.file_clear(@board, @fire_bottom_and_top_lva_script_file_id)
wait()

# Deployment 1 Scrumption
@module_fs.file_clear(@board, @deployment_1_script_file_id)
wait()
script_file_location = open_file_dialog("/", "Select the script file for the deploy 1 test", "*.txt")
FSW_FS_Upload(@entry_size, @deployment_1_script_file_id, script_file_location, @board, @check_aspect)
wait() 
@module_SE.script_run(@board, @deployment_1_script_file_id, 1, 0, "*", "*", "*", "*", "*")
wait()
@module_fs.file_clear(@board, @deployment_1_script_file_id)
wait()