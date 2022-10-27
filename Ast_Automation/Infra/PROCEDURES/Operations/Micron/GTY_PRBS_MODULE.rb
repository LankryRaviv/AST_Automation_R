load_utility('Operations/MICRON/MICRON_MODULE.rb')

class GTY_PRBS

	FAIL_TO_READ_REG =  "Fpga read register\nFAIL\nMC>"

	RXRECCLK = "0x15001c"
	PRBS_TX_SEQ_SEL = "0x150044"
	PRBS_RX_SEQ_SEL = "0x150048"
	PRBS_ENABLE = "0x150040"
	PRBS_RX_STATUS = "0x150080"
	PRBS_BITS_CNT_L0 = "0x150060"
	PRBS_BITS_CNT_L1 = "0x150068"
	PRBS_BITS_CNT_L2 = "0x150070" 
	PRBS_BITS_CNT_L3 = "0x150078"
	PRBS_BITS_CNT_H0 = "0x150064"
	PRBS_BITS_CNT_H1 = "0x15006c"
	PRBS_BITS_CNT_H2 = "0x150074"
	PRBS_BITS_CNT_H3 = "0x15007c"
	PRBS_ERR_CNT_0 = "0x150050"
	PRBS_ERR_CNT_1 = "0x150054"
	PRBS_ERR_CNT_2 = "0x150058"
	PRBS_ERR_CNT_3 = "0x15005c"
	PRBS_FORCE_ERR = "0x15004c"
	PRBS_FORCE_ERR_CH0 = "0x1"
	PRBS_FORCE_ERR_CH1 = "0x2"
	PRBS_FORCE_ERR_CH2 = "0x4"
	PRBS_FORCE_ERR_CH3 = "0x8"
	
	
    def initialize
        
        @micron = MICRON_MODULE.new
        @board= "MIC_LSL"
        @message_completed = "COMPLETED"
        $result_collector = []
        
    end
    
    def micron_remote_cli(micron_id, message) 
        input_data = message
        raw_res = @micron.remote_cli(@board, micron_id, packet_delay=100, input_data, @message_completed, wait_time=1)
        puts("**** [DEBUG: MIC_#{micron_id}] raw_res:\n#{raw_res}")
		return raw_res
    end

    def fpga_write_reg(micron_id, register_address, register_data)
		message = "fpga writereg #{register_address} #{register_data}"
		puts message
        raw_res = micron_remote_cli(micron_id, message)
        #puts("**** [DEBUG: MIC_#{micron_id}] raw_res:\n#{raw_res}")
		return raw_res
    end

    def fpga_read_reg(micron_id, register_address)
		
		message = "fpga readreg #{register_address}"
		puts message
        raw_res = micron_remote_cli(micron_id, message)
		if raw_res == ""
			reg = "FAILD TO READ FROM MICRON #{micron_id}" # Incase of failing to read
			value = "0x0" # Incase of failing to read
			return 0
		end
		if raw_res.include? "FAIL"
			puts("Fail to read from MIC_#{micron_id}. retry")
			raw_res = micron_remote_cli(micron_id, message)
			if raw_res.include? "FAIL"
				reg = "FAILD TO READ FROM MICRON #{micron_id}" # Incase of failing to read
				value = "0x0" # Incase of failing to read
				return 0
			end
		end
		reg = raw_res[/#{"Address = "}(.*?)#{" Value"}/m, 1]
		value = raw_res[/#{"Value="}(.*?)#{"\r"}/m, 1]
		puts("**** [DEBUG: MIC_#{micron_id}] register: #{reg}, value: #{value}")
        return value.to_i(16)
    end

    def calculate_ber(error_count, err_low_cnt, err_upper_cnt)
        total_bit_count = (err_upper_cnt << 32) | err_low_cnt
        ber = (error_count + 1).to_f / total_bit_count.to_f
        return ber
    end

    def report_gty_prbs(mic_lock_status, mic_id, mic_pcs, bit_err_cnt, mic_ber, low_limit, high_limit, test_run_id, error_force)
            
        if mic_lock_status == true
            prbs_lock = "TRUE"
            if (low_limit <= bit_err_cnt) and (bit_err_cnt <= high_limit)
			
                test_status = "TRUE"
				status = "PASS"
                #low_limit = 0
                #high_limit = 1
            else
                test_status = "FALSE"
				status = "FALSE"
            end
        else
            prbs_lock = "FALSE"
            test_status = "FALSE"
			status = "FAIL"
            bit_err_cnt = -999
            mic_ber = -999
            low_limit = -999
            high_limit = -999 
        end

        
		out_string = "[TEST] GTY_PRBS_MICRON_#{mic_id.to_s}_PCS_#{mic_pcs.to_s }" + " GTY_PRBS LOCK: #{prbs_lock}, PRBS: #{test_status}, Error count: #{bit_err_cnt} bit, BER: #{mic_ber}"
		full_test_name = "GTY_PRBS_MICRON_" + mic_id.to_s + "_PCS_" + mic_pcs.to_s
		
		if error_force == true
			out_string = "[TEST] GTY_PRBS_ERR_FRC_MICRON_#{mic_id.to_s}_PCS_#{mic_pcs.to_s }" + " GTY_PRBS LOCK: #{prbs_lock}, PRBS_ERR_FRC: #{test_status}, Error count: #{bit_err_cnt} bit, BER: #{mic_ber}"
			full_test_name = "GTY_PRBS_ERR_FRC_MICRON_" + mic_id.to_s + "_PCS_" + mic_pcs.to_s
		end
		
        $result_collector.append(out_string)
        puts(out_string)
        
        
        log_to_file_micron(run_id = test_run_id, test_name = full_test_name, ll = low_limit, res = bit_err_cnt, hl = high_limit, status = status)
		if test_status == "FALSE"
			flag = false
		else
			flag = true
		end
		return test_status
    end

    def log_to_file_micron(run_id, test_name, ll, res, hl, status)
        time = Time.new
		
        out_file = File.new("C:\\cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
        builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ test_name + ", PROCESS_NAME: BW3_COMP_GTY_PRBS, LL: " + ll.to_s + ", RESULT: " + res.to_s + ", HL: " +  hl.to_s + ", MU: bit, STATUS: " + status
		out_file.puts(builded_string)
        out_file.close
	end
	
	def log_to_file_test(run_id, test_name, status)
        time = Time.new
		full_test_name = test_name
        out_file = File.new("C:\\cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
        #builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ test_name + "_CPBF_LINK_"+ link.to_s + ", PROCESS_NAME: BW3_COMP_GTY_PRBS, LL: " + ll.to_s + ", RESULT: " + res.to_s + ", HL: " +  hl.to_s + ", MU: bit, STATUS: " + status
        builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " +time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ full_test_name + ", PROCESS_NAME: BW3_COMP_GTY_PRBS, LL: 0, RESULT: -999, HL: 0, MU: Bit, STATUS: " + status
		out_file.puts(builded_string)
        out_file.close
    end
	
	def disable_clocl_recovary(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b)
		fpga_write_reg(micron_id = mic_id_a, register_address = RXRECCLK, register_data = "0xf")
        fpga_write_reg(micron_id = mic_id_b, register_address = RXRECCLK, register_data = "0xf")
	end
		
	
	def configure_prbs_pattern(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b)
		register_value_by_pcs = {0=> "0x5", 1=> "0x28", 2=> "0x140", 3=> "0xa00"}
        
        fpga_write_reg(micron_id = mic_id_a, register_address = PRBS_TX_SEQ_SEL, register_value_by_pcs[mic_pcs_a])
        fpga_write_reg(micron_id = mic_id_a, register_address = PRBS_RX_SEQ_SEL, register_value_by_pcs[mic_pcs_a])

        fpga_write_reg(micron_id = mic_id_b, register_address = PRBS_TX_SEQ_SEL, register_value_by_pcs[mic_pcs_b])
        fpga_write_reg(micron_id = mic_id_b, register_address = PRBS_RX_SEQ_SEL, register_value_by_pcs[mic_pcs_b])
	end
	
	def enable_prbs(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b)
		register_value_by_pcs = {0=> "0x11", 1=> "0x22", 2=> "0x44", 3=> "0x88"}
        fpga_write_reg(micron_id = mic_id_a, register_address = PRBS_ENABLE, register_value_by_pcs[mic_pcs_a])
        fpga_write_reg(micron_id = mic_id_b, register_address = PRBS_ENABLE, register_value_by_pcs[mic_pcs_b])
	end
	
	def disable_prbs(mic_id_a, mic_id_b)
		fpga_write_reg(micron_id = mic_id_a, register_address = PRBS_ENABLE, "0x2")
        fpga_write_reg(micron_id = mic_id_b, register_address = PRBS_ENABLE, "0x1")
	end

    def gty_prbs_test(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b, run_id, error_force=true)
	
		test_status = true
        puts("Start GTY_PRBS Test: MIC_#{mic_id_a}, PCS_#{mic_pcs_a} <--> MIC_#{mic_id_b}, PCS#{mic_pcs_b}")

        puts("**** [DEBUG] Disable clock recovery for both microns *****")
        configure_prbs_pattern(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b)
		#fpga_write_reg(micron_id = mic_id_a, register_address = RXRECCLK, register_data = "0xf")
        #fpga_write_reg(micron_id = mic_id_b, register_address = RXRECCLK, register_data = "0xf")

        puts("**** [DEBUG] Configure PRBS test pattern *****")
		configure_prbs_pattern(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b)
        #register_value_by_pcs = {0=> "0x5", 1=> "0x28", 2=> "0x140", 3=> "0xa00"}
        
        #fpga_write_reg(micron_id = mic_id_a, register_address = PRBS_TX_SEQ_SEL, register_value_by_pcs[mic_pcs_a])
        #fpga_write_reg(micron_id = mic_id_a, register_address = PRBS_RX_SEQ_SEL, register_value_by_pcs[mic_pcs_a])

        #fpga_write_reg(micron_id = mic_id_b, register_address = PRBS_TX_SEQ_SEL, register_value_by_pcs[mic_pcs_b])
        #fpga_write_reg(micron_id = mic_id_b, register_address = PRBS_RX_SEQ_SEL, register_value_by_pcs[mic_pcs_b])

        puts("**** [DEBUG] Enable PRBS *****")
		enable_prbs(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b)
        #register_value_by_pcs = {0=> "0x11", 1=> "0x22", 2=> "0x44", 3=> "0x88"}
        #fpga_write_reg(micron_id = mic_id_a, register_address = PRBS_ENABLE, register_value_by_pcs[mic_pcs_a])
        #fpga_write_reg(micron_id = mic_id_b, register_address = PRBS_ENABLE, register_value_by_pcs[mic_pcs_b])

        puts("**** [DEBUG] Check 'Locked' state *****")
        sleep(1)
        mic_a_err_status = fpga_read_reg(micron_id = mic_id_a, register_address = PRBS_RX_STATUS).to_s(2).rjust(8, "0")
        mic_b_err_status = fpga_read_reg(micron_id = mic_id_b, register_address = PRBS_RX_STATUS).to_s(2).rjust(8, "0")
        register_value_by_pcs = {0=> "0x1", 1=> "0x2", 2=> "0x4", 3=> "0x8"}
        mic_a_lock_status = false
		#puts("[DEBUG] ====> mic_a #{mic_a_err_status}")
		#puts("[DEBUG] ====> mic_b #{mic_b_err_status}")
		#puts("[DEBUG] COMPARE ====> #{mic_a_err_status[7-mic_pcs_a]}  OVER   1")
        #if mic_a_err_status == register_value_by_pcs[mic_pcs_a].to_i(16)
		
		if mic_a_err_status[7-mic_pcs_a - 4] == "1"
			puts("*******[DEBUG] MIC_#{mic_id_a}, PCS_#{mic_pcs_a} OVERFLOWED")
		end
		
		if mic_a_err_status[7-mic_pcs_a] == "1"
            puts("**** [DEBUG] PRBS is 'Locked' on MIC_#{mic_id_a}, PCS_#{mic_pcs_a} *****")
            puts("**** [DEBUG] Check bit and error counters *****")
            mic_a_lock_status = true
			sleep(1)
            register_address_by_pcs = {0=> PRBS_BITS_CNT_L0, 1=> PRBS_BITS_CNT_L1, 2=> PRBS_BITS_CNT_L2, 3=> PRBS_BITS_CNT_L3}
            lower_bit_cnt_a = fpga_read_reg(micron_id = mic_id_a, register_address = register_address_by_pcs[mic_pcs_a])
            register_address_by_pcs = {0=> PRBS_BITS_CNT_H0, 1=> PRBS_BITS_CNT_H1, 2=> PRBS_BITS_CNT_H2, 3=> PRBS_BITS_CNT_H3}
            upper_bit_cnt_a = fpga_read_reg(micron_id = mic_id_a, register_address = register_address_by_pcs[mic_pcs_a])
            register_address_by_pcs = {0=> PRBS_ERR_CNT_0, 1=> PRBS_ERR_CNT_1, 2=> PRBS_ERR_CNT_2, 3=> PRBS_ERR_CNT_3}
            bit_err_cnt_a = fpga_read_reg(micron_id = mic_id_a, register_address = register_address_by_pcs[mic_pcs_a])
			mic_a_ber = calculate_ber(bit_err_cnt_a, lower_bit_cnt_a, upper_bit_cnt_a)
			test_status = test_status & report_gty_prbs(mic_a_lock_status, mic_id_a, mic_pcs_a, bit_err_cnt_a, mic_a_ber, low_limit=0, high_limit=0, test_run_id = run_id, flag=false)
			
			if error_force == true
				
				puts("**** [DEBUG] Force error at MIC_#{mic_id_a} generator *****")
				register_value_by_pcs = {0=> PRBS_FORCE_ERR_CH0, 1=> PRBS_FORCE_ERR_CH1, 2=> PRBS_FORCE_ERR_CH2, 3=> PRBS_FORCE_ERR_CH3}
				fpga_write_reg(micron_id = mic_id_b, register_address = PRBS_FORCE_ERR, register_value_by_pcs[mic_pcs_b])
				sleep(1)
				
				puts("**** [DEBUG] Check bit and error counters with error force *****")
				register_address_by_pcs = {0=> PRBS_BITS_CNT_L0, 1=> PRBS_BITS_CNT_L1, 2=> PRBS_BITS_CNT_L2, 3=> PRBS_BITS_CNT_L3}
				fe_lower_bit_cnt_a = fpga_read_reg(micron_id = mic_id_a, register_address = register_address_by_pcs[mic_pcs_a])
				register_address_by_pcs = {0=> PRBS_BITS_CNT_H0, 1=> PRBS_BITS_CNT_H1, 2=> PRBS_BITS_CNT_H2, 3=> PRBS_BITS_CNT_H3}
				fe_upper_bit_cnt_a = fpga_read_reg(micron_id = mic_id_a, register_address = register_address_by_pcs[mic_pcs_a])
				register_address_by_pcs = {0=> PRBS_ERR_CNT_0, 1=> PRBS_ERR_CNT_1, 2=> PRBS_ERR_CNT_2, 3=> PRBS_ERR_CNT_3}
				fe_bit_err_cnt_a = fpga_read_reg(micron_id = mic_id_a, register_address = register_address_by_pcs[mic_pcs_a])
				fe_mic_a_ber = calculate_ber(fe_bit_err_cnt_a, fe_lower_bit_cnt_a, fe_upper_bit_cnt_a)
				test_status = test_status & report_gty_prbs(mic_a_lock_status, mic_id_a, mic_pcs_a, fe_bit_err_cnt_a, fe_mic_a_ber, low_limit=1, high_limit=50, test_run_id = run_id, flag=true)
			
			end
			
        else
            puts("**** [DEBUG] PRBS is NOT 'Locked' on MIC_#{mic_id_a}, PCS_#{mic_pcs_a} *****")
        end
        mic_b_lock_status = false
		puts("[DEBUG] COMPARE ====> #{mic_b_err_status[7-mic_pcs_b]}  OVER   1")
        if mic_b_err_status[7-mic_pcs_b - 4] == "1"
			puts("*******[DEBUG] MIC_#{mic_id_b}, PCS_#{mic_pcs_b} OVERFLOWED")
		end
		if mic_b_err_status[7-mic_pcs_b] == "1"
            puts("**** [DEBUG] PRBS is 'Locked' on MIC_#{mic_id_b}, PCS_#{mic_pcs_b} *****")
            puts("**** [DEBUG] Check bit and error counters *****")
			sleep(1)
            mic_b_lock_status = true
            register_address_by_pcs = {0=> PRBS_BITS_CNT_L0, 1=> PRBS_BITS_CNT_L1, 2=> PRBS_BITS_CNT_L2, 3=> PRBS_BITS_CNT_L3}
            lower_bit_cnt_b = fpga_read_reg(micron_id = mic_id_b, register_address = register_address_by_pcs[mic_pcs_b])
            register_address_by_pcs = {0=> PRBS_BITS_CNT_H0, 1=> PRBS_BITS_CNT_H1, 2=> PRBS_BITS_CNT_H2, 3=> PRBS_BITS_CNT_H3}
            upper_bit_cnt_b = fpga_read_reg(micron_id = mic_id_b, register_address = register_address_by_pcs[mic_pcs_b])
            register_address_by_pcs = {0=> PRBS_ERR_CNT_0, 1=> PRBS_ERR_CNT_1, 2=> PRBS_ERR_CNT_2, 3=> PRBS_ERR_CNT_3}
            bit_err_cnt_b = fpga_read_reg(micron_id = mic_id_b, register_address = register_address_by_pcs[mic_pcs_b])
			mic_b_ber = calculate_ber(bit_err_cnt_b, lower_bit_cnt_b, upper_bit_cnt_b)
			test_status = test_status & report_gty_prbs(mic_b_lock_status, mic_id_b, mic_pcs_b, bit_err_cnt_b, mic_b_ber, low_limit=0, high_limit=0, test_run_id = run_id, flag=false)
			
			if error_force == true
				
				puts("**** [DEBUG] Force error at MIC_#{mic_id_b} generator *****")
				register_value_by_pcs = {0=> PRBS_FORCE_ERR_CH0, 1=> PRBS_FORCE_ERR_CH1, 2=> PRBS_FORCE_ERR_CH2, 3=> PRBS_FORCE_ERR_CH3}
				fpga_write_reg(micron_id = mic_id_a, register_address = PRBS_FORCE_ERR, register_value_by_pcs[mic_pcs_a])
				sleep(1)
				
				puts("**** [DEBUG] Check bit and error counters with error force *****")
				register_address_by_pcs = {0=> PRBS_BITS_CNT_L0, 1=> PRBS_BITS_CNT_L1, 2=> PRBS_BITS_CNT_L2, 3=> PRBS_BITS_CNT_L3}
				fe_lower_bit_cnt_b = fpga_read_reg(micron_id = mic_id_b, register_address = register_address_by_pcs[mic_pcs_b])
				register_address_by_pcs = {0=> PRBS_BITS_CNT_H0, 1=> PRBS_BITS_CNT_H1, 2=> PRBS_BITS_CNT_H2, 3=> PRBS_BITS_CNT_H3}
				fe_upper_bit_cnt_b = fpga_read_reg(micron_id = mic_id_b, register_address = register_address_by_pcs[mic_pcs_b])
				register_address_by_pcs = {0=> PRBS_ERR_CNT_0, 1=> PRBS_ERR_CNT_1, 2=> PRBS_ERR_CNT_2, 3=> PRBS_ERR_CNT_3}
				fe_bit_err_cnt_b = fpga_read_reg(micron_id = mic_id_b, register_address = register_address_by_pcs[mic_pcs_b])
				fe_mic_b_ber = calculate_ber(fe_bit_err_cnt_b, fe_lower_bit_cnt_b, fe_upper_bit_cnt_b)
				test_status = test_status & report_gty_prbs(mic_b_lock_status, mic_id_b, mic_pcs_b, fe_bit_err_cnt_b, fe_mic_b_ber, low_limit=1, high_limit=50, test_run_id = run_id, flag=true)
				
			end
        else
            puts("**** [DEBUG] PRBS is NOT 'Locked' on MIC_#{mic_id_b}, PCS_#{mic_pcs_b} *****")
			test_status = false
			test_status = test_status & report_gty_prbs(mic_b_lock_status, mic_id_b, mic_pcs_b, bit_err_cnt_b = -999, mic_b_ber=-999, low_limit=0, high_limit=0, test_run_id = run_id, flag=true)
        end
		if test_status == false
			final_status = "FAIL"
		else
			final_status = "PASS"
		end
		total_test_name="TEST_GTY_PRBS_MIC_#{mic_id_a}_MIC_#{mic_id_b}_PORT#{mic_pcs_a}_PORT#{mic_pcs_b}"
		log_to_file_test(run_id, total_test_name, final_status)
		
		disable_prbs(mic_id_a, mic_id_b)
		#enable_prbs(mic_id_a, mic_id_b, mic_pcs_a, mic_pcs_b)
		#disable_prbs(mic_id_a, mic_id_b)
		
		return test_status
    end

end