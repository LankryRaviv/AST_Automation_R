
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/Element.rb')
load_utility('Operations/MICRON/HandleRouting.rb')
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

def ping_by_micron_id(micron_id_target, out_file, board="MIC_LSL",run_id = "",output = true)
    test_result = "PASS"
    uut_micron_id = micron_id_target
    fs = MICRON_MODULE.new 
    time = Time.new
    ping_res = fs.ping_micron(board="MIC_LSL", uut_micron_id, converted=false, raw=false, wait_check_timeout=0.3)
    # returned status is 0 or 1
    puts "ping result is #{ping_res}"
    if ping_res == false
        test_result = "FAIL"
        puts "Unable to ping micron #{uut_micron_id}. Continuing to next micron."
    else
        puts "ping succeeded to micron #{uut_micron_id}"
    end
    if(output)
        write_to_log_file(run_id, time, "PING_MICRON_#{get_micron_id_filterd(micron_id_target)}",
        "TRUE", "TRUE", ping_res,"BOOLEAN", test_result, "BW3_COMP_SAFETY", out_file)
    end
    return test_result
end

