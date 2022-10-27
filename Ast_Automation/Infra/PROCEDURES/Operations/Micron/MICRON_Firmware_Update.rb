load_utility('Operations/MICRON/MICRON_FWUPD.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')


def firmware_update(link, image, image_loc, version_info, file_id , from_golden , micron_list, 
broadcast_all, reboot, use_automations, check_version)
    # user can pass in single micron or array of microns
    if !micron_list.kind_of?(Array)
        micron_list_temp = micron_list
        micron_list.append(micron_list_temp)
    end
    # initializing the system for firmware upgrade
    fwupd = MicronFWUPD.new
    
    if (image == "bl1")
        image_code = 0
    elsif (image == "bl2")
        image_code = 1
    elsif (image == "app")
        image_code = 2
    else
        wait
    end

    err_arr = []
    failed_microns = []
    err_count = 0
    
    ### STEP 1 ###
    # Check signature validity for all three layers
    micron_list.each do |micron_id|
        fwupd_validate_hash_converted_L1, fwupd_validate_hash_raw_L1  = fwupd.validate_signature(link, 0, micron_id, true, true)
        fwupd_validate_hash_converted_L2, fwupd_validate_hash_raw_L2  = fwupd.validate_signature(link, 1, micron_id, true, true)
        fwupd_validate_hash_converted_APP,fwupd_validate_hash_raw_APP = fwupd.validate_signature(link, 2, micron_id, true, true)

        if fwupd_validate_hash_raw_L1.nil? || fwupd_validate_hash_raw_L2.nil? || fwupd_validate_hash_raw_APP.nil?
            err_msg = "\nFailed image validity check for micron #{micron_id}. No response from micron."
            err_count += 1
            failed_microns.append([micron_id, "Step 1 signature validity failed"])
            puts(err_msg)
            err_arr.append(err_msg)
            next
        end
        l1_validity_code  = fwupd_validate_hash_raw_L1["MIC_FWUPD_ERROR_CODE"]
        l2_validity_code  = fwupd_validate_hash_raw_L2["MIC_FWUPD_ERROR_CODE"]
        app_validity_code = fwupd_validate_hash_raw_APP["MIC_FWUPD_ERROR_CODE"]
        
        if l1_validity_code == 0 && l2_validity_code == 0 && app_validity_code == 0
            puts "All images valid for micron #{micron_id}. Proceeding with firmware update."            
        else
            err_msg = "ERROR: Invalid signature for micron #{micron_id}: "
            failed_image = []
            if l1_validity_code != 0
                err_msg += "L1 Validity code #{fwupd_validate_hash_converted_L1["MIC_FWUPD_ERROR_CODE"]} "
                failed_image.append(0)
            end
            if l2_validity_code != 0
                err_msg += "L2 Validity code #{fwupd_validate_hash_converted_L2["MIC_FWUPD_ERROR_CODE"]} "
                failed_image.append(1)
            end
            if app_validity_code != 0
                err_msg += "APP Validity code #{fwupd_validate_hash_converted_APP["MIC_FWUPD_ERROR_CODE"]} "
                failed_image.append(2)
            end          
            if !failed_image.include? image_code
                # failed validity check does not include image to be upgraded
                # count test as a failure with note
                err_msg += "\nFailed image validity check for image not being upgraded. Failed image(s) is #{failed_image}, image to upgrade is #{image}"
                err_count += 1
                failed_microns.append([micron_id, "Step 1 signature validity failed"])
            end
            puts(err_msg)
            err_arr.append(err_msg)
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    wait(2)
    ### STEP 2 ###
    # Uploading the image to the correct file_id
	fwupd.firmware_upload(link, micron_list, image_loc, file_id, 1754, broadcast_all)
  
    wait(2)

    ### STEP 3 ###
    # Starting the firmware upgrade procedure
    file_size = fwupd.firmware_size(image_loc)
    micron_list.each do |micron_id|
        fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(link, micron_id, true, true)
        if fwupd_version_hash_converted.empty?  
            err_msg = "ERROR: Micron #{micron_id} did not respond to Firmware Info command."
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 3 Start firmware upgrade"])
            next
        end
        mcu_uid_0 = fwupd_version_hash_raw["MIC_MCU_UID_0"]
        mcu_uid_1 = fwupd_version_hash_raw["MIC_MCU_UID_1"]
        mcu_uid_2 = fwupd_version_hash_raw["MIC_MCU_UID_2"]  
        
        fwupd_start_hash_converted, fwupd_start_hash_raw = fwupd.firmware_start(link, micron_id, image_code, file_size, mcu_uid_0, mcu_uid_1, mcu_uid_2,from_golden,true, true, 2,use_automations)
        fwupd_start_code = fwupd_start_hash_raw["MIC_FWUPD_ERROR_CODE"]

        # checking to see if the correctly start

        if fwupd_start_code == 0
            puts "Firmware update started for micron #{micron_id}. Proceeding with firmware update."
        else
            err_msg = "ERROR: Firmware update failed to start for micron #{micron_id}. Start code is #{fwupd_start_code}"
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 3 Firmware Start failed"])
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    wait(2)
    ### STEP 4 ###
    # Installing the firmware 
    micron_list.each do |micron_id|
        fwupd_install_hash_converted, fwupd_install_hash_raw = fwupd.firmware_install(link, micron_id, image_code, true, true, 3, use_automations)
        fwupd_install_code = fwupd_install_hash_raw["MIC_FWUPD_ERROR_CODE"]

        # checking to see if the install correctly start

        if fwupd_install_code == 0
            puts "Firmware update installed for micron #{micron_id}. Firmware update complete."
        elsif fwupd_install_code == 10
            puts "Firmware update installed for micron #{micron_id}. Proceeding with restart."
        else
            err_msg = "ERROR: Firmware update failed to start for micron #{micron_id}. Code is #{fwupd_install_hash_converted["MIC_FWUPD_ERROR_CODE"]}"
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 4 Firmware Install failed"])
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    wait(2)
    ### STEP 5 ###
    # Rebooting the board and check version number 
    if reboot
        micron_list.each do |micron_id|
            csp = MicronCSP.new
            csp.reboot(link, micron_id, use_automations)
            wait(0.2)
        end
        wait(20)
        if check_version
            micron_list.each do |micron_id|
                fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(link, micron_id, true, true)
                if fwupd_version_hash_converted.empty?  
                    err_msg = "ERROR: Micron #{micron_id} did not respond to Firmware Info command."
                    puts(err_msg)
                    err_arr.append(err_msg)
                    err_count += 1
                    failed_microns.append([micron_id, "Step 5 Start firmware upgrade"])
                    next
                end
            
                if image_code == 0
                    if fwupd_version_hash_raw["MIC_BOOT_L1_MAJOR"] == version_info["BOOT_L1_MAJOR"] &&
                        fwupd_version_hash_raw["MIC_BOOT_L1_MINOR"] == version_info["BOOT_L1_MINOR"] &&
                        fwupd_version_hash_raw["MIC_BOOT_L1_PATCH"] == version_info["BOOT_L1_PATCH"] 
                        puts "Bootloader L1 Firmware succesfully upgraded for micron #{micron_id}"
                    else
                        err_msg = "ERROR: Bootloader L1 Firmware update failed for micron #{micron_id}. Version info was not as expected."
                        puts(err_msg)
                        err_arr.append(err_msg)
                        err_count += 1
                        failed_microns.append([micron_id, "Step 5 Reboot and Verify Version failed"])       
                    end
                end
            
                if image_code == 1
                    if fwupd_version_hash_raw["MIC_BOOT_L2_MAJOR"] == version_info["BOOT_L2_MAJOR"] &&
                        fwupd_version_hash_raw["MIC_BOOT_L2_MINOR"] == version_info["BOOT_L2_MINOR"] &&
                        fwupd_version_hash_raw["MIC_BOOT_L2_PATCH"] == version_info["BOOT_L2_PATCH"] 
                        puts "Bootloader L2 Firmware succesfully upgraded for micron #{micron_id}"
                    else
                        err_msg = "ERROR: Bootloader L2 Firmware update failed for micron #{micron_id}. Version info was not as expected."
                        puts(err_msg)
                        err_arr.append(err_msg)
                        err_count += 1
                        failed_microns.append([micron_id, "Step 5 Reboot and Verify Version failed"])
                    end
                end
            
                if image_code == 2
                    if fwupd_version_hash_raw["MIC_APP_MAJOR"] == version_info["APP_MAJOR"] &&
                        fwupd_version_hash_raw["MIC_APP_MINOR"] == version_info["APP_MINOR"] &&
                        fwupd_version_hash_raw["MIC_APP_PATCH"] == version_info["APP_PATCH"] 
                        puts "Application Firmware succesfully upgraded for micron #{micron_id}"
                    else
                        err_msg = "ERROR: APP Firmware update failed for micron #{micron_id}. Version info was not as expected."
                        puts(err_msg)
                        err_arr.append(err_msg)
                        err_count += 1
                        failed_microns.append([micron_id, "Step 5 Reboot and Verify Version failed"])
                    end
                end
            end
        end
    end


    failed_microns.each do |failed_micron|
        puts("Micron #{failed_micron[0]} installation failed: #{failed_micron[1]}")
    end

    if err_arr.length().positive? 
        puts("Errors encountered during Firmware Update:")
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

    # display and raise errors
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

class TestException < StandardError
    def initialize(msg="General Test Error", exception_type="custom")
        @exception_type = exception_type
        super(msg)
    end
end


