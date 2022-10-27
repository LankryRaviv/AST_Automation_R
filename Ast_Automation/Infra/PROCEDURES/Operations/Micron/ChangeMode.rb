load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')

require 'date'

#This function change the modes to: PS2\Reduce\Operational
def change_mode(micron_id,mode)
    
    mode = mode.to_s.upcase.strip
    fs = MICRON_MODULE.new 
    set_power_mode_hash_converted = fs.set_system_power_mode(board="MIC_LSL", micron_id, mode, true, false,0.2)
    if set_power_mode_hash_converted != []
        set_power_mode_hash_converted = set_power_mode_hash_converted[0]
        if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
            puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
       end 
    end
   
   
    t1 = Time.now
    t2 = Time.now
    while(t2-t1 < 32)
        power_mode_status = "NA"
        get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id, true, false)
        if get_power_mode_hash_converted != []
            get_power_mode_hash_converted = get_power_mode_hash_converted[0]
            power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
        end
        if power_mode_status == mode
            puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id}"
            return true
        else
            puts "ERROR at changing POWER_MODE to #{mode} for #{micron_id}: result is #{power_mode_status}"
            
        end
        t2 = Time.now
        sleep 0.5
        if(mode == "REDUCED")
            sleep 4
        end
        set_power_mode_hash_converted = fs.set_system_power_mode(board="MIC_LSL", micron_id, mode, true, false,0.2)
        if set_power_mode_hash_converted != []
            set_power_mode_hash_converted = set_power_mode_hash_converted[0]
            if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
                puts "Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}"
           end 
        end
    end
    return false
end