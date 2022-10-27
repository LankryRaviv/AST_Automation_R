load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')

micron_id = ARGV[0].strip.to_i
#Image can be bl1, bl2, app
image = ARGV[1].strip
path = ARGV[2].strip
#For example "5.10.1"
version = ARGV[3].strip

micron = ControlMicron.new
status = micron.upload_sw([micron_id], image, path, version)

File.open('C:/Cosmos/ATE/result.json', "w") do |f|
    f.write(status.to_json)
end

start_new_scriptrunner_message_log()
exit!