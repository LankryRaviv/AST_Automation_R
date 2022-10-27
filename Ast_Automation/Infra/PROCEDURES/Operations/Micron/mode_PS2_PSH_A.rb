load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')


def mode_PS2_PSH_A(board="MIC_LSL")
    
	# A
	micron_id_ring = ["MICRON_119", "MICRON_120", "MICRON_107", "MICRON_93", "MICRON_78", "MICRON_77", "MICRON_90", "MICRON_104"]
	   
	fs = MICRON_MODULE.new 
	for micron_id in micron_id_ring
	 
		# send ping to micron 
        ping_res = fs.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2)
	    # returned status is 0 or 1
		puts "ping result is #{ping_res}"
	    if ping_res == false
	       puts "Unable to ping micron #{micron_id}. Continuing to next micron."
	       next
		else
		   puts "ping succeeded to micron #{micron_id}. Continuing to next micron."
	    end

        # change power mode to PS2
        next_power_mode = "PS2"
	    set_power_mode_hash_converted = fs.set_system_power_mode(board="MIC_LSL", micron_id, next_power_mode, true, false)[0]
        sleep 2
		
        if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
	       puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
	    end 
		
	    get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id, true, false)[0]
	    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
		
        if power_mode_status == "PS2"
	       puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id}"
	    else
	       puts "ERROR at changing POWER_MODE to PS2 for #{micron_id}: result is #{power_mode_status}"
        end
		   
	end
	
	# A1
	
	# DONOR to north
	micron_id_donor_north = ["MICRON_104", "MICRON_107"]
	micron_id_PSH_north = ["MICRON_118", "MICRON_121"]
	i=0
	for micron_id in micron_id_donor_north
	
		direction_switch = "NORTH_CLOSED"
	    share_mode = "DONOR"
	    fs.power_sharing(board="MIC_LSL", micron_id, direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=2)
		puts "Micron id = #{micron_id_donor_north[i]} Donor to Micron id = #{micron_id_PSH_north[i]}"
		micron_id = micron_id_PSH_north[i]
		
		# send ping to micron 
        ping_res = fs.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2)
	    # returned status is 0 or 1
		puts "ping result is #{ping_res}"
	    if ping_res == false
	       puts "Unable to ping micron #{micron_id}. Continuing to next micron."
	       next
		else
		   puts "ping succeeded to micron #{micron_id}. Continuing to next micron."
	    end

        # change power mode to PS2
        next_power_mode = "PS2"
	    set_power_mode_hash_converted = fs.set_system_power_mode(board="MIC_LSL", micron_id, next_power_mode, true, false)[0]
        sleep 2
		
        if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
	       puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
	    end 
		
	    get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id, true, false)[0]
	    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
		
        if power_mode_status == "PS2"
	       puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id}"
	    else
	       puts "ERROR at changing POWER_MODE to PS2 for #{micron_id}: result is #{power_mode_status}"
        end
		i=i+1
	end
	
    # DONOR to south
	micron_id_donor_south = ["MICRON_93", "MICRON_90"]
	micron_id_PSH_south = ["MICRON_79", "MICRON_76"]
	i=0
	for micron_id in micron_id_donor_south
	
		direction_switch = "SOUTH_CLOSED"
	    share_mode = "DONOR"
	    fs.power_sharing(board="MIC_LSL", micron_id, direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=2)
		puts "Micron id = #{micron_id_donor_south[i]} Donor to Micron id = #{micron_id_PSH_south[i]}"
		micron_id = micron_id_PSH_sorth[i]
		
		# send ping to micron 
        ping_res = fs.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2)
	    # returned status is 0 or 1
		puts "ping result is #{ping_res}"
	    if ping_res == false
	       puts "Unable to ping micron #{micron_id}. Continuing to next micron."
	       next
		else
		   puts "ping succeeded to micron #{micron_id}. Continuing to next micron."
	    end

        # change power mode to PS2
        next_power_mode = "PS2"
	    set_power_mode_hash_converted = fs.set_system_power_mode(board="MIC_LSL", micron_id, next_power_mode, true, false)[0]
        sleep 2
		
        if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
	       puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
	    end 
		
	    get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id, true, false)[0]
	    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
		
        if power_mode_status == "PS2"
	       puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id}"
	    else
	       puts "ERROR at changing POWER_MODE to PS2 for #{micron_id}: result is #{power_mode_status}"
        end
		i=i+1
	end
    
	# Disable Power Sharing
	micron_id_disable_PSH = ["MICRON_104", "MICRON_107", "MICRON_93", "MICRON_90"]
    for micron_id in micron_id_disable_PSH
	
	    # disable power sharing for microns 104, 107, 93, 90
		share_mode = "DISABLED"
		direction_switch = "ALL_DISCONNECTED"
	    fs.power_sharing(board="MIC_LSL", micron_id, direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=2)
	end
end