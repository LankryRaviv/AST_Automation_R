load_utility('Operations/Micron/Micron_IMU_MTQ.rb')

class MTQCommandDriver
    def initialize()
        @mic = MICRON_IMU_MTQ.new
    end

    def send_mtq_command(link, micron_id, mtqa_state, mtqa_polarity, mtqa_time, mtqb_state, mtqb_polarity, mtqb_time)
        mtq_on_off = calculate_on_off_bits(mtqa_state, mtqa_polarity, mtqb_state, mtqb_polarity)
        return @mic.enable_mtq(link, micron_id, mtq_on_off, 200, 200, true, true, 1, false) 
    end

    def mtq_command_loop(link, micron_id, mtqa_state, mtqa_polarity, mtqa_time, mtqb_state, mtqb_polarity, mtqb_time, loop_until_abort=true, duration=0)

        if loop_until_abort
            duration = Float::INFINITY
        end

        wait_between_cmds = [mtqa_time, mtqb_time].min.to_f/100 - 0.2

        mtq_on_off = calculate_on_off_bits(mtqa_state, mtqa_polarity, mtqb_state, mtqb_polarity)
        starting = Time.new
        while Time.new - starting < duration
            cmd_start_time = Time.new
            # send command without checking for result.  Result has a timeout duration.  Can 
            # change this to check whether command was successful
            @mic.enable_mtq(link, micron_id, mtq_on_off, mtqa_time, mtqb_time, false, false, 1, true) 
            wait(wait_between_cmds-(Time.new-cmd_start_time))
        end
    end

    def mtq_multicommand_loop(link, micron_id, cmd_param_array, mtq_time, loop_until_abort=true, duration=0)

        num_sets = cmd_param_array.length()

        # [mtqa_state, mtqa_polarity, mtqb_state, mtqb_polarity]
        if loop_until_abort
            duration = Float::INFINITY
        end
        curr_set = 0

        starting = Time.new
        while Time.new - starting < duration
            cmd_start_time = Time.new
            cmd_list = cmd_param_array[curr_set]
            mtq_on_off = calculate_on_off_bits(*cmd_list)
            # send command without checking for result.  Result has a timeout duration.  Can 
            # change this to check whether command was successful
            @mic.enable_mtq(link, micron_id, mtq_on_off, mtq_time, mtq_time, false, false, 1, true) 
            wait(1.5-(Time.new-cmd_start_time))
            curr_set += 1
            if curr_set == num_sets
                curr_set = 0
            end
        end
    end

    def calculate_on_off_bits(mtqa_state, mtqa_polarity, mtqb_state, mtqb_polarity)
        mtqa_pos = '00'
        mtqa_neg = '00'
        mtqb_pos = '00'
        mtqb_neg = '00' 
        if mtqa_state.eql? "ON"   
            if mtqa_polarity.eql? "POSITIVE"
            mtqa_pos = '11'
            else
            mtqa_neg = '11'
            end
        end
        if mtqb_state.eql? "ON"   
            if mtqb_polarity.eql? "POSITIVE"
            mtqb_pos = '11'
            else
            mtqb_neg = '11'
            end
        end
        mtq_on_off_str = mtqa_pos + mtqa_neg + mtqb_pos + mtqb_neg
        return mtq_on_off_str.to_i(2)
    end
end
