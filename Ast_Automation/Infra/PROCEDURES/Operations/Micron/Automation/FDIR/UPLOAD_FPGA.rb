load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')

micron_id = ARGV[0].strip.to_i
path = ARGV[1].strip
#For example "00.0010.03"
version = ARGV[2].strip

micron = ControlMicron.new
status = micron.upload_fpga([micron_id], path, version)

File.open('C:/Cosmos/ATE/result.json', "w") do |f|
    f.write(status.to_json)
end

start_new_scriptrunner_message_log()
exit!