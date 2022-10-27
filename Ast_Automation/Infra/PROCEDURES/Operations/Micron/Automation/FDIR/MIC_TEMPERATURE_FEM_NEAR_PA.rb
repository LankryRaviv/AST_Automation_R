load_utility('Operations/MICRON/ThermalTelemetry.rb')


micron_id = ARGV[0].strip.to_i
telemetry = ThermalTelemetry.new

puts telemetry.get_fem_near_pa_temperature(micron_id)
#Output the log to the log file, if we don't use this function,
#the exit function close the script runner befor we output the lasts results to the log file
start_new_scriptrunner_message_log()
# NOTICE: exit!(true) return exit code 0, exit!(false) return exit code 1
#If all the results was true, return exit!(true)
exit!