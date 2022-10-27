load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/CPBF/CPBF_MODULE.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
#load_utility('Operations/Micron/turn_on_off_CPBF.rb')

$RUN_ID = "1234567891011150" #Tzvi Test rerouting ring A only



def Sniffing_Test_ring_A(board = "MIC_LSL")
    
	puts "***********Starting Sniffing Test To ring_A *********************"
##TODO:Add run id
#returnVal = power_on_ring_to_ps2("A",$RUN_ID)
##CPBF=ModuleCPBF.New
##CPBF.set
#
#puts "***********All MICRONS moved to PS2 *********************"
#
#mm = MICRON_MODULE.new
#
## Ring A
#
#microns_list = ["MICRON_104", "MICRON_118", "MICRON_119", "MICRON_107", "MICRON_121", "MICRON_120", "MICRON_78", "MICRON_79", "MICRON_93", "MICRON_77", "MICRON_90", "MICRON_76"]
#microns_list_redandency = ["MICRON_104", "MICRON_118", "MICRON_119", "MICRON_120", "MICRON_121", "MICRON_107", "MICRON_93", "MICRON_79", "MICRON_78", "MICRON_77", "MICRON_76", "MICRON_90"]
#microns_sym = microns_list.map { |x| x.to_sym }
#
#connected_microns_list = []
#connected_microns_list_redandency = []
#
#micron_param_hash = {
#					MICRON_104:[69,137,26,11],
#					MICRON_118:[129,135,21,9], 
#					MICRON_119:[132,132,16,7],
#					MICRON_107:[38,146,1,1], 
#					MICRON_121:[130,140,6,3], # LSL was 130 , new routing 131
#                    MICRON_120:[132,132,11,5], # LSL was 132  , new routing 68						
#		            MICRON_78:[106,129,16,7],  # LSL was 104
#					MICRON_79:[38,130,21,9],   # LSL was 98
#					MICRON_93:[130,140,26,11], # LSL was 42
#					MICRON_77:[104,129,11,5],  
#					MICRON_76:[97,137,6,3],
#					MICRON_90:[73,147,1,1]
#					}
#
#chain_id = 0
#
## Move to reduced power mode all microns 
#for micron_id in microns_list
#
#    # send ping to micron 
#    ping_res = mm.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2)
#    # returned status is 0 or 1
#	puts "ping result is #{ping_res}"
#    if ping_res == false
#       puts "!!!!!!!!!! Unable to ping micron #{micron_id}. Continuing to next micron. !!!!!!!!!!"
#       next
#	else
#	   puts "******* ping succeeded to micron #{micron_id}. Continuing to next micron. *******"
#    end
#	
#    next_power_mode = "REDUCED"
#    mm.set_system_power_mode(board, micron_id, next_power_mode, true, false)[0]
#	connected_microns_list.append(micron_id)
#	
#end
#
#sleep 5
#
#for micron_id in connected_microns_list
#
#    get_power_mode_hash_converted = mm.get_system_power_mode(board, micron_id, true, false)[0]
#    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
#	
#	if power_mode_status=="REDUCED"
#	   puts "****** Micron: #{micron_id}: Power mode set correctly to REDUCED mode - status ok. ******"
#       puts "****** Micron: #{micron_id}: CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - status ok. ******"   
#	else
#	   puts "!!!!!! Micron: #{micron_id} - Error State - power mode do not change to REDUCED from ps2. !!!!!!"
#	end
#	 	
#end
#
## Check HSL (Verify if the result in the register 0x140644 is 0x30000101)
#reg_add = 0x140644
#for micron_id in microns_list
#    reg_data = read_micron_reg(micron_id, reg_add)
#	if reg_data == 0x30000101
#	   puts "******  Micron: #{micron_id} - Result in register 0x140644 Verified, Result: 0x#{dec2hex(reg_data)}. ******"
#	else
#	   puts "!!!!!!! Micron: #{micron_id} - Unmatch result in register 0x140644, Result: 0x#{dec2hex(reg_data)}. !!!!!!!"
#	end	
#		
#end
#puts "****  Checks HSL Done ***********************"
#
## change power mode to PS2 
#for micron_id in connected_microns_list
# 
#    # change power mode to PS2
#    next_power_mode = "PS2"
#    set_power_mode_hash_converted = mm.set_system_power_mode(board="MIC_LSL", micron_id, next_power_mode, true, false)[0]
#    sleep 2
#	
#    if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
#       puts "!!!!!!!!!! Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]} !!!!!!!!!!"
#    end 
#	
#    get_power_mode_hash_converted = mm.get_system_power_mode(board="MIC_LSL", micron_id, true, false)[0]
#    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
#	
#    if power_mode_status == "PS2"
#       puts "****** CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id} ******"
#    else
#       puts "!!!!!! ERROR at changing POWER_MODE to PS2 for #{micron_id}: result is #{power_mode_status} !!!!!!"
#    end
#	   
#end
#puts "***********All MICRONS moved to PS2 *********************"
#
#microns_sym = connected_microns_list.map { |x| x.to_sym }
## Set rerouting to HSL (LSL not changing)
#for micron_id in microns_sym
#    
#	routing_ls = micron_param_hash[micron_id][0]
#    routing_hs = micron_param_hash[micron_id][1]
#    wfd = micron_param_hash[micron_id][2]
#    ttd = micron_param_hash[micron_id][3]
#  			
#    mm.set_micron_routing_param(board, micron_id, chain_id, routing_ls, routing_hs, wfd, ttd, converted=true, raw=false, wait_check_timeout=2)
#	
#end
#
#puts "******************Rerouting HSL Ring A Done********************"
#
#
## Move to reduced power mode all microns 
#for micron_id in microns_list_redandency
#
#    # send ping to micron 
#    ping_res = mm.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2)
#    # returned status is 0 or 1
#	puts "ping result is #{ping_res}"
#    if ping_res == false
#       puts "!!!!!!!!!! Unable to ping micron #{micron_id}. Continuing to next micron. !!!!!!!!!!"
#       next
#	else
#	   puts "******* ping succeeded to micron #{micron_id}. Continuing to next micron. *******"
#    end
#	
#    next_power_mode = "REDUCED"
#    mm.set_system_power_mode(board, micron_id, next_power_mode, true, false)[0]
#	connected_microns_list_redandency.append(micron_id)
#end
#
#sleep 5
#
#for micron_id in connected_microns_list_redandency
#
#    get_power_mode_hash_converted = mm.get_system_power_mode(board, micron_id, true, false)[0]
#    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
#	
#	if power_mode_status=="REDUCED"
#	   puts "****** Micron: #{micron_id}: Power mode set correctly to REDUCED mode - status ok. ******"
#       puts "****** Micron: #{micron_id}: CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - status ok. ******"   
#	else
#	   puts "!!!!!! Micron: #{micron_id} - Error State - power mode do not change to REDUCED from ps2. !!!!!!"
#	end
#	 	
#end
#puts "***********All MICRONS moved to Reduced  *********************"
#
## Check HSL (Verify if the result in the register 0x140644 is 0x30000101)
#reg_add = 0x140644
#for micron_id in connected_microns_list_redandency
#    reg_data = read_micron_reg(micron_id, reg_add)
#	if reg_data == 0x30000101
#	   puts "******  Micron: #{micron_id} - Result in register 0x140644 Verified, Result: 0x#{dec2hex(reg_data)}. ******"
#	else
#	   puts "!!!!!!! Micron: #{micron_id} - Unmatch result in register 0x140644, Result: 0x#{dec2hex(reg_data)}. !!!!!!!"
#	end	
#		
#end
#puts "****  Checks Rerouting HSL Done ***********************"
#
############## PRBS TEST ################
#
#
################## END PRBS TEST ########
#
#
## Set all microns to the default routing
#for micron_id in connected_microns_list
#    set_default_routing_table_res = mm.set_micron_default_routing_param(board, micron_id, converted=true, raw=false, wait_check_timeout=2)[0]
#	micron_num = set_default_routing_table_res["MICRON_ID"]
#	status_code = set_default_routing_table_res["MIC_ERROR_CODE"] 		
#	if status_code == 0
#	puts "****** Micron: #{micron_num} - set to default routing, Status code: #{status_code} - Status OK. ******"
#	
#    else
#	puts "!!!!!! Micron: #{micron_num} - didn't set back to default routing !!!!!!"
#    end
#	
#    get_routing_table_res = mm.get_micron_default_routing(board, micron_id, converted=true, raw=false, wait_check_timeout=2)[0]
#	micron_param = get_routing_table_res["MICRON_ID"]
#	lsl_param = get_routing_table_res["MIC_CURRENT_ROUTING_LOW_SPEED"]
#	hsl_param = get_routing_table_res["MIC_CURRENT_ROUTING_HIGH_SPEED"]
#	wfd_param = get_routing_table_res["MIC_CURRENT_ROUTING_WHOLE_FRAME_DELAY"]
#	ttd_param = get_routing_table_res["MIC_CURRENT_ROUTING_TIME_TAG_DELAY"]
#	puts "Micron: #{micron_param}"
#	puts "LSL: #{lsl_param}"
#	puts "HSL: #{hsl_param}"
#	puts "WFD: #{wfd_param}"
#	puts "TTD: #{ttd_param}"
#	
#end
#
	puts "********************************************************"
	puts "********************************************************"
	puts "***$$$ END Routing and Rerouting Sniffing Test $$$******"
	puts "********************************************************"
	puts "********************************************************"
	
	puts "########################################################"
	puts "#########PowerOff All Microns !!!!!!!!!!!!!!############"
	retPowerOff = power_off_ring("A",$RUN_ID)
	
end

# read register function
$c = ModuleCPBF.new
def read_micron_reg(micron_id, regaddr)
    rw_flag = 0 # read
    data = 0x0  # Ignored if rw_flag = 0
    timeout = 100
    recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, regaddr, data, timeout)[0]
    data = recv["CPBF_REG_DATA"]
    puts("[DEBUG] MICRON REG #{regaddr}, DATA: #{data}")
    return data
end

def dec2hex(number)

    number.to_s(16)

end
