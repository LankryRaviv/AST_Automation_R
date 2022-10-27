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
	#options[:rings_filter] = ['A', 'B', 'C', 'D', 'E']
	#options[:rings_chain_length] = true # Calculate maximum chain length according to ring

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
	flag = move_ring_to_mode_and_validate("F", "REDUCED", $RUN_ID)
	puts("******Ring F in reduced: #{flag}")

	puts "********************************************************"
	puts "***********All MICRONS moved to Reduced  ***************"
	puts "********************************************************"
	puts "****  starting testing PRBS to ring D only *************"
	puts "********************************************************"

	############# PRBS TEST ################

	# Test PRBS on ring D with error force
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=4, chk_micron_id=5, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=5, chk_micron_id=6, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=6, chk_micron_id=7, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0223, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=7, chk_micron_id=21, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0322, chk_pcs_status=0x3022, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=11, chk_micron_id=10, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=10, chk_micron_id=9, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=9, chk_micron_id=8, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=8, chk_micron_id=7, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0232, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=186, chk_micron_id=187, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=187, chk_micron_id=188, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=188, chk_micron_id=189, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=189, chk_micron_id=190, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2023, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=193, chk_micron_id=192, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=192, chk_micron_id=191, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=191, chk_micron_id=190, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2030, run_id_str=RUN_ID)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=190, chk_micron_id=176, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x2322, run_id_str=RUN_ID)
	
 	
	################# END PRBS TEST ########
	puts "********************************************************"
	puts "****   PRBS test to ring E only Done********************"
	puts "********************************************************"
	
	
	puts "********************************************************"
	puts "************ Move to PS2 power mode all microns ****" 
	puts "********************************************************"

	flag = move_ring_to_mode_and_validate("F", "PS2", $RUN_ID)
	puts("******Ring F in reduced: #{flag}")
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
