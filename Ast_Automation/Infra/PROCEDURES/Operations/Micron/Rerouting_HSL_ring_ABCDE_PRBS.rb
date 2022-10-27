load('Operations/MICRON/MICRON_MODULE.rb')
load('Operations/CPBF/CPBF_MODULE.rb')

load_utility('Operations/MICRON/MICRON_PRBS no csv.rb')
load('Operations/Micron/TrajectoryControlFunctions.rb')
#load_utility('Operations/Micron/turn_on_off_CPBF.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/micron_rapid_power.rb')
load('Operations/MICRON/Routing/routing_operations_delegate_cosmos_lsl.rb')
load('Operations/MICRON/Routing/routing.rb')



require_relative 'MICRON_PRBS no csv'

include MICRON_PRBS

#$RUN_ID = "1234567891011182" 


def Rerouting_HSL_rings_ABCDE(board = "MIC_LSL")

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
	$RUN_ID = ARGV[1]
	out_file.puts(builded_string)
	out_file.close
	cpbf_master = ARGV[ARGV.length()-7].strip()
	apc = ARGV[ARGV.length()-5].strip
	puts("CPBF #{cpbf_master[-2..-1]} is set to master")


	options = RoutingOptions.hsl_reroute_ym
	options[:rings_filter] = ['A', 'B', 'C', 'D', 'E']
	options[:rings_chain_length] = true # Calculate maximum chain length according to ring

	puts "********************************************************"
	puts "****Starting PRBS rerouting Test To rings_A&B&C&D*******"
	puts "********************************************************"

	#TODO:Add run id
	puts "********************************************************"
	puts "***********Move microns to PS2 ********************"
	puts "********************************************************"
	
	

    

    board = 'MIC_LSL'

    powering = ModuleMicronRapidPower.new(board, options)

    powering.power_up('PS2','TEST')

	puts "********************************************************"
	puts "***********All MICRONS moved to PS2 ********************"
	puts "********************************************************"
	
	puts "********************************************************"	
	puts "********* rerouting to HSL only ************************"
	puts "********************************************************"


	# Ring A + B +C +D +E
	
    delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
    routing = Routing.new(options, delegate)
    routing.reroute


	puts "********************************************************"
	puts "*************Rerouting HSL RingS ABCDE Done***************"
	puts "********************************************************"
	puts "************ Move to reduced power mode all microns ****" 
	puts "********************************************************"

	flag = move_ring_to_mode_and_validate("A", "REDUCED", $RUN_ID)
	puts("******Ring A in reduced: #{flag}")
    flag = move_ring_to_mode_and_validate("B", "REDUCED", $RUN_ID)
	puts("******Ring B in reduced: #{flag}")
    flag = move_ring_to_mode_and_validate("C", "REDUCED", $RUN_ID)
	puts("******Ring C in reduced: #{flag}")
	flag = move_ring_to_mode_and_validate("D", "REDUCED", $RUN_ID)
	puts("******Ring D in reduced: #{flag}")
	flag = move_ring_to_mode_and_validate("E", "REDUCED", $RUN_ID)
	puts("******Ring E in reduced: #{flag}")

	puts "********************************************************"
	puts "***********All MICRONS moved to Reduced  ***************"
	puts "********************************************************"
	puts "****  starting testing PRBS to ring D only *************"
	puts "********************************************************"

	############# PRBS TEST ################

	# Test PRBS on ring D with error force
	test_prbs_micron_single_line(gen_micron_id=167, chk_micron_id=166, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=166, chk_micron_id=165, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=179, chk_micron_id=165, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=165, chk_micron_id=164, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=178, chk_micron_id=164, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=164, chk_micron_id=163, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
 	test_prbs_micron_single_line(gen_micron_id=177, chk_micron_id=163, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
 	test_prbs_micron_single_line(gen_micron_id=163, chk_micron_id=162, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0032, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=162, chk_micron_id=161, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=176, chk_micron_id=161, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x2032, run_id_str=$RUN_ID)
 	test_prbs_micron_single_line(gen_micron_id=175, chk_micron_id=161, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=161, chk_micron_id=160, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
 	test_prbs_micron_single_line(gen_micron_id=174, chk_micron_id=160, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=160, chk_micron_id=159, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
 	test_prbs_micron_single_line(gen_micron_id=173, chk_micron_id=159, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
 	test_prbs_micron_single_line(gen_micron_id=159, chk_micron_id=158, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
 	test_prbs_micron_single_line(gen_micron_id=172, chk_micron_id=158, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
 	test_prbs_micron_single_line(gen_micron_id=158, chk_micron_id=157, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0032, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=157, chk_micron_id=156, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2030, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=156, chk_micron_id=142, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x2300, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=142, chk_micron_id=128, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3200, chk_pcs_status=0x0320, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=128, chk_micron_id=129, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=153, chk_micron_id=139, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=139, chk_micron_id=138, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=114, chk_micron_id=100, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x2300, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=100, chk_micron_id=86, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3200, chk_pcs_status=0x2300, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=86, chk_micron_id=72, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3200, chk_pcs_status=0x2320, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=72, chk_micron_id=73, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=83, chk_micron_id=97, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3200, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=97, chk_micron_id=111, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x2300, chk_pcs_status=0x3200, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=111, chk_micron_id=125, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x2300, chk_pcs_status=0x3002, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=125, chk_micron_id=124, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=30, chk_micron_id=31, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=31, chk_micron_id=32, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=18, chk_micron_id=32, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=32, chk_micron_id=33, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=19, chk_micron_id=33, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=33, chk_micron_id=34, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=20, chk_micron_id=34, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=34, chk_micron_id=35, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x0023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=35, chk_micron_id=36, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=21, chk_micron_id=22, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0230, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=22, chk_micron_id=36, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3022, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=36, chk_micron_id=37, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=23, chk_micron_id=37, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=37, chk_micron_id=38, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=24, chk_micron_id=38, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=38, chk_micron_id=39, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=25, chk_micron_id=39, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=39, chk_micron_id=40, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=40, chk_micron_id=41, gen_micron_pcs=1, chk_micron_pcs=1, gen_pcs_status=0x0032, chk_pcs_status=0x0203, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=41, chk_micron_id=55, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3200, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=55, chk_micron_id=69, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x2300, chk_pcs_status=0x3002, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=69, chk_micron_id=68, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=44, chk_micron_id=58, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=58, chk_micron_id=59, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	
	################# END PRBS TEST ########
	puts "********************************************************"
	puts "****   PRBS test to ring E only Done********************"
	puts "********************************************************"
	
	
	puts "********************************************************"
	puts "************ Move to PS2 power mode all microns ****" 
	puts "********************************************************"

	flag = move_ring_to_mode_and_validate("E", "PS2", $RUN_ID)
	puts("******Ring E in reduced: #{flag}")
    flag = move_ring_to_mode_and_validate("D", "PS2", $RUN_ID)
	puts("******Ring D in reduced: #{flag}")
    flag = move_ring_to_mode_and_validate("C", "PS2", $RUN_ID)
	puts("******Ring C in reduced: #{flag}")
	flag = move_ring_to_mode_and_validate("B", "PS2", $RUN_ID)
	puts("******Ring B in reduced: #{flag}")
	flag = move_ring_to_mode_and_validate("A", "PS2", $RUN_ID)
	puts("******Ring A in reduced: #{flag}")

	puts "********************************************************"
	puts "***********All MICRONS moved to PS2  ***************"
	puts "********************************************************"
	
	puts "********************************************************"
    puts "****  Set all microns to the default routing ***********"
	puts "********************************************************"

    micron = MICRON_MODULE.new
    routing.reroute_default

    puts micron.set_micron_routing_param('MIC_LSL', 109, 0, 34, 68, 81, 33)
    puts micron.set_micron_routing_param('MIC_LSL', 122, 0, 34, 144, 81, 33)
    puts micron.set_micron_routing_param('MIC_LSL', 123, 0, 34, 135, 76, 31)


	puts "********************************************************"
	puts "**** all microns in default routing ********************"
	puts "********************************************************"
	puts "***  set back power mode to PS2 ************************"
	puts "********************************************************"

	puts "***********All MICRONS moved to PS2 ********************"

	puts "********************************************************"
	puts "********************************************************"
	puts "***$$$            END Rerouting PRBS  $$$           ****"
	puts "***$$$ & PRBS Tests  to Rings A,B,C & D        $$$******"
	puts "********************************************************"

	puts "########################################################"
	puts "#########PowerOff All Microns !!!!!!!!!!!!!!############"
	#retPowerOff = power_off_ring("E",$RUN_ID)
	powering.power_down('TEST')
	
	out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
	out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult) # Run with GUI
	builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"  # Run with GUI
	#out_file.puts("\nRUN_ID: " + RUN_ID + "TEST RESULT = " + testResult)  # Run with script runner
	#builded_string = "RUN_ID: " + RUN_ID + " TEST_END"  # Run with script runner
	out_file.puts(builded_string)
	out_file.close
	STDOUT.write '\n\n'
	exit!

end



# read register function
$c = ModuleCPBF.new
def read_micron_reg(micron_id, regaddr)
    rw_flag = 0 # read
    data = 0x0  # Ignored if rw_flag = 0
    timeout = 1000
    recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, regaddr, data, timeout)[0]
    data = recv["CPBF_REG_DATA"]
    puts("[DEBUG] MICRON REG #{regaddr}, DATA: #{data}")
    return data
end

def dec2hex(number)

    number.to_s(16)

end
