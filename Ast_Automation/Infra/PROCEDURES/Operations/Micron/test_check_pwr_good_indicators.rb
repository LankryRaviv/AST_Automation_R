$LOAD_PATH << File.expand_path('../../',__dir__) #PROCEDURES folder
$LOAD_PATH << File.expand_path('../',__dir__) #Operations folder
$LOAD_PATH << File.expand_path('./',__dir__) #Micron folder
load 'check_pwr_good_indicators.rb'
load 'Automation/FDIR/ControlMicron.rb'
load 'Tools/module_file_tools.rb'
load 'Tools/module_clogger.rb'
require 'json'
require 'date'


include FileTools
include CLogger

data_path = ARGV[0].strip
data = read_json_file(data_path)

micron_id = data.fetch("micron_id")
path_json = data.fetch("output_path")
report_file_name = data.fetch("output_file_name")

cm = ControlMicron.new
power_mode_response = cm.get_power_mode(micron_id)
power_mode = ""

if power_mode_response == nil
    log_error("Failed to get power mode")
    sleep 1
    exit(1)
else
    power_mode = power_mode_response["MIC_CURRENT_SYSTEM_POWER_MODE"]
    log_message("power_mode=#{power_mode}")
end

pgs = CheckPwrGoodIndicators.new(micron_id, power_mode)
pg_statuses = pgs.get_pwr_good_indicators_status
log_message("Number of power goods with invalid statuses: #{pg_statuses[0].length}")
#pg_statuses_mismatch = pgs.get_pwr_good_indicators_status[0]
#pg_statuses_all = pgs.get_pwr_good_indicators_status[1]

#power_good_indicator_statuses_mismatch = {
 #   "power_mode" => power_mode,
  #  "final_status" => pg_statuses_mismatch.empty?,
   # "pg_statuses" => pg_statuses_mismatch
#}

for pos in 0..pg_statuses.length - 1
    log_message("pg_statuses[#{pos}]=#{pg_statuses[pos]}")
    power_good_indicator_statuses = {
        "power_mode" => power_mode,
        "final_status" => pg_statuses[pos].empty?,
        "pg_statuses" => pg_statuses[pos]
    }
    log_message("power_good_indicator_statuses:#{power_good_indicator_statuses}")
    path_json_pg = "#{path_json}#{report_file_name.sub("*POWERMODE*", power_mode).sub("*TIMESTAMP*",(DateTime.now).to_s.gsub(":","-")[0..-7])}"
    log_message("path_json_pg:#{path_json_pg}")
    path_json_pg_full = "#{path_json}all_#{report_file_name.sub("*POWERMODE*", power_mode).sub("*TIMESTAMP*",(DateTime.now).to_s.gsub(":","-")[0..-7])}"
    log_message("path_json_pg_full:#{path_json_pg_full}")
    if pos == 0 #pg statuses with mismatches
        write_to_json(power_good_indicator_statuses, path_json_pg)
        log_response(power_good_indicator_statuses)
    elsif pos == 1 #all pg statuses
        write_to_json(power_good_indicator_statuses, "#{path_json_pg_full}")
    end
end

#write_to_json(power_good_indicator_statuses, path_json)

#path_json_pg = "C:/Cosmos/ATE/result_pg_#{power_mode}.json"
#write_to_json(power_good_indicator_statuses, path_json_pg)

#STDOUT.write power_good_indicator_statuses.inspect
#Output the log to the log file, if we don't use this function,
#the exit function close the script runner before we output the lasts results to the log file
start_new_scriptrunner_message_log()
# NOTICE: exit!(true) return exit code 0, exit!(false) return exit code 1
#If all the results was true, return exit!(true)
exit!(pg_statuses[0].empty? ? 0:1)