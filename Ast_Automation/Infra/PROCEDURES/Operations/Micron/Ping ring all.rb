load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
    
	# Ring all
	micron_id_ring = [11, 4, 186, 193, 179, 139, 125, 111, 97, 83, 69, 25, 18, 58, 72, 86, 100, 114, 128, 172]
	test_status = "Pass"
	for micron_id in micron_id_ring
	 
		# power on and send ping to micron 
        ping_res = ping_target_traj_off(micron_id)
	    # returned pass or fail
		if (ping_res == true) 
			puts "The Micron " + micron_id.to_s + " ping Pass"
		else 
			puts "The Micron" + micron_id.to_s + " ping Failed"
			test_status = "Fail"
		end
	end
	put test_status
end
