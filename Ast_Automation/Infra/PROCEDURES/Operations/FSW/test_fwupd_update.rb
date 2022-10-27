$LOAD_PATH << File.expand_path('../../',__dir__) #Operations folder
$LOAD_PATH << File.expand_path('../',__dir__) #Micron folder
$LOAD_PATH << File.expand_path('./',__dir__) #FSW folder
load('Operations/FSW/FSW_FWUPD.rb')
load('Operations/FSW/FSW_CSP.rb')
load('Tools\module_file_tools.rb')
load('Operations\Tools\module_clogger.rb')
include FileTools
include CLogger



  def test_image_upgrade(board, image, location, file_id)
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

    board.each do |b|

      fwupd_validate_hash_converted, fwupd_validate_hash_raw  = fwupd.validate_signature(b, image_code, true, true)
      validity_code = fwupd_validate_hash_raw["FWUPD_ERROR_CODE"]

      if validity_code == SUCCESS
        puts "Image is valid. Proceeding with firmware update."
        log_message( "Image is valid. Proceeding with firmware update.")
        wait(2)
      else
        log_message( "Image contains an invalid signature.")
        puts( "Image contains an invalid signature.")
        log_message( "Validity Code #{validity_code}")
        value = message_box("Validation of image failed; Continue? ", 'Yes', 'No')
        case value
        when 'Yes'
          puts 'Continuing'
        when 'No'
          abort
        end
      end

      cmd_fs = ModuleFS.new
      log_message( 'Clearing file and wait 20s')
      puts( 'Clearing file and wait 20s')
      cmd_fs.file_clear(b, file_id, false, false, 20)

      fwupd.firmware_upload(b, location, file_id,1754)

      file_size = fwupd.firmware_size(location)
      fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(b,true, true)
      mcu_uid_0 = fwupd_version_hash_raw["MCU_UID_0"]
      mcu_uid_1 = fwupd_version_hash_raw["MCU_UID_1"]
      mcu_uid_2 = fwupd_version_hash_raw["MCU_UID_2"]

      fwupd_start_hash_converted, fwupd_start_hash_raw = fwupd.firmware_start(b, image_code, file_size, mcu_uid_0, mcu_uid_1, mcu_uid_2,0,true, true, 3, true)
      fwupd_start_code = fwupd_start_hash_raw['FWUPD_ERROR_CODE']

      # checking to see if the correctly start

      if fwupd_start_code == SUCCESS
        log_message( "Firmware update started. Proceeding with firmware update.")
        puts( "Firmware update started. Proceeding with firmware update.")
      else
        log_message( "Firmware update failed to start.")
        puts( "Firmware update failed to start.")
        abort
      end

      wait(2)

      ### STEP 4 ###

      # Installing the firmware
      fwupd_install_hash_converted, fwupd_install_hash_raw = fwupd.firmware_install(b, image_code, true, true, 5,  true)
      fwupd_install_code = fwupd_install_hash_raw['FWUPD_ERROR_CODE']

      # checking to see if the correctly start

      if fwupd_install_code == SUCCESS
        log_message( "Firmware update installed. Firmware update complete.")
        puts "Firmware update installed. Firmware update complete."

      elsif fwupd_install_code == RESTART
          puts "Firmware update installed. Proceeding with restart."
          log_message( "Firmware update installed. Proceeding with restart.")
      else
          puts "Firmware update failed to start."
          log_message( "Firmware update failed to start.")
          abort
      end

      ### STEP 5 ###
      # Rebooting the board and check version number
      csp = ModuleCSP.new
      csp.reboot(b, true)

      # Waiting 25 seconds, since it takes the board ~5 seconds to boot
      wait(25)
      fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(b,true, true, 5)
      puts "Firmware upgrade complete: BL1 Version Info:

      Major: #{fwupd_version_hash_raw["BOOT_L1_MAJOR"]},
      Minor #{fwupd_version_hash_raw["BOOT_L1_MINOR"]},
      Patch #{fwupd_version_hash_raw["BOOT_L1_PATCH"]},

      BL2 Version Info:
      Major: #{fwupd_version_hash_raw["BOOT_L2_MAJOR"]},
      Minor #{fwupd_version_hash_raw["BOOT_L2_MINOR"]},
      Patch #{fwupd_version_hash_raw["BOOT_L2_PATCH"]},

      APP Version Info:
      Major: #{fwupd_version_hash_raw["APP_MAJOR"]},
      Minor #{fwupd_version_hash_raw["APP_MINOR"]},
      Patch #{fwupd_version_hash_raw["APP_PATCH"]},"
      log_message( "Firmware upgrade complete: BL1 Version Info:

      Major: #{fwupd_version_hash_raw["BOOT_L1_MAJOR"]},
      Minor #{fwupd_version_hash_raw["BOOT_L1_MINOR"]},
      Patch #{fwupd_version_hash_raw["BOOT_L1_PATCH"]},

      BL2 Version Info:
      Major: #{fwupd_version_hash_raw["BOOT_L2_MAJOR"]},
      Minor #{fwupd_version_hash_raw["BOOT_L2_MINOR"]},
      Patch #{fwupd_version_hash_raw["BOOT_L2_PATCH"]},

      APP Version Info:
      Major: #{fwupd_version_hash_raw["APP_MAJOR"]},
      Minor #{fwupd_version_hash_raw["APP_MINOR"]},
      Patch #{fwupd_version_hash_raw["APP_PATCH"]},")
    end
   end
   target = "BW3"
   path_json = ARGV[0]
   board = ARGV[1]

   generalData = read_json_file(path_json)
   data= generalData.fetch(board)
  puts data.inspect
  sleep 10
   data.each {|dat|
     if dat.fetch("if_run")
        image = dat.fetch("type")
         location = dat.fetch("path")
         file_id = dat.fetch("file_id")
         boards = [board]
         test_image_upgrade(boards, image, location, file_id)
     end
   }

exit!
