load_utility('Operations/MICRON/GTY_PRBS_MODULE.rb')
load_utility('Operations/Micron/ChangeMode.rb')


@gp = GTY_PRBS.new

config_file_data = File.read("C:\\cosmos\\ATE\\PRBS_CONFIGURATION\\PRBS_PAIRS_MAIN_RING_A.txt").split
config_file_length = config_file_data.length()
puts config_file_length
for line in 1..config_file_length-1 do
  if config_file_data[line] != ""
    pair = config_file_data[line].split(',')
    mic_id_a = pair[0].to_i
    mic_id_b = pair[1].to_i
    mic_pcs_a = pair[2].to_i
    mic_pcs_b = pair[3].to_i
    excecute = pair[4]
    if excecute.downcase == 'y'
      change_mode(mic_id_a,"REDUCED")
      change_mode(mic_id_b,"REDUCED")
      sleep(10)
      ret = @gp.gty_prbs_test(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b, run_id="123456789", error_force=true)
      change_mode(mic_id_a,"PS2")
      change_mode(mic_id_b,"PS2")
    end
  else
    puts("Empty line")  
  end
end



puts("__________________________________________________________________________________________________")
for x in $result_collector do
    puts x
end