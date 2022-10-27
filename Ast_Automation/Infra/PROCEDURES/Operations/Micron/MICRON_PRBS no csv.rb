module MICRON_PRBS
    #load_utility('Operations/MICRON/MICRON_MODULE.rb')
    load_utility('Operations/CPBF/CPBF_MODULE.rb')

    require 'csv'
    require 'date'

    module Settings
        MEASURE_TIME = 1 #sec    
    end

    #micron_id = "MICRON_21"

    #m = MICRON_MODULE.new
    #board= "MIC_LSL"

    $result_collector = []

    $c = ModuleCPBF.new

    CPBF_MICRON_LIST = [77, 78, 93, 107, 120, 119, 104, 90]

    RING_A = [118, 119, 120, 121, 107, 93, 79, 78, 77, 76, 90, 104]
    RING_B = [131, 132, 133, 134, 135, 136, 122, 108, 94, 80, 66, 65, 64, 63, 62, 61, 75, 89, 103, 117]
    RING_C = [144, 145, 146, 147, 148, 149, 150, 151, 137, 123, 109, 95, 81, 67, 53, 52, 51, 50, 49, 48, 47, 46, 60, 74, 88, 102, 116, 130]
    RING_D = [152,138,124,110,96,82,68,54,45,59,73,87,101,115,129,143]
    RING_E = [156,157,158,159,160,161,162,163,164,165,166,167, 172, 173,174,175,176,177,178,179,153,139,125,111,97,83,69,55,142,128,114,100,86,72,58,44,30,31,32,33,34,35,36,37,38,39,40,41,18,19,20,21,22,23,24,25]
    RING_F = [186,187,188,189,190,191,192,193,11,10,9,8,7,6,5,4]

    def log_to_file_micron(run_id, test_name, micron_id, pcs, ll, res, hl, status)
        time = Time.new
		full_test_name = test_name +"_MICRON_" + micron_id.to_s + "_PCS_" + pcs.to_s
        out_file = File.new("C:\\cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
        #builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ test_name +"_MICRON_" + micron_id.to_s + "_PCS_" + pcs.to_s + ", PROCESS_NAME: BW3_COMP_PRBS, LL: " + ll.to_s + ", RESULT: " + res.to_s + ", HL: " +  hl.to_s + ", MU: bit, STATUS: " + status
        builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ full_test_name.ljust(30,' ') + ", PROCESS_NAME: BW3_COMP_PRBS, LL: " + ll.to_s + ", RESULT: " + res.to_s + ", HL: " +  hl.to_s + ", MU: bit, STATUS: " + status
		out_file.puts(builded_string)
        out_file.close
    end

    def log_to_file_cpbf(run_id, test_name, link, ll, res, hl, status, cpbf)
        time = Time.new
		full_test_name = test_name + "_CPBF_"+ cpbf +"_LINK_"+ link.to_s
        out_file = File.new("C:\\cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
        #builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ test_name + "_CPBF_LINK_"+ link.to_s + ", PROCESS_NAME: BW3_COMP_PRBS, LL: " + ll.to_s + ", RESULT: " + res.to_s + ", HL: " +  hl.to_s + ", MU: bit, STATUS: " + status
        builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " +time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ full_test_name.ljust(30,' ') + ", PROCESS_NAME: BW3_COMP_PRBS, LL: " + ll.to_s + ", RESULT: " + res.to_s + ", HL: " +  hl.to_s + ", MU: bit, STATUS: " + status
		out_file.puts(builded_string)
        out_file.close
    end
	
	def log_to_file_test(run_id, test_name, status)
        time = Time.new
		full_test_name = test_name
		if status == "PASS"
			res = "0"
		else
			res = "-999"
		end
        out_file = File.new("C:\\cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
        #builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ test_name + "_CPBF_LINK_"+ link.to_s + ", PROCESS_NAME: BW3_COMP_PRBS, LL: " + ll.to_s + ", RESULT: " + res.to_s + ", HL: " +  hl.to_s + ", MU: bit, STATUS: " + status
        builded_string = "RUN_ID: " + run_id.to_s + " DATE_TIME: " +time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: "+ full_test_name + ", PROCESS_NAME: BW3_COMP_PRBS, LL: 0, RESULT: -999, HL: 0, MU: Bit, STATUS: " + status
		out_file.puts(builded_string)
        out_file.close
    end

    def reset_error_cnt_and_enable_prbs_at_micron(micron_id)
        """
        Enable PRBS data gen+chcker at micron on all Micron PCS0123
        """
        #micron_id = "MICRON_#{micron_id}"
        micron_id = micron_id
        rw_flag = 1 # write
        register_address = 0x103300
        data = 0xff
        timeout = 1000
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0] # Ignore recived data 
        # Read register data for confirmation
        micron_id = micron_id
        rw_flag = 0 # read
        register_address = 0x103300
        data = 0xf
        timeout = 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data_rx = recv["CPBF_REG_DATA"]
        puts("[DEBUG] REG MICRON_#{micron_id} PRBS_PCS_CONTROL #{dec2hex(register_address)}, DATA_RX: #{dec2hex(data_rx)}, DATA_TX: #{dec2hex(data)}")
    end

    def disable_prbs_data_at_micron(micron_id)
        """
        Disable PRBS data gen+chcker at micron on all Micron PCS0123
        """
        #micron_id = "MICRON_#{micron_id}"
        micron_id = micron_id
        rw_flag = 1 # write
        register_address = 0x103300
        data = 0x0
        timeout = 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        # Read register data for confirmation
        micron_id = micron_id
        rw_flag = 0 # read
        register_address = 0x103300
        data = 0x0
        timeout = 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data_rx = recv["CPBF_REG_DATA"]
        puts("[DEBUG] MICRON_#{micron_id} PRBS_PCS_CONTROL CONFIRMATION #{dec2hex(register_address)}, DATA_RX: #{dec2hex(data_rx)}, DATA_TX: #{dec2hex(data)}")
    end

    def cpbf_vup_aggr_bypass_enable()
        """
        CPBF vup aggr bypass enable 
        must run before cpbf_select_link(link)
        """
        param = "VUP_AGGR_BYPASS_ENABLE"
        $c.cpbf_link_reset_cmd(param)
    end

    def cpbf_vup_aggr_bypass_disable()
        """
        CPBF vup aggr bypass enable 
        must run before cpbf_select_link(link)
        """
        param = "VUP_AGGR_BYPASS_DISABLE"
        $c.cpbf_link_reset_cmd(param)
    end

    def cpbf_select_link(link)
        """
        select linkage
        """
        param = "VUP_AGGR_BYPASS_GT_SELECT_#{link}"
        $c.cpbf_link_reset_cmd(param)
    end

    def enable_prbs_data_at_cpbf(micron_id=0)
        """
        Enable PRBS gen+checker data at CPBF
        to CPBF - micron id = 0
        """
        micron_id = micron_id
        rw_flag = 1 # write
        register_address = 0x1001
        data = 0x3
        timeout = 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        # Read register data for confirmation
        micron_id = micron_id
        rw_flag = 0 # write
        register_address = 0x1001
        data = 0x3
        timeout = 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data_rx = recv["CPBF_REG_DATA"]
        puts("[DEBUG] CPBF_PRBS_PCS_CONTROL CONFIRMATION #{dec2hex(register_address)}, DATA_RX: #{dec2hex(data_rx)}, DATA_TX: #{dec2hex(data)}")
        
    end

    def disable_prbs_data_at_cpbf(micron_id=0)
        """
        Enable PRBS gen+checker data at CPBF
        to CPBF - micron id = 0
        """
        rw_flag = 1 # write
        register_address = 0x1001
        data = 0x0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        # Read register data for confirmation
        rw_flag = 0 # read
        register_address = 0x1001
        data = 0x1
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data_rx = recv["CPBF_REG_DATA"]
        puts("[DEBUG] CPBF_PRBS_PCS_CONTROL CONFIRMATION #{dec2hex(register_address)}, DATA_RX: #{dec2hex(data_rx)}, DATA_TX: #{dec2hex(data)}")
    end

    def reset_error_cnt_and_enable_prbs_at_cpbf(micron_id=0)
        """
        Reset error counter at CPBF
        to CPBF - micron id = 0
        """
        # rw_flag = 1 # write
        # register_address = 0x1001
        # data = 0x0
        # timeout = 1000 # 1000 
        # recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        # sleep(0.2)
        rw_flag = 1 # write
        register_address = 0x1001
        data = 0xb
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        # Read register data for confirmation
        rw_flag = 0 # read
        register_address = 0x1001
        data = 0xb
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data_rx = recv["CPBF_REG_DATA"]
        puts("[DEBUG] CPBF_PRBS_PCS_CONTROL CONFIRMATION #{dec2hex(register_address)}, DATA_RX: #{dec2hex(data_rx)}, DATA_TX: #{dec2hex(data)}")
    end

    def enable_force_errors_in_prbs_data_at_cpbf(micron_id=0)
        """
        Force error in the generator of CPBF (the error will be shown on Micron)
        for CPBF - micron id = 0
        """
        rw_flag = 1 # write
        register_address = 0x1006
        data = 0x1
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
    end

    def disable_force_errors_in_prbs_data_at_cpbf(micron_id=0)
        """
        disable Force error in the generator of CPBF
        for CPBF - micron id = 0
        """
        rw_flag = 1 # write
        register_address = 0x1006
        data = 0x0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
    end

    def enable_force_errors_in_prbs_data_at_micron(micron_id)
        """
        Enable PRBS gen+checker data at CPBF
        for CPBF - micron id = 0
        """
        rw_flag = 1 # write
        register_address = 0x103338
        data = 0xf
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
    end

    def disable_force_errors_in_prbs_data_at_micron(micron_id)
        """
        Enable PRBS gen+checker data at CPBF
        for CPBF - micron id = 0
        """
        rw_flag = 1 # write
        register_address = 0x103338
        data = 0x0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
    end

    def confirm_cpbf_link(micron_id=0)
        """
        Confirm link between cpbf to micron
        """
        flag = false
        rw_flag = 0 # read
        register_address = 0x1002
        data = 0x0  # Ignored if rw_flag = 0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data = recv["CPBF_REG_DATA"]
        puts("[DEBUG] CPBF_PRBS_PCS_STATUS CONNECTION REG #{dec2hex(register_address)}, DATA: #{dec2hex(data)}")
        if data == 1
            flag = true
        end
        return flag
    end

    def confirm_cpbf_link_wait_for_prbs_to_lock(micron_id=0, link)
        """
        Confirm link between cpbf to micron
        """
        flag = false
        counter = 10
        while (flag == false) and (counter >0 )do
            sleep(1)
            counter = counter - 1
            rw_flag = 0 # read
            register_address = 0x1002
            data = 0x0  # Ignored if rw_flag = 0
            timeout = 1000 # 1000 
            recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
            data = recv["CPBF_REG_DATA"]
            puts("[DEBUG] CPBF_PRBS_PCS_STATUS REG #{dec2hex(register_address)}, DATA: #{dec2hex(data)}")
            if data == 1
                flag = true
                puts("[DEBUG] PRBS at CPBF Link #{link} is lock")
            else
                puts("[DEBUG] PRBS at CPBF Link #{link} is not lock")
            end
        end
        return flag
    end

    def reset_error_cnt_at_micron(micron_id)
        """
        Reset error counter at Micron
        """
        rw_flag = 1 # write
        register_address = 0x103300
        data = 0x0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        # Read register data for confirmation
        rw_flag = 0 # read
        register_address = 0x103300
        data = 0x0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data_rx = recv["CPBF_REG_DATA"]
        puts("[DEBUG] MICRON_ID_#{micron_id} PRBS_PCS_CONTROL CONFIRMATION #{dec2hex(register_address)}, DATA_RX: #{dec2hex(data_rx)}, DATA_TX: #{dec2hex(data)}")   
        
        sleep(0.2)
        rw_flag = 1 # write
        register_address = 0x103300
        data = 0xff
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        # Read register data for confirmation
        rw_flag = 0 # read
        register_address = 0x103300
        data = 0xff
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data_rx = recv["CPBF_REG_DATA"]
        puts("[DEBUG] MICRON_ID_#{micron_id} PRBS_PCS_CONTROL CONFIRMATION #{dec2hex(register_address)}, DATA_RX: #{dec2hex(data_rx)}, DATA_TX: #{dec2hex(data)}")
    end

    def read_cpbf_error_count(micron_id=0)
        """
        Read error count
        """
        rw_flag = 0 # read
        register_address = 0x1003
        data = 0x0  # Ignored if rw_flag = 0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data = recv["CPBF_REG_DATA"]
        puts("[DEBUG] CPBF ERRORS REG #{dec2hex(register_address)}, DATA: #{data}")
        return data
    end

    def read_cpbf_lower_bit_count(micron_id=0)
        """
        Read lower bit error count
        """
        rw_flag = 0 # read
        register_address = 0x1004
        data = 0x0  # Ignored if rw_flag = 0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data = recv["CPBF_REG_DATA"]
        puts("[DEBUG] CPBF LOWER BIT REG #{dec2hex(register_address)}, DATA: #{data}")
        return data
    end

    def read_cpbf_upper_bit_count(micron_id=0)
        """
        Read upper bit error count
        """
        rw_flag = 0 # read
        register_address = 0x1005
        data = 0x0  # Ignored if rw_flag = 0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data = recv["CPBF_REG_DATA"]
        puts("[DEBUG] CPBF UPPER BIT REG #{dec2hex(register_address)}, DATA: #{data}")
        return data
    end

    def read_micron_error_count(micron_id, pcs)
        """
        Read error count
        """
        rw_flag = 0 # read
        # register_address = 0x103308
        register_address = {0=> 0x103308, 1=> 0x103314, 2=> 0x103320, 3=> 0x10332c} 
        data = 0x0  # Ignored if rw_flag = 0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address[pcs], data, timeout)[0]
        data = recv["CPBF_REG_DATA"]
        puts("[DEBUG] MICRON_#{micron_id} PCS#{pcs} ERROR REG #{dec2hex(register_address[pcs])}, DATA: #{data}")
        return data
    end

    def read_micron_lower_bit_count(micron_id, pcs)
        """
        Read error count
        """
        rw_flag = 0 # read
        # register_address = 0x103318
        register_address = {0=> 0x10330c, 1=> 0x103318, 2=> 0x103324, 3=> 0x103330}
        data = 0x0  # Ignored if rw_flag = 0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address[pcs], data, timeout)[0]
        data = recv["CPBF_REG_DATA"]
        puts("[DEBUG] MICRON_#{micron_id} PCS#{pcs} LOWER BIT REG #{dec2hex(register_address[pcs])}, DATA: #{data}")
        return data
    end

    def read_micron_upper_bit_count(micron_id, pcs)
        """
        Read error count
        """
        
        rw_flag = 0 # read
        register_address = {0=> 0x103310, 1=> 0x10331c, 2=> 0x103328, 3=> 0x103334} 
        data = 0x0  # Ignored if rw_flag = 0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address[pcs], data, timeout)[0]
        data = recv["CPBF_REG_DATA"]
        puts("[DEBUG] MICRON_#{micron_id} PCS#{pcs} UPPER BIT REG #{dec2hex(register_address[pcs])}, DATA: #{data}")
        return data
    end

    def get_expected_pcs_status(micron_id)
        """
        For micron id get PCS expected status result from csv sheet
        """
        table = CSV.parse(File.read("C:\\cosmos\\PROCEDURES\\Operations\\Routing\\PRBS Operational table.csv"), headers: true)
        pcs_channel_col = 0
        micron_id_col = 1
        pcs_status_col = 2
        micron_id_list = [*1..150]
        
        for id in micron_id_list do
        # puts("MICRON ID: #{micron_id}")
        # puts table.by_row[id][1]
            if micron_id.to_s == table.by_row[id][micron_id_col]
                pcs_status = table.by_row[id].to_s.split(",")[pcs_status_col]
                pcs_channel = table.by_row[id].to_s.split(",")[pcs_channel_col]
                break
            end
        end
        puts("[DEBUG] MICRON_ID#{micron_id} EXPECTED PCS_STATUS: #{pcs_status}")
        return pcs_status, pcs_channel
    end

    def dec2bin(number, width)
        puts("start dec2bin method")
        # number = Integer(number)
        # if(number == 0) then 0 end
            
        # ret_bin = ""
        # while(number != 0)
        #     ret_bin = String(number % 2) + ret_bin
        #     number = number / 2
        # end
        # ret_bin.rjust(width, "0")
        puts number.respond_to?(:to_i) 
        number = number.to_i
        bin_data = data.to_s(2).rjust(16, "0")[-14..-1] 
    end

    def get_expected_pcs_status2(micron_id)
        """
        for micron id get PCS expected status result from csv sheet
        """
        table = CSV.parse(File.read("C:\\cosmos\\PROCEDURES\\Operations\\Routing\\PRBS_PCS_CONNECTION_TABLE_BY_RING.csv"), headers: true)
        micron_id_col = 0
        pcs_status_col =1
        micron_id_list = [*1..150]
        pcs_status_arr = []
        for id in micron_id_list do
            #puts table.by_row[id][1]
            csv_micron_id = table.by_row[id][micron_id_col]
            if csv_micron_id == micron_id.to_s
                pcs_status = table.by_row[id][pcs_status_col]
                break
            end
        end
        puts("[DEBUG] MICRON_ID_#{micron_id} EXPECTED PCS_STATUS: #{pcs_status}")
        return pcs_status
    end

    def dec2hex(number)
        number.to_s(16)
    end

    

    def confirm_micron_link(micron_id, expected_status)
        """
        Confirm micron link 
        """
        flag = false
        rw_flag = 0 # read
        register_address = 0x103304
        data = 0x0  # Ignored if rw_flag = 0
        timeout = 1000 # 1000 
        recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)[0]
        data = recv["CPBF_REG_DATA"]
        
        # expected_data = get_expected_pcs_status2(micron_id)
        expected_data = expected_status
        #puts expected_data
        #puts data
        puts("[DEBUG] MICRON_ID_#{micron_id} PCS_STATUS REG: #{dec2hex(register_address)}, DATA: #{dec2hex(data)} EXPECTED PCS STATUS: #{dec2hex(expected_data)}")
        # if data == expected_data.hex
        if data == expected_data
            flag = true
			puts("[DEBUG] PCS_STATUS_REG AT MICRON_#{micron_id} IS MATCH TO EXPECTED PCS STATUS")
            #puts("PRBS at MICRON_ID_#{micron_id} is lock")
        end
        if data != 0
            pcs_array = ["","","",""]
            # bin_data = dec2bin(data, 16)[-14..-1] 
            bin_data = dec2bin(data, 16)

            if bin_data[0..1] == "11" # pcs3 valid
                pcs_array[3]= 1
            elsif bin_data[0..1] == "00"
                pcs_array[3]= 0
            else
                pcs_array[3]= 9  #  9 is error code
            end

            if bin_data[4..5] == "11" # pcs2 valid
                pcs_array[2]= 1
            elsif bin_data[4..5] == "00"
                pcs_array[2]= 0
            else
                pcs_array[2]= 9
            end

            if bin_data[8..9] == "11" # pcs1 valid
            pcs_array[1]= 1
            elsif bin_data[8..9] == "00"
            pcs_array[1]= 0
            else
            pcs_array[1]= 9
            end

            if bin_data[12..13] == "11" # pcs0 valid
            pcs_array[0]= 1
            elsif bin_data[12..13] == "00"
            pcs_array[0]= 0
            else
            pcs_array[0]= 9
            end
        else
            puts("[ALERT] #{micron_id}: NO VALID PCS CONNECTION")
            pcs_array = [0,0,0,0]
        end
        return flag, pcs_array
    end


    def confirm_micron_link_wait_for_prbs_to_lock(micron_id, expected_status)
        """
        Confirm micron link 
        """

        flag = false
        counter = 10
        while (flag == false) and (counter >0 ) do
            sleep(1)
            counter = counter - 1
            rw_flag = 0 # read
            register_address = 0x103304
            data = 0x0  # Ignored if rw_flag = 0
            timeout = 1000 # 1000 
            recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, register_address, data, timeout)
            #puts recv.class
            #puts recv.length
            
            data = recv[0]["CPBF_REG_DATA"]
            # expected_data = get_expected_pcs_status2(micron_id)
            expected_data = expected_status
            #puts expected_data
            #puts data
            puts("[DEBUG] MICRON_ID_#{micron_id} PCS_STATUS REG: #{dec2hex(register_address)}, DATA: #{dec2hex(data)} EXPECTED PCS STATUS: #{dec2hex(expected_data)}")
            if data == expected_data
				puts("[ALERT] PCS_STATUS_REG AT MICRON_#{micron_id} IS MATCH TO EXPECTED PCS STATUS")
                #puts("[DEBUG] PRBS at MICRON_ID_#{micron_id} is lock")
                flag = true
            else
                puts("[ALERT] PCS_STATUS_REG AT MICRON_#{micron_id} DOESN'T MATCH TO EXPECTED PCS STATUS")
				#puts("[DEBUG] PRBS at MICRON_ID_#{micron_id} is not lock")
            end
        end
        puts data unless data.is_a? Integer
        puts data.class unless data.is_a? Integer
        if data != 0
            pcs_array = ["","","",""]
			#puts("convert recv data from dec to bin")
            # bin_data = dec2bin(data, 16)[-14..-1]
            puts data.respond_to?(:to_i) 
            #puts("checkpoint1")
            data = data.to_i
            #puts("checkpoint2")
            bin_data = data.to_s(2).rjust(16, "0")[-14..-1] 
            #puts("checkpoint3")
            #bin_data = dec2bin(data, 16)
            #puts("parsing recv data to array")
            if bin_data[0..1] == "11" # pcs3 valid
                pcs_array[3]= 1
            elsif bin_data[0..1] == "00"
                pcs_array[3]= 0
            else
                pcs_array[3]= 9  #  9 is error code
            end

            if bin_data[4..5] == "11" # pcs2 valid
                pcs_array[2]= 1
            elsif bin_data[4..5] == "00"
                pcs_array[2]= 0
            else
                pcs_array[2]= 9
            end

            if bin_data[8..9] == "11" # pcs1 valid
            pcs_array[1]= 1
            elsif bin_data[8..9] == "00"
            pcs_array[1]= 0
            else
            pcs_array[1]= 9
            end

            if bin_data[12..13] == "11" # pcs0 valid
            pcs_array[0]= 1
            elsif bin_data[12..13] == "00"
            pcs_array[0]= 0
            else
            pcs_array[0]= 9
            end
        else
            puts("[ALERT] #{micron_id}: NO VALID PCS CONNECTION")
            pcs_array = [0,0,0,0]
        end
        return flag, pcs_array
    end

    def calculate_ber(error_count, err_low_cnt, err_upper_cnt)
        total_bit_count = (err_upper_cnt << 32) | err_low_cnt
        ber = (error_count + 1).to_f / total_bit_count.to_f
        return ber
    end


    def test_prbs_cpbf_to_micron(micron_list, run_id_str)
        # This method is for microns that are connected to CPBF
        # test the checkers of CPBF
        # First function to run in main
        for micron_id in micron_list
            reset_error_cnt_and_enable_prbs_at_micron(micron_id)
        end

        # Loop CPBF linkages and measure error and BER
        
        for link in [*1..8] do
            # cpbf_link_reset_vup_bypass(link)
            
            cpbf_select_link(link)
            cpbf_vup_aggr_bypass_enable()
            reset_error_cnt_and_enable_prbs_at_cpbf()
            sleep(11) # Wait for PRBS to lock
            connection = confirm_cpbf_link() # Confirm connectivity
            if connection == true
                sleep(Settings::MEASURE_TIME)
                err_cnt = read_cpbf_error_count()
                err_low_cnt = read_cpbf_lower_bit_count()
                err_upper_cnt = read_cpbf_upper_bit_count()
                ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
                
                if err_cnt > 0
                    out_string = "[TEST] CPBF LINK #{link}: Connection: PASS, PRBS FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res=err_cnt, hl=0, status= "FAIL")
                else
                    out_string = "[TEST] CPBF LINK #{link}: Connection: PASS, PRBS PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res=err_cnt, hl=0, status= "PASS")
                end
            else
                # puts("[ERROR]: No connection on link #{link}")
                out_string = "[TEST] CPBF LINK #{link}: Connection: FAIL, PRBS FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res=err_cnt, hl=0, status= "FAIL")
            end
            disable_prbs_data_at_cpbf()
        end
        for id in micron_list
            disable_prbs_data_at_micron(micron_id)
        end
    end

    # This method is for complete ring (A-F)
    # test PRBS for all Microns and all PCS0123 in all Microns
    # Secound function to run in main
    def test_prbs_micron_to_micron(micron_list, run_id_str)

        pcs_list = [0,1,2,3]

        for micron_id in micron_list
            reset_error_cnt_and_enable_prbs_at_micron(micron_id)
        end
        sleep(10) # Wait for PRBS to lock

        for micron_id in micron_list
            connection, valid_pcs_channels = confirm_micron_link(micron_id)
            print("MICRON_ID_#{micron_id} LOCK PRBS ON PCS: #{valid_pcs_channels}\n")
            for pcs in pcs_list do
                if valid_pcs_channels[pcs] == 1
                    sleep(Settings::MEASURE_TIME)
                    err_cnt = read_micron_error_count(micron_id, pcs)
                    err_low_cnt = read_micron_lower_bit_count(micron_id, pcs)
                    err_upper_cnt = read_micron_upper_bit_count(micron_id, pcs)
                    ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
                    if err_cnt > 0
                        out_string = "[TEST] MICRON_#{micron_id} PCS#{pcs}: Connection: PASS, PRBS: FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                        puts(out_string)
                        $result_collector.append(out_string)
                        log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=pcs, ll=0, res=err_cnt, hl=0, status= "FAIL")
                    else
                        out_string = "[TEST] MICRON_#{micron_id} PCS#{pcs}: Connection: PASS, PRBS: PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                        puts(out_string)
                        $result_collector.append(out_string)
                        log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=pcs, ll=0, res=err_cnt, hl=0, status= "PASS")
                    end
                elsif valid_pcs_channels[pcs] == 9
                # puts("[ERROR]: No connection on #{micron_id} PCS#{pcs}")
                    out_string = "[TEST] MICRON_#{micron_id} PCS#{pcs}: Connection: FAIL, PRBS: FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=pcs, ll=0, res="-999", hl=0, status= "FAIL")
                else
                    puts("[ALERT]: MICRON_#{micron_id} PCS#{pcs}: No connection")
                    log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=pcs, ll=0, res="-999", hl=0, status= "FAIL")
                end
            end
        end
        for micron_id in micron_list
            disable_prbs_data_at_micron(micron_id)
        end
    end


    # This method if for testing PRBS one single line between two microns
    # For debugging, not in normal test
    def test_prbs_micron_single_line(gen_micron_id, chk_micron_id, gen_micron_pcs, chk_micron_pcs, gen_pcs_status, chk_pcs_status, run_id_str)
		puts("**** Start testing PRBS between MICRON_#{gen_micron_id}, PCS#{gen_micron_pcs} and MICRON_#{chk_micron_id}, PCS#{chk_micron_pcs} ****")
		test_flag = true				
        
        cpbf_vup_aggr_bypass_disable()
        sleep(0.5)
        
        reset_error_cnt_and_enable_prbs_at_micron(chk_micron_id)
        reset_error_cnt_and_enable_prbs_at_micron(gen_micron_id)
        #sleep(11) # wait for PRBS to lock

        # For gen_micron_id
        connection, pcs_channels = confirm_micron_link_wait_for_prbs_to_lock(gen_micron_id, gen_pcs_status)
        if (pcs_channels[gen_micron_pcs] == 1) #and (connection == true)
            #puts("condition: pcs_channels[chk_micron_pcs] == #{pcs_channels[chk_micron_pcs]} and connection == #{connection}")
            # reset_error_cnt_and_enable_prbs_at_micron(chk_micron_id)
            # reset_error_cnt_and_enable_prbs_at_micron(gen_micron_id)
            sleep(Settings::MEASURE_TIME)
            err_cnt = read_micron_error_count(gen_micron_id, gen_micron_pcs)
            err_low_cnt = read_micron_lower_bit_count(gen_micron_id, gen_micron_pcs)
            err_upper_cnt = read_micron_upper_bit_count(gen_micron_id, gen_micron_pcs)
            ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
            if err_cnt > 0
                out_string = "[TEST] MICRON_#{gen_micron_id} PCS#{gen_micron_pcs}: Connection: PASS, PRBS: FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=gen_micron_id, pcs=gen_micron_pcs, ll=0, res=err_cnt, hl=0, status= "FAIL")
				test_flag = false				 
            else
                out_string = "[TEST] MICRON_#{gen_micron_id} PCS#{gen_micron_pcs}: Connection: PASS, PRBS: PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=gen_micron_id, pcs=gen_micron_pcs, ll=0, res=err_cnt, hl=0, status= "PASS")
            end   
        else
            out_string = "[TEST] MICRON_#{gen_micron_id} PCS#{gen_micron_pcs}: Connection: FAIL, PRBS: FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
            puts(out_string)
            $result_collector.append(out_string)
            log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=gen_micron_id, pcs=gen_micron_pcs, ll=0, res="-999", hl=0, status= "FAIL")
			test_flag = false				 
        end
        # For chk_micron_id
        connection, pcs_channels = confirm_micron_link_wait_for_prbs_to_lock(chk_micron_id, chk_pcs_status)
        if (pcs_channels[chk_micron_pcs] == 1) #and (connection == true)
            
            # reset_error_cnt_and_enable_prbs_at_micron(gen_micron_id)
            # reset_error_cnt_and_enable_prbs_at_micron(chk_micron_id)
            sleep(Settings::MEASURE_TIME)
            err_cnt = read_micron_error_count(chk_micron_id, chk_micron_pcs)
            err_low_cnt = read_micron_lower_bit_count(chk_micron_id, chk_micron_pcs)
            err_upper_cnt = read_micron_upper_bit_count(chk_micron_id, chk_micron_pcs)
            ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
            if err_cnt > 0
                out_string = "[TEST] MICRON_#{chk_micron_id} PCS#{chk_micron_pcs}: Connection: PASS, PRBS: FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=chk_micron_id, pcs=chk_micron_pcs, ll=0, res=err_cnt, hl=0, status= "FAIL")
				test_flag = false				 
            else
                out_string = "[TEST] MICRON_#{chk_micron_id} PCS#{chk_micron_pcs}: Connection: PASS, PRBS: PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=chk_micron_id, pcs=chk_micron_pcs, ll=0, res=err_cnt, hl=0, status= "PASS")
            end
        else
            out_string = "[TEST] MICRON_#{chk_micron_id} PCS#{chk_micron_pcs}: Connection: FAIL, PRBS: FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
            puts(out_string)
            $result_collector.append(out_string)
            log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=chk_micron_id, pcs=chk_micron_pcs, ll=0, res="-999", hl=0, status= "FAIL")
			test_flag = false				 
        end
        disable_prbs_data_at_micron(chk_micron_id)
        disable_prbs_data_at_micron(gen_micron_id)
		if test_flag
			log_to_file_test(run_id=run_id, test_name="TEST_PRBS_MIC_#{gen_micron_id}_MIC_#{chk_micron_id}_PORT#{gen_micron_pcs}_PORT#{chk_micron_pcs}", status="PASS")
        else
			log_to_file_test(run_id=run_id, test_name="TEST_PRBS_MIC_#{gen_micron_id}_MIC_#{chk_micron_id}_PORT#{gen_micron_pcs}_PORT#{chk_micron_pcs}", status="FAIL")
		end	  																																			 
        return test_flag
    end


    def test_prbs_micron_single_line_err_force(gen_micron_id, chk_micron_id, gen_micron_pcs, chk_micron_pcs, gen_pcs_status, chk_pcs_status, run_id_str)
		puts("**** Start testing PRBS between MICRON_#{gen_micron_id}, PCS#{gen_micron_pcs} and MICRON_#{chk_micron_id}, PCS#{chk_micron_pcs} ****")
		test_flag = true				
        
        cpbf_vup_aggr_bypass_disable()
        sleep(0.5)

        reset_error_cnt_and_enable_prbs_at_micron(chk_micron_id)
        reset_error_cnt_and_enable_prbs_at_micron(gen_micron_id)
        
        #sleep(11) # wait for PRBS to lock

        # For gen_micron_id
        connection, pcs_channels = confirm_micron_link_wait_for_prbs_to_lock(gen_micron_id, gen_pcs_status)
        if (pcs_channels[gen_micron_pcs] == 1) #and (connection == true)
            #puts("condition: pcs_channels[chk_micron_pcs] == #{pcs_channels[chk_micron_pcs]} and connection == #{connection}")
            sleep(Settings::MEASURE_TIME)
            err_cnt = read_micron_error_count(gen_micron_id, gen_micron_pcs)
            err_low_cnt = read_micron_lower_bit_count(gen_micron_id, gen_micron_pcs)
            err_upper_cnt = read_micron_upper_bit_count(gen_micron_id, gen_micron_pcs)
            ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
            if err_cnt > 0
                out_string = "[TEST] MICRON_#{gen_micron_id} PCS#{gen_micron_pcs}: Connection: PASS, PRBS: FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=gen_micron_id, pcs=gen_micron_pcs, ll=0, res=err_cnt, hl=0, status= "FAIL")
				test_flag = false				 
            else
                out_string = "[TEST] MICRON_#{gen_micron_id} PCS#{gen_micron_pcs}: Connection: PASS, PRBS: PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=gen_micron_id, pcs=gen_micron_pcs, ll=0, res=err_cnt, hl=0, status= "PASS")

                enable_force_errors_in_prbs_data_at_micron(chk_micron_id)
                sleep(1)
                err_cnt = read_micron_error_count(gen_micron_id, gen_micron_pcs)
                err_low_cnt = read_micron_lower_bit_count(gen_micron_id, gen_micron_pcs)
                err_upper_cnt = read_micron_upper_bit_count(gen_micron_id, gen_micron_pcs)
                ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
                if (err_cnt >=1) and (err_cnt <=50)
                    out_string = "[TEST] MICRON_#{gen_micron_id} PCS#{gen_micron_pcs}: Connection: PASS, PRBS_ERR_FRC PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_micron(run_id=run_id_str, test_name="PRBS_ERR_FRC", micron_id=gen_micron_id, pcs=gen_micron_pcs, ll=0, res=err_cnt, hl=50, status= "PASS")
                    
                else
                    out_string = "[TEST] MICRON_#{gen_micron_id} PCS#{gen_micron_pcs}: Connection: PASS, PRBS_ERR_FRC FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_micron(run_id=run_id_str, test_name="PRBS_ERR_FRC", micron_id=gen_micron_id, pcs=gen_micron_pcs, ll=0, res=err_cnt, hl=50, status= "FAIL")
					test_flag = false				 
                end
                disable_force_errors_in_prbs_data_at_micron(chk_micron_id)
            end   
        else
            out_string = "[TEST] MICRON_#{gen_micron_id} PCS#{gen_micron_pcs}: Connection: FAIL, PRBS: FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
            puts(out_string)
            $result_collector.append(out_string)
            log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=gen_micron_id, pcs=gen_micron_pcs, ll=0, res="-999", hl=0, status= "FAIL")
			test_flag = false				 
        end
        # For chk_micron_id
        connection, pcs_channels = confirm_micron_link_wait_for_prbs_to_lock(chk_micron_id, chk_pcs_status)
        if (pcs_channels[chk_micron_pcs] == 1) #and (connection == true)
            #puts("condition: pcs_channels[chk_micron_pcs] == #{pcs_channels[chk_micron_pcs]} and connection == #{connection}")
            sleep(Settings::MEASURE_TIME)
            err_cnt = read_micron_error_count(chk_micron_id, chk_micron_pcs)
            err_low_cnt = read_micron_lower_bit_count(chk_micron_id, chk_micron_pcs)
            err_upper_cnt = read_micron_upper_bit_count(chk_micron_id, chk_micron_pcs)
            ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
            if err_cnt > 0
                out_string = "[TEST] MICRON_#{chk_micron_id} PCS#{chk_micron_pcs}: Connection: PASS, PRBS: FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=chk_micron_id, pcs=chk_micron_pcs, ll=0, res=err_cnt, hl=0, status= "FAIL")
				test_flag = false				 
            else
                out_string = "[TEST] MICRON_#{chk_micron_id} PCS#{chk_micron_pcs}: Connection: PASS, PRBS: PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=chk_micron_id, pcs=chk_micron_pcs, ll=0, res=err_cnt, hl=0, status= "PASS")

                enable_force_errors_in_prbs_data_at_micron(gen_micron_id)
                sleep(1)
                err_cnt = read_micron_error_count(chk_micron_id, chk_micron_pcs)
                err_low_cnt = read_micron_lower_bit_count(chk_micron_id, chk_micron_pcs)
                err_upper_cnt = read_micron_upper_bit_count(chk_micron_id, chk_micron_pcs)
                ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
                if (err_cnt >=1) and (err_cnt <=50)
                    out_string = "[TEST] MICRON_#{chk_micron_id} PCS#{chk_micron_pcs}: Connection: PASS, PRBS_ERR_FRC PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_micron(run_id=run_id_str, test_name="PRBS_ERR_FRC", micron_id=chk_micron_id, pcs=chk_micron_pcs, ll=0, res=err_cnt, hl=50, status= "PASS")
                    
                else
                    out_string = "[TEST] MICRON_#{chk_micron_id} PCS#{chk_micron_pcs}: Connection: PASS, PRBS_ERR_FRC FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_micron(run_id=run_id_str, test_name="PRBS_ERR_FRC", micron_id=chk_micron_id, pcs=chk_micron_pcs, ll=0, res=err_cnt, hl=50, status= "FAIL")
					test_flag = false				 
                end
                disable_force_errors_in_prbs_data_at_micron(gen_micron_id)
            end
        else
            out_string = "[TEST] MICRON_#{chk_micron_id} PCS#{chk_micron_pcs}: Connection: FAIL, PRBS: FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
            puts(out_string)
            $result_collector.append(out_string)
            log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=chk_micron_id, pcs=chk_micron_pcs, ll=0, res="-999", hl=0, status= "FAIL")
			test_flag = false				 
        end
        disable_prbs_data_at_micron(chk_micron_id)
        disable_prbs_data_at_micron(gen_micron_id)
		if test_flag
			log_to_file_test(run_id=run_id, test_name="TEST_PRBS_MIC_#{gen_micron_id}_MIC_#{chk_micron_id}_PORT#{gen_micron_pcs}_PORT#{chk_micron_pcs}", status="PASS")
        else
			log_to_file_test(run_id=run_id, test_name="TEST_PRBS_MIC_#{gen_micron_id}_MIC_#{chk_micron_id}_PORT#{gen_micron_pcs}_PORT#{chk_micron_pcs}", status="FAIL")
		end
		return test_flag
    end


    # This method test PRBS between micron and CPBF
    def test_prbs_micron_cpbf_single_link(micron_id, link, micron_pcs, pcs_status,run_id_str, cpbf_master)
		puts("**** Start test PRBS between CPBF link #{link} and MICRON #{micron_id} PCS #{micron_pcs} ****")
		test_flag = true				
        # test gen an_d cheker of CPBF
        reset_error_cnt_and_enable_prbs_at_micron(micron_id)
        # Select requried link and enable aggr bypass at CPBF
        cpbf_select_link(link)
        cpbf_vup_aggr_bypass_enable()
        # Enable PRBS at CPBF
        reset_error_cnt_and_enable_prbs_at_cpbf()
        #sleep(11)
        connection = confirm_cpbf_link_wait_for_prbs_to_lock(0, link) # Confirm connectivity
        if connection == true
            reset_error_cnt_and_enable_prbs_at_cpbf()
            reset_error_cnt_and_enable_prbs_at_micron(micron_id)
            sleep(1)
            err_cnt = read_cpbf_error_count()
            err_low_cnt = read_cpbf_lower_bit_count()
            err_upper_cnt = read_cpbf_upper_bit_count()
            ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
            err_cpbf = err_cnt
            if err_cnt > 0
                out_string = "[TEST] CPBF_#{cpbf_master}_LINK #{link}: Connection: PASS, PRBS FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res=err_cnt, hl=0, status= "FAIL", cpbf=cpbf_master)
				test_flag = false				 
            else
                out_string = "[TEST] CPBF_#{cpbf_master}_LINK #{link}: Connection: PASS, PRBS PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res=err_cnt, hl=0, status= "PASS", cpbf=cpbf_master)
            end
        else
            out_string = "[TEST] CPBF_#{cpbf_master}_LINK #{link}: Connection: FAIL, PRBS FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
            puts(out_string)
            $result_collector.append(out_string)
            log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res="-999", hl=0, status= "FAIL", cpbf=cpbf_master)
			test_flag = false				 
        end
    
        # PRBS at micron
        connection, pcs_channels = confirm_micron_link_wait_for_prbs_to_lock(micron_id, pcs_status)
        if pcs_channels[micron_pcs] == 1
            sleep(Settings::MEASURE_TIME)
            err_cnt = read_micron_error_count(micron_id, micron_pcs)
            err_low_cnt = read_micron_lower_bit_count(micron_id, micron_pcs)
            err_upper_cnt = read_micron_upper_bit_count(micron_id, micron_pcs)
            ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
            err_micron = err_cnt
            
            if err_cnt > 0
                out_string = "[TEST] MICRON_#{micron_id} PCS#{micron_pcs}: Connection: PASS, PRBS FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=micron_pcs, ll=0, res=err_cnt, hl=0, status= "FAIL")
				test_flag = false				 
            else
                out_string = "[TEST] MICRON_#{micron_id} PCS#{micron_pcs}: Connection: PASS, PRBS PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=micron_pcs, ll=0, res=err_cnt, hl=0, status= "PASS")
            end
        else
            out_string = "[TEST] MICRON_#{micron_id} PCS#{micron_pcs}: Connection: FAIL, PRBS FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
            puts(out_string)
            $result_collector.append(out_string)
            log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=micron_pcs, ll=0, res="-999", hl=0, status= "FAIL")
			test_flag = false				 
        end
        disable_prbs_data_at_cpbf()
        disable_prbs_data_at_micron(micron_id)
		if test_flag == true
			log_to_file_test(run_id=run_id, test_name="TEST_PRBS_MIC_#{micron_id}_MIC_0_PORT#{micron_pcs}_PORT#{link}", status="PASS")
        else
			log_to_file_test(run_id=run_id, test_name="TEST_PRBS_MIC_#{micron_id}_MIC_0_PORT#{micron_pcs}_PORT#{link}", status="FAIL")
		end
		return test_flag				
    end


    # This method test PRBS between micron and CPBF with error forcing
    def test_prbs_micron_cpbf_single_link_err_force(micron_id, link, micron_pcs, pcs_status, run_id_str, cpbf_master)
		puts("**** Start test PRBS between CPBF link #{link} and MICRON #{micron_id} PCS #{micron_pcs} ****")
		test_flag = true				
        # test gen an_d cheker of CPBF
        reset_error_cnt_and_enable_prbs_at_micron(micron_id)
        # Select requried link and enable aggr bypass at CPBF
        cpbf_select_link(link)
        cpbf_vup_aggr_bypass_enable()
        # Enable PRBS at CPBF
        reset_error_cnt_and_enable_prbs_at_cpbf()
        # sleep(11)
        # connection = confirm_cpbf_link() # Confirm connectivity
        connection = confirm_cpbf_link_wait_for_prbs_to_lock(0, link)
        if connection == true
            reset_error_cnt_and_enable_prbs_at_cpbf()
            reset_error_cnt_and_enable_prbs_at_micron(micron_id)
            sleep(1)
            err_cnt = read_cpbf_error_count()
            err_low_cnt = read_cpbf_lower_bit_count()
            err_upper_cnt = read_cpbf_upper_bit_count()
            ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
            err_cpbf = err_cnt
            if err_cnt > 0
                out_string = "[TEST] CPBF_#{cpbf_master}_LINK #{link}: Connection: PASS, PRBS FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res=err_cnt, hl=0, status= "FAIL", cpbf=cpbf_master)
				test_flag = false				 
            else
                out_string = "[TEST] CPBF_#{cpbf_master}_LINK #{link}: Connection: PASS, PRBS PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res=err_cnt, hl=0, status= "PASS", cpbf=cpbf_master)
                
                # Force errors at micron outpuT
                enable_force_errors_in_prbs_data_at_micron(micron_id)
                sleep(1)
                err_cnt = read_cpbf_error_count()
                err_low_cnt = read_cpbf_lower_bit_count()
                err_upper_cnt = read_cpbf_upper_bit_count()
                ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
                if (err_cnt >=1) and (err_cnt <=50)
                    out_string = "[TEST] CPBF_#{cpbf_master}_LINK #{link}: Connection: PASS, PRBS_ERR_FRC PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_cpbf(run_id=run_id_str, test_name="PRBS_ERR_FRC", link=link, ll=1, res=err_cnt, hl=50, status= "PASS", cpbf=cpbf_master)
                    
                else
                    out_string = "[TEST] CPBF_#{cpbf_master}_LINK #{link}: Connection: PASS, PRBS_ERR_FRC FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_cpbf(run_id=run_id_str, test_name="PRBS_ERR_FRC", link=link, ll=1, res=err_cnt, hl=50, status= "FAIL", cpbf=cpbf_master)
					test_flag = false				 
                end
                disable_force_errors_in_prbs_data_at_micron(micron_id)
            end
            
        else
            out_string = "[TEST] CPBF_#{cpbf_master}_LINK #{link}: Connection: FAIL, PRBS FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
            puts(out_string)
            $result_collector.append(out_string)
            log_to_file_cpbf(run_id=run_id_str, test_name="PRBS", link=link, ll=0, res="-999", hl=0, status= "FAIL", cpbf=cpbf_master)
			test_flag = false				 
        end
    
        # PRBS at micron
        reset_error_cnt_and_enable_prbs_at_cpbf()
        reset_error_cnt_and_enable_prbs_at_micron(micron_id)
        connection, pcs_channels = confirm_micron_link_wait_for_prbs_to_lock(micron_id, pcs_status)
		#puts("Before if condition")
        if (pcs_channels[micron_pcs] == 1)
			#puts("Inside if condition")
            sleep(1)
            err_cnt = read_micron_error_count(micron_id, micron_pcs)
            err_low_cnt = read_micron_lower_bit_count(micron_id, micron_pcs)
            err_upper_cnt = read_micron_upper_bit_count(micron_id, micron_pcs)
            ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
            err_micron = err_cnt
            
            if err_cnt > 0
                out_string = "[TEST] MICRON_#{micron_id} PCS#{micron_pcs}: Connection: PASS, PRBS FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=micron_pcs, ll=0, res=err_cnt, hl=0, status= "FAIL")
				test_flag = false				 

            else
                out_string = "[TEST] MICRON_#{micron_id} PCS#{micron_pcs}: Connection: PASS, PRBS PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                puts(out_string)
                $result_collector.append(out_string)
                log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=micron_pcs, ll=0, res=err_cnt, hl=0, status= "PASS")

                # Force errors at micron output
                enable_force_errors_in_prbs_data_at_cpbf()
                sleep(1)
                err_cnt = read_micron_error_count(micron_id ,micron_pcs)
                err_low_cnt = read_micron_lower_bit_count(micron_id ,micron_pcs)
                err_upper_cnt = read_micron_upper_bit_count(micron_id ,micron_pcs)
                ber_res = calculate_ber(err_cnt, err_low_cnt, err_upper_cnt)
                if (err_cnt >=1) and (err_cnt <=50)
                    out_string = "[TEST] MICRON_#{micron_id} PCS#{micron_pcs}: Connection: PASS, PRBS_ERR_FRC PASS, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_micron(run_id=run_id_str, test_name="PRBS_ERR_FRC", micron_id=micron_id, pcs=micron_pcs, ll=1, res=err_cnt, hl=50, status= "PASS")
                    
                else
                    out_string = "[TEST] MICRON_#{micron_id} PCS#{micron_pcs}: Connection: PASS, PRBS_ERR_FRC FAIL, Error count: #{err_cnt} bit, BER: #{ber_res}"
                    puts(out_string)
                    $result_collector.append(out_string)
                    log_to_file_micron(run_id=run_id_str, test_name="PRBS_ERR_FRC", micron_id=micron_id, pcs=micron_pcs, ll=1, res=err_cnt, hl=50, status= "FAIL")
					test_flag = false				 
                end
                disable_force_errors_in_prbs_data_at_micron(micron_id)
            end
        else
            out_string = "[TEST] MICRON_#{micron_id} PCS#{micron_pcs}: Connection: FAIL, PRBS FAIL, Error count: #{"-999"} bit, BER: #{"-999"}"
            puts(out_string)
            $result_collector.append(out_string)
            log_to_file_micron(run_id=run_id_str, test_name="PRBS", micron_id=micron_id, pcs=micron_pcs, ll=0, res="-999", hl=0, status= "FAIL")
			test_flag = false				 
        end
        disable_prbs_data_at_cpbf()
        disable_prbs_data_at_micron(micron_id)
		if test_flag == true
			log_to_file_test(run_id=run_id, test_name="TEST_PRBS_MIC_#{micron_id}_MIC_0_PORT#{micron_pcs}_PORT#{link}", status="PASS")
        else
			log_to_file_test(run_id=run_id, test_name="TEST_PRBS_MIC_#{micron_id}_MIC_0_PORT#{micron_pcs}_PORT#{link}", status="FAIL")
		end
		return test_flag
    end
					
end



# Main 
# test_prbs_cpbf_to_micron(CPBF_MICRON_LIST)
# test_prbs_micron_to_micron(RING_A)
# test_prbs_micron_to_micron(RING_B)
# test_prbs_micron_to_micron(RING_C)
# test_prbs_micron_to_micron(RING_D)
# test_prbs_micron_to_micron(RING_E)
# test_prbs_micron_to_micron(RING_F)

#Debug
# run_id_str = "123456"
# count=10
# while (count>0)
#     # test_prbs_micron_cpbf_single_link_err_force(micron_id=78, link=2, micron_pcs=2)
#     #test_prbs_cpbf_to_micron(CPBF_MICRON_LIST)
#     test_prbs_micron_single_line_err_force(gen_micron_id=77, chk_micron_id=63, gen_micron_pcs=3, chk_micron_pcs=2, run_id_str=run_id_str)
#     for x in $result_collector do
#         puts x
#     end
#     count=count-1
# end

