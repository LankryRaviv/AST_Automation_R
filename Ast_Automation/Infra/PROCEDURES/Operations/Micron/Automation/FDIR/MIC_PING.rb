load_utility('Operations/MICRON/ping.rb')
load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')

micron_id = ARGV[0].strip.to_i
po = ControlMicron.new

puts po.ping(micron_id)
#Output the log to the log file, if we don't use this function,
#the exit function close the script runner befor we output the lasts results to the log file
start_new_scriptrunner_message_log()
# NOTICE: exit!(true) return exit code 0, exit!(false) return exit code 1
#If all the results was true, return exit!(true)
exit!
