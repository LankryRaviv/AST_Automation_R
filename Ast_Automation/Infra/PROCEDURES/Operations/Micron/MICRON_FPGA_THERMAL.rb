# """
# Read temperature inside FPGA
# # Micron must be on power mode operational
# """



load_utility('Operations/MICRON/MICRON_MODULE.rb')

require 'date'

def get_micron_fpga_temp(micron_id)
    """
    Return temperature inside FPGA
    """
    m = MICRON_MODULE.new
    board= "MIC_LSL"
    fpga_temperature = -999
    raw_res = m.get_micron_detailed_telemetry_thermal(board, micron_id)
    if raw_res != []
        raw_res = raw_res[0]
        puts("##########  Result  #########")
        fpga_temperature = raw_res["MIC_TEMPERATURE_INSIDE_FPGA"].to_f
    end

    puts("FPGA TEMPERATURE: #{fpga_temperature}")
    return fpga_temperature
end


def check_fpga_temperature(micron_id, file_info, run_id = "", fpga_temp_ll = 35, fpga_temp_hl = 90)
    flag = true
    test_result = "PASS"
    time = Time.now
    cnt = 0
    fpga_temperature = 0
    fpga_temperature = get_micron_fpga_temp(micron_id)
        
    if fpga_temperature.between?(fpga_temp_ll, fpga_temp_hl)
        puts("MIC_TEMPERATURE_INSIDE FPGA in range: #{fpga_temperature}C, range: #{fpga_temp_ll}, #{fpga_temp_hl}")
    else
        puts("MIC_TEMPERATURE_INSIDE FPGA out of range: #{fpga_temperature}C, range: #{fpga_temp_ll}, #{fpga_temp_hl}")
        flag = false
        test_result = "FAIL"
    end
    write_to_log_file(run_id, time, "FPGA_TEMPERATURE_MICRON_#{get_micron_id_filterd(micron_id)}",
    fpga_temp_hl, fpga_temp_ll, fpga_temperature, "C", test_result, "BW3_COMP_SAFETY", file_info)

    return flag
end
