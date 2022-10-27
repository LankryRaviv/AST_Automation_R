load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/HandleRouting.rb')
load_utility('Operations/Micron/ChangeToPS2MicronsInChain.rb')
load_utility('Operations/Micron/Ping.rb')
load_utility('Operations/Micron/RebootMicronsInChain.rb')
load_utility('Operations/Micron/ChangeMode.rb')

#DOES not fully working!!!!!
def save_microns_status_mode(micron_id_target,targetIsOFF)
    handle_routing = HandleRouting.new
    micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id_target)
    fs = MICRON_MODULE.new 
    old_micron_status_mode = ""
    last_mode = ""
    last_direction_switch = ""
    last_micron_id = ""
    test_result = "PASS"
    uut_micron_id = "MICRON_" + micron_id_target.to_s
    wasDonor = false
    
    if(micron_id_ring.length() != directions.length())
        return false
    end

    for micron_id in 0..micron_id_ring.length()
        if(micron_id_ring[micron_id] == nil)
            next
        end
        if(micron_id_ring.length() == 1)
            next
        end
        #Return to the original share mode
        if(wasDonor)
            wasDonor = false
            fs.set_power_sharing(board="MIC_LSL", last_micron_id, last_direction_switch, last_mode, converted=false, raw=false, wait_check_timeout=2)
        end
        #return the last micron to the original state. reboot the Micron to return to PS1 after changed to PS2.
        if(micron_id != 0 && old_micron_status_mode == "PS1")
            if(old_micron_status_mode == "PS1")
                reboot = fs.sys_reboot(board="MIC_LSL", micron_id_ring[micron_id-1], converted=false, raw=false, wait_check_timeout=2)
                puts "SYS REBOOT - MICRON_ID = #{micron_id_ring[micron_id-1]}"
                sleep 8
                get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id_ring[micron_id-1], true, false,wait_check_timeout=2)[0]
                power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
        
                if power_mode_status == "PS1"
                    puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id_ring[micron_id-1]}"
                else
                    isAllReboot = "FAIL"
                    puts "REBOOT FAILED to #{micron_id_ring[micron_id-1]}"
                end

            else
                if(change_mode(micron_id_ring[micron_id-1],old_micron_status_mode) == false)
                    test_result = "FAIL"
                end
            end

           
        end
        get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id_ring[micron_id], true, false)[0]
        old_micron_status_mode = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
        
        if(old_micron_status_mode == "PS1")
            #Set next power mode to ps2
            if(change_mode(micron_id_ring[micron_id],"PS2") == false)
                test_result = "FAIL"
            end
        end
        
        direction_switch = directions[micron_id]
        next_micron_id = ""
        if(micron_id == (micron_id_ring.length()-1))
            next_micron_id = uut_micron_id
        else
            next_micron_id = micron_id_ring[micron_id + 1]
        end

        #send ping to next micron 
        if(ping_by_micron_id(next_micron_id) == false)
            #Save sharing mode and Donor to the next Micron
            #last_mode = fs.get_power_sharing(board="MIC_LSL", micron_id_ring[micron_id], direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=2)
            #Pahrse the mode
            #last_mode = last_mode["MIC_SHARE_MODE"]
            #puts last_mode
            share_mode = "DONOR"
            wasDonor = true
            #if(last_mode == "DISABLED")
             #   last_direction_switch = "ALL_DISCONNECTED"
            #else
            last_direction_switch = direction_switch
            #end
            
            last_micron_id = micron_id_ring[micron_id]
            fs.set_power_sharing(board="MIC_LSL", micron_id_ring[micron_id], direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=2)
            puts "Micron id = #{micron_id_ring[micron_id]} Donor to Micron id = #{next_micron_id} on direction #{direction_switch}"
            sleep 5
        end

    end
    if(targetIsOFF)
        #Cancled donor from micron befor target
        fs.set_power_sharing(board="MIC_LSL", micron_id_ring[micron_id_ring.length()-1], "ALL_DISCONNECTED", "DISABLED", converted=false, raw=false, wait_check_timeout=2)
        sleep 2
        last_mode = fs.get_power_sharing(board="MIC_LSL", micron_id_ring[micron_id_ring.length()-1], "ALL_DISCONNECTED", "DISABLED", converted=false, raw=false, wait_check_timeout=2)
       
        #power_sharing_mode_status = last_mode["MIC_SHARE_MODE"]
        #if(power_sharing_mode_status == "DISABLED")
        puts "Micron id = #{micron_id_ring[micron_id_ring.length()-1]} Disabled donor to Micron id = #{uut_micron_id}"
        #end
       
    end
    return test_result
end
       
        #get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", next_micron_id, true, false)[0]
        #old_next_micron_status_mode = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
        #Set the next Micron to PS2 befor reboot the current Micron
        #next_power_mode = "PS2"
        #puts next_micron_id
        #if(change_mode(next_micron_id,"PS2") == false)
        #    test_result = "FAIL"
        #end

        #if(old_micron_status_mode == "PS1")
        #    reboot = fs.sys_reboot(board="MIC_LSL", micron_id_ring[micron_id], converted=false, raw=false, wait_check_timeout=2)
        #    puts "SYS REBOOT - MICRON_ID = #{micron_id_ring[micron_id]}"
        #    sleep 8
         #   get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id_ring[micron_id], true, false,wait_check_timeout=2)[0]
        #    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
    
        #    if power_mode_status == "PS1"
        #        puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{uut_micron_id}"
        #    else
         #       isAllReboot = "FAIL"
         #       puts "REBOOT FAILED to #{uut_micron_id}"
         #   end

        #else

        #end
     
