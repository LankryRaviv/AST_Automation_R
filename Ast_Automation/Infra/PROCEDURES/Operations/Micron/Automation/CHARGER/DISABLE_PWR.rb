load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')

micron_id = ARGV[0].strip.to_i

micron = ControlMicron.new

#ret = micron.donee(micron_id, direction)
ret = micron.disable_mode(micron_id)
puts ret
#ret = micron.charging_next_micron(77, "SOUTH_CLOSED", 63, "NORTH_CLOSED", 'PS2')
#ret = micron.donor(micron_id, direction)
start_new_scriptrunner_message_log()
exit!