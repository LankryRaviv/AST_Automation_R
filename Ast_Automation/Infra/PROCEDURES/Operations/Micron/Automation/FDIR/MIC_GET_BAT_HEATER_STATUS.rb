load('Operations/Micron/ChangeMode.rb')
load('C:/cosmos/PROCEDURES/Operations/Micron/Automation/FDIR/ControlMicron.rb')

micron_id = ARGV[0].strip.to_i
number = ARGV[1].strip.to_i
po = ControlMicron.new

puts po.get_heater_status_bat(micron_id,number)
#Output the log to the log file, if we don't use this function,
#the exit function close the script runner befor we output the lasts results to the log file
start_new_scriptrunner_message_log()
# NOTICE: exit!(true) return exit code 0, exit!(false) return exit code 1
#If all the results was true, return exit!(true)
exit!