load_utility('Operations/EPS/EPS_PCDU')
load_utility('Operations/FSW/FSW_Telem')
load_utility('Operations/FSW/UTIL_CmdSender')

class ModuleMicronPower

    def initialize()
        @target = "BW3"
        @cmd_sender = CmdSender.new
        @telem = ModuleTelem.new
        @pcdu = PCDU.new
        @realtime_destination = 'COSMOS_UMBILICAL'
        @wait_time = 5
    end

    def set_all_micron_switches(apc_board, switch_state)
        # switch_state = "ON" or "OFF"

        if switch_state == "ON"
            val = 1
            check_expression = "!= 'OFF'"
        elsif switch_state == "OFF"
           val = 0
           check_expression = "== 'OFF'"
        end

        micron_packet = "#{apc_board}-MIC_068_130_TLM"

        # Turn on Power telemetry from APC and the micron packet
        @telem.set_realtime(apc_board, "POWER_PCDU_LVC_TLM", @realtime_destination, 1)
        @telem.set_realtime(apc_board, "MIC_004_067_TLM", @realtime_destination, 1)
        @telem.set_realtime(apc_board, "MIC_068_130_TLM", @realtime_destination, 1)
        @telem.set_realtime(apc_board, "MIC_131_193_TLM", @realtime_destination, 1)

        # Set Micron power share & check micron 104 power
        @pcdu.set_POWER_SHARE_MICRON_104(apc_board, val)
        wait_check(@target, micron_packet, "MIC_104_POWER_MODE", check_expression, @wait_time)

        # Set Micron power share & check micron 107 power
        @pcdu.set_POWER_SHARE_MICRON_107(apc_board, val)
        wait_check(@target, micron_packet, "MIC_107_POWER_MODE", check_expression, @wait_time)

        # Set Micron power share & check micron 78 power
        @pcdu.set_POWER_SHARE_MICRON_78(apc_board, val)
        wait_check(@target, micron_packet, "MIC_078_POWER_MODE", check_expression, @wait_time)

        # Set Micron power share & check micron 120 power
        @pcdu.set_POWER_SHARE_MICRON_120(apc_board, val)
        wait_check(@target, micron_packet, "MIC_120_POWER_MODE", check_expression, @wait_time)

        # Set Micron power share & check micron 77 power
        @pcdu.set_POWER_SHARE_MICRON_77(apc_board, val)
        wait_check(@target, micron_packet, "MIC_077_POWER_MODE", check_expression, @wait_time)

        # Set Micron power share & check micron 119 power
        @pcdu.set_POWER_SHARE_MICRON_119(apc_board, val)
        wait_check(@target, micron_packet, "MIC_119_POWER_MODE", check_expression, @wait_time)

        # Set Micron power share & check mocron 90 power 
        @pcdu.set_POWER_SHARE_MICRON_90(apc_board, val)
        wait_check(@target, micron_packet, "MIC_090_POWER_MODE", check_expression, @wait_time)

        # Set Micron power share and check micron 93 power
        @pcdu.set_POWER_SHARE_MICRON_93(apc_board, val)
        wait_check(@target, micron_packet, "MIC_093_POWER_MODE", check_expression, @wait_time)
    end

    def set_individual_micron_power_share_switch(apc_board, switch_name, switch_state, no_hazardous_check = FALSE)
        # switch_state = "ON" or "OFF"

        # Turn on DPC
        if switch_state == "ON"
            cmd_params = {"OUTPUT_CHANNEL": "DPC",
                            "STATE_ONOFF": "ON",
                            "DELAY": 0}
            @cmd_sender.send_with_cmd_count_check(apc_board, "APC_LVC_OUTPUT_SINGLE", cmd_params, "POWER", @wait_time, no_hazardous_check)
        end


        if switch_state == "ON"
            val = 1
            val_check_expression = "!= 'OFF'"
        elsif switch_state == "OFF"
            val = 0
            val_check_expression = "== 'OFF'"
        end


        # Construct method name
        #method_name = "set_#{switch_name}"
        #@pcdu.public_send(method_name, apc_board, val)
        
        if switch_name == "POWER_SHARE_MICRON_104"
          us_switch = "MICRON_12V_11"
        elsif switch_name == "POWER_SHARE_MICRON_78"
           us_switch = "MICRON_12V_12"
        elsif switch_name == "POWER_SHARE_MICRON_107"
           us_switch = "MICRON_12V_13"
        elsif switch_name == "POWER_SHARE_MICRON_120"
           us_switch = "MICRON_12V_14"
        elsif switch_name == "POWER_SHARE_MICRON_77"
           us_switch = "MICRON_12V_15"
        elsif switch_name == "POWER_SHARE_MICRON_90"
           us_switch = "MICRON_12V_16"
        elsif switch_name == "POWER_SHARE_MICRON_119"
           us_switch = "MICRON_12V_17"
        elsif switch_name == "POWER_SHARE_MICRON_93"
           us_switch = "MICRON_12V_18"
        end
        
        # Set upstream only if turning on
        if val == 1
          # Formulate parameters
          cmd_name = "PCDU_SET_US_REG_SWITCH"
          params = {
            "SWITCH_NUM_US_REG": us_switch,
            "SWITCH_STATE": val
          }
          send_pcdu_cmd(apc_board, cmd_name, params, no_hazardous_check, 5, 7)
          #@cmd_sender.send_with_cmd_count_check(apc_board, cmd_name, params, "POWER", 4, no_hazardous_check)
        end
        
        # Always set downstream
        # Formulate parameters
        cmd_name = "PCDU_SET_DS_SWITCH"
        params = {
          "SWITCH_NUM_DS": switch_name,
          "SWITCH_STATE": val
        }
        send_pcdu_cmd(apc_board, cmd_name, params, no_hazardous_check, 5, 7)
        #@cmd_sender.send_with_cmd_count_check(apc_board, cmd_name, params, "POWER", 4, no_hazardous_check)

        # Check that downstream is in proper state
        wait_check(@target, "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_#{switch_name}", "== '#{switch_state}'", 10)
        
        # Check Micron State
        mic_num = switch_name.split('_')
        mic_num = mic_num[-1]
        if mic_num.length < 3
          mic_num = "0#{mic_num}"
        end
        micron_packet = "#{apc_board}-MIC_068_130_TLM"
        #wait_check(@target, micron_packet, "MIC_#{mic_num}_POWER_MODE", val_check_expression, @wait_time)

    end

    def turn_off_all_micron_12V_upstream_switches(apc_board)

        # Verify all the downstream switches are off

        if tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_HDRM_LVA_P1") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_104") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_HDRM_LVA_P1") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_104") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_HDRM_LVA_P2") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_107") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_HDRM_LVA_P3") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_78") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_HDRM_LVA_R1") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_120") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_HDRM_LVA_R2") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_77") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_HDRM_LVA_R3") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_119") == "OFF" and
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_90") == "OFF" and 
           tlm("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_POWER_SHARE_MICRON_93") == "OFF"

        
            @pcdu.set_upstream_reg(apc_board, "MICRON_12V_11", 0)
            wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_12V_11_POSITION", "=='OFF'", 10)
      
            @pcdu.set_upstream_reg(apc_board, "MICRON_12V_12", 0)
            wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_12V_12_POSITION", "=='OFF'", 10)
     
            @pcdu.set_upstream_reg(apc_board, "MICRON_12V_13", 0)
            wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_12V_13_POSITION", "=='OFF'", 10)
        
            @pcdu.set_upstream_reg(apc_board, "MICRON_12V_14", 0)
            wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_12V_14_POSITION", "=='OFF'", 10)
        
            @pcdu.set_upstream_reg(apc_board, "MICRON_12V_15", 0)
            wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_12V_15_POSITION", "=='OFF'", 10)
        
            @pcdu.set_upstream_reg(apc_board, "MICRON_12V_16", 0)
            wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_12V_16_POSITION", "=='OFF'", 10)
   
            @pcdu.set_upstream_reg(apc_board, "MICRON_12V_17", 0)
            wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_12V_17_POSITION", "=='OFF'", 10) 

            @pcdu.set_upstream_reg(apc_board, "MICRON_12V_18", 0)
            wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_MICRON_12V_18_POSITION", "=='OFF'", 10)
        else
            raise("Downstream switches are not OFF. Upstream switches were not turned off")
        end
    end

    def enable_boost_control(apc_board, state)
        cmd_params = {"STATE": state}
        @cmd_sender.send_with_cmd_count_check(apc_board, "PCDU_ENABLE_BOOST_CONTROL", cmd_params, "POWER", 10)

    end

    def set_pcdu_boost_switch(apc_board, switch_name, state)

        # Set switch
        cmd_params = {"SWITCH_NUM_BOOST": switch_name,
                      "SWITCH_STATE": state}
        @cmd_sender.send_with_cmd_count_check(apc_board, "PCDU_SET_BOOST_SWITCH", cmd_params, "POWER", 10)

        # Check telemetry of the boost switch
        switch = convert_switch_num(switch_name)
        wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_BOOST_#{switch}_POSITION", "== '#{state}'", 10)

    end

    def set_duty_cycle(apc_board, duty_cycle, amps)
        

        # convert amps to counts
        counts = convert_amps_to_counts(amps)

        # Send command
        cmd_params = {"SWITCH_NUM_DUTY_CYCLE": duty_cycle,
                      "DUTY_CYCLE_BOOST": counts}
        @cmd_sender.send_with_cmd_count_check(apc_board, "PCDU_SET_BOOST_DUTY_CYCLE", cmd_params, "POWER", 10)

        # Check telemetry
        switch_string = convert_switch_num(duty_cycle)
        wait_check("BW3", "#{apc_board}-POWER_PCDU_LVC_TLM", "PCDU_BOOST_#{switch_string}_DUTY", "== #{counts}", 10) # UPDATE if these needs to be a tolerance or is in amps

    end

    def convert_amps_to_counts(amps)

        if amps >= 2.42

            counts = 1000

        elsif amps < 2.42 and amps >= 1.189

            counts = (amps - 2.42) * (2000-1000)/(1.189 - 2.42) + 1000

        elsif amps < 1.189 and amps > 0.477

            counts = (amps - 1.189) * (3000-2000)/(0.477 - 1.189) + 2000

        elsif amps <= 0.477 and amps > 0.469

            counts = (amps - 0.477) * (4000-3000)/(0.469 - 0.477) + 3000

        elsif amps <= 0.469

            counts = 4000

        else
            raise("Invalid amp selection")
        end

        return counts

    end

    def convert_switch_num(switch_name)

        # Check telemetry state
        if switch_name[-1] == "1"
            return "ONE"
        elsif switch_name[-1] == "2"
            return "TWO"
        elsif switch_name[-1] == "3"
            return "THREE"
        elsif switch_name[-1] == "4"
            return "FOUR"
        elsif switch_name[-1] == "5"
            return "FIVE"
        elsif switch_name[-1] == "6"
            return "SIX"
        elsif switch_name[-1] == "7"
            return "SEVEN"
        elsif switch_name[-1] == "8"
            return "EIGHT"
        end

    end

    def send_pcdu_cmd(apc_board, cmd_name, params, no_hazardous_check, num_tries=3, wait_time = 7)

        try_count = 1
        while try_count <= num_tries

            # Get initial counters
            init_csp_rec_count = tlm("BW3", "#{apc_board}-FSW_TLM_APC", "CSP_CMD_REC_COUNTER")
            init_csp_err_count = tlm("BW3", "#{apc_board}-FSW_TLM_APC", "CSP_CMD_ERROR_COUNTER")
            init_pwr_rec_count = tlm("BW3", "#{apc_board}-FSW_TLM_APC", "POWER_CMD_REC_COUNTER")
            init_pwr_err_count = tlm("BW3", "#{apc_board}-FSW_TLM_APC", "POWER_CMD_ERROR_COUNTER")

            # Send command
            @cmd_sender.send(apc_board, cmd_name, params, no_hazardous_check)
            #wait(wait_time)
            start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            while Process.clock_gettime(Process::CLOCK_MONOTONIC)-start_time < wait_time
              # Check the command counters
              if tlm("BW3", "#{apc_board}-FSW_TLM_APC", "CSP_CMD_REC_COUNTER") == (init_csp_rec_count + 1) and 
                  tlm("BW3", "#{apc_board}-FSW_TLM_APC", "CSP_CMD_ERROR_COUNTER") == init_csp_err_count and
                  tlm("BW3", "#{apc_board}-FSW_TLM_APC", "POWER_CMD_REC_COUNTER") == (init_pwr_rec_count + 1) and 
                  tlm("BW3", "#{apc_board}-FSW_TLM_APC", "POWER_CMD_ERROR_COUNTER") == init_pwr_err_count
                  failed = FALSE
                  break
              else
                  failed = TRUE
                  
              end
              
            end
            if failed 
              try_count = try_count + 1
            else
               break
            end

        end

        if failed
            raise("ERROR: Sending command #{cmd_name} with parameters #{params} failed after #{try_count-1}")
        end


    end
end