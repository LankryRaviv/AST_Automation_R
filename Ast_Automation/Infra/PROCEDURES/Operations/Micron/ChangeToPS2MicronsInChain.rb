load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/HandleRouting.rb')
load_utility('Operations/MICRON/Ping.rb')
load_utility('Operations/MICRON/MICRON_BATT_THERMAL.rb')
load_utility('Operations/MICRON/MICRON_SoC.rb')

require 'date'


def get_micron_id_filterd(micron_id)
    filtered = ("MICRON_" + micron_id.to_s)[-3..-1].delete('ON_')
    if(filtered.to_s.length() == 1)
        filtered = "00" + filtered.to_s
    end
    if(filtered.to_s.length() == 2)
        filtered = "0" + filtered.to_s
    end
    return filtered.to_s
end

def change_to_ps2_microns_in_chain(micron_id_target, out_file, board="MIC_LSL",run_id = "",withDefaultRouting = false,withSocAndTempCheck = false,disabledDoner = true)
    test_result = "PASS"
    uut_micron_id = "MICRON_" + micron_id_target.to_s
    handle_routing = HandleRouting.new
    micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id_target)
    fs = MICRON_MODULE.new 
    ret_value = true
    time = Time.new
    sleep 10 #waiting untill the first micron wake up from a power sharing from the CS.
    if(micron_id_ring.length() != directions.length())
        return "FAIL",micron_id_ring.length()
    end
    
    for micron_id in 0..micron_id_ring.length()
        time = Time.new
        test_result = "PASS"
        ret_change_mode = true

        if(micron_id_ring[micron_id] == nil)
            next
        end
        #if(micron_id_ring.length() == 1)
         #   next
        #end
        

        ping_pass = true
        # send ping to micron 
        ret_ping = ping_by_micron_id(micron_id_ring[micron_id], out_file, "MIC_LSL",run_id)
        if(ret_ping == "FAIL")
            ret_change_mode = false
            test_result = "FAIL" 
            ping_pass = false
            return test_result,micron_id
        end
        
        # if(ping_pass && check_mode(micron_id_ring[micron_id], out_file, "PS2"))
        #     next
        # end
        #checking routing for each Micron
         if(withDefaultRouting)
            version = verify_sw_version(micron_id_ring[micron_id], out_file, run_id.to_s)
             res_routing_bool = get_micron_default_routing(micron_id_ring[micron_id], out_file, run_id,ping_pass)
             if(res_routing_bool == false)
                 ret_change_mode = false
                 test_result = "FAIL" 
                 return test_result,micron_id
             end
         end
        #Set next power mode to ps2
        ret_change_mode = change_mode(micron_id_ring[micron_id],"PS2")
        if(ret_change_mode == false)
            test_result = "FAIL" 
        end
        #checking sw version
        
        #  if(version == false)
        #      #ret_change_mode = false
        #      test_result = "FAIL" 
        #      #return test_result,micron_id
        #  end
        #ret_value = ret_value & version
       
        ret_value = ret_value & ret_change_mode
        write_to_log_file(run_id, time, "SET_POWER_MODE_PS2_MICRON_#{get_micron_id_filterd(micron_id_ring[micron_id])}",
        "TRUE", "TRUE", ret_change_mode, "BOOLEAN", test_result, "BW3_COMP_SAFETY", out_file)
      
        if(ret_change_mode == false)
           return test_result,micron_id
        end
        if(withSocAndTempCheck)
            #Checking SOC & Temprature
            soc = check_batteries_soc(micron_id_ring[micron_id], out_file, run_id.to_s)
            
            if(soc == false)
                ret_change_mode = false
                test_result = "FAIL" 
                return test_result,micron_id
            end
            ret_value = ret_value & soc
            bat_temperature = check_batteries_temperature(micron_id_ring[micron_id], out_file, run_id.to_s)
            if(bat_temperature == false)
                ret_change_mode = false
                test_result = "FAIL" 
                return test_result,micron_id
            end
            ret_value = ret_value & bat_temperature

            

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
        t1 = Time.now
        t2 = Time.now
        while(t2-t1 < 40)
            power_sharing_mode_status = "NA"
            fs.set_power_sharing(board="MIC_LSL", micron_id_ring[micron_id], direction_switch, share_mode, converted=false, raw=false, wait_check_timeout=1)
            puts "Micron id = #{micron_id_ring[micron_id]} Donor to Micron id = #{next_micron_id} on direction #{direction_switch}"
            sleep 10 #waiting until the next micron wake up from the donor.
            last_mode = fs.get_power_sharing(board="MIC_LSL", micron_id_ring[micron_id],direction_switch, share_mode, converted=true, raw=false, wait_check_timeout=0.5)
            if last_mode != []
                last_mode = last_mode[0]
                power_sharing_mode_status = last_mode["MIC_SHARE_MODE"]
            end
            if(power_sharing_mode_status == "DONOR")
                puts "Micron id = #{micron_id_ring[micron_id]} Donor to Micron id = #{next_micron_id} on direction #{direction_switch}"
                break
            else
                puts "Micron id = #{micron_id_ring[micron_id]} Failed to donor to Micron id = #{next_micron_id}"
            end
            t2 = Time.now  
        end
        #sleep 3
        ret_ping = ping_by_micron_id(next_micron_id,"MIC_LSL",run_id)
        if(ret_ping == "FAIL")
            test_result = "FAIL" 
            return test_result,micron_id
        end
        #Set the next Micron to PS2 befor reboot the current Micron
        sleep 2
        next_power_mode = "PS2"
        puts next_micron_id
        ret_change_mode = change_mode(next_micron_id,"PS2")
        
        
        ret_value = ret_value & ret_change_mode
        #return power sharing to be disabled.
        if(disabledDoner)
            t1 = Time.now
            t2 = Time.now
            while(t2-t1 < 35)
                power_sharing_mode_status = "NA"
                fs.set_power_sharing(board="MIC_LSL", micron_id_ring[micron_id], "ALL_DISCONNECTED", "DISABLED", converted=false, raw=false, wait_check_timeout=0.4)
                #Validating that power sharing is disabled.
                last_mode = fs.get_power_sharing(board="MIC_LSL", micron_id_ring[micron_id], "ALL_DISCONNECTED", "DISABLED", converted=true, raw=false, wait_check_timeout=0.5)
                if last_mode != []
                    last_mode = last_mode[0]
                    power_sharing_mode_status = last_mode["MIC_SHARE_MODE"]
                end
                if(power_sharing_mode_status == "DISABLED")
                    puts "Micron id = #{micron_id_ring[micron_id]} Disabled donor to Micron id = #{next_micron_id}"
                    break
                else
                    puts "Micron id = #{micron_id_ring[micron_id]} Failed to disabled donor to Micron id = #{next_micron_id}"
                end
                t2 = Time.now  
            end
        end
        if(ret_change_mode == false)
            break
        end
    end
    

    # send ping to the target Micron
    
    resPing = ping_by_micron_id(uut_micron_id, out_file, "MIC_LSL",run_id)
    #if(ret_value == true)
     #   test_result = "PASS"
    #end
    ping_pass = true
    if(resPing == "FAIL")
        test_result = "FAIL"
        ping_pass = false
        return test_result,micron_id_ring.length()
    end
    #Change to ps2 the target Micron.
    ret_change_mode = change_mode(uut_micron_id,"PS2")
    if(ret_change_mode == false)
        test_result = "FAIL" 
    end
    write_to_log_file(run_id, time, "SET_POWER_MODE_PS2_MICRON_#{get_micron_id_filterd(uut_micron_id)}",
    "TRUE", "TRUE", ret_change_mode, "BOOLEAN", test_result, "BW3_COMP_SAFETY", out_file)
  
    if(ret_change_mode == false)
        return test_result,micron_id_ring.length()
     end

    #checking sw version
     
    #  if(version == false)
    #      #ret_change_mode = false
    #      test_result = "FAIL" 
    #      #return test_result,micron_id
    #  end
    #  #ret_value = ret_value & version

    if(withDefaultRouting)
        version = verify_sw_version(uut_micron_id, out_file, run_id.to_s)
         res_routing_bool = get_micron_default_routing(uut_micron_id, out_file, run_id,ping_pass)
         if(res_routing_bool == false)
             ret_change_mode = false
             test_result = "FAIL"
             return test_result,micron_id_ring.length()
         end
     end
    if(withSocAndTempCheck)
        #Checking SOC & Temprature for target Micron
        soc = check_batteries_soc(uut_micron_id, out_file, run_id.to_s)
                
        if(soc == false)
            test_result = "FAIL" 
            return test_result,micron_id_ring.length()
        end
        ret_value = ret_value & soc
        bat_temperature = check_batteries_temperature(uut_micron_id, out_file, run_id.to_s)
        if(bat_temperature == false)
            test_result = "FAIL" 
            return test_result,micron_id_ring.length()
        end
        ret_value = ret_value & bat_temperature
    end
    puts "TEST RESULT = #{test_result}"
    puts "Ping to Micron ID - #{uut_micron_id} #{test_result}"


    return  test_result,micron_id_ring.length()
end

