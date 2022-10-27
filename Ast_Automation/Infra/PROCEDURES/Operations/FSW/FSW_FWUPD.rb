load 'Operations/FSW/UTIL_CmdSender.rb' 
load 'Operations/FSW/FSW_FS_Upload.rb'
load 'Operations/FSW/FSW_FS_Continue_Upload.rb'

class ModuleFWUPD
    def initialize
      @cmd_sender = CmdSender.new
      @target = "BW3"
    end

    def validate_signature(board, image,converted=false, raw=false, wait_check_timeout=2, no_hazardous_check = true)
        
        # Formulate cmd and tlm parameters
        cmd_name = "FSW_FIRMWARE_VALIDATE"
        cmd_params = {
            "IMAGE_TYPE": image,
        }
        pkt_name = "FIRMWARE_VALIDATE_RES"
            return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check)
    end

    def firmware_upload(board, image, file_id=155, entry_size=1754, check_aspect="CRC", check_test=0)
      FSW_FS_Upload(entry_size, file_id, image, board, check_aspect, check_test)
    end

    def firmware_upload_slim(board, image, file_id=155, entry_size=186, check_aspect="CRC", check_test=0)
        FSW_FS_Upload_Slim(entry_size, file_id, image, board, check_aspect, check_test)
    end

    def firmware_continue_upload(board, image, file_id=155, entry_size=1754,check_aspect="CRC")
        FSW_FS_Continue_Upload(entry_size, file_id, image, board, check_aspect)
    end

    def firmware_size(image)
      return File.size(image)
    end


    def firmware_info(board,converted=false, raw=false, wait_check_timeout=2)

        # Formulate cmd and tlm parameters
        cmd_name = "FSW_FIRMWARE_INFO"
        cmd_params = {
        }
        pkt_name = "FIRMWARE_INFO_RES"
            return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
    end

    def firmware_start(board, image,image_size, mcu_1,mcu_2, mcu_3,from_golden = 0,converted=false, raw=false, wait_check_timeout=3, no_hazardous_check=false)
        
        # Formulate cmd and tlm parameters
        cmd_name = "FSW_FIRMWARE_START"
        cmd_params = {
            "IMAGE_TYPE": image,
            "TARGET_MCU_1": mcu_1,
            "TARGET_MCU_2": mcu_2,
            "TARGET_MCU_3": mcu_3,
            "IMAGE_SIZE": image_size,
            "FROM_GOLDEN_STORAGE": from_golden
        }
        pkt_name = "FIRMWARE_START_RES"
            return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check)
    end

    def firmware_install(board, image, converted=false, raw=false, wait_check_timeout=3, no_hazardous_check=false)
        
        # Formulate cmd and tlm parameters
        cmd_name = "FSW_FIRMWARE_INSTALL"
        cmd_params = {
        }
        pkt_name = "FIRMWARE_INSTALL_RES"
            return send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check)
    end


    private
    def send_cmd_get_response(board, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check=false)
        mnemonic = "RECEIVED_COUNT"
        comparison = ">"
        # Try once
        full_pkt_name = CmdSender.get_full_pkt_name(board, pkt_name)
        current_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)
        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
        wait(wait_check_timeout)
        new_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)
        if new_val == current_val
            # Try twice
            current_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)
            @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
            wait(wait_check_timeout)
            new_val = @cmd_sender.get_current_val(board, pkt_name, mnemonic)
            if new_val == current_val
                # Try three times
                @cmd_sender.send_with_wait_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_check_timeout, no_hazardous_check)
            end
        end

        # Get data to return, depending on format requested
        res = []

        if converted
            res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
            res.push(res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        end

        if raw
            res_pkt_raw = get_tlm_packet(@target, full_pkt_name, value_types = :RAW)
            res.push(res_pkt_raw.map {|item| [item[0], item[1]]}.to_h)
        end

        return res
        end
    end

