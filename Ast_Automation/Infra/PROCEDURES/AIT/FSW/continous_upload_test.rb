load('Operations/FSW/FSW_FS_Download.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS_Continue_Upload.rb')

#FSW_FS_Upload(1754, 4108, "C:/Users/psaripalli/Documents/repos/apc/Cube/APP-Debug/apcApp.bin", "APC_YP", aspect="CRC", test_break=0)
FSW_FS_Upload_Slim(186, 4108, "C:/Users/psaripalli.AD/Documents/BW3/repos/ast-simulators/cosmos/PROCEDURES/AIT/FSW/image_bins/apcApp_Test.bin", "APC_YP", aspect="CRC", test_break="TEST")
FSW_FS_Continue_Upload_Slim(186, 4108, "C:/Users/psaripalli.AD/Documents/BW3/repos/ast-simulators/cosmos/PROCEDURES/AIT/FSW/image_bins/apcApp_Test.bin", "APC_YP", aspect="CRC", starting_entry=1)
#FileDownload.new(4108, "APC_YP","out","MAIN_IMAGE_DOWNLOAD", 1754, 50, 900 )
