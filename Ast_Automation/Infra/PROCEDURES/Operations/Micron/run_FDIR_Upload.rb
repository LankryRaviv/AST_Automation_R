$LOAD_PATH << File.expand_path('../../',__dir__) #PROCEDURES folder
$LOAD_PATH << File.expand_path('../',__dir__) #Operations folder
$LOAD_PATH << File.expand_path('./',__dir__) #Micron folder
load_utility('MICRON_FS_Upload.rb')
load('Tools\module_file_tools.rb')
load('Operations\Tools\module_clogger.rb')
include FileTools
include CLogger
micron_id = ARGV[0].to_i
path_json = ARGV[1]
generalData = read_json_file(path_json)
data = generalData.fetch("Upload_FDIR")

filesIdAndPath = {
  1005 => "#{File.expand_path('../',__dir__)}\FDIRScripts/exit_to_ps2.txt",
  1006 => "#{File.expand_path('../',__dir__)}\FDIRScripts/reset_to_ps1.txt",
  1007 => "#{File.expand_path('../',__dir__)}\FDIRScripts/battery_heaters_on.txt",
  1008 => "#{File.expand_path('../',__dir__)}\FDIRScripts/battery_heaters_off.txt",
  1009 => "#{File.expand_path('../',__dir__)}\FDIRScripts/charger_on.txt",
  1010 => "#{File.expand_path('../',__dir__)}\FDIRScripts/charger_off.txt",
  1011 => "#{File.expand_path('../',__dir__)}\FDIRScripts/mb_heater_on.txt",
  1012 => "#{File.expand_path('../',__dir__)}\FDIRScripts/mb_heater_off.txt",
  1013 => "#{File.expand_path('../',__dir__)}\FDIRScripts/fem_heaters_turn_on_all.txt",
  1014 => "#{File.expand_path('../',__dir__)}\FDIRScripts/fem_heaters_turn_off_all.txt",
  1015 => "#{File.expand_path('../',__dir__)}\FDIRScripts/fem_heaters_turn_off_all_switch_PS2.txt"
}

puts(filesIdAndPath)

puts(data.fetch("EntrySize"))
EntrySize=data.fetch("EntrySize")

puts(data.fetch("Link"))
Link = data.fetch("Link")

puts(micron_id)

MaxEntrySize = data.fetch("MaxEntrySize")
puts(data.fetch("MaxEntrySize"))


BroadcastAll=data.fetch("BroadcastAll")
puts(data.fetch("BroadcastAll"))

DoFileCheck = data.fetch("DoFileCheck")
puts(data.fetch("DoFileCheck"))



responses = []
filesIdAndPath.each do |key, value|

  puts(key)
  puts(value)

sleep 2

res = MICRON_FS_Upload(EntrySize, key, value, Link, micron_id, MaxEntrySize, BroadcastAll, DoFileCheck, )
log_message(res)
responses.push(res)
end
log_response(responses)
exit!
