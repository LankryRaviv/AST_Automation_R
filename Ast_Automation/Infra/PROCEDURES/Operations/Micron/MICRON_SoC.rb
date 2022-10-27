# """
# Read batteries string voltage and current. 
# Calculate Soc
# Micron must be on power mode PS2
# """



load('Operations/MICRON/MICRON_MODULE.rb')

require 'date'


def calc_soc(v, i)
    # """
    # calculate and return battery string Soc
    # """
    v = v.to_f
    i = i.to_f/1000 # divide by 1000 to convert to A
    soc = 100*(1.03*v-0.45*i-13.55)/2.9
    puts("raw soc: #{soc}")
    if soc > 95
        soc = 100
    end
    if soc < 5
        soc = 0
    end
    return soc
end

def get_micron_batteries_soc(micron_id)
    """
    Return batteries SoC from micron
    """
    m = MICRON_MODULE.new
    board = "MIC_LSL" 
    soC_A = -1
    soC_B = -1
    raw_res = m.get_micron_detailed_telemetry_eps(board, micron_id)
    if raw_res != []
        raw_res = raw_res[0]
        puts("##########  Result  #########")
    
        string_A_voltage = raw_res["MIC_BATT_STR_VOLTAGE_STR_A"]
        #puts("String A voltage: #{string_A_voltage}")
        string_A_current = raw_res["MIC_BATT_STR_CURR_STR_A"]
        #puts("String A current: #{string_A_current}")
        string_B_voltage = raw_res["MIC_BATT_STR_VOLTAGE_STR_B"]
        #puts("String B voltage: #{string_B_voltage}")
        string_B_current = raw_res["MIC_BATT_STR_CURR_STR_B"]
        #puts("String B current: #{string_B_current}")
        soC_A = calc_soc(string_A_voltage, string_A_current)
        #puts("String A SoC: #{soC_A}")
        soC_B = calc_soc(string_B_voltage, string_B_current)
        #puts("String B SoC: #{soC_B}")
    end
    return soC_A.round(2), soC_B.round(2)
end

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

def check_batteries_soc(micron_id, file_info, run_id, ll = 50,hl = 100)
    time = Time.new
    string_A_SoC, string_B_SoC = get_micron_batteries_soc(micron_id)
	test_result = "PASS"

    string_A_SoC_ll = ll
    string_A_SoC_hl = hl
    string_B_SoC_ll = ll
    string_B_SoC_hl = hl

    flag = true
    if string_A_SoC.between?(string_A_SoC_ll, string_A_SoC_hl)
        puts("String A SoC in range: #{string_A_SoC}%, range: #{string_A_SoC_ll}, #{string_A_SoC_hl}")
    else
        puts("String A SoC out of range: #{string_A_SoC}%, range: #{string_A_SoC_ll}, #{string_A_SoC_hl}")
		test_result = "FAIL"
        flag = false
    end
    if file_info != nil
        write_to_log_file(run_id, time, "SOC_A_MICRON_#{get_micron_id_filterd(micron_id)}",
        string_A_SoC_hl, string_A_SoC_ll, string_A_SoC,
        "%", test_result, "BW3_COMP_SAFETY", file_info)
    end

	test_result = "PASS"
    if string_B_SoC.between?(string_B_SoC_ll, string_B_SoC_hl)
        puts("String B SoC in range: #{string_B_SoC}%, range: #{string_B_SoC_ll}, #{string_B_SoC_hl}")
    else
        puts("String B SoC out of range: #{string_B_SoC}%, range: #{string_B_SoC_ll}, #{string_B_SoC_hl}")
		test_result = "FAIL"
        flag = false
    end
    if file_info != nil
        write_to_log_file(run_id, time, "SOC_B_MICRON_#{get_micron_id_filterd(micron_id)}",
        string_B_SoC_hl, string_B_SoC_ll, string_B_SoC,
        "%", test_result, "BW3_COMP_SAFETY", file_info)
    end

    return flag
end


