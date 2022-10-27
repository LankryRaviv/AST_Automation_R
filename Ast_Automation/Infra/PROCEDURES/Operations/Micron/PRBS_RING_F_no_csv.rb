load('Operations/Micron/TrajectoryControlFunctions.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/micron_rapid_power.rb')
load('Operations/MICRON/Routing/routing_operations_delegate_cosmos_lsl.rb')
load('Operations/MICRON/Routing/routing.rb')
load('Operations/MICRON/MICRON_MODULE.rb')
load('Operations/FSW/FSW_DPC.rb')

board = "MIC_LSL"
options = RoutingOptions.hsl_reroute_ym
#options[:rings_filter] = ['A','B','C','D', 'E', 'F']
#options[:rings_chain_length] = true # Calculate maximum chain length according to ring

delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
routing = Routing.new(options, delegate)
micron = MICRON_MODULE.new


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
puts("CPBF #{cpbf_master[-2..-1]} is set to master")



# Run with Script Runner
#RUN_ID = "21111111111111110"
#ring = "F"
#out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
#out_file.write("\n")
#out_file.write("\n")
#builded_string = "\nRUN_ID: " + RUN_ID + " TEST_START"
#out_file.puts(builded_string)
#out_file.close
#cpbf_master = "XP"
#apc = "APC_YM"
#puts("CPBF #{cpbf_master} is set to master")


$result_collector = []
prbs_test = true
# power ring D to reduced
#power_on, ring_list = power_on_ring_to_reduced(ring, apc, ARGV[1]) # Run with GUI
#power_on, ring_list = power_on_ring_to_reduced(ring, apc, RUN_ID) # Run with script runner


puts("_________________________Power micron On___________________________________")



powering = ModuleMicronRapidPower.new(board, options)

powering.power_up('PS2','TEST')

puts("_________________________Back to defualt HSL routing___________________________________")

routing.reroute_default

# Reroute fix to bypass micron 35

# SET_ROUTING:  MicronID 34  LSL 34  (00100010) HSL 140 (10001100) WFD 31  TTD 13  [HS] (Location 7 )
puts micron.set_micron_routing_param('MIC_LSL', 34, 0, 34, 140, 31, 13)
# SET_ROUTING:  MicronID 35  LSL 40  (00101000) HSL 147 (10010011) WFD 16  TTD 7   [HS] (Location 4 )
puts micron.set_micron_routing_param('MIC_LSL', 35, 0, 40, 147, 16, 7)
# SET_ROUTING:  MicronID 21  LSL 105 (01101001) HSL 104 (01101000) WFD 21  TTD 9   [HS] (Location 5 )
puts micron.set_micron_routing_param('MIC_LSL', 21, 0, 105, 104, 21, 9)
# SET_ROUTING:  MicronID 20  LSL 65  (01000001) HSL 34  (00100010) WFD 26  TTD 11  [HS] (Location 6 )
puts micron.set_micron_routing_param('MIC_LSL', 20, 0, 65, 34, 26, 11)
# SET_ROUTING:  MicronID 19  LSL 65  (01000001) HSL 129 (10000001) WFD 21  TTD 9   [HS] (Location 5 )
puts micron.set_micron_routing_param('MIC_LSL', 19, 0, 65, 129, 21, 9)
# SET_ROUTING:  MicronID 18  LSL 64  (01000000) HSL 145 (10010001) WFD 16  TTD 7   [HS] (Location 4 )
puts micron.set_micron_routing_param('MIC_LSL', 18, 0, 64, 145, 16, 7)


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
flag = flag & move_ring_to_mode_and_validate("F", "REDUCED", $RUN_ID)
puts("******Ring F in reduced: #{flag}")


#____________________________________________________________________________




#if(flag)


    # # Test PRBS on ring E -hard codded with error force:
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=4, chk_micron_id=5, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=5, chk_micron_id=6, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=6, chk_micron_id=7, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0223, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=7, chk_micron_id=21, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3202, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=11, chk_micron_id=10, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=10, chk_micron_id=9, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=9, chk_micron_id=8, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0230, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=8, chk_micron_id=22, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3220, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=186, chk_micron_id=187, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=187, chk_micron_id=188, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=188, chk_micron_id=189, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2003, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=189, chk_micron_id=175, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x2302, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=193, chk_micron_id=192, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=192, chk_micron_id=191, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=191, chk_micron_id=190, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2030, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=190, chk_micron_id=176, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x2320, run_id_str=RUN_ID)
	
	
#end

puts("----------------------------------------------- Reroute HSL 122,109, 123 back to defualt ---------------------------------------------------------------") 
#INFO: DPC is YM

# Rev 12



# Reroute back to defaulte mic35

puts micron.set_micron_default_routing_param('MIC_LSL', 18)
puts micron.set_micron_default_routing_param('MIC_LSL', 19)
puts micron.set_micron_default_routing_param('MIC_LSL', 20)
puts micron.set_micron_default_routing_param('MIC_LSL', 21)
puts micron.set_micron_default_routing_param('MIC_LSL', 35)
puts micron.set_micron_default_routing_param('MIC_LSL', 34)

puts("-----------------------------------------------------------------------------------------------------------------------------------------------------")
puts("---------------------------------------------------------------- Power off Microns ------------------------------------------------------------------")

#power_off = power_off_ring(ring, apc, ARGV[1]) # Run with GUI
#power_off = power_off_ring(ring, apc, RUN_ID) # Run with script runner

flag = true
flag = flag & move_ring_to_mode_and_validate("A", "PS2", $RUN_ID)
puts("******Ring A in PS2: #{flag}")
flag = flag & move_ring_to_mode_and_validate("B", "PS2", $RUN_ID)
puts("******Ring B in PS2: #{flag}")
flag = flag & move_ring_to_mode_and_validate("C", "PS2", $RUN_ID)
puts("******Ring C in PS2: #{flag}")
flag = flag & move_ring_to_mode_and_validate("D", "PS2", $RUN_ID)
puts("******Ring D in PS2: #{flag}")
flag = flag & move_ring_to_mode_and_validate("E", "PS2", $RUN_ID)
puts("******Ring E in PS2: #{flag}")
flag = flag & move_ring_to_mode_and_validate("F", "PS2", $RUN_ID)
puts("******Ring F in PS2: #{flag}")



#powering.power_down('TEST')

if(power_on && prbs_test && flag)
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