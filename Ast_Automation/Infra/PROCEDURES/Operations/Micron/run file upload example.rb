load('Operations/MICRON/MICRON_FS_Upload.rb')

filename = open_file_dialog("/","Select the file to upload")
micron_id = ask("Enter the micron ID to upload file to")

MICRON_FS_Upload(1754, 25, filename, "MIC_LSL", micron_id)

#MICRON_FS_Upload(1754, 25, 'C:/COSMOS/ast-master/procedures/Operations/MICRON/fpga install files/BOOT_zipped_desc.bin', "MICRON", 50)
