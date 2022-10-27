load 'check_pwr_good_indicators.rb'
load 'Tools/module_file_tools.rb'
require 'date'


class PwrGoodPwrModeSwitching

    def initialize(input_data)
        @data = input_data
        @cycle_no = 0
        @cycles = Array.new
        @cycles_all = Array.new
        @cycle = {}
        @cycle_all = {}
        @microns = Array.new
        @microns_all = Array.new
        @micron = {}
        @micron_all = {}
        @steps = Array.new
        @steps_all = Array.new
        @result = {}
        @result_all = {}
        @report_path = "./result.json"
        @full_report_path = "./result.json"
        @prev_power_mode = "-"

        path_json = @data.fetch("output_path")
        puts "***************"
        puts path_json
        report_file_name = @data.fetch("output_file_name")
        report_file_name = "#{report_file_name.sub("*TIMESTAMP*",(DateTime.now).to_s.gsub(":","-")[0,10])}"
        puts report_file_name
        @report_path = path_json + report_file_name
        puts @report_path
        @full_report_path = "#{path_json}full_#{report_file_name}"
        puts @full_report_path

        @has_invalid_states = false
    end

    include FileTools

    def get_full_report_path
        return @full_report_path
    end

    def start_cycle(cycle_no)
        @cycle_no = cycle_no
        @cycle = {}
        @cycle.store("cycle_no", @cycle_no)
        @cycle.store("timestamp", DateTime.now)
        @cycle_all = @cycle.dup
        @cycles.push(@cycle)
        @cycles_all.push(@cycle_all)
    end

    def add_step(micron_id, power_mode, step_no)
        if step_no == 1
            @steps = Array.new
            @steps_all = Array.new
            @prev_power_mode = "-"
            @micron = {
                "micron_id" => micron_id
            }
            @micron_all = @micron.dup
        end
    
        pgs = CheckPwrGoodIndicators.new(micron_id, power_mode)
        pg_statuses = pgs.get_pwr_good_indicators_status

        if !@has_invalid_states && pg_statuses[0].length > 0
            @has_invalid_states = true
        end
        #pg_statuses = [] #dummy w/o cosmos

        step = {
            "step_no" => step_no,
            "timestamp" => DateTime.now,
            "power_mode" => power_mode,
            "prev_power_mode" => @prev_power_mode,
            "indicators" => pg_statuses[0]
        }
        step_all = step.dup
        step_all.store("indicators", pg_statuses[1])
        
        @steps.push(step)
        @steps_all.push(step_all)
        @micron.store("steps", @steps)
        @micron_all.store("steps", @steps_all)

        micron_obj = get_obj_if_exists(@microns, "micron_id", micron_id)
        add_replace_obj(micron_obj, @micron, @microns)

        micron_obj_all = get_obj_if_exists(@microns_all, "micron_id", micron_id)
        add_replace_obj(micron_obj_all, @micron_all, @microns_all)
       
        @prev_power_mode = power_mode
    end

    def flush
        @cycle.store("microns",@microns)
        @cycle_all.store("microns",@microns_all)
        cycle_obj = get_obj_if_exists(@cycles, "cycle_no", @cycle_no)
        add_replace_obj(cycle_obj, @cycle, @cycles)
        cycle_obj_all = get_obj_if_exists(@cycles_all, "cycle_no", @cycle_no)
        add_replace_obj(cycle_obj_all, @cycle_all, @cycles_all)
        obj = {"cycles" => @cycles}
        obj_all = {"cycles" => @cycles_all}
        write_to_json(obj,@report_path)
        write_to_json(obj_all,@full_report_path)
    end

    def has_invalid_states
        return @has_invalid_states
    end


    private
    def get_obj_if_exists(list, key, value)
        return list.find {|obj| obj.fetch(key) == value}
    end

    def add_replace_obj(old_object, new_object, list)
        if(old_object == nil)
            list.push(new_object)
        else
            list.delete(old_object)
            list.push(new_object)
        end
    end

end