load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/Element.rb')
load_utility('Operations/MICRON/HandleRouting.rb')

def ping_by_micron_id(micron_id_target,board="MIC_LSL")
    test_result = "PASS"
    uut_micron_id = "MICRON_" + micron_id_target.to_s
    handle_routing = HandleRouting.new
    micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id_target)
    #micron_id_ring = [Element.new("MICRON_104","NORTH_CLOSED")]
    #micron_id_ring = ["MICRON_119", "MICRON_120", "MICRON_107", "MICRON_93", "MICRON_78", "MICRON_77", "MICRON_90", "MICRON_104"]
    fs = MICRON_MODULE.new 
    
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
        # send ping to micron 
        ping_res = fs.ping_micron(board="MIC_LSL", micron_id_ring[micron_id], converted=false, raw=false, wait_check_timeout=2)
        # returned status is 0 or 1
        puts "ping result is #{ping_res}"
        if ping_res == false
            test_result = "FAIL"
            puts "Unable to ping micron #{micron_id_ring[micron_id]}. Continuing to next micron."
        else
            puts "ping succeeded to micron #{micron_id_ring[micron_id]}. Continuing to next micron."
        end
        
        #Set next power mode to ps2
        next_power_mode = "PS2"
        set_power_mode_hash_converted = fs.set_system_power_mode(board="MIC_LSL", micron_id_ring[micron_id], next_power_mode, true, false)[0]
        sleep 2
        
        if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
            puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
        end 
    
        get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id_ring[micron_id], true, false)[0]
        power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
    
        if power_mode_status == "PS2"
            puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id_ring[micron_id]}"
        else
            puts "ERROR at changing POWER_MODE to PS2 for #{micron_id_ring[micron_id]}: result is #{power_mode_status}"
        end
        #Donor to the next Micron
        direction_switch = directions[micron_id]
        next_micron_id = ""
        if(micron_id == (micron_id_ring.length()-1))
            next_micron_id = uut_micron_id
        else
            next_micron_id = micron_id_ring[micron_id + 1]
        end
        share_mode = "DONOR"
        fs.set_power_sharing(board="MIC_LSL", micron_id_ring[micron_id], direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=3)
        puts "Micron id = #{micron_id_ring[micron_id]} Donor to Micron id = #{next_micron_id} on direction #{direction_switch}"
        sleep 5

        #Set the next Micron to PS2 befor reboot the current Micron
        next_power_mode = "PS2"
       
        puts next_micron_id
        set_power_mode_hash_converted = fs.set_system_power_mode(board="MIC_LSL", next_micron_id, next_power_mode, true, false,wait_check_timeout=3)[0]
        sleep 2
        
        if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
            puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
        end 
    
        get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", next_micron_id, true, false,wait_check_timeout=3)[0]
        power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
    
        if power_mode_status == "PS2"
            puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{next_micron_id}"
        else
            puts "ERROR at changing POWER_MODE to PS2 for #{next_micron_id}: result is #{power_mode_status}"
        end

        #Reboot the micron after donor done.
        #reboot = fs.sys_reboot(board="MIC_LSL", micron_id_ring[micron_id], converted=false, raw=false, wait_check_timeout=2)
        #puts "SYS REBOOT - MICRON_ID = #{micron_id_ring[micron_id]}"
        #sleep 13
        #Validating that micron change to PS1 after reboot
        #get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id_ring[micron_id], true, false,wait_check_timeout=2)[0]
        #power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
    
        #if power_mode_status == "PS1"
        #    puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id_ring[micron_id]}"
        #else
        #    puts "REBOOT FAILED to #{micron_id_ring[micron_id]}"
        #end
    end

    # send ping to the target Micron
    ping_res = fs.ping_micron(board="MIC_LSL", uut_micron_id, converted=false, raw=false, wait_check_timeout=2)
    # returned status is 0 or 1
    puts "ping result is #{ping_res}"
    if ping_res == false
        test_result = "FAIL"
        puts "Unable to ping micron #{uut_micron_id}. Continuing to next micron."
    else
        puts "ping succeeded to micron #{uut_micron_id}. Continuing to next micron."
    end

     #Reboot the micron after donor done.
     
    
    #Validating that the Micron reboot
    #ping_res = fs.ping_micron(board="MIC_LSL", uut_micron_id, converted=false, raw=false, wait_check_timeout=2)
    # returned status is 0 or 1
    #puts "ping result is #{ping_res}"
    #if ping_res == false
     #   puts "Reboot succeeded."
    #else
    #    if(micron_id_ring.length() != 0)
    #        test_result = "FAIL"
     #   end
    #    puts "Reboot Failed."
    #end
    #Not fully secured, indicating move to PS1 only by failing to ping.

   puts "TEST RESULT = #{test_result}"
   puts "Ping to Micron ID - #{uut_micron_id} #{test_result}"

   puts "Reboot all microns in the chain..."
   isAllReboot = reboot_all_microns_in_chain(micron_id_target,board="MIC_LSL")
   puts "Reboot Microns - #{isAllReboot}"
 
end


def reboot_all_microns_in_chain(micron_id_target,board="MIC_LSL")
    handle_routing = HandleRouting.new
    micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id_target)
    fs = MICRON_MODULE.new 

    uut_micron_id = "MICRON_" + micron_id_target.to_s
    isAllReboot = "PASS"
    reboot = fs.sys_reboot(board="MIC_LSL", uut_micron_id, converted=false, raw=false, wait_check_timeout=2)
    puts "SYS REBOOT - MICRON_ID = #{uut_micron_id}"
    sleep 8
    get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", uut_micron_id, true, false,wait_check_timeout=2)[0]
    power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]

    if power_mode_status == "PS1"
        puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{uut_micron_id}"
    else
        isAllReboot = "FAIL"
        puts "REBOOT FAILED to #{uut_micron_id}"
    end


    for micron_id in (micron_id_ring.length()-1).downto(0)

        reboot = fs.sys_reboot(board="MIC_LSL", micron_id_ring[micron_id], converted=false, raw=false, wait_check_timeout=2)
        puts "SYS REBOOT - MICRON_ID = #{micron_id_ring[micron_id]}"
        sleep 8
        #Validating that micron change to PS1 after reboot
        get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id_ring[micron_id], true, false,wait_check_timeout=2)[0]
        power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
    
        if power_mode_status == "PS1"
            puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id_ring[micron_id]}"
        else
            isAllReboot = "FAIL"
            puts "REBOOT FAILED to #{micron_id_ring[micron_id]}"
        end
   end
   return isAllReboot
end