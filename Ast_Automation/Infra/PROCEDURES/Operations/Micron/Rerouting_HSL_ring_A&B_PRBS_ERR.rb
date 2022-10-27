load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/CPBF/CPBF_MODULE.rb')

load_utility('Operations/MICRON/MICRON_PRBS no csv.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
#load_utility('Operations/Micron/turn_on_off_CPBF.rb')

require_relative 'MICRON_PRBS no csv'

include MICRON_PRBS

#$RUN_ID = "1234567891011160" #Tzvi Test rerouting ring A abd ringB

def Rerouting_HSL_rings_AB(board = "MIC_LSL")

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

	puts "***********Starting Sniffing Test To rings_A&B *********************"

	#TODO:Add run id
	returnVal = power_on_ring_to_ps2("B",$RUN_ID)


	puts "***********All MICRONS moved to PS2 *********************"

	mm = MICRON_MODULE.new

	# Ring A + B

	microns_list = ["MICRON_104", "MICRON_118", "MICRON_119", "MICRON_117", "MICRON_103", "MICRON_120", "MICRON_121", "MICRON_107", "MICRON_122", "MICRON_108", "MICRON_134", "MICRON_133", "MICRON_93", "MICRON_79", "MICRON_80", "MICRON_94", "MICRON_78", "MICRON_77", "MICRON_76", "MICRON_90", "MICRON_75", "MICRON_89", "MICRON_63", "MICRON_64"]
	all_microns_list = ["MICRON_104", "MICRON_118", "MICRON_119", "MICRON_117", "MICRON_103", "MICRON_120", "MICRON_121", "MICRON_107", "MICRON_122", "MICRON_108", "MICRON_134", "MICRON_133", "MICRON_78", "MICRON_79", "MICRON_80", "MICRON_93", "MICRON_94", "MICRON_77", "MICRON_76", "MICRON_90", "MICRON_75", "MICRON_89", "MICRON_63", "MICRON_64", "MICRON_132", "MICRON_131", "MICRON_135", "MICRON_136", "MICRON_65", "MICRON_66", "MICRON_62", "MICRON_61"]
	microns_list_redandency = ["MICRON_104", "MICRON_118", "MICRON_117", "MICRON_103", "MICRON_119", "MICRON_120", "MICRON_134", "MICRON_133", "MICRON_121", "MICRON_107", "MICRON_122", "MICRON_108", "MICRON_93", "MICRON_79", "MICRON_80", "MICRON_94", "MICRON_78", "MICRON_77", "MICRON_63", "MICRON_64", "MICRON_76", "MICRON_90", "MICRON_75", "MICRON_89"]
	microns_sym = microns_list.map { |x| x.to_sym }

	connected_microns_list = []
	connected_microns_list_redandency = []


	micron_param_hash = {
						MICRON_104:[69,137,56,23],
						MICRON_118:[129,7,51,21],
						MICRON_119:[132,132,46,19],
						MICRON_117:[65,141,46,19],
						MICRON_103:[65,146,41,17],
						MICRON_120:[68,68,41,17],
						MICRON_121:[131,100,36,15],
						MICRON_107:[38,146,31,13],
						MICRON_122:[34,140,31,13],
						MICRON_108:[34,146,26,11],
						MICRON_134:[134,131,36,15],
						MICRON_133:[133,145,31,13],
						MICRON_93:[130,140,56,23],
						MICRON_79:[38,34,51,21],
						MICRON_80:[34,136,46,19],
						MICRON_94:[34,147,41,17],
						MICRON_78:[106,129,46,19],
						MICRON_77:[104,97,41,17],
						MICRON_76:[97,65,36,15],
						MICRON_90:[73,147,31,13],
						MICRON_75:[65,137,31,13],
						MICRON_89:[65,147,26,11],
						MICRON_63:[105,134,36,15],
						MICRON_64:[106,144,31,13]
						}

	chain_id = 0

	## Move to reduced power mode all microns
	for micron_id in microns_list

		# send ping to micron
		ping_res = mm.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2, num_tries=3)
		# returned status is 0 or 1
		puts "ping result is #{ping_res}"
		if ping_res == false
		   puts "!!!!!!!!!! Unable to ping micron #{micron_id}. Continuing to next micron. !!!!!!!!!!"
		   next
		else
		   puts "******* ping succeeded to micron #{micron_id}. Continuing to next micron. *******"
		end

		next_power_mode = "REDUCED"
		mm.set_system_power_mode(board, micron_id, next_power_mode, true, false)[0]
		connected_microns_list.append(micron_id)

	end

	sleep 3

	for micron_id in connected_microns_list

		get_power_mode_hash_converted = mm.get_system_power_mode(board, micron_id, true, false)[0]
		power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]

		if power_mode_status=="REDUCED"
		   puts "****** Micron: #{micron_id}: Power mode set correctly to REDUCED mode - status ok. ******"
		   puts "****** Micron: #{micron_id}: CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - status ok. ******"
		else
		   puts "!!!!!! Micron: #{micron_id} - Error State - power mode do not change to REDUCED from ps2. !!!!!!"
		end

	end

	# Check HSL (Verify if the result in the register 0x140644 is 0x30000101)
	reg_add = 0x140644
	for micron_id in microns_list
		reg_data = read_micron_reg(micron_id, reg_add)
		if reg_data == 0x30000101
		   puts "******  Micron: #{micron_id} - Result in register 0x140644 Verified, Result: 0x#{dec2hex(reg_data)}. ******"
		   reg_data = read_micron_reg(micron_id,0x100014)
		   puts "******  Micron: #{micron_id} - Result in register 0x100014 Verified, Result: #{(reg_data)}. ******"
		else
		   puts "!!!!!!! Micron: #{micron_id} - Unmatch result in register 0x140644, Result: 0x#{dec2hex(reg_data)}. !!!!!!!"
		end

	end
	puts "****  Checks HSL Done ***********************"

	# change power mode to PS2
	for micron_id in connected_microns_list

		# change power mode to PS2
		next_power_mode = "PS2"
		set_power_mode_hash_converted = mm.set_system_power_mode(board="MIC_LSL", micron_id, next_power_mode, true, false)[0]

		if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
		   puts "!!!!!!!!!! Micron: #{micron_id} Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]} !!!!!!!!!!"
		end

	end

	for micron_id in connected_microns_list

		get_power_mode_hash_converted = mm.get_system_power_mode(board="MIC_LSL", micron_id, true, false)[0]
		power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]

		if power_mode_status == "PS2"
		   puts "****** CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id} ******"
		else
		   puts "!!!!!! ERROR at changing POWER_MODE to PS2 for #{micron_id}: result is #{power_mode_status} !!!!!!"
		end

	end
	puts "***********All MICRONS moved to PS2 *********************"

	microns_sym = connected_microns_list.map { |x| x.to_sym }
	# Set rerouting to HSL (LSL not changing)
	for micron_id in microns_sym

		routing_ls = micron_param_hash[micron_id][0]
		routing_hs = micron_param_hash[micron_id][1]
		wfd = micron_param_hash[micron_id][2]
		ttd = micron_param_hash[micron_id][3]

		mm.set_micron_routing_param(board, micron_id, chain_id, routing_ls, routing_hs, wfd, ttd, converted=true, raw=false, wait_check_timeout=2)

	end

	puts "******************Rerouting HSL RingS A&B Done********************"


	# Move to reduced power mode all microns
	for micron_id in microns_list_redandency

		# send ping to micron
		ping_res = mm.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2, num_tries=3)
		# returned status is 0 or 1
		puts "ping result is #{ping_res}"
		if ping_res == false
		   puts "!!!!!!!!!! Unable to ping micron #{micron_id}. Continuing to next micron. !!!!!!!!!!"
		   next
		else
		   puts "******* ping succeeded to micron #{micron_id}. Continuing to next micron. *******"
		end

		next_power_mode = "REDUCED"
		mm.set_system_power_mode(board, micron_id, next_power_mode, true, false)[0]
		connected_microns_list_redandency.append(micron_id)
	end

	sleep 5 # if the all ring can be  0

	for micron_id in connected_microns_list_redandency

		get_power_mode_hash_converted = mm.get_system_power_mode(board, micron_id, true, false)[0]
		power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]

		if power_mode_status=="REDUCED"
		   puts "****** Micron: #{micron_id}: Power mode set correctly to REDUCED mode - status ok. ******"
		   puts "****** Micron: #{micron_id}: CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - status ok. ******"
		else
		   puts "!!!!!! Micron: #{micron_id} - Error State - power mode do not change to REDUCED from ps2. !!!!!!"
		end

	end
	puts "***********All MICRONS moved to Reduced  *********************"

	# Check HSL (Verify if the result in the register 0x140644 is 0x30000101)
	reg_add = 0x140644
	for micron_id in microns_list_redandency
		reg_data = read_micron_reg(micron_id, reg_add)
		if reg_data == 0x30000101
		   puts "******  Micron: #{micron_id} - Result in register 0x140644 Verified, Result: 0x#{dec2hex(reg_data)}. ******"
		   reg_data = read_micron_reg(micron_id,0x100014)
		   puts "******  Micron: #{micron_id} - Result in register 0x100014 Verified, Result: #{(reg_data)}. ******"
		else
		   puts "!!!!!!! Micron: #{micron_id} - Unmatch result in register 0x140644, Result: 0x#{dec2hex(reg_data)}. !!!!!!!"
		end

	end
	puts "****  Checks Rerouting HSL Done ***********************"


	############# PRBS TEST ################
	#tests PRBS to MB A=>> 93,79,78,77,76,90
	#				  B=>> 75,89,63,64,80,94
	# Test PRBS on ring A with error force
	#test_prbs_micron_cpbf_single_link_err_force(micron_id=93, link=3, micron_pcs=0, pcs_status=0x2003, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=79, chk_micron_id=93, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0322, chk_pcs_status=0x3003, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=78, chk_micron_id=79, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0323, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=77, chk_micron_id=78, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x0033, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=76, chk_micron_id=77, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0232, chk_pcs_status=0x2033, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=90, chk_micron_id=76, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0332, run_id_str=$RUN_ID)

	# Test PRBS on ring B with error force
	test_prbs_micron_single_line_err_force(gen_micron_id=75, chk_micron_id=76, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=89, chk_micron_id=75, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0330, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=63, chk_micron_id=77, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3022, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=64, chk_micron_id=63, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0330, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=80, chk_micron_id=79, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=94, chk_micron_id=80, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0303, run_id_str=$RUN_ID)


	#####################################################################
	#tests PRBS to MB A=>> 104,118,119,120,121,107
	#				  B=>> 122,108,134,133,117,103

	# Test PRBS on ring A with error force
	#test_prbs_micron_cpbf_single_link_err_force(micron_id=104, link=7, micron_pcs=1, pcs_status=0x0230, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=118, chk_micron_id=104, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3022, chk_pcs_status=0x0330, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=119, chk_micron_id=118, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x3032, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=120, chk_micron_id=119, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0033, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=121, chk_micron_id=120, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2023, chk_pcs_status=0x0233, run_id_str=$RUN_ID)
	#test_prbs_micron_single_line_err_force(gen_micron_id=107, chk_micron_id=121, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3023, run_id_str=$RUN_ID)

	# Test PRBS on ring B with error force
	test_prbs_micron_single_line_err_force(gen_micron_id=122, chk_micron_id=121, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=108, chk_micron_id=122, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3003, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=134, chk_micron_id=120, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x0322, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=133, chk_micron_id=134, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x3003, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=117, chk_micron_id=118, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line_err_force(gen_micron_id=103, chk_micron_id=117, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3030, run_id_str=$RUN_ID)

	################# END PRBS TEST ########


    # Set all microns to the default routing
	for micron_id in all_microns_list
		set_default_routing_table_res = mm.set_micron_default_routing_param(board, micron_id, converted=true, raw=false, wait_check_timeout=2)[0]
		micron_num = set_default_routing_table_res["MICRON_ID"]
		status_code = set_default_routing_table_res["MIC_ERROR_CODE"]
		if status_code == 0
		   puts "****** Micron: #{micron_num} - set to default routing, Status code: #{status_code} - Status OK. ******"

		else
		   puts "!!!!!! Micron: #{micron_num} - didn't set back to default routing !!!!!!"
		end

		get_routing_table_res = mm.get_micron_default_routing(board, micron_id, converted=true, raw=false, wait_check_timeout=2)[0]
		micron_param = get_routing_table_res["MICRON_ID"]
		lsl_param = get_routing_table_res["MIC_CURRENT_ROUTING_LOW_SPEED"]
		hsl_param = get_routing_table_res["MIC_CURRENT_ROUTING_HIGH_SPEED"]
		wfd_param = get_routing_table_res["MIC_CURRENT_ROUTING_WHOLE_FRAME_DELAY"]
		ttd_param = get_routing_table_res["MIC_CURRENT_ROUTING_TIME_TAG_DELAY"]
		puts "Micron: #{micron_param}"
		puts "LSL: #{lsl_param}"
		puts "HSL: #{hsl_param}"
		puts "WFD: #{wfd_param}"
		puts "TTD: #{ttd_param}"

	end

	# set back power mode to PS2
	for micron_id in connected_microns_list_redandency

		# change power mode to PS2
		next_power_mode = "PS2"
		set_power_mode_hash_converted = mm.set_system_power_mode(board="MIC_LSL", micron_id, next_power_mode, true, false)[0]

		if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
		   puts "!!!!!!!!!! Micron: #{micron_id} Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]} !!!!!!!!!!"
		end

	end

	for micron_id in connected_microns_list_redandency

		get_power_mode_hash_converted = mm.get_system_power_mode(board="MIC_LSL", micron_id, true, false)[0]
		power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]

		if power_mode_status == "PS2"
		   puts "****** CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id} ******"
		else
		   puts "!!!!!! ERROR at changing POWER_MODE to PS2 for #{micron_id}: result is #{power_mode_status} !!!!!!"
		end

	end

	puts "***********All MICRONS moved to PS2 *********************"

	puts "********************************************************"
	puts "********************************************************"
	puts "***$$$ END Routing and Rerouting Sniffing      $$$******"
	puts "***$$$ & PRBS Tests  to Rings A and B          $$$******"
	puts "********************************************************"

	puts "########################################################"
	puts "#########PowerOff All Microns !!!!!!!!!!!!!!############"
	retPowerOff = power_off_ring("B",$RUN_ID)
	
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
