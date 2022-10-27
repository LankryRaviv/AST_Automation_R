load_utility('AIT/CPBF/test_CPBF_MICRON_FUPLOAD')

@cpbf = TestCPBFMicronFUpload.new

# Micron FPGA Firmware upload
# File ID:25
# entries_qty = (file_size in bytes / 1754)
# end_entry = entries_qty
# max_fu_duration = (entries_qty*period_ms)/1000
version_info = {
    MAJOR: 5,
    MINOR: 4,
    PATCH: 3
}
@cpbf.test_complete_firmware_upload(micron_list=[4], file_id=25, link="MIC_HSL", 
                                    entries_qty=13296,entry_size=1754,
                                    start_entry=1,end_entry=13296,period_ms=50,
                                    image_type="app",image_size=123456,
                                    version_info=version_info,max_fu_duration=30)

# Micron Software upload
# File ID:12
# entries_qty = (file_size in bytes / 1754)
# max_fu_duration = (entries_qty*period_ms)/1000
#@cpbf.test_complete_fpga_upload(micron_list=[4], file_id=12, link="MIC_HSL", entries_qty=13296,entry_size=1754,start_entry=1,end_entry=13296,period_ms=20,max_fu_duration=1000)
