load('Operations/Micron/TrajectoryControlFunctions.rb')
load('Operations/MICRON/micron_beamforming.rb')
load('Operations/CPBF/CPBF_send_cli_list.rb')

microns = [90]
moved_to_operational = true

#Config FPGA FREQ (DL & UL)
config_fpga(microns)

#Config CPBF located in 'Operations/CPBF/CPBF_send_cli_list.rb'
# beamen=0x1
# opmode=1
# testmode=0
# df=0x040000,0x00000000000000
# timetagtype=0
filename = open_file_dialog('./', 'Select CPBF CLI List')
send_cli_cmds_from_file(filename)

#Move to Operational
moved_to_operational = move_ring_to_mode_and_validate('', 'OPERATIONAL', "", false, microns, nil)
puts "Move to operational mode - #{moved_to_operational}"


if moved_to_operational
    #Run beamforming located in 'Operations/MICRON/micron_beamforming.rb'
    filename = open_file_dialog("/","Select beamforming file to upload")
    send_bf_cmds_from_file(filename)
else
    puts "FAILED TO MOVE OPERATIONAL MODE!!"
end