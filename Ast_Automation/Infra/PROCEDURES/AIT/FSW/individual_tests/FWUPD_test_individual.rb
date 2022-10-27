load('Operations/FSW/FSW_Firmware_Update.rb')

def update_app_layers(collector_list, file_id)
  collector_list.each do |board|
    application_name = board[:FILE_APPLICATION_TEST]
    version_app_test = {
      "APP_MAJOR": board[:APPLICATION_MAJOR_TEST],
      "APP_MINOR": board[:APPLICATION_MINOR_TEST],
      "APP_PATCH": board[:APPLICATION_PATCH_TEST]
    }
    image_directory =  __dir__ + '\\..\\' + "image_bins\\" + "#{application_name}"
    ##### Application firmware test #####
    firmware_update(board[:BOARD], "app", image_directory, version_app_test, file_id, true)

    version_app = {
      "APP_MAJOR": board[:APPLICATION_MAJOR],
      "APP_MINOR": board[:APPLICATION_MINOR],
      "APP_PATCH": board[:APPLICATION_PATCH]
    }

    # Reverting back to original image
    firmware_update(board[:BOARD], "app", board[:FILE_APPLICATION] , version_app, file_id, true)
  end
  status_bar("testing_application_layers")
end


def update_bl1_layers(collector_list, file_id)
  collector_list.each do |board|
    bl1_name = board[:FILE_BOOTLOADERL1_TEST]
    version_bl1_test = {
      "BOOT_L1_MAJOR": board[:BOOTLOADERL1_MAJOR_TEST],
      "BOOT_L1_MINOR": board[:BOOTLOADERL1_MINOR_TEST],
      "BOOT_L1_PATCH": board[:BOOTLOADERL1_PATCH_TEST]
    }
    image_directory =  __dir__ + '\\..\\'  + "image_bins\\" + "#{bl1_name}"

    ##### Application firmware test #####
    firmware_update(board[:BOARD], "bl1", image_directory, version_bl1_test, file_id, true)

    version_bl1 = {
      "BOOT_L1_MAJOR": board[:BOOTLOADERL1_MAJOR],
      "BOOT_L1_MINOR": board[:BOOTLOADERL1_MINOR],
      "BOOT_L1_PATCH": board[:BOOTLOADERL1_PATCH]
    }

    # Reverting back to original image
    firmware_update(board[:BOARD], "bl1", board[:FILE_BOOTLOADERL1] , version_bl1, file_id, true)
  end
  status_bar("testing_bl1_layers")
end


def update_bl2_layers(collector_list, file_id)
  collector_list.each do |board|
    bl2_name = board[:FILE_BOOTLOADERL2_TEST]
    version_bl2_test = {
      "BOOT_L2_MAJOR": board[:BOOTLOADERL2_MAJOR_TEST],
      "BOOT_L2_MINOR": board[:BOOTLOADERL2_MINOR_TEST],
      "BOOT_L2_PATCH": board[:BOOTLOADERL2_PATCH_TEST]
    }
    image_directory =  __dir__ + '\\..\\' + "image_bins\\" + "#{bl2_name}"

    ##### BootloaderL2 firmware test #####
    firmware_update(board[:BOARD], "bl2", image_directory, version_bl2_test, file_id, true)
    version_bl2 = {
      "BOOT_L2_MAJOR": board[:BOOTLOADERL2_MAJOR],
      "BOOT_L2_MINOR": board[:BOOTLOADERL2_MINOR],
      "BOOT_L2_PATCH": board[:BOOTLOADERL2_PATCH]
    }
    # Reverting back to original image
    firmware_update(board[:BOARD], "bl2", board[:FILE_BOOTLOADERL2] , version_bl2, file_id, true)
  end
  status_bar("testing_bl2_layers")
end

def checking_version_patch(collector_list, image, fwupd)
  collector_list.each do |board|
  
    if (image == "bl1")
        image_code = 0
    elsif (image == "bl2")
        image_code = 1
    elsif (image == "app")
        image_code = 2
    else
      puts "Wrong Image"
        wait
    end
  fwupd_validate_hash_converted, fwupd_validate_hash_raw  = fwupd.validate_signature(board[:BOARD], image_code, true, true)
  validity_code = fwupd_validate_hash_raw["FWUPD_ERROR_CODE"]

  if validity_code == SUCCESS
    puts "Image is valid. Proceeding with firmware updare."
  else
    puts "Image is invalid"
    wait
    end
  end
  status_bar("version checks")
end


