load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/CPBF/CPBF_MODULE.rb')

load_utility('Operations/MICRON/MICRON_PRBS no csv.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
#load_utility('Operations/Micron/turn_on_off_CPBF.rb')

require_relative 'MICRON_PRBS no csv'

include MICRON_PRBS

#$RUN_ID = "1234567891011180" #Tzvi Test rerouting ring A abd ringB

def Rerouting_HSL_rings_ABCD(board = "MIC_LSL")

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

	puts "********************************************************"
	puts "******Starting Sniffing Test To rings_A&B&C&D***********"
	puts "********************************************************"
	#TODO:Add run id
	#returnVal = power_on_ring_to_ps2("D",$RUN_ID)

	puts "********************************************************"
	puts "***********All MICRONS moved to PS2 ********************"
	puts "********************************************************"
	
	mm = MICRON_MODULE.new

	# Ring A + B +C +D

	microns_list = ["MICRON_104",
					"MICRON_103",
					"MICRON_102",
					"MICRON_101",
					"MICRON_118",
					"MICRON_117",
					"MICRON_116",
					"MICRON_115",
					"MICRON_119",
					"MICRON_133",
					"MICRON_132",
					"MICRON_131",
					"MICRON_130",
					"MICRON_147",
					"MICRON_146",
					"MICRON_145",
					"MICRON_144",
					"MICRON_120",
					"MICRON_134",
					"MICRON_135",
					"MICRON_136",
					"MICRON_137",
					"MICRON_138",
					"MICRON_148",
					"MICRON_149",
					"MICRON_150",
					"MICRON_151",
					"MICRON_152",
					"MICRON_107",
					"MICRON_108",
					"MICRON_109",
					"MICRON_110",
					"MICRON_121",
					"MICRON_122",
					"MICRON_123",
					"MICRON_124",
					"MICRON_93",
					"MICRON_94",
					"MICRON_95",
					"MICRON_96",
					"MICRON_79",
					"MICRON_80",
					"MICRON_81",
					"MICRON_82",
					"MICRON_78",
					"MICRON_64",
					"MICRON_65",
					"MICRON_66",
					"MICRON_67",
					"MICRON_68",
					"MICRON_50",
					"MICRON_51",
					"MICRON_52",
					"MICRON_53",
					"MICRON_54",
					"MICRON_77",
					"MICRON_63",
					"MICRON_62",
					"MICRON_61",
					"MICRON_60",
					"MICRON_59",
					"MICRON_49",
					"MICRON_48",
					"MICRON_47",
					"MICRON_46",
					"MICRON_45",
					"MICRON_90",
					"MICRON_89",
					"MICRON_88",
					"MICRON_87",
					"MICRON_76",
					"MICRON_75",
					"MICRON_74",
					"MICRON_73"
					]
	
	
	microns_list_redandency = [ "MICRON_104",
								"MICRON_118",
								"MICRON_117",
								"MICRON_103",
								"MICRON_116",
								"MICRON_102",
								"MICRON_115",
								"MICRON_101",
								"MICRON_119",
								"MICRON_120",
								"MICRON_134",
								"MICRON_133",
								"MICRON_147",
								"MICRON_146",
								"MICRON_132",
								"MICRON_131",
								"MICRON_130",
								"MICRON_129",
								"MICRON_143",
								"MICRON_144",
								"MICRON_145",
								"MICRON_148",
								"MICRON_149",
								"MICRON_135",
								"MICRON_136",
								"MICRON_150",
								"MICRON_137",
								"MICRON_138",
								"MICRON_152",
								"MICRON_151",
								"MICRON_121",
								"MICRON_122",
								"MICRON_123",
								"MICRON_124",
								"MICRON_110",
								"MICRON_109",
								"MICRON_108",
								"MICRON_107",
								"MICRON_93",
								"MICRON_79",
								"MICRON_80",
								"MICRON_94",
								"MICRON_81",
								"MICRON_95",
								"MICRON_82",
								"MICRON_96",
								"MICRON_78",
								"MICRON_77",
								"MICRON_63",
								"MICRON_64",
								"MICRON_50",
								"MICRON_51",
								"MICRON_65",
								"MICRON_66",
								"MICRON_67",
								"MICRON_68",
								"MICRON_54",
								"MICRON_53",
								"MICRON_52",
								"MICRON_49",
								"MICRON_48",
								"MICRON_62",
								"MICRON_61",
								"MICRON_60",
								"MICRON_59",
								"MICRON_47",
								"MICRON_46",
								"MICRON_45",
								"MICRON_60",
								"MICRON_76",
								"MICRON_75",
								"MICRON_74",
								"MICRON_73",
								"MICRON_87",
								"MICRON_88",
								"MICRON_89",
								"MICRON_90"]
 
	microns_sym = microns_list.map { |x| x.to_sym }

	connected_microns_list = []
	connected_microns_list_redandency = []


	micron_param_hash = {
						MICRON_77:[104,97,51,21],
						MICRON_63:[105,134,46,19],
						MICRON_62:[65,131,21,9],
						MICRON_61:[65,97,16,7],
						MICRON_60:[65,97,11,5],
						MICRON_59:[65,141,6,3],
						MICRON_49:[97,129,31,13],
						MICRON_48:[65,137,26,11],
						MICRON_47:[65,146,11,5],
						MICRON_46:[65,146,6,3],
						MICRON_45:[65,146,1,1],
						MICRON_78:[106,129,56,23],
						MICRON_79:[38,34,61,25],
						MICRON_80:[34,68,56,23],
						MICRON_81:[34,68,51,21],
						MICRON_82:[34,136,46,19],
						MICRON_93:[130,140,66,27],
						MICRON_94:[34,147,51,21],
						MICRON_95:[34,147,46,19],
						MICRON_96:[34,147,41,17],
						MICRON_64:[106,140,41,17],
						MICRON_65:[34,135,26,11],
						MICRON_66:[34,100,21,9],
						MICRON_67:[34,100,16,7],
						MICRON_68:[34,140,11,5],
						MICRON_50:[98,34,36,15],
						MICRON_51:[34,136,31,13],
						MICRON_52:[34,146,16,7],
						MICRON_53:[34,146,11,5],
						MICRON_54:[34,146,6,3],
						MICRON_90:[73,147,41,17],
						MICRON_89:[65,147,36,15],
						MICRON_88:[65,147,31,13],
						MICRON_87:[65,147,26,11],
						MICRON_76:[97,65,46,19],
						MICRON_75:[65,65,41,17],
						MICRON_74:[65,65,36,15],
						MICRON_73:[65,137,31,13],
						MICRON_104:[69,137,66,27],
						MICRON_103:[65,146,51,21],
						MICRON_102:[65,146,46,19],
						MICRON_101:[65,146,41,17],
						MICRON_118:[129,35,61,25],
						MICRON_117:[65,97,56,23],
						MICRON_116:[65,97,51,21],
						MICRON_115:[65,141,46,19],
						MICRON_107:[38,146,41,17],
						MICRON_108:[34,146,36,15],
						MICRON_109:[34,146,31,13],
						MICRON_110:[34,146,26,11],
						MICRON_121:[131,100,46,19],
						MICRON_120:[68,68,51,21],
						MICRON_134:[134,131,46,19],
						MICRON_135:[34,134,21,9],
						MICRON_136:[34,68,16,7],
						MICRON_137:[34,68,11,5],
						MICRON_138:[34,136,6,3],
						MICRON_148:[130,132,31,13],
						MICRON_149:[34,140,26,11],
						MICRON_150:[34,147,11,5],
						MICRON_151:[34,147,6,3],
						MICRON_152:[34,147,1,1],
						MICRON_122:[34,100,41,17],
						MICRON_123:[34,100,36,15],
						MICRON_124:[34,140,31,13],
						MICRON_119:[132,132,56,23],
						MICRON_133:[133,137,41,17],
						MICRON_132:[65,130,26,11],
						MICRON_131:[65,65,21,9],
						MICRON_130:[65,65,16,7],
						MICRON_129:[65,137,11,5],
						MICRON_147:[129,35,36,15],
						MICRON_146:[65,141,31,13],
						MICRON_145:[65,147,16,7],
						MICRON_144:[65,147,11,5],
						MICRON_143:[65,147,6,3]
						}

	chain_id = 0
	puts "********************************************************"
	puts "***********Check ping to all microns *******************"
	puts "********************************************************"
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
	puts "********************************************************"
	puts "***********ping test to all microns Done****************"
	puts "********************************************************"
	puts "***********move all microns to REDUCED mode ************"
	puts "********************************************************"
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
	puts "********************************************************"
	puts "***********all microns moved to REDUCED mode************"
	puts "********************************************************"	
	puts "**check read registe to all micron in defaulte routing *"
	puts "********************************************************"
	
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
	puts "********************************************************"
	puts "****  Checks HSL with defaulte routing Done ************"
	puts "********************************************************"
	puts "*********** change power mode to PS2 *******************"
	puts "********************************************************"
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
	puts "********************************************************"
	puts "***********All MICRONS moved to PS2 ********************"
	puts "********************************************************"	
	puts "**** rerouting to HSL only *****************************"
	puts "********************************************************"
	microns_sym = connected_microns_list.map { |x| x.to_sym }
	# Set rerouting to HSL (LSL not changing)
	for micron_id in microns_sym

		routing_ls = micron_param_hash[micron_id][0]
		routing_hs = micron_param_hash[micron_id][1]
		wfd = micron_param_hash[micron_id][2]
		ttd = micron_param_hash[micron_id][3]

		mm.set_micron_routing_param(board, micron_id, chain_id, routing_ls, routing_hs, wfd, ttd, converted=true, raw=false, wait_check_timeout=2)

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
	puts "********************************************************"
	puts "*************Rerouting HSL RingS A&B Done***************"
	puts "********************************************************"
	puts "************ Move to reduced power mode all microns ****" 
	puts "********************************************************"
	
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

	sleep 1 # if the all ring can be  0

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
	puts "********************************************************"
	puts "***********All MICRONS moved to Reduced  ***************"
	puts "********************************************************"
	puts "******** Check HSL  ************************************"
	puts "* Verify if the result in the registers: ***************"
	puts "*reg  0x140644 is 0x30000101) **************************"
	puts "*reg  0x100014 is micron ID)  **************************"
	puts "********************************************************"
	
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
	puts "********************************************************"
	puts "****  Checks Rerouting HSL Done ************************"
	puts "********************************************************"
	puts "****  starting testing PRBS to ring D only *************"
	puts "********************************************************"

	############# PRBS TEST ################

	# Test PRBS on ring D with error force
	test_prbs_micron_single_line(gen_micron_id=115, chk_micron_id=116, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=101, chk_micron_id=115, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=$RUN_ID)
	
	test_prbs_micron_single_line(gen_micron_id=129, chk_micron_id=130, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=143, chk_micron_id=129, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=$RUN_ID)
	
	test_prbs_micron_single_line(gen_micron_id=138, chk_micron_id=137, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=152, chk_micron_id=138, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=$RUN_ID)
	
	test_prbs_micron_single_line(gen_micron_id=124, chk_micron_id=123, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2030, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=110, chk_micron_id=124, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3002, run_id_str=$RUN_ID)
	

	test_prbs_micron_single_line(gen_micron_id=82, chk_micron_id=81, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=96, chk_micron_id=82, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=$RUN_ID)
	
	test_prbs_micron_single_line(gen_micron_id=68, chk_micron_id=67, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=54, chk_micron_id=68, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3002, run_id_str=$RUN_ID)
	
	test_prbs_micron_single_line(gen_micron_id=59, chk_micron_id=60, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=45, chk_micron_id=59, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=$RUN_ID)
	
	test_prbs_micron_single_line(gen_micron_id=73, chk_micron_id=74, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=$RUN_ID)
	test_prbs_micron_single_line(gen_micron_id=87, chk_micron_id=73, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=$RUN_ID)

	
	################# END PRBS TEST ########
	puts "********************************************************"
	puts "****   PRBS test to ring D only Done********************"
	puts "********************************************************"
    puts "****  Set all microns to the default routing ***********"
	puts "********************************************************"
	for micron_id in microns_list
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
	puts "********************************************************"
	puts "**** all microns in default routing ********************"
	puts "********************************************************"
	puts "***  set back power mode to PS2 ************************"
	puts "********************************************************"
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

	puts "***********All MICRONS moved to PS2 ********************"

	puts "********************************************************"
	puts "********************************************************"
	puts "***$$$ END Routing and Rerouting Sniffing +PRBS  $$$****"
	puts "***$$$ & PRBS Tests  to Rings A,B,C & D        $$$******"
	puts "********************************************************"

	puts "########################################################"
	puts "#########PowerOff All Microns !!!!!!!!!!!!!!############"
	retPowerOff = power_off_ring("D",$RUN_ID)
	
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
