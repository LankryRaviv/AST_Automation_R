load_utility('Operations/MICRON/MICRON_SoC.rb')


microns = []

#read the first argument example
micron_id = ARGV[0].strip.to_i

#read arguments in a loop example
ARGV.each do |micron_id|
    microns << micron_id.to_i
end

#Example of how to write to the stdout (shell prompt by default)
STDOUT.write "ARG 1 - #{micron_id}\n"
STDOUT.write "ALL ARGS - #{ARGV}\n"

################ Start script implementation ##################

######## Check Battery SOC #########
#Keep the results in the array
result = Array.new(microns.length) { false }

microns.each_with_index do |micron_id, i|
    result[i] = check_batteries_soc(micron_id, "")
end

################ End script implementation ####################

#Output the log to the log file, if we don't use this function,
#the exit function close the script runner befor we output the lasts results to the log file
start_new_scriptrunner_message_log()
# NOTICE: exit!(true) return exit code 0, exit!(false) return exit code 1
#If all the results was true, return exit!(true)
exit!(result.all?)