load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/HandleRouting.rb')
load_utility('Operations/MICRON/Ping.rb')
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

def reboot_microns_in_chain(micron_id_target, file_info, powerOffTargetMicron,board="MIC_LSL",run_id = "",startRebootIndex = 1,fromBegining = false)
    handle_routing = HandleRouting.new
    micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id_target)
    fs = MICRON_MODULE.new 
    isAllReboot = "PASS"
    specific_reboot = "PASS"
    time = Time.new
   if(fromBegining)
        startRebootIndex = micron_id_ring.length()
   end
    sleep 2
    if(startRebootIndex == micron_id_ring.length())
        if(powerOffTargetMicron == true)
            specific_reboot = "PASS"
            uut_micron_id = "MICRON_" + micron_id_target.to_s
            try_count = 0
            num_tries = 5
            while try_count < num_tries
                reboot = fs.sys_reboot(board="MIC_LSL", uut_micron_id, converted=false, raw=false, wait_check_timeout=1)
                puts "SYS REBOOT - MICRON_ID = #{uut_micron_id}"
                sleep 4
                #get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", uut_micron_id, true, false,wait_check_timeout=5)[0]
                #power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
                bool_flag = false
                #if power_mode_status != "PS1"
            #     bool_flag = true
            #     isAllReboot = "PASS"
                #    puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{uut_micron_id}"
                #    break
                #else
                #    isAllReboot = "FAIL"
            #     puts "REBOOT FAILED to #{uut_micron_id}"
                #    if try_count == num_tries
                #        break
                #    end
                if(ping_by_micron_id(uut_micron_id,board="MIC_LSL",run_id,false) == "FAIL")
                    bool_flag = true
                    #isAllReboot = "PASS"
                    specific_reboot = "PASS"
                    #isAllReboot = "PASS"
                    puts "REBOOT MICRON_ID = #{uut_micron_id}  - PASS"
                    break
                else
                    bool_flag = false
                    #isAllReboot = "FAIL"
                    specific_reboot = "FAIL"
                    puts "REBOOT MICRON_ID = #{uut_micron_id}  - FAIL"
                    
                end
                try_count = try_count + 1
                #end
            end
            if(try_count == 5 && specific_reboot == "FAIL")
                isAllReboot = "FAIL"
            end
            write_to_log_file(run_id, time, "REBOOT_MICRON_#{get_micron_id_filterd(uut_micron_id)}",
            "TRUE", "TRUE", bool_flag, "BOOLEAN", specific_reboot, "BW3_COMP_SAFETY", file_info)
        end
    end

    #startRebootIndex micron_id_ring.length()-1
    for micron_id in (startRebootIndex-1).downto(0)
        specific_reboot = "PASS"
        time = Time.new
        try_count = 0
        num_tries = 5
        while try_count < num_tries
            reboot = fs.sys_reboot(board="MIC_LSL", micron_id_ring[micron_id], converted=false, raw=false, wait_check_timeout=1)
            puts "SYS REBOOT - MICRON_ID = #{micron_id_ring[micron_id]}"
            sleep 4
            #Validating that ping faild to micron 
            if(ping_by_micron_id(micron_id_ring[micron_id],board="MIC_LSL",run_id,false) == "FAIL")
                bool_flag = true
                #isAllReboot = "PASS"
                specific_reboot = "PASS"
                #isAllReboot = "PASS"
                puts "REBOOT MICRON_ID = #{micron_id_ring[micron_id]}  - PASS"
                break
            else
                bool_flag = false
                #isAllReboot = "FAIL"
                puts "REBOOT MICRON_ID = #{micron_id_ring[micron_id]}  - FAIL"
                specific_reboot = "FAIL"
                #break
            end
                try_count = try_count + 1
          
        end
        if(try_count == 5 && specific_reboot == "FAIL")
            isAllReboot = "FAIL"
        end
        write_to_log_file(run_id, time, "REBOOT_MICRON_#{get_micron_id_filterd(micron_id_ring[micron_id])}",
        "TRUE", "TRUE", bool_flag, "BOOLEAN", specific_reboot, "BW3_COMP_SAFETY", file_info)

   end
  
   return isAllReboot
end

