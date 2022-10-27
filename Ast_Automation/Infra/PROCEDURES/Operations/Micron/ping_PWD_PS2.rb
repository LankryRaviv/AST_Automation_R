def ping_PWD_PS2(board="MIC_LSL", micron_id, fs)

        # send ping to micron 
        ping_res = fs.ping_micron(board="MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2)
	    # returned status is 0 or 1
		puts "ping result is #{ping_res}"
	    if ping_res == false
	       puts "Unable to ping micron #{micron_id}. Continuing to next micron."
	       next
	    end

        # change power mode to PS2
        next_power_mode = "PS2"
	    set_power_mode_hash_converted = fs.set_system_power_mode(board="MIC_LSL", micron_id, next_power_mode, true, false)[0]
        sleep 2
		
        if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
	       puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
	       # Add a retry loop
	    end 
		
	    get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id, true, false)[0]
	    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
		
        if power_mode_status == "PS2"
	       puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id}"
	    else
	       puts "ERROR at changing POWER_MODE to PS2 for #{micron_id}: result is #{power_mode_status}"
        end
		   
end