load('Operations/Micron/TrajectoryControlFunctions.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/micron_rapid_power.rb')
load('Operations/MICRON/Routing/routing_operations_delegate_cosmos_lsl.rb')
load('Operations/MICRON/Routing/routing.rb')
load('Operations/MICRON/MICRON_MODULE.rb')
load('Operations/FSW/FSW_DPC.rb')

board = "MIC_LSL"
options = RoutingOptions.lsl_reroute_ym
options[:rings_filter] = ['A','B','C','D', 'E']

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
RUN_ID = ARGV[1]
out_file.puts(builded_string)
out_file.close
cpbf_master = ARGV[ARGV.length()-7].strip()
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip
puts("CPBF #{cpbf_master[-2..-1]} is set to master")



# Run with Script Runner
#RUN_ID = "21111111111111110"
#ring = "E"
#out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
#out_file.write("\n")
#out_file.write("\n")
#builded_string = "\nRUN_ID: " + RUN_ID + " TEST_START"
#out_file.puts(builded_string)
#out_file.close
#cpbf_master = "XP"
#apc = "APC_YM"
#puts("CPBF #{} is set to master")


$result_collector = []
prbs_test = true
# power ring E to reduced
#power_on, ring_list = power_on_ring_to_reduced(ring, apc, ARGV[1]) # Run with GUI
#power_on, ring_list = power_on_ring_to_reduced(ring, apc, RUN_ID) # Run with script runner


puts("_________________________Power micron On___________________________________")






powering = ModuleMicronRapidPower.new(board, options)

powering.power_up('PS2','TEST')
flag = true
flag = flag & move_ring_to_mode_and_validate("A", "REDUCED", $RUN_ID)
puts("******Ring A in reduced: #{flag}")
flag = flag & move_ring_to_mode_and_validate("B", "REDUCED", $RUN_ID)
puts("******Ring B in reduced: #{flag}")
flag = flag & move_ring_to_mode_and_validate("C", "REDUCED", $RUN_ID)
puts("******Ring C in reduced: #{flag}")
flag = flag & move_ring_to_mode_and_validate("D", "REDUCED", $RUN_ID)
puts("******Ring D in reduced: #{flag}")
flag = flag & move_ring_to_mode_and_validate("E", "REDUCED", $RUN_ID)
puts("******Ring E in reduced: #{flag}")


#____________________________________________________________________________

micron = MICRON_MODULE.new
# SET_ROUTING:  MicronID 109 LSL 34  (00100010) HSL 68  (01000100) WFD 81  TTD 33  [HS] (Location 17)
puts micron.set_micron_routing_param('MIC_LSL', 109, 0, 34, 68, 81, 33)
# SET_ROUTING:  MicronID 110 LSL 34  (00100010) HSL 144 (10010000) WFD 76  TTD 31  [HS] (Location 16)
puts micron.set_micron_routing_param('MIC_LSL', 122, 0, 34, 144, 81, 33)
# SET_ROUTING:  MicronID 123 LSL 34  (00100010) HSL 135 (10000111) WFD 76  TTD 31  [HS] (Location 16)
puts micron.set_micron_routing_param('MIC_LSL', 123, 0, 34, 135, 76, 31)

#if(flag)


    # # Test PRBS on ring E -hard codded with error force:
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=18, chk_micron_id=19, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=19, chk_micron_id=20, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=20, chk_micron_id=21, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=21, chk_micron_id=35, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3002, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=35, chk_micron_id=34, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=34, chk_micron_id=33, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=33, chk_micron_id=32, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=32, chk_micron_id=31, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=31, chk_micron_id=30, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=30, chk_micron_id=44, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3020, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=44, chk_micron_id=45, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=58, chk_micron_id=59, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=72, chk_micron_id=73, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=86, chk_micron_id=87, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=100, chk_micron_id=101, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=114, chk_micron_id=115, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=128, chk_micron_id=129, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=172, chk_micron_id=173, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=173, chk_micron_id=174, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=174, chk_micron_id=175, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2003, run_id_str=RUN_ID)
	
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=175, chk_micron_id=161, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x0302, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=161, chk_micron_id=160, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=160, chk_micron_id=159, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=159, chk_micron_id=158, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=158, chk_micron_id=157, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=157, chk_micron_id=156, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=156, chk_micron_id=142, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x0320, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=142, chk_micron_id=143, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=179, chk_micron_id=178, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=178, chk_micron_id=177, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=177, chk_micron_id=176, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2030, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=176, chk_micron_id=162, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x0320, run_id_str=RUN_ID)
	
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=162, chk_micron_id=163, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=163, chk_micron_id=164, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=164, chk_micron_id=165, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=165, chk_micron_id=166, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=166, chk_micron_id=167, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=167, chk_micron_id=153, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x0302, run_id_str=RUN_ID)
	
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=153, chk_micron_id=152, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=139, chk_micron_id=138, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=125, chk_micron_id=124, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=111, chk_micron_id=110, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=97, chk_micron_id=96, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=83, chk_micron_id=82, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=69, chk_micron_id=68, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=25, chk_micron_id=24, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=24, chk_micron_id=23, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=23, chk_micron_id=22, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0230, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=22, chk_micron_id=36, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3020, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=36, chk_micron_id=37, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=37, chk_micron_id=38, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=38, chk_micron_id=39, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=39, chk_micron_id=40, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=40, chk_micron_id=41, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0203, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=41, chk_micron_id=55, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3002, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=55, chk_micron_id=54, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	
	
#end

puts("----------------------------------------------- Reroute HSL 122,109, 123 back to defualt ---------------------------------------------------------------") 
#INFO: DPC is YM

# Rev 12



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

#power_off = power_off_ring(ring, apc, ARGV[1]) # Run with GUI
#power_off = power_off_ring(ring, apc, RUN_ID) # Run with script runner

powering.power_down('TEST')

if(power_on && prbs_test && power_off)
    testResult = "PASS"
end


puts("-------------------------------------------------------------------------------------------------")
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

out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult) # Run with GUI
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"  # Run with GUI
#out_file.puts("\nRUN_ID: " + RUN_ID + "TEST RESULT = " + testResult)  # Run with script runner
#builded_string = "RUN_ID: " + RUN_ID + " TEST_END"  # Run with script runner
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!