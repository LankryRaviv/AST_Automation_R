load_utility('Operations/MICRON/MICRON_MODULE.rb')
require 'json'

class EpsTelemetry

    # MIC_SOLAR_IP_PROTECT_VOLTAGE_STR_A
    # MIC_SOLAR_IP_PROTECT_VOLTAGE_STR_B
    # MIC_SOLAR_IP_PROTECT_CURR_STR_A
    # MIC_SOLAR_IP_PROTECT_CURR_STR_B

    def initialize
        @micron = MICRON_MODULE.new
        @board = "MIC_LSL"
        @path_json = 'C:/Cosmos/ATE/result.json'
        @diction = {}
    end

    def write_to_json()
        File.open(@path_json, "w") do |f|
            f.write(@diction.to_json)
        end
    end

    def get_telemetry_dictionary(micron_id)
        telemetry = @micron.get_micron_detailed_telemetry_eps(@board, micron_id, subsystem_id="EPS", converted=true, raw=false, wait_check_timeout=0.5)
        if telemetry.empty?
            return nil
        end
        return telemetry[0]
    end

    def get_solar_panel_string_a_voltage(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        key = "MIC_SOLAR_IP_PROTECT_VOLTAGE_STR_A"
        @diction[key] = telemetry[key].to_s
        return @diction
    end

    def get_solar_panel_string_b_voltage(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        key = "MIC_SOLAR_IP_PROTECT_VOLTAGE_STR_B"
        @diction[key] = telemetry[key].to_s
        return @diction
    end
    
    def get_solar_panel_string_a_current(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        key = "MIC_SOLAR_IP_PROTECT_CURR_STR_A"
        @diction[key] = telemetry[key].to_s
        return @diction
    end

    def get_solar_panel_string_b_current(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        key = "MIC_SOLAR_IP_PROTECT_CURR_STR_B"
        @diction[key] = telemetry[key].to_s
        return @diction
    end

end