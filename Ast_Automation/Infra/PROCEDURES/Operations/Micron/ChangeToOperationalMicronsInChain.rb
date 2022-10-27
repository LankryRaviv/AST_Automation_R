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

def change_to_operational_mode_microns_in_chain(micron_id_target, out_file, board="MIC_LSL",run_id = "",withDefaultRouting = false,withSocAndTempCheck = false)
    test_result = "PASS"
    uut_micron_id = "MICRON_" + micron_id_target.to_s
    handle_routing = HandleRouting.new
    micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id_target)
    fs = MICRON_MODULE.new 
    ret_value = true
    time = Time.new

    if(micron_id_ring.length() != directions.length())
        return "FAIL"
    end

    for micron_id in 0..micron_id_ring.length()
        time = Time.new
        test_result = "PASS"
        ret_change_mode = true

        if(micron_id_ring[micron_id] == nil)
            next
        end
        #if(micron_id_ring.length() == 1)
        #    next
        #end
        ping_pass = true
        # send ping to micron 
        ret_ping = ping_by_micron_id(micron_id_ring[micron_id], out_file, "MIC_LSL",run_id)
        if(ret_ping == "FAIL")
            ret_change_mode = false
            test_result = "FAIL" 
            ping_pass = false
        end
        #checking routing for each Micron
        
        if(withDefaultRouting)
            res_routing_bool = get_micron_default_routing(micron_id_ring[micron_id],out_file,run_id,ping_pass)
            if(res_routing_bool == false)
                ret_change_mode = false
                test_result = "FAIL"
                return test_result
            end
        end
        
        #Set next power mode
        ret_change_mode = change_mode(micron_id_ring[micron_id],"OPERATIONAL")
        if(ret_change_mode == false)
            ret_value = ret_value & ret_change_mode
            test_result = "FAIL" 

        end
      

        ret_value = ret_value & ret_change_mode
        write_to_log_file(run_id, time, "SET_POWER_MODE_OPERATIONAL_MICRON_#{get_micron_id_filterd(micron_id_ring[micron_id])}",
             "TRUE", "TRUE", ret_change_mode, "BOOLEAN", test_result, "BW3_COMP_SAFETY", out_file)
        if(ret_change_mode == false)
            return test_result
        end
        
        if(withSocAndTempCheck)
            #Checking SOC & Temprature
            soc = check_batteries_soc(micron_id_ring[micron_id], out_file, run_id.to_s)
            
            if(soc == false)
                ret_change_mode = false
                test_result = "FAIL" 
                return test_result
            end
            ret_value = ret_value & soc
            bat_temperature = check_batteries_temperature(micron_id_ring[micron_id], out_file, run_id.to_s)
            if(bat_temperature == false)
                ret_change_mode = false
                test_result = "FAIL" 
                return test_result
            end
            ret_value = ret_value & bat_temperature
        end
        
        
    end
    

    # send ping to the target Micron
    resPing = ping_by_micron_id(uut_micron_id,out_file, "MIC_LSL",run_id)
    #if(ret_value == true)
     #   test_result = "PASS"
    #end
    ping_pass = true
    if(resPing == "FAIL")
        test_result = "FAIL"
        ping_pass = false
    end
   
    if(withDefaultRouting)
        res_routing_bool = get_micron_default_routing(uut_micron_id, out_file, run_id,ping_pass)
        if(res_routing_bool == false)
            ret_change_mode = false
            test_result = "FAIL"
            return test_result
        end
    end
    if(withSocAndTempCheck)
        #Checking SOC & Temprature for target Micron
        soc = check_batteries_soc(uut_micron_id, out_file, run_id.to_s)
                
        if(soc == false)   
            test_result = "FAIL" 
            return test_result
        end
        ret_value = ret_value & soc
        bat_temperature = check_batteries_temperature(uut_micron_id, out_file, run_id.to_s)
        if(bat_temperature == false)
            test_result = "FAIL" 
            return test_result
        end
        ret_value = ret_value & bat_temperature
    end
    
    #Change the mode of the target Micron.
    ret_change_mode = change_mode(uut_micron_id,"OPERATIONAL")
    if(ret_change_mode == false)
        test_result = "FAIL" 
    end
    write_to_log_file(run_id, time, "SET_POWER_MODE_OPERATIONAL_MICRON_#{get_micron_id_filterd(micron_id_ring[micron_id])}",
    "TRUE", "TRUE", ret_change_mode, "BOOLEAN", test_result, "BW3_COMP_SAFETY", file_info)
    if(ret_change_mode == false)
        return test_result 
    end
    puts "TEST RESULT = #{test_result}"
    puts "Ping to Micron ID - #{uut_micron_id} #{test_result}"

    if(ret_value == true)
        test_result = "PASS"
    else
        test_result = "FAIL"
    end
    return  test_result
end
