load 'MICRON_MODULE.rb'
load 'MICRON_CSP.rb'
load 'check_pwr_good_pwr_mode_switching.rb'
load 'power_goods_change_power_mode_json_to_csv_converter.rb'
load 'Tools/module_file_tools.rb'
load 'Tools/module_clogger.rb'

def Power_Modes_Switching(board="MIC_LSL", micron_id_list, input_data, auto_reboot: true)
  
	include FileTools
	include CLogger

  counter_fail = 0
  counter_pass = 0
  cycle = 1
  max_cycles = input_data.fetch("max_cycles",3)
  read_power_goods = PwrGoodPwrModeSwitching.new(input_data)

  
  while cycle < max_cycles + 1
	log_message("starting cycle: #{cycle}")
	read_power_goods.start_cycle(cycle)
    for micron_id in micron_id_list 
      
		begin #start begin-rescue-ensure block

      fs = MICRON_MODULE.new
      auto_transition = "DISABLE"
      fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
      csp = MicronCSP.new
      csp.reboot(board, micron_id, auto_reboot)
      # Waiting 15 seconds, since it takes the board ~5 seconds to boot
      wait(15)
      ###fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
      get_power_mode_hash_converted1, get_power_mode_hash_raw1 = fs.get_system_power_mode(board, micron_id, true, true)
      
      # Check current system power mode
	  log_message(get_power_mode_hash_converted1)
      power_mode_status1 = get_power_mode_hash_converted1["MIC_CURRENT_SYSTEM_POWER_MODE"]
      if power_mode_status1 == "PS1"
		log_message("power mode=:#{power_mode_status1}")
		read_power_goods.add_step(micron_id, power_mode_status1, 1)
		read_power_goods.flush
         puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status1} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS1"
    	 
    	 ### change power mode to PS2
    	 ###auto_transition = "ENABLE"
    	 ###fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
    	 next_power_mode = "PS2"
    	 set_power_mode_hash_converted2, set_power_mode_hash_raw2 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
         sleep 2
    	 get_power_mode_hash_converted2, get_power_mode_hash_raw2 = fs.get_system_power_mode(board, micron_id, true, true)
		 log_message(get_power_mode_hash_converted2)
    	 power_mode_status2 = get_power_mode_hash_converted2["MIC_CURRENT_SYSTEM_POWER_MODE"]
    	
    	if power_mode_status2 == "PS2"
			log_message("power mode=:#{power_mode_status2}")
			read_power_goods.add_step(micron_id, power_mode_status2, 2)
			read_power_goods.flush
    	   puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status2} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2"
    	   
    	   # change power mode to Operational
    	   next_power_mode = "OPERATIONAL"
    	   set_power_mode_hash_converted3, set_power_mode_hash_raw3 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
           sleep 15
    	   get_power_mode_hash_converted3, get_power_mode_hash_raw3 = fs.get_system_power_mode(board, micron_id, true, true)
		   log_message(get_power_mode_hash_converted3)
    	   power_mode_status3 = get_power_mode_hash_converted3["MIC_CURRENT_SYSTEM_POWER_MODE"]
    	   if power_mode_status3 == "OPERATIONAL"
			log_message("power mode=:#{power_mode_status3}")
			read_power_goods.add_step(micron_id, power_mode_status3, 3)
			read_power_goods.flush
    	      puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status3} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is OPERATIONAL"
    		  
    		  # change power mode to PS2
    		  next_power_mode = "PS2"
    	      set_power_mode_hash_converted4, set_power_mode_hash_raw4 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
              sleep 5
    	      get_power_mode_hash_converted4, get_power_mode_hash_raw4 = fs.get_system_power_mode(board, micron_id, true, true)
    	      power_mode_status4 = get_power_mode_hash_converted4["MIC_CURRENT_SYSTEM_POWER_MODE"]
    		  if power_mode_status4 == "PS2"
				log_message("power mode=:#{power_mode_status4}")
				read_power_goods.add_step(micron_id, power_mode_status4, 4)
				read_power_goods.flush
    		     puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status4} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2"
    			 
    			 # change power mode to REDUCED
    			 next_power_mode = "REDUCED"
    	         set_power_mode_hash_converted5, set_power_mode_hash_raw5 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
                 sleep 15
    	         get_power_mode_hash_converted5, get_power_mode_hash_raw5 = fs.get_system_power_mode(board, micron_id, true, true)
    	         power_mode_status5 = get_power_mode_hash_converted5["MIC_CURRENT_SYSTEM_POWER_MODE"]
    			 if power_mode_status5 == "REDUCED"
					log_message("power mode=:#{power_mode_status5}")
					read_power_goods.add_step(micron_id, power_mode_status5, 5)
					read_power_goods.flush
    			    puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status5} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is REDUCED"
    				
    				# change power mode to PS2
    				next_power_mode = "PS2"
    	            set_power_mode_hash_converted6, set_power_mode_hash_raw6 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
                    sleep 5
    	            get_power_mode_hash_converted6, get_power_mode_hash_raw6 = fs.get_system_power_mode(board, micron_id, true, true)
    	            power_mode_status6 = get_power_mode_hash_converted6["MIC_CURRENT_SYSTEM_POWER_MODE"]
                    if power_mode_status6 == "PS2"
						log_message("power mode=:#{power_mode_status6}")
						read_power_goods.add_step(micron_id, power_mode_status6, 6)
						read_power_goods.flush
    			       puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status6} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2"
    				   
    				   # change power mode to PS1
    				   auto_transition = "DISABLE"
    	               fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
    				   # Rebooting the board
                       #csp = MicronCSP.new
                       csp.reboot(board, micron_id, auto_reboot)
    				   # Waiting 15 seconds, since it takes the board ~5 seconds to boot
                       wait(15)
                       ###auto_transition = "DISABLE"
    	               ###fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
    				   get_power_mode_hash_converted7, get_power_mode_hash_raw7 = fs.get_system_power_mode(board, micron_id, true, true)
      
                       # Check current system power mode
                       power_mode_status7 = get_power_mode_hash_converted7["MIC_CURRENT_SYSTEM_POWER_MODE"]
    				   if power_mode_status7 == "PS1"
						log_message("power mode=:#{power_mode_status7}")
						read_power_goods.add_step(micron_id, power_mode_status7, 7)
						read_power_goods.flush
    				      puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status7} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS1"
						  next_power_mode = "PS2"
    	                  set_power_mode_hash_converted8, set_power_mode_hash_raw8 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
                          sleep 5
    	                  get_power_mode_hash_converted8, get_power_mode_hash_raw8 = fs.get_system_power_mode(board, micron_id, true, true)
    	                  power_mode_status8 = get_power_mode_hash_converted8["MIC_CURRENT_SYSTEM_POWER_MODE"]
    					  if power_mode_status8 == "PS2"
							log_message("power_mode_status8: power mode=:#{power_mode_status8}")
							read_power_goods.add_step(micron_id, power_mode_status8, 8)
							read_power_goods.flush
    					     log_message("CURRENT_SYSTEM_POWER_MODE is #{power_mode_status8} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    						 
    						 # Rebooting the board
    						 #csp = MicronCSP.new
                             csp.reboot(board, micron_id, auto_reboot)
    				         # Waiting 15 seconds, since it takes the board ~5 seconds to boot
                             wait(15)
							 ######################################
    					  # change power mode to PS2
    	                  auto_transition = "ENABLE"
    	                  fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
						  wait(5)
							####################################
							 next_power_mode = "PS2"
							 set_power_mode_hash_converted9, set_power_mode_hash_raw9 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
							 wait(5)
    						 get_power_mode_hash_converted9, get_power_mode_hash_raw9 = fs.get_system_power_mode(board, micron_id, true, true)
    						 power_mode_status9 = get_power_mode_hash_converted9["MIC_CURRENT_SYSTEM_POWER_MODE"]
							 log_message("step 8 - reboot; power mode after reboot=#{power_mode_status9}")
    						 if power_mode_status9 == "PS2"
								log_message("power_mode_status9: power mode=:#{power_mode_status9}")
								read_power_goods.add_step(micron_id, power_mode_status9, 9)
								read_power_goods.flush
    						   log_message("CURRENT_SYSTEM_POWER_MODE is #{power_mode_status9} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    							log_message("Micron: #{micron_id} - The entire process of switching between the Power Modes has been successful")
								counter_pass = counter_pass + 1
								log_message("Micron: #{micron_id} - loop_pass #{counter_pass}")
								auto_bit = get_power_mode_hash_converted9["MIC_PS2_AUTO_TRANSITION"]
							    log_message("Auto transition bit: #{auto_bit}")
    						 else
							    times = [5,5,5,5,5,5];
								for i in times
								   wait(i)
								   power_mode_status10 = get_power_mode_hash_converted9["MIC_CURRENT_SYSTEM_POWER_MODE"]
								   if power_mode_status10 == "PS2"
									log_message("power mode=:#{power_mode_status10}")
									read_power_goods.add_step(micron_id, power_mode_status10, 10)
									read_power_goods.flush
								      log_message("CURRENT_SYSTEM_POWER_MODE is #{power_mode_status10} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    							      log_message("Micron: #{micron_id} - The entire process of switching between the Power Modes has been successful")
									  counter_pass = counter_pass + 1
								      log_message("Micron: #{micron_id} - loop_pass #{counter_pass}")
									  auto_bit = get_power_mode_hash_converted9["MIC_PS2_AUTO_TRANSITION"]
									  log_message("Auto transition bit: #{auto_bit}")
								   end
								end
								if power_mode_status10 != "PS2"
								log_message("Micron: #{micron_id} - Error State - power mode do not change to PS2 after Rebooting")
								log_message("Power Mode: #{power_mode_status10}")
								counter_fail = counter_fail + 1
							    log_message("Micron: #{micron_id} - loop_failed #{counter_fail}")
								auto_bit = get_power_mode_hash_converted9["MIC_PS2_AUTO_TRANSITION"]
								log_message("Auto transition bit: #{auto_bit}")
								end
								read_power_goods.flush
    						 end
    						 
    					  else
    					     log_message("Micron: #{micron_id} - Error State - power mode do not change to PS2 from PS1")
							 counter_fail = counter_fail + 1
							 log_message("Micron: #{micron_id} - loop_failed #{counter_fail}")
							 read_power_goods.flush
    					  end
    					  
    				      
    				   else
    				      puts "Micron: #{micron_id} - Error State - power mode do not change to PS1 from PS2"
						  counter_fail = counter_fail + 1
						  puts "Micron: #{micron_id} - loop_failed #{counter_fail}"
						  read_power_goods.flush
    				   end
                       				   
                    else
    				   puts "Micron: #{micron_id} - Error State - power mode do not change to PS2 from reduced"
					   counter_fail = counter_fail + 1
					   puts "Micron: #{micron_id} - loop_failed #{counter_fail}"
					   read_power_goods.flush
                    end				
    				
    		     else
    			    puts "Micron: #{micron_id} - Error State - power mode do not change to REDUCED from ps2"
					counter_fail = counter_fail + 1
					puts "Micron: #{micron_id} - loop_failed #{counter_fail}"
					read_power_goods.flush
    			 end 
    			  
    		  else
    		     puts "Micron: #{micron_id} - Error State - power mode do not change to PS2 from operational"
				 counter_fail = counter_fail + 1
				 puts "Micron: #{micron_id} - loop_failed #{counter_fail}"
				 read_power_goods.flush
    		  end
    		
    			 
    	   else
    	      puts "Micron: #{micron_id} - Error State - power mode do not change to OPERATIONAL from ps2"
			  counter_fail = counter_fail + 1
			  puts "Micron: #{micron_id} - loop_failed #{counter_fail}"
			  read_power_goods.flush
    	   end
    	     
    	else
    	   puts "Micron: #{micron_id} - Error State - power mode do not change to PS2 from ps1"
		   counter_fail = counter_fail + 1
		   puts "Micron: #{micron_id} - loop_failed #{counter_fail}"
		   read_power_goods.flush
    	end
    	
      else
        puts "Micron: #{micron_id} - Error State - power mode is not PS1"
		counter_fail = counter_fail + 1
		puts "Micron: #{micron_id} - loop_failed #{counter_fail}"
		read_power_goods.flush
      end

	rescue Exception => exception
		log_error(exception.message)
		log_error(exception.backtrace)
	ensure
		log_error("One of the steps threw an exception. check logs")
		counter_fail += 1
	end #end of the begin-rescue-ensure block

	end
	cycle+=1
	read_power_goods.flush
  end

    path_to_full_report = read_power_goods.get_full_report_path
	hash = read_json_file(path_to_full_report)
	file_path =  input_data.fetch("output_path")
	file_name = "result_read_pwr_goods_pwr_modes_#{(DateTime.now).to_s.gsub(":","-")[0,16]}.csv"
	convert_json_to_csv(hash, file_path, file_name)

  if counter_fail > 0
	return false
  else
  	#returns true if all power goods were in the expected state, otherwise false
  	return !read_power_goods.has_invalid_states
  end


end