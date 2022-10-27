load('Operations/CPBF/CPBF_send_cli_list.rb')
filename = open_file_dialog('./', 'Select CLI List')
send_cli_cmds_from_file(filename)