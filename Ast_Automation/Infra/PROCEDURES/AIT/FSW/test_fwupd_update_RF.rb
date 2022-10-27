load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_FWUPD.rb')
load('Operations/FSW/FSW_CSP.rb')


class RF_MANUAL_FIRMWARE_UPGRADE < ASTCOSMOSTestFSW
  def initialize(target = "BW3")
    super()
  end

  def setup
    @board = combo_box("Select board for image upload", "APC_YP", "APC_YM", "FC_YP", "FC_YM", "DPC_1", "DPC_2", "DPC_3", "DPC_4", "DPC_5")
    @image = combo_box("Select image layer to upgrade:", "app", "bl2","bl1")
    @location = open_file_dialog("/", "Select Image to Upload", "*.bin")
    @file_id = 4108

    if @board.include?("DPC")
      @stack = combo_box("Select side", "YP", "YM")
    end
  end

  def test_image_upgrade
    fwupd = ModuleFWUPD.new
    if (@image == "bl1")
        image_code = 0
    elsif (@image == "bl2")
        image_code = 1
    elsif (@image == "app")
        image_code = 2
    else
        wait
    end

    fwupd_validate_hash_converted, fwupd_validate_hash_raw  = fwupd.validate_signature(@board, image_code, true, true)
    validity_code = fwupd_validate_hash_raw["FWUPD_ERROR_CODE"]

    if validity_code == SUCCESS
      puts "Image is valid. Proceeding with firmware updare."
      wait(2)
   else
      puts "Image contains an invalid signature."
      puts "Validity Code #{validity_code}"
      value = message_box("Validation of image failed; Continue? ", 'Yes', 'No')
      case value
      when 'Yes'
        puts 'Continuing'
      when 'No'
        abort
      end
   end

   fwupd.firmware_upload_slim(@board, @location, @file_id,186)

   file_size = fwupd.firmware_size(@location)
    fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(@board,true, true)
    mcu_uid_0 = fwupd_version_hash_raw["MCU_UID_0"]
    mcu_uid_1 = fwupd_version_hash_raw["MCU_UID_1"]
    mcu_uid_2 = fwupd_version_hash_raw["MCU_UID_2"]

    fwupd_start_hash_converted, fwupd_start_hash_raw = fwupd.firmware_start(@board, image_code, file_size, mcu_uid_0, mcu_uid_1, mcu_uid_2,0,true, true, 3, true)
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
       fwupd_install_hash_converted, fwupd_install_hash_raw = fwupd.firmware_install(@board, image_code, true, true, 5,  true)
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
        csp.reboot(@board, true)

        # Waiting 25 seconds, since it takes the board ~5 seconds to boot
        wait(25)
        fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(@board,true, true, 5)
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
      end
    end

