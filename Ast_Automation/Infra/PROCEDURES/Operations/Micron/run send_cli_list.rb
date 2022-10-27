load_utility('Operations/MICRON/micron_send_cli_list.rb')

filename = open_file_dialog("/","Select the file to upload")

# comment out the following two lines if using a hardcoded
# list of micron IDs
microns = ask("Enter the comma delimited list of Microns")
micron_list = microns.split(',').map(&:to_i)

# uncomment below line and replace with actual micron IDs
# if hardcoding the values
#micron_list = [87,88,107]
# can also use parameter for wait_time between CLI cmds default is 1 sec
wait_time = 1

send_cli_cmds_from_file(micron_list, filename, wait_time)
