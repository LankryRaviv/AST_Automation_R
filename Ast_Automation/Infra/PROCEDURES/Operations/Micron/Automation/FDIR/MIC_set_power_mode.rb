load_utility('Operations/Micron/ChangeMode.rb')
load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')
micron_id = ARGV[0].strip.to_i
power_mode = ARGV[1].strip


po = ControlMicron.new

puts po.set_power_mode(micron_id, power_mode)
#Output the log to the log file, if we don't use this function,
#the exit function close the script runner befor we output the lasts results to the log file
start_new_scriptrunner_message_log()
# NOTICE: exit!(true) return exit code 0, exit!(false) return exit code 1
#If all the results was true, return exit!(true)
exit!