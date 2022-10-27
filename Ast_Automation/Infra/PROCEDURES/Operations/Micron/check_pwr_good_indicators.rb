load 'MICRON_MODULE.rb'
load 'pwr_good_indicators_excel_reader.rb'
load 'Tools/module_clogger.rb'


class CheckPwrGoodIndicators

    def initialize(micron_id = 104, power_mode)
        @micron_id = micron_id
        @power_mode = power_mode
        @micron = MICRON_MODULE.new
        @board = "MIC_LSL"     
    end

include CLogger

public
def get_pwr_good_indicators_status
#get telemetry from cosmos and    
#compare retured values with excel list.
#return map of PGs with current and expected values
#format:
#{
#    "INDICATOR_NAME_IN_COSMOS":
#       {
#        "status":1,
#        "expected":0
#        },
#           etc...
#}

    telemetry = get_detailed_telemetry_pg_indicators #telemetry map from cosmos
    telemetry_thermal = get_detailed_telemetry_thermal #thermal telemetry for checking temp.dependent pwr goods
    
    #read pg indicators from Excel
    excel_reader = PwrGoodIndicatorsExcelReader.new(@power_mode)
    excel_result = excel_reader.get_pwr_good_indicator_status_map

    #compare cosmos to excel
    #status_differences = compare_pg_excel_to_cosmos(excel_result, telemetry)
    result = compare_values(excel_result, telemetry, telemetry_thermal)
    log_message(result)

    #return an array with mismatching and all power goods
    return result
end

private
def get_detailed_telemetry_pg_indicators

    telemetry = @micron.get_micron_detailed_telemetry_eps(@board, @micron_id, subsystem_id="EPS", converted=true, raw=false, wait_check_timeout=1.0)
    log_message(telemetry)
    if telemetry.empty?
        return nil
    else 
        return telemetry[0]
    end
end

def get_detailed_telemetry_thermal
    thermal_tlm_res = @micron.get_micron_detailed_telemetry_thermal(@board, @micron_id, subsystem_id="THERMAL", converted=true, raw=false, wait_check_timeout=1)
    log_message(thermal_tlm_res.inspect)
    return thermal_tlm_res.empty? ? nil: thermal_tlm_res[0]
end


#return 2 maps of pg indicators: [0] map with pg where the status does not match the expected status (excel != cosmos); [1] map with all pg
def compare_values(excel_map, cosmos_map, thermal_map)
    all_power_goods = Array.new #all power goods with current and expected status
    status_differences = Array.new #power goods where actual and expected status do not match
    excel_map.fetch("pwr_goods").each { |key, value| 
        if cosmos_map.has_key?(key)
            converted = get_converted_value(value.fetch("status").to_s)
           
                statuses = {}
                statuses["pg_name"] = key
                statuses["pg_status"] = cosmos_map[key]
                statuses["pg_expected"] = converted != -1 ? converted : get_temp_dependent_expected_status(excel_map.fetch("pwr_temp_dep"), thermal_map, cosmos_map, key)

                #check that pg is inline with parent
                #invalid scenario: pg on - parent off; 
                if statuses["pg_status"].eql? 1 && value.has_key?("parent") && cosmos_map.fetch(value.fetch("parent")) == 0
                    statuses["parent_status_fault"] = true
                end
                
                #check MIC_ENABLE
                mic_enable_negative = excel_map.fetch("mic_en_neg") #negative logic: 1=off, 0=on
                mic_enable_value = -1
                mic_enable_name = ""
                if cosmos_map.has_key?("MIC_ENABLE#{key[12..-1]}")
                    mic_enable_name = "MIC_ENABLE#{key[12..-1]}"
                    if mic_enable_negative.include? mic_enable_name
                        neg_value = cosmos_map.fetch("MIC_ENABLE#{key[12..-1]}")
                        mic_enable_value = neg_value == 0 ? 1 : 0
                    else
                        mic_enable_value = cosmos_map.fetch("MIC_ENABLE#{key[12..-1]}")
                    end
                end
                
                if mic_enable_value != -1
                    statuses["pg_en_status"] = mic_enable_value
                    statuses["pg_en_name"] = mic_enable_name
                    statuses["pg_en_msg"] = get_enable_msg(cosmos_map[key], mic_enable_value)
                end
                all_power_goods[all_power_goods.length] = statuses

            if !statuses["pg_expected"].eql? cosmos_map[key]
                status_differences[status_differences.length] = statuses
            end
        end
    }
    return [status_differences, all_power_goods]
end

def get_converted_value(value)
    #need to look for matching substring as the value can contain extra characters, eg "ON (auto)"
    return value["ON"] ? 1 : value["OFF"] ? 0 : value["temp"] ? -1 : -2 #-2 should not happen. In such case verify dataset
end

def get_temp_dependent_expected_status(temp_dep_map, thermal_telemetry_map, cosmos_telemetry_map, pg_name)
    thermal_key_list = temp_dep_map.fetch(pg_name).fetch("thermals")

    #1 case that is ON (1) if any of its children are ON (1) else return 0 as expected status
    dep_child = thermal_key_list.find {|item| item.eql? "dep_on_child"}
    if dep_child != nil
        child_list = temp_dep_map.fetch(pg_name).fetch("children")
        for child in child_list
            if cosmos_telemetry_map.fetch(child).eql? 1
                return 1
            end
        end
        return 0
    else
        temp_list = Array.new
        thermal_key_list.each {|item| 
            item_temp = thermal_telemetry_map.fetch(item)
            if item_temp.to_s != "NaN"
                temp_list.push(item_temp) 
            end
        }
        if temp_list.size != 0
            temp_list.sort!
        end
        #should be ON (1) if temp is 5 degress or less; off (0) if temp is at least 10 degrees; 6-9 is a grey area as we don't have temp history to know the correct status
        return temp_list.size == 0? -1 : temp_list[0] <= 5 ? 1 : temp_list[0] >=10 ? 0 : -1
    end
end

def get_enable_msg(pg_status, en_status)
    if pg_status == 0 && en_status == 1
        return "failed to connect"
    elsif pg_status == 1 && en_status == 0
        return "failed to disconnect"
    else return "ok"
    end
end



end
