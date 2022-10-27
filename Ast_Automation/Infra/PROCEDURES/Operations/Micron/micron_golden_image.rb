load('Operations/MICRON/MICRON_FWUPD.rb')
load('Operations/MICRON/Micron_FS.rb')
load('Operations/MICRON/MICRON_CSP.rb')
load('C:\Ast_Automation\AST_Automation\bin\Debug\PROCEDURES\Operations\FSW\create_golden_descriptor.rb')
load('Operations/Micron/MICRON_MODULE.rb')

def golden_image_update(link, image_type, image_loc, micron_list, file_id, file_descriptor_id, broadcast_all, reboot, use_automations)
    fwupd = MicronFWUPD.new
    fs = MicronFS.new
    mic = MICRON_MODULE.new

    if !micron_list.kind_of?(Array)
        micron_list_temp = micron_list
        micron_list.append(micron_list_temp)
    end

    file_size = File.size(image_loc)
    
    if (image_type == "bl1")
        image_code = 0
        layer='bl1'
    elsif (image_type == "bl2")
        image_code = 1
        layer='bl2'
    elsif (image_type == "app")
        image_code = 2
        layer='app'
    else
        wait
    end

    err_arr = []
    failed_microns = []
    err_count = 0

    # Step 1 - validate signatures
    micron_list.each do |micron_id|
        fwupd_validate_hash_converted, fwupd_validate_hash_raw  = fwupd.validate_signature(link, image_code, micron_id, true, true)
        validity_code = fwupd_validate_hash_raw["MIC_FWUPD_ERROR_CODE"]

        if validity_code == 0
            puts "Image is valid for Micron #{micron_id}. Proceeding with firmware updare."
            wait(2)
        else
            err_msg = "ERROR: Image contains an invalid signature for micron #{micron_id}. Validity Code #{validity_code}"
            puts(err_msg)
            if !use_automations
                value = message_box("Validation of image failed; Continue? ", 'Yes', 'No')
                case value
                    when 'Yes'
                        puts 'Continuing'
                    when 'No'
                        next
                end
            end
            err_count += 1
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 1 signature validity failed"])
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end


    # Step 2 - Clear files  
    micron_list.each do |micron_id|
        fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(link, micron_id, true, true)
        #convert to hex
        mcu_uid_0 = fwupd_version_hash_raw["MIC_MCU_UID_0"]
        # perform XOR
        xor_val = 'AAAAAAAA'.to_i(16)
        pass_val = mcu_uid_0 ^ xor_val
        cli_cmd = "fs locking #{file_id} unlock #{pass_val}"
        # send CLI command
        send_mic_cli(link, micron_id, cli_cmd)

        cli_cmd = "fs locking #{file_descriptor_id} unlock #{pass_val}"
        send_mic_cli(link, micron_id, cli_cmd)
    end

    
    micron_list.each do |micron_id|
        puts("Clearing file for micron #{micron_id} and wait 10s")
        res = fs.file_clear(link, micron_id, file_id, true, false, 10)[0]
        if res['MIC_STATUS'] == 0
            puts("File #{file_id} cleared for micron #{micron_id}.")
        else
            err_msg = "File clear for #{file_id} on micron #{micron_id} failed with code #{res}"
            puts(err_msg)
            err_count += 1
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 2 File Clear failed"])
        end
        
        puts 'Clearing file and wait 10s'
        res = fs.file_clear(link, micron_id, file_descriptor_id, true, false, 10)[0]
        if res['MIC_STATUS'] == 0
            puts("File #{file_id} cleared for micron #{micron_id}.")
        else
            err_msg = "File clear for #{file_id} on micron #{micron_id} failed with code #{res}"
            puts(err_msg)
            err_count += 1
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 2 File Clear failed"])
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    # Step 3 - Create golden descriptor, upload image and descriptor
    puts("Uploading golden image.")
    if !fwupd.firmware_upload(link, micron_list, image_loc, file_id, 1754, broadcast_all)
        err_msg = ("ERROR: Failed golden image upload for microns. Exiting")
        puts(err_msg)
        err_arr.append(err_msg)
        err_count += 1
        return false, get_status_hash(micron_list, failed_microns)
    end


    micron_list.each do |micron_id|
        fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(link, micron_id, true, true)
        mcu_uid_0 = fwupd_version_hash_raw["MIC_MCU_UID_0"]
        mcu_uid_1 = fwupd_version_hash_raw["MIC_MCU_UID_1"]
        mcu_uid_2 = fwupd_version_hash_raw["MIC_MCU_UID_2"]

        desc_file, result = create_golden_image(layer, file_size, mcu_uid_0, mcu_uid_1, mcu_uid_2)

        if !result
            err_msg = ("Unable to create golden descriptor file for micron #{micron_id}. Continuing with next micron")
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 3 Create Golden Descriptor failed"])
            next
        end
        puts("Descriptor file for micron #{micron_id} created at: #{desc_file}")
        
        puts 'Uploading golden descriptor'
        if !fwupd.firmware_upload(link, micron_id, desc_file, file_descriptor_id, 1754, false)
            err_msg = ("ERROR: Failed golden image descriptor upload for micron #{micron_id}.")
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 3 Upload Golden Descriptor failed"])
            next
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    if err_arr.length().positive? 
        puts("Errors encountered during Golden Image Update:")
        err_arr.each do |err|
            puts(err)
        end
    end

    if use_automations
        mic_status_hash = get_status_hash(micron_list, failed_microns)
        if err_count > 0
            return false, mic_status_hash
        end
        return true, mic_status_hash
    end

    if err_count > 0
        raise TestException.new "Total of #{err_count} Errors during Firmware Update.  Errors are:\n#{err_arr.join("\n")}"
    end
end

def get_status_hash(micron_list, failed_microns)
    mic_status_hash = Hash.new
    micron_list.each do |micron_id|
        mic_status_hash["MICRON_#{micron_id}".to_sym] = "PASS"
    end
    failed_microns.each do |micron_arr|
        mic_status_hash["MICRON_#{micron_arr[0]}".to_sym] = "FAIL at #{micron_arr[1]}"
    end
    return mic_status_hash
end

def send_mic_cli(link, micron_id, cli_cmd)
    mic = MICRON_MODULE.new
    cli_cmd_len = cli_cmd.length  
    if cli_cmd_len <= 21
        res = mic.remote_cli(link, micron_id, 0, cli_cmd, "COMPLETED")
    else
        remainder = cli_cmd_len%21
        iterations = (cli_cmd_len/21).floor()
        start_idx = 0
        end_idx = 20
        iterations.times {
            puts("sending #{cli_cmd[start_idx..end_idx]}") 
            mic.remote_cli(link, micron_id, 0, cli_cmd[start_idx..end_idx], "CONTINUE")
            start_idx = end_idx + 1
            end_idx = end_idx + 21
        }
        res = mic.remote_cli(link, micron_id, 0, cli_cmd[start_idx..(start_idx + remainder)], "COMPLETED")
    end
    puts("Micron #{micron_id} responded with #{res}")
end
class TestException < StandardError
    def initialize(msg="General Test Error", exception_type="custom")
        @exception_type = exception_type
        super(msg)
    end
end
