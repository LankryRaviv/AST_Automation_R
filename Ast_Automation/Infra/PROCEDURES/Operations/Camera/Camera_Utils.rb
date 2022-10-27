load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_FS_Download.rb')
load_utility('Operations/FSW/FSW_FS.rb')
load_utility('Operations/FSW/FSW_Telem.rb')

class ModuleCameraUtils

    def initialize(target = "BW3", csp_destination = "COSMOS_UMBILICAL")
        @target = target
        @cmd_sender = CmdSender.new
        @module_telem = ModuleTelem.new
        @file_util = ModuleFS.new
        @csp_destination = csp_destination
        @wait_time = 5
        

        @nodes = {"DPC_1": 15, "DPC_2": 16, "DPC_3": 17, "DPC_4": 18, "DPC_5": 19}

    end

    
    def power_cameras(apc_board, state, delay=0)

        # Turn on Power packet
        @module_telem.set_realtime(apc_board, "POWER_PCDU_LVC_TLM", @csp_destination, 1)
        @module_telem.set_realtime(apc_board, "POWER_CSBATS_TLM", @csp_destination, 1)
        @module_telem.set_realtime(apc_board, "PAYLOAD_TLM", @csp_destination, 1)

        # Check the DPC has power
        if state == 'ON'

            cmd_params = {"OUTPUT_CHANNEL": "DPC",
            "STATE_ONOFF": state,
            "DELAY": delay}
            @cmd_sender.send_with_cmd_count_check(apc_board, "APC_LVC_OUTPUT_SINGLE", cmd_params, "POWER", @wait_time)

            # Wait a few seconds for DPCs to boot
            wait(5)

            # Try to ping the DPC to verify they are on
            dpcs = ["DPC_1", "DPC_2", "DPC_3", "DPC_4", "DPC_5"]
            dpcs.each do |dpc|
                init_rec_cnt = tlm("BW3", "#{dpc}-CSP_PING", "RECEIVED_COUNT")
                @cmd_sender.send(dpc, "CSP_PING", {})
                wait_check("BW3", "#{dpc}-CSP_PING", "RECEIVED_COUNT", ">#{init_rec_cnt}", 5)
            end
        end

        # Turn on/off Camera LVC channel
        cmd_params = {"OUTPUT_CHANNEL": "CAMERAS",
                    "STATE_ONOFF": state,
                    "DELAY": delay}
        @cmd_sender.send_with_cmd_count_check(apc_board, "APC_LVC_OUTPUT_SINGLE", cmd_params, "POWER", @wait_time)

        # Verify LVC output is on
        if state == 'ON'
            wait_check(@target, "#{apc_board}-POWER_PCDU_LVC_TLM", "LVC_OUTPUT_CURRENT_3", " > 0", @wait_time)
        else
            wait_check(@target, "#{apc_board}-POWER_PCDU_LVC_TLM", "LVC_OUTPUT_CURRENT_3", " == 0", @wait_time)
        end
    end

    def power_cameras_alt_stack(primary_stack, state, delay=0)

        if primary_stack == "YP"
            secondary_stack = "YM"
        else
            secondary_stack = "YP"
        end

        if state == "ON"
            cmd_params = {"OUTPUT_CHANNEL": "DPC",
            "STATE_ONOFF": state,
            "DELAY": delay}
            @cmd_sender.send("APC_#{secondary_stack}", "APC_LVC_OUTPUT_SINGLE", cmd_params)

            wait(5)
        end

        cmd_params = {"OUTPUT_CHANNEL": "CAMERAS",
                    "STATE_ONOFF": state,
                    "DELAY": delay}
        @cmd_sender.send("APC_#{secondary_stack}", "APC_LVC_OUTPUT_SINGLE", cmd_params)


    end

    def set_I2C(dpc, register, value)

        # Send command
        cmd_params = {"REGISTER_I2C": register,
                      "VAlUE": value}
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_WRITE_I2C", cmd_params, "CAMERA", @wait_time)

        # Get new response packet and verify telemetry
        read_I2C(dpc, register)

        wait_check(@target, "#{dpc}-CAM_I2C_RES", "CAM_I2C_VALUE", "==#{value}", @wait_time)
                
    end

    def read_I2C(dpc, register)
        # Get initial packet count
        init_cnt = tlm(@target, "#{dpc}-CAM_I2C_RES", "RECEIVED_COUNT")

        # Get a new response packet
        cmd_params = {"REGISTER_I2C": register}
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_READ_I2C", cmd_params, "CAMERA", @wait_time)

        # Wait until a new response packet was received
        wait_check(@target, "#{dpc}-CAM_I2C_RES", "RECEIVED_COUNT", ">#{init_cnt}", @wait_time)

        # Return telemetry value
        return tlm(@target, "#{dpc}-CAM_I2C_RES", "CAM_I2C_VALUE")

    end

    def set_SPI(dpc, register, value)

        # Send command
        cmd_params = {"REGISTER_SPI": register,
                      "VAlUE": value}
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_WRITE_SPI", cmd_params, "CAMERA", @wait_time)

        # Get new response packet and verify telemetry
        read_SPI(dpc, register)

        wait_check(@target, "#{dpc}-CAM_SPI_RES", "CAM_SPI_VALUE", "==#{value}", @wait_time)
    end

    def read_SPI(dpc, register)
        # Get initial packet count
        init_cnt = tlm(@target, "#{dpc}-CAM_SPI_RES", "RECEIVED_COUNT")

        # Get a new response packet
        cmd_params = {"REGISTER_SPI": register}
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_READ_SPI", cmd_params, "CAMERA", @wait_time)

        # Wait until a new response packet was received
        wait_check(@target, "#{dpc}-CAM_SPI_RES", "RECEIVED_COUNT", ">#{init_cnt}", @wait_time)

        # Return telemetry value
        return tlm(@target, "#{dpc}-CAM_SPI_RES", "CAM_SPI_VALUE")

    end

    def init_camera(dpc)

        # Send command
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_INIT", {}, "CAMERA", @wait_time)
        wait(0.5)

        # Verify camera is initialized
        get_camera_tlm(dpc)

        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_INIT_STATUS", "=='ON'", @wait_time)

        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)
    end

    def init_camera_alt_stack(dpc, primary_stack, secondary_stack)

        # Send command
        cmd_params = {"CSP_NODE_ALT_STACK": dpc,
                      "CSP_PORT_ALT_STACK": 18}
        @cmd_sender.send_with_cmd_count_check("APC_#{primary_stack}","CAM_INIT_ALT_STACK", cmd_params, "CAMERA", @wait_time)
        wait(0.5)

        # Verify camera is initialized
        get_camera_tlm(dpc)

        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_INIT_STATUS", "=='ON'", @wait_time)

        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)

    end

    def get_camera_tlm(dpc)

        # Get initial packet count
        init_cnt = tlm(@target, "#{dpc}-CAMERA_TLM", "RECEIVED_COUNT")

        # Send get status command
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_STATUS", {}, "CAMERA", @wait_time)

        # Wait until a new response packet was received
        wait_check(@target, "#{dpc}-CAMERA_TLM", "RECEIVED_COUNT", ">#{init_cnt}", @wait_time)

    end
    
    def get_camera_tlm_alt_stack(dpc, primary_stack)

        if primary_stack =="YP"
            stack = "YM"
        else
            stack = "YP"
        end
        node = @nodes[dpc.to_sym]

        # Get initial packet count
        init_cnt = tlm(@target, "#{dpc}-CAMERA_TLM", "RECEIVED_COUNT")

        cmd_params = {"CSP_NODE_ALT_STACK": node, # This should be updated when the database is to CAM_CSP_PORT_ALT_STACK
                      "CAM_CSP_PORT_ALT_STACK": 18}

        # Send get status command
        @cmd_sender.send("APC_#{stack}","CAM_STATUS_ALT_STACK", cmd_params)

        # Get initial packet count
        wait_check(@target, "#{dpc}-CAMERA_TLM", "RECEIVED_COUNT", ">#{init_cnt}", @wait_time)

    end

    def set_mode(dpc, mode)
        # Send command
        cmd_params = {"MODE_CAM": mode}
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_MODE", cmd_params, "CAMERA", @wait_time)
        wait(0.5)

        # Verify camera mode
        get_camera_tlm(dpc)
        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_MODE", "=='#{mode}'", @wait_time)
    end

    def set_mode_alt_stack(dpc, mode, primary_stack, secondary_stack)

        cmd_params = {"CSP_NODE_ALT_STACK": dpc,
                      "CSP_PORT_ALT_STACK": 18,
                      "MODE_CAM": mode}
        @cmd_sender.send_with_cmd_count_check("APC_#{primary_stack}","CAM_MODE_ALT_STACK", cmd_params, "CAMERA", @wait_time)
        wait(0.5)

        # Verify camera mode
        get_camera_tlm(dpc)
        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_MODE", "=='#{mode}'", @wait_time)

    end

    def take_picture(dpc)

        # Get initial picture total
        get_camera_tlm(dpc)
        init_pics = tlm(@target, "#{dpc}-CAMERA_TLM", "CAM_TOTAL_PICS_TAKEN")

        # Send command 
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_TAKEPIC", {}, "CAMERA", @wait_time)
        wait(0.5)

        # Verify a picture was taken
        get_camera_tlm(dpc)
        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_TOTAL_PICS_TAKEN", "==#{init_pics + 1}", @wait_time)
        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_TAKEPIC_STATUS", "=='TRUE'", @wait_time)

    end

    def save_picture(dpc, file_id, offset)

        # Send the command
        cmd_params = {"FILE_ID_CAM": file_id}
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_SAVE", cmd_params, "CAMERA", @wait_time)
        wait(0.5)

        # Verify save status
        get_camera_tlm(dpc)
        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_SAVE_STATUS", "=='TRUE'", @wait_time)

    end

    def take_vid(dpc, vid_time, file_id, file_offset = 0)

        # Send the command
        cmd_params = {"SECONDS": vid_time,
                      "FILE_ID": file_id}
        @cmd_sender.send_with_cmd_count_check(dpc,"CAM_TAKEVID", cmd_params, "CAMERA", @wait_time)


    end

    def take_vid_alt_stack(dpc, vid_time, file_id, file_offset = 0, primary_stack)
        # dpc = DPC_1, DPC_2, DPC_3, DPC_4, DPC_5
        # primary_stack = YP, YM
        if primary_stack =="YP"
            stack = "YM"
        else
            stack = "YP"
        end

        # Send the command
        cmd_params = {"CAM_CSP_NODE_ALT_STACK": @nodes[dpc.to_sym],
                      "CAM_CSP_PORT_ALT_STACK": 18,
                      "SECONDS": vid_time,
                      "FILE_ID": file_id}
        @cmd_sender.send("APC_#{stack}","CAM_TAKEVID_ALT_STACK", cmd_params)

    end

    def download_pictures(board, file_id, save_file_name, alt_stack, primary_stack = "")

        if alt_stack
            csp_id = @nodes[board.to_sym]
            if primary_stack = "YP"
                board = "APC_YM"
            else
                board = "APC_YP"
            end
        else
            csp_id = 1
        end

        # Download from FSW Storage
        @file_dnld = FileDownload.new(file_id, board, save_file_name, "PICTURE_FILE_3", 1754, 50, 900, nil, nil, 5000, 0, Cosmos::USERPATH, "BW3", alt_stack, csp_id)

    end

    def check_camera_status(dpc)
        # Get Camera Status
        get_camera_tlm(dpc)
        wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)
    end

    def clear_and_format_file(dpc, file_id, entry_qty, entry_size)

        # Prepare file using CAM_PREP_FILE command
        cmd_params = {"FILE_ID_CAM": file_id}
        @cmd_sender.send(dpc,"CAM_PREP_FILE", cmd_params)

        wait(40)

        ##
        ## POLL FILE INFO

        format_timeout = 5 * 60
        poll_interval = 1
        starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        status = false
        while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < format_timeout
            puts "polling file info"

            file_info_hash_converted, file_info_hash_raw = @file_util.file_info(dpc, file_id, true, true)

            # check status and file_status before continuing with step 4 (upload)
            info_request_status = file_info_hash_converted["STATUS"]
            if info_request_status == 57
                puts "FILE_INFO_CMD status was #{info_request_status} - file busy formatting"

            elsif info_request_status == 0
                puts "FILE_INFO_CMD status was #{info_request_status} - formatting complete. confirming file info request file status is 0"
                status =  true
                break

            elsif info_request_status == 55
                puts "FILE_INFO_CMD status was #{info_request_status} - file empty. confirming file info request file status is 0"

                info_request_file_status = file_info_hash_raw["FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
                if info_request_file_status == 0
                status = true
                puts "FILE_INFO_CMD file_status was #{info_request_file_status} - continuing with upload"
                break
                else
                puts "FILE_INFO_CMD file_status was #{info_request_file_status} - aborting"
                break
                end
            else
                puts "FILE_INFO_CMD status was #{info_request_status} - unknown error (STEP 3), aborting"
                break
            end

            sleep(poll_interval)
        end

        if status != true
            puts "formatting failed"
            check_expression("#{status} == true")
        end


    end

    def prep_file(dpc, file_id)

        # Prepare file using CAM_PREP_FILE command
        cmd_params = {"FILE_ID_CAM": file_id}
        @cmd_sender.send(dpc,"CAM_PREP_FILE", cmd_params)

        wait(40)

        ##
        ## POLL FILE INFO

        format_timeout = 5 * 60
        poll_interval = 1
        starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        status = false
        while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < format_timeout
            puts "polling file info"

            file_info_hash_converted, file_info_hash_raw = @file_util.file_info(dpc, file_id, true, true)

            # check status and file_status before continuing with step 4 (upload)
            info_request_status = file_info_hash_converted["STATUS"]
            if info_request_status == 57
                puts "FILE_INFO_CMD status was #{info_request_status} - file busy formatting"

            elsif info_request_status == 0
                puts "FILE_INFO_CMD status was #{info_request_status} - formatting complete. confirming file info request file status is 0"
                status =  true
                break

            elsif info_request_status == 55
                puts "FILE_INFO_CMD status was #{info_request_status} - file empty. confirming file info request file status is 0"

                info_request_file_status = file_info_hash_raw["FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
                if info_request_file_status == 0
                status = true
                puts "FILE_INFO_CMD file_status was #{info_request_file_status} - continuing with upload"
                break
                else
                puts "FILE_INFO_CMD file_status was #{info_request_file_status} - aborting"
                break
                end
            else
                puts "FILE_INFO_CMD status was #{info_request_status} - unknown error (STEP 3), aborting"
                break
            end

            sleep(poll_interval)
        end

        if status != true
            puts "formatting failed"
            check_expression("#{status} == true")
        end


    end

    def prep_file_alt_stack(dpc, file_id, primary_stack)
        if primary_stack =="YP"
            stack = "YM"
        else
            stack = "YP"
        end
        node = @nodes[dpc.to_sym]

        cmd_params = {"CSP_NODE_ALT_STACK": node, # This should be updated when the database is to CAM_CSP_PORT_ALT_STACK
                      "CAM_CSP_PORT_ALT_STACK": 18,
                      "FILE_ID_CAM": file_id}
        @cmd_sender.send("APC_#{stack}", "CAM_PREP_FILE_ALT_STACK", cmd_params)

        ##
        ## POLL FILE INFO

        format_timeout = 5 * 60
        poll_interval = 1
        starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        status = false
        while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < format_timeout
            puts "polling file info"

            file_info_hash_converted, file_info_hash_raw = @file_util.file_info_altstack("APC_#{stack}", node, file_id, true, true)

            # check status and file_status before continuing with step 4 (upload)
            info_request_status = file_info_hash_converted["STATUS"]
            if info_request_status == 57
                puts "FILE_INFO_CMD status was #{info_request_status} - file busy formatting"

            elsif info_request_status == 0
                puts "FILE_INFO_CMD status was #{info_request_status} - formatting complete. confirming file info request file status is 0"
                status =  true
                break

            elsif info_request_status == 55
                puts "FILE_INFO_CMD status was #{info_request_status} - file empty. confirming file info request file status is 0"

                info_request_file_status = file_info_hash_raw["FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
                if info_request_file_status == 0
                status = true
                puts "FILE_INFO_CMD file_status was #{info_request_file_status} - continuing with upload"
                break
                else
                puts "FILE_INFO_CMD file_status was #{info_request_file_status} - aborting"
                break
                end
            else
                puts "FILE_INFO_CMD status was #{info_request_status} - unknown error (STEP 3), aborting"
                break
            end

            sleep(poll_interval)
        end

        if status != true
            puts "formatting failed"
            check_expression("#{status} == true")
        end

    end


    def init_and_format_dpcs(dpc_list,file_id, entry_qty, entry_size)
        dpc_list.each do |dpc|

            # Initalize Camera
            init_camera(dpc)
        
            # Get Camera Status
            get_camera_tlm(dpc)
            wait_check(@target, "#{dpc}-CAMERA_TLM", "CAM_STATUS", "=='OKAY'", @wait_time)
        
            # Set Camera Mode to 720 (2)
            set_mode(dpc, 720)
        
            # Format File
            clear_and_format_file(dpc, file_id, entry_qty, entry_size)
        
        end
    end


end