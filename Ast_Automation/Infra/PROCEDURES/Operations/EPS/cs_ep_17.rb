load_utility('Operations/FSW/UTIL_CmdSender')

$target = "BW3"
$board = "APC_YP"
$pkt = "POWER_PCDU_LVC_TLM"
$cmd_sender = CmdSender.new

def print_val(step, mnemonic)
  val = $cmd_sender.get_current_val($board, $pkt, mnemonic)
  puts "#{step} - #{mnemonic}: #{val}"
end


 print_val("1.2", "BCU1_PRESENCE")
 print_val("1.2", "BCU2_PRESENCE")
 print_val("1.2", "BCU3_PRESENCE")
 print_val("1.2", "BCU4_PRESENCE")
 print_val("1.2", "BCU5_PRESENCE")
 print_val("1.2", "BCU6_PRESENCE")
 print_val("1.2", "AGG_PRESENCE")
 wait
 puts("\n\n")
 6.times do |i|
   8.times do |j|
     mnemonic = "BCU#{i+1}_CELL_VOLTAGE_#{j}"
     val = $cmd_sender.get_current_val($board, $pkt, mnemonic)
     if val < 3.0 or val > 4.2
       puts "\n\n\n\nERROR!!!!!!!\n\n\n\n"
       check(false)
     end
     print_val("1.3", mnemonic)
   end
   puts " "
 end
 wait

 puts("\n\n")
 6.times do |i|
   min = "BCU#{i+1}_CELL_VOLTAGE_MIN"
   max = "BCU#{i+1}_CELL_VOLTAGE_MAX"
   diff = $cmd_sender.get_current_val($board, $pkt, max) - $cmd_sender.get_current_val($board, $pkt, min)
   if diff > 0.060
     puts "\n\n\n\nERROR!!!!!!!\n\n\n\n"
     check(false)
   end
   print_val("1.4 ", min)
   print_val("1.4", max)
   puts("1.4 - Difference:                            #{diff}\n")
   puts " "
 end


 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.5", "BCU#{i+1}_INTERNAL_TEMP")
   print_val("1.5", "BCU#{i+1}_OUTER_TEMP")
   print_val("1.5", "BCU#{i+1}_BALANCED_TEMP")
   print_val("1.5", "BCU#{i+1}_BATTERY1_TEMP")
   print_val("1.5", "BCU#{i+1}_BATTERY2_TEMP")
   print_val("1.5", "BCU#{i+1}_BOARD_TEMP")
   puts " "
 end


 wait
 puts("\n\n")
 6.times do |i|
   min = "BCU#{i+1}_CELL_VOLTAGE_MIN"
   max = "BCU#{i+1}_CELL_VOLTAGE_MAX"
   threshold = $cmd_sender.get_current_val($board, $pkt, "BCU#{i+1}_CELL_BALANCE_THR")
   diff = $cmd_sender.get_current_val($board, $pkt, max) - $cmd_sender.get_current_val($board, $pkt, min)
   print_val("1.6 ", min)
   print_val("1.6", max)
   print_val("1.6", "BCU#{i+1}_CELL_BALANCE_AUTO")
   print_val("1.6", "BCU#{i+1}_CELL_BALANCE_STATUS")
   puts("1.6 - Difference:                            #{diff}\n")
   puts " "
 end


 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.7", "BCU#{i+1}_CELL_BALANCE_AUTO")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.8", "BCU#{i+1}_CELL_BALANCE_THR")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.9", "BCU#{i+1}_HEATER_AUTO")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.10", "BCU#{i+1}_HEATER_ON_THR")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.11", "BCU#{i+1}_HEATER_OFF_THR")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.12", "BCU#{i+1}_BOARD_TEMP")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.13", "BCU#{i+1}_BATTERY2_TEMP")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.14", "AGG_PACK_TEMPERATURE_#{i}")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.15", "BCU#{i+1}_CURRENT_IN")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.16", "BCU#{i+1}_CURRENT_OUT")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.17", "AGG_PACK_CURRENT_#{i}")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.18", "BCU#{i+1}_VOLTAGE_IN")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.19", "BCU#{i+1}_VOLTAGE_OUT")
   puts " "
 end

 
 wait
 puts("\n\n")
 6.times do |i|
   print_val("1.20", "AGG_PACK_VOLTAGE_#{i}")
   puts " "
 end

 
 wait

puts("\n\n\n\n\n\n")

print_val("2.2", "PCDU_BATT_V12_4_STATUS")
print_val("2.2", "PCDU_BATT_V12_3_STATUS")
print_val("2.2", "PCDU_BATT_V28_6_STATUS")
print_val("2.2", "PCDU_BATT_V28_5_STATUS")
print_val("2.2", "PCDU_BATT_V28_4_STATUS")
print_val("2.2", "PCDU_BATT_V28_3_STATUS")
print_val("2.2", "PCDU_BATT_V28_2_STATUS")
print_val("2.2", "PCDU_BATT_PPU_UNREG_STATUS")
print_val("2.2", "PCDU_BATT_V12_5_STATUS")
print_val("2.2", "PCDU_MPPT_V5_4_STATUS")
print_val("2.2", "PCDU_MPPT_V5_3_STATUS")
print_val("2.2", "PCDU_MPPT_V12_2_STATUS")
print_val("2.2", "PCDU_MPPT_V12_1_STATUS")
print_val("2.2", "PCDU_MPPT_V12_8_STATUS")
print_val("2.2", "PCDU_MPPT_V12_7_STATUS")
print_val("2.2", "PCDU_MPPT_V12_6_STATUS")
print_val("2.2", "PCDU_MPPT_V5_1_STATUS")
print_val("2.2", "PCDU_MPPT_V5_2_STATUS")
print_val("2.2", "PCDU_MICRON_12V_18_STATUS")
print_val("2.2", "PCDU_MICRON_12V_17_STATUS")
print_val("2.2", "PCDU_MICRON_12V_16_STATUS")
print_val("2.2", "PCDU_MICRON_12V_15_STATUS")
print_val("2.2", "PCDU_MICRON_12V_14_STATUS")
print_val("2.2", "PCDU_MICRON_12V_13_STATUS")
print_val("2.2", "PCDU_MICRON_12V_12_STATUS")
print_val("2.2", "PCDU_MICRON_12V_11_STATUS")
print_val("2.2", "PCDU_BOOST_EIGHT_STATUS")
print_val("2.2", "PCDU_BOOST_SEVEN_STATUS")
print_val("2.2", "PCDU_BOOST_SIX_STATUS")
print_val("2.2", "PCDU_BOOST_FIVE_STATUS")
print_val("2.2", "PCDU_BOOST_FOUR_STATUS")
print_val("2.2", "PCDU_BOOST_THREE_STATUS")
print_val("2.2", "PCDU_BOOST_TWO_STATUS")
print_val("2.2", "PCDU_BOOST_ONE_STATUS")


 
wait
puts "\n\n"

print_val("2.3", "PCDU_BATT_V12_4_IRQ")
print_val("2.3", "PCDU_BATT_V12_3_IRQ")
print_val("2.3", "PCDU_BATT_V28_6_IRQ")
print_val("2.3", "PCDU_BATT_V28_5_IRQ")
print_val("2.3", "PCDU_BATT_V28_4_IRQ")
print_val("2.3", "PCDU_BATT_V28_3_IRQ")
print_val("2.3", "PCDU_BATT_V28_2_IRQ")
print_val("2.3", "PCDU_BATT_PPU_UNREG_IRQ")
print_val("2.3", "PCDU_BATT_V12_5_IRQ")
print_val("2.3", "PCDU_MPPT_V5_4_IRQ")
print_val("2.3", "PCDU_MPPT_V5_3_IRQ")
print_val("2.3", "PCDU_MPPT_V12_2_IRQ")
print_val("2.3", "PCDU_MPPT_V12_1_IRQ")
print_val("2.3", "PCDU_MPPT_V12_8_IRQ")
print_val("2.3", "PCDU_MPPT_V12_7_IRQ")
print_val("2.3", "PCDU_MPPT_V12_6_IRQ")
print_val("2.3", "PCDU_MPPT_V5_1_IRQ")
print_val("2.3", "PCDU_MPPT_V5_2_IRQ")
print_val("2.3", "PCDU_MICRON_12V_18_IRQ")
print_val("2.3", "PCDU_MICRON_12V_17_IRQ")
print_val("2.3", "PCDU_MICRON_12V_16_IRQ")
print_val("2.3", "PCDU_MICRON_12V_15_IRQ")
print_val("2.3", "PCDU_MICRON_12V_14_IRQ")
print_val("2.3", "PCDU_MICRON_12V_13_IRQ")
print_val("2.3", "PCDU_MICRON_12V_12_IRQ")
print_val("2.3", "PCDU_MICRON_12V_11_IRQ")
print_val("2.3", "PCDU_BOOST_EIGHT_IRQ")
print_val("2.3", "PCDU_BOOST_SEVEN_IRQ")
print_val("2.3", "PCDU_BOOST_SIX_IRQ")
print_val("2.3", "PCDU_BOOST_FIVE_IRQ")
print_val("2.3", "PCDU_BOOST_FOUR_IRQ")
print_val("2.3", "PCDU_BOOST_THREE_IRQ")
print_val("2.3", "PCDU_BOOST_TWO_IRQ")
print_val("2.3", "PCDU_BOOST_ONE_IRQ")


 
wait
puts "\n\n"

print_val("2.4", "PCDU_BATT_V12_4_IRQ_EN")
print_val("2.4", "PCDU_BATT_V12_3_IRQ_EN")
print_val("2.4", "PCDU_BATT_V28_6_IRQ_EN")
print_val("2.4", "PCDU_BATT_V28_5_IRQ_EN")
print_val("2.4", "PCDU_BATT_V28_4_IRQ_EN")
print_val("2.4", "PCDU_BATT_V28_3_IRQ_EN")
print_val("2.4", "PCDU_BATT_V28_2_IRQ_EN")
print_val("2.4", "PCDU_BATT_PPU_UNREG_IRQ_EN")
print_val("2.4", "PCDU_BATT_V12_5_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V5_4_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V5_3_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V12_2_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V12_1_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V12_8_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V12_7_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V12_6_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V5_1_IRQ_EN")
print_val("2.4", "PCDU_MPPT_V5_2_IRQ_EN")
print_val("2.4", "PCDU_MICRON_12V_18_IRQ_EN")
print_val("2.4", "PCDU_MICRON_12V_17_IRQ_EN")
print_val("2.4", "PCDU_MICRON_12V_16_IRQ_EN")
print_val("2.4", "PCDU_MICRON_12V_15_IRQ_EN")
print_val("2.4", "PCDU_MICRON_12V_14_IRQ_EN")
print_val("2.4", "PCDU_MICRON_12V_13_IRQ_EN")
print_val("2.4", "PCDU_MICRON_12V_12_IRQ_EN")
print_val("2.4", "PCDU_MICRON_12V_11_IRQ_EN")
print_val("2.4", "PCDU_BOOST_EIGHT_IRQ_EN")
print_val("2.4", "PCDU_BOOST_SEVEN_IRQ_EN")
print_val("2.4", "PCDU_BOOST_SIX_IRQ_EN")
print_val("2.4", "PCDU_BOOST_FIVE_IRQ_EN")
print_val("2.4", "PCDU_BOOST_FOUR_IRQ_EN")
print_val("2.4", "PCDU_BOOST_THREE_IRQ_EN")
print_val("2.4", "PCDU_BOOST_TWO_IRQ_EN")
print_val("2.4", "PCDU_BOOST_ONE_IRQ_EN")


 
wait
puts "\n\n"

print_val("2.5", "PCDU_BATT_V12_3_ADC_VMON")
print_val("2.5", "PCDU_BATT_V12_4_ADC_VMON")
print_val("2.5", "PCDU_BATT_V12_5_ADC_VMON")
print_val("2.5", "PCDU_MPPT_V12_1_ADC_VMON")
print_val("2.5", "PCDU_MPPT_V12_2_ADC_VMON")
print_val("2.5", "PCDU_MPPT_V12_6_ADC_VMON")
print_val("2.5", "PCDU_MPPT_V12_7_ADC_VMON")
print_val("2.5", "PCDU_MPPT_V12_8_ADC_VMON")
print_val("2.5", "PCDU_MICRON_V12_11_ADC_VMON")
print_val("2.5", "PCDU_MICRON_V12_12_ADC_VMON")
print_val("2.5", "PCDU_MICRON_V12_13_ADC_VMON")
print_val("2.5", "PCDU_MICRON_V12_14_ADC_VMON")
print_val("2.5", "PCDU_MICRON_V12_15_ADC_VMON")
print_val("2.5", "PCDU_MICRON_V12_16_ADC_VMON")
print_val("2.5", "PCDU_MICRON_V12_17_ADC_VMON")
print_val("2.5", "PCDU_MICRON_V12_18_ADC_VMON")



 
wait
puts "\n\n"


print_val("2.6", "PCDU_BATT_ADC_THERM1")
print_val("2.6", "PCDU_BATT_ADC_THERM2")
print_val("2.6", "PCDU_BATT_ADC_THERM3")
print_val("2.6", "PCDU_BATT_ADC_THERM4")
print_val("2.6", "PCDU_MICRON_ADC_THERM1")
print_val("2.6", "PCDU_MICRON_ADC_THERM2")
print_val("2.6", "PCDU_MPPT_SWITCH_ADC_THERM1")
print_val("2.6", "PCDU_MPPT_SWITCH_ADC_THERM2")


 
wait
puts "\n\n"


print_val("2.7", "PCDU_BATT_ADC_VBATT_MON")
print_val("2.7", "PCDU_MPPT_BUSBAR_MEDIAN")



 
wait
puts "\n\n"


print_val("3.1", "PCDU_MPPT_SEP_STRAP_STATUS")



 
wait
puts "\n\n"


print_val("3.2", "PCDU_BATT_ADC_IMON_MAIN")



 
wait
puts "\n\n"


print_val("3.3", "PCDU_BATT_ADC_VBATT_MON")
print_val("3.3", "AGG_PACK_VOLTAGE_0")
print_val("3.3", "AGG_PACK_VOLTAGE_1")
print_val("3.3", "AGG_PACK_VOLTAGE_2")
print_val("3.3", "AGG_PACK_VOLTAGE_3")
print_val("3.3", "AGG_PACK_VOLTAGE_4")
print_val("3.3", "AGG_PACK_VOLTAGE_5")



 
wait
puts "\n\n"


print_val("3.4", "PCDU_MPPT_SOLAR_ADC_VMON1")
print_val("3.4", "PCDU_MPPT_SOLAR_ADC_VMON2")
print_val("3.4", "PCDU_MPPT_SOLAR_ADC_VMON3")
print_val("3.4", "PCDU_MPPT_SOLAR_ADC_VMON4")
print_val("3.4", "PCDU_MPPT_MODE_STATE")



