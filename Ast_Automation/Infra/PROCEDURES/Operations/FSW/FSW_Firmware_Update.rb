load 'Operations/FSW/FSW_FWUPD.rb'
load 'Operations/FSW/FSW_CSP.rb'
set_line_delay(0)


  ## ERROR CODES
  SUCCESS = 0
  RESTART = 175
  
def firmware_update(board, image, image_loc, version_info, file_id = 155, no_hazardous_check = false, continue_upload = 0, from_golden = 0)

    # initializing the system for firmware upgrade
    fwupd = ModuleFWUPD.new
    if (image == "bl1")
        image_code = 0
    elsif (image == "bl2")
        image_code = 1
    elsif (image == "app")
        image_code = 2
    else
        wait
    end
    
    ### STEP 1 ###
    # Check signature validity for all three layers

    fwupd_validate_hash_converted_L1, fwupd_validate_hash_raw_L1  = fwupd.validate_signature(board, 0, true, true)
    fwupd_validate_hash_converted_L2, fwupd_validate_hash_raw_L2  = fwupd.validate_signature(board, 1, true, true)
    fwupd_validate_hash_converted_APP,fwupd_validate_hash_raw_APP = fwupd.validate_signature(board, 2, true, true)

    l1_validity_code  = fwupd_validate_hash_raw_L1["FWUPD_ERROR_CODE"]
    l2_validity_code  = fwupd_validate_hash_raw_L2["FWUPD_ERROR_CODE"]
    app_validity_code = fwupd_validate_hash_raw_APP["FWUPD_ERROR_CODE"]

    if l1_validity_code == SUCCESS && l2_validity_code == SUCCESS && app_validity_code == SUCCESS
       puts "All images valid. Proceeding with firmware updare."
       wait(2)
    else
       puts "One or more images contains an invalid signature."
       puts "L1 validity Code #{l1_validity_code}; L2 validity Code #{l2_validity_code}; App validity Code #{app_validity_code}"
       abort
    end

    #check if it's a testrunner test
    if continue_upload == "TEST"
       fwupd.firmware_upload(board, image_loc, file_id, 1754, "CRC", continue_upload)
    else
       ### STEP 2 ###
       # Uploading the image to the correct file_id
       if continue_upload == 0
           fwupd.firmware_upload(board, image_loc, file_id,1754)
       #continue upload
       else
           fwupd.firmware_continue_upload(board, image_loc, file_id)
       end
       wait(2)

    ### STEP 3 ###
    # Starting the firmware upgrade procedure
       file_size = fwupd.firmware_size(image_loc)
       fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(board,true, true)
       mcu_uid_0 = fwupd_version_hash_raw["MCU_UID_0"]
       mcu_uid_1 = fwupd_version_hash_raw["MCU_UID_1"]
       mcu_uid_2 = fwupd_version_hash_raw["MCU_UID_2"]
      
       fwupd_start_hash_converted, fwupd_start_hash_raw = fwupd.firmware_start(board, image_code, file_size, mcu_uid_0, mcu_uid_1, mcu_uid_2,from_golden,true, true, 5, no_hazardous_check)
       fwupd_start_code = fwupd_start_hash_raw['FWUPD_ERROR_CODE']

       # checking to see if the correctly start

       if fwupd_start_code == SUCCESS
         puts "Firmware update started. Proceeding with firmware update."
       else
         puts "Firmware update failed to start."
         abort
       end

       wait(2)
       ### STEP 4 ###

       # Installing the firmware 
       fwupd_install_hash_converted, fwupd_install_hash_raw = fwupd.firmware_install(board, image_code, true, true, 5, no_hazardous_check)
       fwupd_install_code = fwupd_install_hash_raw['FWUPD_ERROR_CODE']
    
       # checking to see if the correctly start
    
       if fwupd_install_code == SUCCESS
           puts "Firmware update installed. Firmware update complete."
        
       elsif fwupd_install_code == RESTART
           puts "Firmware update installed. Proceeding with restart."
       else
           puts "Firmware update failed to start."
           abort
       end

       ### STEP 5 ###
       # Rebooting the board and check version number 
        csp = ModuleCSP.new
        csp.reboot(board, true)
  
        # Waiting 25 seconds, since it takes the board ~5 seconds to boot
        wait(25)
        fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(board,true, true, 5)
  
        if image_code == 0
            if fwupd_version_hash_raw["BOOT_L1_MAJOR"] == version_info[:BOOT_L1_MAJOR] &&
                fwupd_version_hash_raw["BOOT_L1_MINOR"] == version_info[:BOOT_L1_MINOR] &&
                fwupd_version_hash_raw["BOOT_L1_PATCH"] == version_info[:BOOT_L1_PATCH]
                puts "Bootloader L1 Firmware succesfully upgraded"
            else
                puts "Bootloader L1 Firmware update failed. 
                Major: #{fwupd_version_hash_raw["BOOT_L1_MAJOR"]} -- Check: #{version_info[:BOOT_L1_MAJOR]}, 
                Minor #{fwupd_version_hash_raw["BOOT_L1_MINOR"]} -- Check: #{version_info[:BOOT_L1_MINOR]},
                Patch #{fwupd_version_hash_raw["BOOT_L1_PATCH"]} -- Check: #{version_info[:BOOT_L1_PATCH]}"
                abort
  
            end
        end
  
        if image_code == 1
            if fwupd_version_hash_raw["BOOT_L2_MAJOR"] == version_info[:BOOT_L2_MAJOR] &&
                fwupd_version_hash_raw["BOOT_L2_MINOR"] == version_info[:BOOT_L2_MINOR] &&
                fwupd_version_hash_raw["BOOT_L2_PATCH"] == version_info[:BOOT_L2_PATCH]
                puts "Bootloader L2 Firmware succesfully upgraded"
            else
                puts "Bootloader L2 Firmware update failed.
                Major: #{fwupd_version_hash_raw["BOOT_L2_MAJOR"]} -- Check: #{version_info[:BOOT_L2_MAJOR]}, 
                Minor #{fwupd_version_hash_raw["BOOT_L2_MINOR"]} -- Check: #{version_info[:BOOT_L2_MINOR]},
                Patch #{fwupd_version_hash_raw["BOOT_L2_PATCH"]} -- Check: #{version_info[:BOOT_L2_PATCH]}"
                abort
  
            end
        end
  
        if image_code == 2
            if fwupd_version_hash_raw["APP_MAJOR"] == version_info[:APP_MAJOR] &&
                fwupd_version_hash_raw["APP_MINOR"] == version_info[:APP_MINOR] &&
                fwupd_version_hash_raw["APP_PATCH"] == version_info[:APP_PATCH]
                puts "Application Firmware succesfully upgraded"
            else
               puts " Application Firmware update failed.
               Major: #{fwupd_version_hash_raw["APP_MAJOR"]} -- Check: #{version_info[:APP_MAJOR]}, 
               Minor #{fwupd_version_hash_raw["APP_MINOR"]} -- Check: #{version_info[:APP_MINOR]},
               Patch #{fwupd_version_hash_raw["APP_PATCH"]} -- Check: #{version_info[:APP_PATCH]}"
               abort
  
            end
        end
    end
end


