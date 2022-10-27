# """
# Read batteries temperature 
# # Micron must be on power mode PS1 at least
# """



load_utility('Operations/MICRON/MICRON_MODULE.rb')

require 'date'
micron_id = "MICRON_21"


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

def get_micron_batt_temp(micron_id)
    """
    Return batteries temperature from micron
    """
    m = MICRON_MODULE.new
  
    board = "MIC_LSL" 
    raw_res = m.get_micron_detailed_telemetry_thermal(board, micron_id)
    if raw_res != []
        raw_res = raw_res[0]

        puts("##########  Result  #########")
        #puts raw_res
        temp_battery_cell_0 = raw_res["MIC_TEMPERATURE_BATTERY_CELL_0"].to_f
        #puts("TEMPERATURE_BATTERY_CELL_0: #{temp_battery_cell_0}")
        temp_battery_cell_1 = raw_res["MIC_TEMPERATURE_BATTERY_CELL_1"].to_f
        #puts("TEMPERATURE_BATTERY_CELL_1: #{temp_battery_cell_1}")
        temp_battery_cell_2 = raw_res["MIC_TEMPERATURE_BATTERY_CELL_2"].to_f
        #puts("TEMPERATURE_BATTERY_CELL_2: #{temp_battery_cell_2}")
        temp_battery_cell_3 = raw_res["MIC_TEMPERATURE_BATTERY_CELL_3"].to_f
        #puts("TEMPERATURE_BATTERY_CELL_3: #{temp_battery_cell_3}")
        temp_battery_cell_4 = raw_res["MIC_TEMPERATURE_BATTERY_CELL_4"].to_f
        #puts("TEMPERATURE_BATTERY_CELL_4: #{temp_battery_cell_4}")
        temp_battery_cell_5 = raw_res["MIC_TEMPERATURE_BATTERY_CELL_5"].to_f
        #puts("TEMPERATURE_BATTERY_CELL_5: #{temp_battery_cell_5}")
        temp_battery_cell_6 = raw_res["MIC_TEMPERATURE_BATTERY_CELL_6"].to_f
        #puts("TEMPERATURE_BATTERY_CELL_6: #{temp_battery_cell_6}")
        temp_battery_cell_7 = raw_res["MIC_TEMPERATURE_BATTERY_CELL_7"].to_f
        #puts("TEMPERATURE_BATTERY_CELL_7: #{temp_battery_cell_7}")
        return [temp_battery_cell_0,temp_battery_cell_1,temp_battery_cell_2,temp_battery_cell_3,temp_battery_cell_4,temp_battery_cell_5,temp_battery_cell_6,temp_battery_cell_7]
    end
    return [-999,-999,-999,-999,-999,-999,-999,-999]
end


def check_batteries_temperature(micron_id, file_info, run_id , batt_temp_ll = 19, batt_temp_hl = 30)
    flag = true
    batteries_temperature_array = get_micron_batt_temp(micron_id)
    cnt = 0
    test_result = "PASS"

    for temp in batteries_temperature_array do
        time = Time.new
        if temp.between?(batt_temp_ll, batt_temp_hl) || temp == 65535.0
            puts("MIC_TEMPERATURE_BATTERY_CELL_#{cnt} in range: #{temp}C, range: #{batt_temp_ll}, #{batt_temp_hl}")
        else
            puts("MIC_TEMPERATURE_BATTERY_CELL_#{cnt} out of range: #{temp}C, range: #{batt_temp_ll}, #{batt_temp_hl}")
            test_result = "FAIL"
            flag = false
        end
        if file_info != []
            write_to_log_file(run_id, time, "TEMPERATURE_BATTERY_CELL_#{cnt}_MICRON_#{get_micron_id_filterd(micron_id)}",
            batt_temp_hl, batt_temp_ll, temp, "C", test_result, "BW3_COMP_SAFETY", file_info)
        end

        cnt +=1
    end
  
    return flag
end





    