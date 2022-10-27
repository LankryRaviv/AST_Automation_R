#require_relative 'GTY_PRBS_MODULE'

#include GTY_PRBS
#load_utility('Operations/MICRON/GTY_PRBS_MODULE.rb')
load_utility('Operations/MICRON/GTY_PRBS_MAIN_RING_x.rb')


@gp = GTY_PRBS.new
ret = @gp.gty_prbs_test(mic_id_a=22, mic_id_b=23, mic_pcs_a=1, mic_pcs_b=0, run_id="123456789", error_force=true)
#ret = @gp.fpga_read_reg(23, "0x140644")

#ret = prbs_main_ring_e("E", run_id="1234", apc="YM", cpbf_master="XP")
puts("__________________________________________________________________________________________________")
for x in $result_collector do
    puts x
end

puts ret