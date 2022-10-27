load_utility('Operations/Micron/MICRON_SoC.rb')

micron_id = ARGV[0].strip.to_i
string_a, string_b = get_micron_batteries_soc(micron_id)
diction = {"STRING_A" => string_a.to_s, "STRING_B" => string_b.to_s}
File.open('C:/Cosmos/ATE/result.json', "w") do |f|
    f.write(diction.to_json)
end
start_new_scriptrunner_message_log()
exit!
