load_utility('Operations/Micron/MICRON_Firmware_Update.rb')

version_info_bl1 = {BOOT_L1_MAJOR: 1 ,BOOT_L1_MINOR: 2, BOOT_L1_PATCH: 1}
version_info_app = {APP_MAJOR: 5 ,APP_MINOR: 8, APP_PATCH: 99}
path = 'C:/cosmos/ATE/FSW/5.8.99/fcApplication.bin'
pathBL = 'C:/COSMOS/ast-master/procedures/Operations/MICRON/fcBootloaderL1.bin'
micron_list = [78]

#firmware_update("MICRON", "bl1", pathBL, version_info, file_id =12, from_golden = 1, micron_id)

res = firmware_update("MIC_LSL", "app", path, version_info_app, file_id =12, from_golden = 0, micron_list,
                broadcast_all: false, reboot: true, use_automations: true)
                
puts(res)