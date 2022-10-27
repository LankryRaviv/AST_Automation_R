load_utility('AIT/CPBF/test_CPBF_MICRON_FUPLOAD.rb')

cpbf_test = TestCPBFMicronFUpload.new

# to hardcode list of microns, comment out next line, and uncomment the lines after
#cpbf_test.setup

micron_list = [4,5,6]
fpga_image = 'C:/cosmos/ATE/FPGA_VERSION/00.0009.00/fpga_900_1.img'
entry_size = 1754
file_type = 'FPGA'
period_between_fupload_pkts = 100 # in ms
max_fupload_duration = 1200 # in seconds
cpbf_test.set_fupload_params(micron_list, fpga_image, entry_size, file_type)
cpbf_test.set_micron_list(micron_list)
cpbf_test.set_entries(fpga_image, entry_size)
cpbf_test.set_file_type('FPGA')

# step 1 - perform file format via broadcast
cpbf_test.test_file_format_lsl()

# step 2 - perform file upload
