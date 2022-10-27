load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
require_relative 'MICRON_PRBS no csv'

include MICRON_PRBS
testResult = "FAIL"

# Run with GUI
ring = ARGV[ARGV.length()-1].strip
out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
#Read arguments
for data in ARGV
   out_file.write(data + " ")
end
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
builded_string = "\nRUN_ID: " + RUN_ID + " TEST_START"
out_file.puts(builded_string)
out_file.close
cpbf_master = ARGV[ARGV.length()-7].strip()
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip
puts("CPBF #{cpbf_master[-2..-1]} is set to master")



# Run with Script Runner
#RUN_ID = "21111111111111110"
#ring = "D"
#out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
#out_file.write("\n")
#out_file.write("\n")
#builded_string = "\nRUN_ID: " + RUN_ID + " TEST_START"
#out_file.puts(builded_string)
#out_file.close
#cpbf_master = "XP"
#apc = "APC_YM"
#puts("CPBF #{cpbf_master} is set to master" )


$result_collector = []
prbs_test = true
# power ring D to reduced


puts("----------------------------------------Power microns to PS2-------------------------------------------------------------------------------------------")
#power_on, ring_list = power_on_ring_to_ps2(ring, apc, RUN_ID) # Run with script runner
power_on, ring_list = power_on_ring_to_reduced(ring, apc, ARGV[1]) # Run with GUI
puts("--------------------------------------------------------------------------------------------------------------------------------------------------------")


puts(" ----------------------------------------------------- Reroute HSL 122,109, 123 ------------------------------------------------------------------------")


#INFO: DPC is YM

# Rev 12

load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/FSW/FSW_DPC.rb')

########## Code Start ##########

micron = MICRON_MODULE.new
dpc = ModuleDPC.new

# UART_CONTROL:  Chain 3 DPC: 3 UART: 2 Control false
puts dpc.set_micron_uart('DPC_3', 'UART2', 'OFF')
# UART_CONTROL:  Chain 5 DPC: 4 UART: 2 Control false
puts dpc.set_micron_uart('DPC_4', 'UART2', 'OFF')

# UART_CONTROL:  Chain 4 DPC: 4 UART: 4 Control true
puts dpc.set_micron_uart('DPC_4', 'UART4', 'ON')

# SET_ROUTING:  MicronID 109 LSL 34  (00100010) HSL 68  (01000100) WFD 81  TTD 33  [HS] (Location 17)
puts micron.set_micron_routing_param('MIC_LSL', 109, 0, 34, 68, 81, 33)
# SET_ROUTING:  MicronID 110 LSL 34  (00100010) HSL 144 (10010000) WFD 76  TTD 31  [HS] (Location 16)
puts micron.set_micron_routing_param('MIC_LSL', 122, 0, 34, 144, 81, 33)
# SET_ROUTING:  MicronID 123 LSL 34  (00100010) HSL 135 (10000111) WFD 76  TTD 31  [HS] (Location 16)
puts micron.set_micron_routing_param('MIC_LSL', 123, 0, 34, 135, 76, 31)

puts("--------------------------------------------------------------------------------------------------------------------------------------------------------")
puts("------------------------------------------------------------------ Power microns to REDUCED--------------------------------------------------------------")

flag = move_ring_to_mode_and_validate("A", "REDUCED", RUN_ID)
flag = move_ring_to_mode_and_validate("B", "REDUCED", RUN_ID)
flag = move_ring_to_mode_and_validate("C", "REDUCED", RUN_ID)
flag = move_ring_to_mode_and_validate("D", "REDUCED", RUN_ID)

puts("--------------------------------------------------------------------------------------------------------------------------------------------------------")

if(power_on)


    # # Test PRBS on ring D -hard codded with error force:
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=45, chk_micron_id=46, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=59, chk_micron_id=60, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=73, chk_micron_id=74, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=87, chk_micron_id=88, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=101, chk_micron_id=102, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=115, chk_micron_id=116, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=129, chk_micron_id=130, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=143, chk_micron_id=144, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=54, chk_micron_id=53, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=68, chk_micron_id=67, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=82, chk_micron_id=81, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=96, chk_micron_id=95, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=110, chk_micron_id=109, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=124, chk_micron_id=123, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=138, chk_micron_id=137, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=152, chk_micron_id=151, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	
	
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=123, chk_micron_id=109, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x0322, run_id_str=RUN_ID) # testinig PRBS with the new reroute btween 123 to 109
	
end


puts("--------------------------------------------------------------- Power microns back to PS2---------------------------------------------------------------")

flag = move_ring_to_mode_and_validate("D", "PS2", RUN_ID)
flag = move_ring_to_mode_and_validate("C", "PS2", RUN_ID)
flag = move_ring_to_mode_and_validate("B", "PS2", RUN_ID)
flag = move_ring_to_mode_and_validate("A", "PS2", RUN_ID)

puts("--------------------------------------------------------------------------------------------------------------------------------------------------------")
puts("----------------------------------------------- Reroute HSL 122,109, 123 back to defualt ---------------------------------------------------------------") 
#INFO: DPC is YM

# Rev 12

load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/FSW/FSW_DPC.rb')

########## Code Start ##########

micron = MICRON_MODULE.new
dpc = ModuleDPC.new

# UART_CONTROL:  Chain 3 DPC: 3 UART: 2 Control false
puts dpc.set_micron_uart('DPC_3', 'UART2', 'OFF')
# UART_CONTROL:  Chain 5 DPC: 4 UART: 2 Control false
puts dpc.set_micron_uart('DPC_4', 'UART2', 'OFF')

# UART_CONTROL:  Chain 4 DPC: 4 UART: 4 Control true
puts dpc.set_micron_uart('DPC_4', 'UART4', 'ON')

# SET_ROUTING_DEFAULT:  MicronID 107
puts micron.set_micron_default_routing_param('MIC_LSL', 107)
# SET_ROUTING_DEFAULT:  MicronID 108
puts micron.set_micron_default_routing_param('MIC_LSL', 108)
# SET_ROUTING_DEFAULT:  MicronID 109
puts micron.set_micron_default_routing_param('MIC_LSL', 109)
# SET_ROUTING_DEFAULT:  MicronID 121
puts micron.set_micron_default_routing_param('MIC_LSL', 121)
# SET_ROUTING_DEFAULT:  MicronID 122
puts micron.set_micron_default_routing_param('MIC_LSL', 122)
# SET_ROUTING_DEFAULT:  MicronID 123
puts micron.set_micron_default_routing_param('MIC_LSL', 123)

puts("-----------------------------------------------------------------------------------------------------------------------------------------------------")
puts("---------------------------------------------------------------- Power off Microns ------------------------------------------------------------------")

#power_off = power_off_ring(ring, apc, RUN_ID) # Run with script runner
power_off = power_off_ring(ring, apc, ARGV[1]) # Run with GUI

if(power_on && prbs_test && power_off)
    testResult = "PASS"
end


puts("------------------------------------------------------------------------------------------------------------------------------------------------------")
#for x in $result_collector do
 #   puts x
#end

num_of_res_lines = 0
fail_flag = false
for x in $result_collector do
	puts x
	if x.include? "Connection" and x.include? "BER"
		num_of_res_lines = num_of_res_lines + 1 
	end
	if x.include? "FAIL" or x.include? "Fail"
		fail_flag = true
	end
end
if num_of_res_lines = 112 and fail_flag == false
	puts("Ring C Final Status = Pass")
else 
	puts("Ring C Final Status = Fail")
end

#out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult) # Run with GUI
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"  # Run with GUI
#out_file.puts("\nRUN_ID: " + RUN_ID + "TEST RESULT = " + testResult)  # Run with script runner
#builded_string = "RUN_ID: " + RUN_ID + " TEST_END"  # Run with script runner
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!