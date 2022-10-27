load_utility('Operations/MICRON/MICRON_MODULE.rb')
require 'json'

class ThermalTelemetry

    # MIC_TEMPERATURE_INSIDE_FPGA 
    # MIC_TEMPERATURE_INSIDE_MCU 
    # MIC_TEMPERATURE_SOLAR_PANEL 
    # MIC_TEMPERATURE_IMU 
    # MIC_TEMPERATURE_MB_0-6 
    # MIC_TEMPERATURE_BATTERY_CELL_0-7
    # MIC_TEMPERATURE_FEM_INSIDE_CU_0-15 
    # MIC_TEMPERATURE_FEM_NEAR_PA_0-15 

    def initialize
        @micron = MICRON_MODULE.new
        @board = "MIC_LSL"
        @path_json = 'C:/Cosmos/ATE/result.json'
    end

    def write_to_json(dictionary)
        File.open(@path_json, "w") do |f|
            f.write(dictionary.to_json)
        end
    end

    def get_telemetry_dictionary(micron_id)
        telemetry = @micron.get_micron_detailed_telemetry_thermal(@board, micron_id, subsystem_id="THERMAL", converted=true, raw=false, wait_check_timeout=0.5)
        if telemetry.nil?
            return nil
        end
        return telemetry[0]
    end

    def get_temperature_mb(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        diction = {}
        for sensor_number in 0..6 do
            key = "MIC_TEMPERATURE_MB_#{sensor_number}"
            diction[key] = telemetry[key].to_s
        end
        write_to_json(diction)
        return diction
    end

    def get_fpga_temperature(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        key = "MIC_TEMPERATURE_INSIDE_FPGA"
        diction = {}
        diction[key] = telemetry[key].to_s
        write_to_json(diction)
        return diction
    end

    def get_mcu_temperature(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        key = "MIC_TEMPERATURE_INSIDE_MCU"
        diction = {}
        diction[key] = telemetry[key].to_s
        write_to_json(diction)
        return diction
    end

    def get_solar_panel_temperature(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        key = "MIC_TEMPERATURE_SOLAR_PANEL"
        diction = {}
        diction[key] = telemetry[key].to_s
        write_to_json(diction)
        return diction
    end

    def get_imu_temperature(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        key = "MIC_TEMPERATURE_IMU"
        diction = {}
        diction[key] = telemetry[key].to_s
        write_to_json(diction)
        return diction
    end

    def get_battery_temperature(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        diction = {}
        for cell in 0..7 do
            key = "MIC_TEMPERATURE_BATTERY_CELL_#{cell}"
            diction[key] = telemetry[key].to_s
        end
        write_to_json(diction)
        return diction
    end

    def get_fem_inside_cu_temperature(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        diction = {}
        for sensor_number in 0..15 do
            key = "MIC_TEMPERATURE_FEM_INSIDE_CU_#{sensor_number}"
            diction[key] = telemetry[key].to_s
        end
        write_to_json(diction)
        return diction
    end

    def get_fem_near_pa_temperature(micron_id)
        telemetry = get_telemetry_dictionary(micron_id)
        return nil unless !telemetry.nil?
        diction = {}
        for sensor_number in 0..15 do
            key = "MIC_TEMPERATURE_FEM_NEAR_PA_#{sensor_number}"
            diction[key] = telemetry[key].to_s
        end
        write_to_json(diction)
        return diction
    end

end