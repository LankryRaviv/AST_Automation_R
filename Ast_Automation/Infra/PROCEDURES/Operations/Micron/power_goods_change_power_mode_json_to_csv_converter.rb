load 'Tools/module_clogger.rb'

def convert_json_to_csv(hash, file_path, file_name)
    begin
    if hash.kind_of?(Hash)
        file = File.new(file_path+file_name, 'w')

        #top line with column names
        file.write("cycle_no,cycle_start_time,micron_id,step_no,step_start_time,power_mode,prev_power_mode,pwr_good_name,pwr_good_status,pwr_good_expected_status,pwr_enable_status,pwr_enable_name,pwr_enable_msg,pwr_good_result\n")

        cycles_arr = hash.fetch("cycles")
        for cycle in cycles_arr
            cycle_no = cycle.fetch("cycle_no").to_s
            cycle_start_time = cycle.fetch("timestamp")
            
            microns_arr = cycle.fetch("microns")
            for micron in microns_arr
                micron_id = micron.fetch("micron_id").to_s
                
                steps_arr = micron.fetch("steps")
                for step in steps_arr
                    step_no = step.fetch("step_no").to_s
                    step_start_time = step.fetch("timestamp")
                    power_mode = step.fetch("power_mode")
                    prev_power_mode = step.fetch("prev_power_mode")

                    indicators_arr = step.fetch("indicators")
                    for indicator in indicators_arr
                        pwr_good_name = indicator.fetch("pg_name")
                        pwr_good_status = indicator.fetch("pg_status").to_s
                        pwr_good_expected_status = indicator.fetch("pg_expected").to_s
                        pwr_enable_status = indicator.fetch("pg_en_status", "NA").to_s
                        pwr_enable_name = indicator.fetch("pg_en_name","NA")
                        pwr_enable_msg = indicator.fetch("pg_en_msg","NA")
                        pwr_good_result = pwr_good_status == pwr_good_expected_status ? "PASS" : "FAIL"

                        line = ""
                        line.concat(cycle_no).concat(",").concat(cycle_start_time).concat(",")
                        line.concat(micron_id).concat(",").concat(step_no).concat(",").concat(step_start_time).concat(",")
                        line.concat(power_mode).concat(",").concat(prev_power_mode).concat(",")
                        line.concat(pwr_good_name).concat(",").concat(pwr_good_status).concat(",").concat(pwr_good_expected_status).concat(",")
                        line.concat(pwr_enable_status).concat(",").concat(pwr_enable_name).concat(",")
                        line.concat(pwr_enable_msg).concat(",").concat(pwr_good_result).concat("\n")

                        file.write(line)
                    
                    end #indicators_arr for loop end
                
                end #steps_arr for loop end
            
            end #microns_arr for loop end

        end #cycles_arr for loop end

        file.close
    end
    rescue Exception => exception
        log_error(exception.message)
		log_error(exception.backtrace)
    end
end


