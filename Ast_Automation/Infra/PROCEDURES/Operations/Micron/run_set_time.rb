load_utility('Operations/Micron/Automation/FDIR/ControlMicron.rb')

micron_id = ARGV[0].strip.to_i
cm = ControlMicron.new
#micron_id = 77
ret = cm.epoch([micron_id])
cm.write_to_json(ret)
puts ret
start_new_scriptrunner_message_log()
exit!