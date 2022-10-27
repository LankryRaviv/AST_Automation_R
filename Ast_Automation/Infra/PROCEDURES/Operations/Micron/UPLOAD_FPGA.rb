load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')

micron_ids = ARGV[0].strip.split(",").map(&:to_i)
versionPath = ARGV[1].strip
pathToWrite = ARGV[3].strip
#For example "00.0010.03"
version = ARGV[2].strip

micron = ControlMicron.new
status = micron.upload_fpga(micron_ids, versionPath, version)

File.open(pathToWrite, "w") do |f|
    f.write(status.to_json)
end

STDOUT.write status.inspect

start_new_scriptrunner_message_log()
exit!