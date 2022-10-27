load_utility('Operations/MICRON/micron_beamforming.rb')

filename = open_file_dialog("/","Select the file to upload")

send_bf_cmds_from_file(filename)