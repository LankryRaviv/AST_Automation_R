load_utility('Operations/FSW/UTIL_CmdSender.rb')
load_utility('Operations/MICRON/MICRON_FS_Upload.rb')

class MicronFWUPD
    def initialize
      @cmd_sender = CmdSender.new
      @target = "BW3"
    end

    def validate_signature(link, image, micron_id, converted=false, raw=false, wait_check_timeout=2)
        
        # Formulate cmd and tlm parameters
        cmd_name = "MIC_FIRMWARE_VALIDATE"
        cmd_params = {
			"MICRON_ID": micron_id,
            "IMAGE_TYPE": image,
        }
        pkt_name = "MIC_FIRMWARE_VALIDATE_RES"
        return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
    end

    def firmware_upload(link, micron_list, image, file_id=25, entry_size=1754, broadcast_all=false)
	    ret, status = MICRON_FS_Upload(entry_size, file_id, image, link, micron_list,broadcast_all: broadcast_all)             
        return ret
    end

    def firmware_size(image)
      return File.size(image)   
    end
    
    
    def firmware_info(link, micron_id, converted=false, raw=false, wait_check_timeout=2)
        
        # Formulate cmd and tlm parameters
        cmd_name = "MIC_FIRMWARE_INFO"
        cmd_params = {
			"MICRON_ID": micron_id,
        }
        pkt_name = "MIC_FIRMWARE_INFO_RES"
        return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout)
    end

    def firmware_start(link, micron_id, image,image_size, mcu_1,mcu_2, mcu_3,from_golden = 0,converted=false, raw=false, wait_check_timeout=2, no_hazardous_check = true)
        
        # Formulate cmd and tlm parameters
        cmd_name = "MIC_FIRMWARE_START"
        cmd_params = {
			"MICRON_ID": micron_id,
            "IMAGE_TYPE": image,
            "TARGET_MCU_1": mcu_1,
            "TARGET_MCU_2": mcu_2,
            "TARGET_MCU_3": mcu_3,
            "IMAGE_SIZE": image_size,
            "FROM_GOLDEN_STORAGE": from_golden
        }
        pkt_name = "MIC_FIRMWARE_START_RES"
        return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check)
    end

    def firmware_install(link, micron_id, image,converted=false, raw=false, wait_check_timeout=2, no_hazardous_check = true)
        
        # Formulate cmd and tlm parameters
        cmd_name = "MIC_FIRMWARE_INSTALL"
        cmd_params = {
			"MICRON_ID": micron_id,
        }
        pkt_name = "MIC_FIRMWARE_INSTALL_RES"
        return send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check)
    end

    def send_cmd_get_response(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check = true)
        full_pkt_name = get_full_pkt_name(link, pkt_name)
        res = []
        if !@cmd_sender.send_with_recv_count_retry_check(link, cmd_name, cmd_params, pkt_name, wait_check_timeout,no_hazardous_check,5)
          return res
        end
        # Send command, verify that response is received and is for this file ID
        # @cmd_sender.send_with_wait_check(board, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_check_timeout)
    
        # Get data to return, depending on format requested
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

    def get_full_pkt_name(board, pkt_name)
        return board+"-"+pkt_name
    end

    def send_cmd_get_response_orig(link, cmd_name, cmd_params, pkt_name, converted, raw, wait_check_timeout, no_hazardous_check = true)
        mnemonic = "RECEIVED_COUNT"
        comparison = ">"
        full_pkt_name = CmdSender.get_full_pkt_name(link, pkt_name)
    
        # Send command, verify that response is received and is for this file ID    
        @cmd_sender.send_with_wait_check(link, cmd_name, cmd_params, pkt_name, mnemonic, comparison, wait_check_timeout, no_hazardous_check)

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

