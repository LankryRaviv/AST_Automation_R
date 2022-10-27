load_utility('Operations/Micron/Automation/CHARGER/EpsTelemetry.rb')

micron_id = ARGV[0].strip.to_i
#On which direction the micron DONEE,DONOR
#direction = ARGV[1].strip


micron = EpsTelemetry.new
diction = {}
#ret = micron.donee(micron_id, direction)
#ret = micron.disable_mode(77)
#ret = micron.charging_next_micron(77, "SOUTH_CLOSED", 63, "NORTH_CLOSED", 'PS2')
puts micron.get_solar_panel_string_a_current(micron_id)
puts micron.get_solar_panel_string_b_current(micron_id)
puts micron.get_solar_panel_string_a_voltage(micron_id)
puts micron.get_solar_panel_string_b_voltage(micron_id)
micron.write_to_json()
start_new_scriptrunner_message_log()
exit!