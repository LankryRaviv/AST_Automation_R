load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')

micron_id = ARGV[0].strip.to_i
#On which direction the micron DONEE,DONOR
direction = ARGV[1].strip


micron = ControlMicron.new

#ret = micron.donee(micron_id, direction)
#ret = micron.disable_mode(77)
#ret = micron.charging_next_micron(77, "SOUTH_CLOSED", 63, "NORTH_CLOSED", 'PS2')
ret = micron.charging_neighbor(micron_id, direction)
puts ret
start_new_scriptrunner_message_log()
exit!