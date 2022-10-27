load_utility('Operations/MICRON/MICRON_MODULE.rb')
load('Operations/MICRON/MICRON_CSP.rb')

def mode_PS2(board, ring)

    if ring == "A"
	   micron_id_ring = [118, 119, 120, 121, 107, 93, 79, 78, 77, 76, 90, 104]
	   
	elsif ring == "B"
	   micron_id_ring = [131, 132, 133, 134, 135, 136, 122, 108, 94, 80, 66, 65, 64, 63, 62, 61, 75, 89, 103, 117]
	   
	elsif ring == "C"
	   micron_id_ring = [144, 145, 146, 147, 148, 149, 150, 151, 137, 123, 109, 95, 81, 67, 53,
	   52, 51, 50, 49, 48, 47, 46, 60, 74, 88, 102, 116, 130]
	  
	elsif ring == "D"
	   micron_id_ring = [157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 152, 138, 124, 110,
	   96, 82, 68, 54, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 45, 59, 73, 87, 101, 115, 129, 143]
	
	elsif ring == "E"
	   micron_id_ring = [172, 173, 174, 175, 176, 177, 178, 179, 167, 153, 139, 125, 111, 97, 83,
	   69, 55, 41, 25, 24, 23, 22, 21, 20, 19, 18, 30, 44, 58, 72, 86, 100, 114, 128, 142, 156]
	
	elsif ring == "F"
	   micron_id_ring = [186, 187, 188, 189, 190, 191, 192, 193, 11, 10, 9, 8, 7, 6, 5, 4]
	   
	elsif ring == "ALL"
	   micron_id_ring = [118, 119, 120, 121, 107, 93, 79, 78, 77, 76, 90, 104, 131, 132, 133, 134,
	   135, 136, 122, 108, 94, 80, 66, 65, 64, 63, 62, 61, 75, 89, 103, 117, 144, 145, 146, 147, 148,
	   149, 150, 151, 137, 123, 109, 95, 81, 67, 53, 52, 51, 50, 49, 48, 47, 46, 60, 74, 88, 102, 116, 130,
	   157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 152, 138, 124, 110, 96, 82, 68, 54, 40, 39, 38, 37,
	   36, 35, 34, 33, 32, 31, 45, 59, 73, 87, 101, 115, 129, 143, 172, 173, 174, 175, 176, 177, 178, 179,
	   167, 153, 139, 125, 111, 97, 83, 69, 55, 41, 25, 24, 23, 22, 21, 20, 19, 18, 30, 44, 58, 72, 86, 100,
	   114, 128, 142, 156, 186, 187, 188, 189, 190, 191, 192, 193, 11, 10, 9, 8, 7, 6, 5, 4]
	     
	elsif ring == "ALL_R"
	   micron_id_ring = [186, 187, 188, 189, 190, 191, 192, 193, 11, 10, 9, 8, 7, 6, 5, 4, 172, 173, 174,
	   175, 176, 177, 178, 179, 167, 153, 139, 125, 111, 97, 83, 69, 55, 41, 25, 24, 23, 22, 21, 20, 19,
	   18, 30, 44, 58, 72, 86, 100, 114, 128, 142, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166,
	   152, 138, 124, 110, 96, 82, 68, 54, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 45, 59, 73, 87, 101, 115,
	   129, 143, 144, 145, 146, 147, 148, 149, 150, 151, 137, 123, 109, 95, 81, 67, 53, 52, 51, 50, 49, 48, 47,
	   46, 60, 74, 88, 102, 116, 130, 131, 132, 133, 134, 135, 136, 122, 108, 94, 80, 66, 65, 64, 63, 62, 61, 75,
	   89, 103, 117, 118, 119, 120, 121, 107, 93, 79, 78, 77, 76, 90, 104]
	      
	else
	   puts "Incorrect Ring Letter"
	end
	
	
	mic = MICRON_MODULE.new 
	for micron_id in micron_id_ring
	 
		# change power mode to PS2
		ping_res = mic.ping_micron("MIC_LSL", micron_id, converted=false, raw=false, wait_check_timeout=2)
		# returned status is 0 or 1
		puts ping_res
		if ping_res == false
			puts "Unable to ping micron #{micron_id}. Continuing to next micron."
			next
		end


        next_power_mode = "PS2"
	    set_power_mode_hash_converted = mic.set_system_power_mode(board, micron_id, next_power_mode, true, false)[0]
		if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
			puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
		end
        sleep 2
	    get_power_mode_hash_converted = mic.get_system_power_mode(board, micron_id, true, false)[0]
	    power_mode_status = get_power_mode_hash_converted["CURRENT_SYSTEM_POWER_MODE"]
		
		if power_mode_status == "PS2"
	       puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id}"
		else
		   puts "ERROR at changing POWER_MODE to PS2 for #{micron_id}: result is #{power_mode_status}"
		end
		   
	end
	
end