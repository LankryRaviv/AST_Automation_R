load_utility('Operations/Micron/MICRON_MODULE.rb')
load_utility('Operations/Micron/MICRON_CSP.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\Tools\module_clogger.rb')
include CLogger
def Power_Modes_Switching(board, micron_id_list, auto_reboot, numOfCycle)
  
  counter_fail = 0
  counter_pass = 0
  
  while numOfCycle>0
    log_message("More #{numOfCycle} rounds")
    for micron_id in micron_id_list 
      
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
      power_mode_status1 = get_power_mode_hash_converted1["MIC_CURRENT_SYSTEM_POWER_MODE"]
      if power_mode_status1 == "PS1"
         log_message ("CURRENT_SYSTEM_POWER_MODE is #{power_mode_status1} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS1")
    	 
    	 ### change power mode to PS2
    	 ###auto_transition = "ENABLE"
    	 ###fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
    	 next_power_mode = "PS2"
    	 set_power_mode_hash_converted2, set_power_mode_hash_raw2 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
         sleep 2
    	 get_power_mode_hash_converted2, get_power_mode_hash_raw2 = fs.get_system_power_mode(board, micron_id, true, true)
    	 power_mode_status2 = get_power_mode_hash_converted2["MIC_CURRENT_SYSTEM_POWER_MODE"]
    	
    	if power_mode_status2 == "PS2"
    	   log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status2} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    	   
    	   # change power mode to Operational
    	   next_power_mode = "OPERATIONAL"
    	   set_power_mode_hash_converted3, set_power_mode_hash_raw3 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
           sleep 15
    	   get_power_mode_hash_converted3, get_power_mode_hash_raw3 = fs.get_system_power_mode(board, micron_id, true, true)
    	   power_mode_status3 = get_power_mode_hash_converted3["MIC_CURRENT_SYSTEM_POWER_MODE"]
    	   if power_mode_status3 == "OPERATIONAL"
    	      log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status3} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is OPERATIONAL")
    		  
    		  # change power mode to PS2
    		  next_power_mode = "PS2"
    	      set_power_mode_hash_converted4, set_power_mode_hash_raw4 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
              sleep 2
    	      get_power_mode_hash_converted4, get_power_mode_hash_raw4 = fs.get_system_power_mode(board, micron_id, true, true)
    	      power_mode_status4 = get_power_mode_hash_converted4["MIC_CURRENT_SYSTEM_POWER_MODE"]
    		  if power_mode_status4 == "PS2"
    		     log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status4} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    			 
    			 # change power mode to REDUCED
    			 next_power_mode = "REDUCED"
    	         set_power_mode_hash_converted5, set_power_mode_hash_raw5 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
                 sleep 15
    	         get_power_mode_hash_converted5, get_power_mode_hash_raw5 = fs.get_system_power_mode(board, micron_id, true, true)
    	         power_mode_status5 = get_power_mode_hash_converted5["MIC_CURRENT_SYSTEM_POWER_MODE"]
    			 if power_mode_status5 == "REDUCED"
    			    log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status5} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is REDUCED")
    				
    				# change power mode to PS2
    				next_power_mode = "PS2"
    	            set_power_mode_hash_converted6, set_power_mode_hash_raw6 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
                    sleep 2
    	            get_power_mode_hash_converted6, get_power_mode_hash_raw6 = fs.get_system_power_mode(board, micron_id, true, true)
    	            power_mode_status6 = get_power_mode_hash_converted6["MIC_CURRENT_SYSTEM_POWER_MODE"]
                    if power_mode_status6 == "PS2"
    			       log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status6} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    				   
    				   # change power mode to PS1
    				   auto_transition = "DISABLE"
    	               fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
    				   # Rebooting the board
                       csp = MicronCSP.new
                       csp.reboot(board, micron_id, auto_reboot)
    				   # Waiting 15 seconds, since it takes the board ~5 seconds to boot
                       wait(15)
                       ###auto_transition = "DISABLE"
    	               ###fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
    				   get_power_mode_hash_converted7, get_power_mode_hash_raw7 = fs.get_system_power_mode(board, micron_id, true, true)
      
                       # Check current system power mode
                       power_mode_status7 = get_power_mode_hash_converted7["MIC_CURRENT_SYSTEM_POWER_MODE"]
    				   if power_mode_status7 == "PS1"
    				      log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status7} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS1")
    					  
    					  # change power mode to PS2
    	                  ###auto_transition = "ENABLE"
    	                  ###fs.set_system_ps2_auto(board, micron_id, auto_transition, true, true, wait_check_timeout=2)
    	                  next_power_mode = "PS2"
    	                  set_power_mode_hash_converted8, set_power_mode_hash_raw8 = fs.set_system_power_mode(board, micron_id, next_power_mode, true, true)
                          sleep 2
    	                  get_power_mode_hash_converted8, get_power_mode_hash_raw8 = fs.get_system_power_mode(board, micron_id, true, true)
    	                  power_mode_status8 = get_power_mode_hash_converted8["MIC_CURRENT_SYSTEM_POWER_MODE"]
    					  if power_mode_status8 == "PS2"
    					     log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status8} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    						 
    						 # Rebooting the board
    						 csp = MicronCSP.new
                             csp.reboot(board, micron_id, auto_reboot)
    				         # Waiting 15 seconds, since it takes the board ~5 seconds to boot
                             wait(15)
    						 get_power_mode_hash_converted9, get_power_mode_hash_raw9 = fs.get_system_power_mode(board, micron_id, true, true)
    						 power_mode_status9 = get_power_mode_hash_converted9["MIC_CURRENT_SYSTEM_POWER_MODE"]
    						 if power_mode_status9 == "PS2"
    						    log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status9} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    							log_message( "Micron: #{micron_id} - The entire process of switching between the Power Modes has been successful")
								counter_pass = counter_pass + 1
								log_message( "Micron: #{micron_id} - loop_pass #{counter_pass}")
								auto_bit = get_power_mode_hash_converted9["MIC_PS2_AUTO_TRANSITION"]
							    log_message( "Auto transition bit: #{auto_bit}" )
    						 else
							    times = [5,5,5,5,5,5];
								for i in times
								   wait(i)
								   power_mode_status10 = get_power_mode_hash_converted9["MIC_CURRENT_SYSTEM_POWER_MODE"]
								   if power_mode_status10 == "PS2"
								      log_message( "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status9} - status ok. confirming CURRENT_SYSTEM_POWER_MODE is PS2")
    							      log_message( "Micron: #{micron_id} - The entire process of switching between the Power Modes has been successful")
									  counter_pass = counter_pass + 1
								      log_message( "Micron: #{micron_id} - loop_pass #{counter_pass}")
									  auto_bit = get_power_mode_hash_converted9["MIC_PS2_AUTO_TRANSITION"]
									  log_message( "Auto transition bit: #{auto_bit}" )
								   end
								end
								if power_mode_status10 != "PS2"
								log_message( "Micron: #{micron_id} - Error State - power mode do not change to PS2 after Rebooting")
								log_message( "Power Mode: #{power_mode_status10}")
								counter_fail = counter_fail + 1
							    log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
								auto_bit = get_power_mode_hash_converted9["MIC_PS2_AUTO_TRANSITION"]
								log_message( "Auto transition bit: #{auto_bit}")
								end
    						 end
    						 
    					  else
    					     log_message( "Micron: #{micron_id} - Error State - power mode do not change to PS2 from PS1")
							 counter_fail = counter_fail + 1
							 log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
    					  end
    					  
    				      
    				   else
    				      log_message( "Micron: #{micron_id} - Error State - power mode do not change to PS1 from PS2")
						  counter_fail = counter_fail + 1
						  log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
    				   end
                       				   
                    else
    				   log_message( "Micron: #{micron_id} - Error State - power mode do not change to PS2 from reduced")
					   counter_fail = counter_fail + 1
					   log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
                    end				
    				
    		     else
    			    log_message( "Micron: #{micron_id} - Error State - power mode do not change to REDUCED from ps2")
					counter_fail = counter_fail + 1
					log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
    			 end 
    			  
    		  else
    		     log_message( "Micron: #{micron_id} - Error State - power mode do not change to PS2 from operational")
				 counter_fail = counter_fail + 1
				 log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
    		  end
    		
    			 
    	   else
    	      log_message( "Micron: #{micron_id} - Error State - power mode do not change to OPERATIONAL from ps2")
			  counter_fail = counter_fail + 1
			  log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
    	   end
    	     
    	else
    	   log_message( "Micron: #{micron_id} - Error State - power mode do not change to PS2 from ps1")
		   counter_fail = counter_fail + 1
		   log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
    	end
    	
      else
        log_message( "Micron: #{micron_id} - Error State - power mode is not PS1")
		counter_fail = counter_fail + 1
		log_message( "Micron: #{micron_id} - loop_failed #{counter_fail}")
      end
	end
    numOfCycle-=1
  end
  return counter_fail
end