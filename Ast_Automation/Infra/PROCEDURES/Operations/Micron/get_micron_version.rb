require 'csv'

def get_micron_version()
    curr_dir = __dir__
    version_hash = Hash.new
    table = CSV.parse(File.read(curr_dir + ".\\micron_version_config.csv"), headers: false)
    table.each do |entry|
        version_hash[entry[0]] = entry[1..4]
    end
    # convert version info to hash
    pre_sw_app = version_hash['pre_sw_app']
    version_hash['pre_sw_app'] = {APP_MAJOR: pre_sw_app[0].to_i, APP_MINOR: pre_sw_app[1].to_i, APP_PATCH: pre_sw_app[2].to_i}
    pre_sw_bl1 = version_hash['pre_sw_bl1']
    version_hash['pre_sw_bl1'] = {BOOT_L1_MAJOR: pre_sw_bl1[0].to_i, BOOT_L1_MINOR: pre_sw_bl1[1].to_i, BOOT_L1_PATCH: pre_sw_bl1[2].to_i}
    pre_sw_bl2 = version_hash['pre_sw_bl2']
    version_hash['pre_sw_bl2'] = {BOOT_L2_MAJOR: pre_sw_bl2[0].to_i, BOOT_L2_MINOR: pre_sw_bl2[1].to_i, BOOT_L2_PATCH: pre_sw_bl2[2].to_i}
    post_sw_app = version_hash['post_sw_app']
    version_hash['post_sw_app'] = {APP_MAJOR: post_sw_app[0].to_i, APP_MINOR: post_sw_app[1].to_i, APP_PATCH: post_sw_app[2].to_i}
    post_sw_bl1 = version_hash['post_sw_bl1']
    version_hash['post_sw_bl1'] = {BOOT_L1_MAJOR: post_sw_bl1[0].to_i, BOOT_L1_MINOR: post_sw_bl1[1].to_i, BOOT_L1_PATCH: post_sw_bl1[2].to_i}
    post_sw_bl2 = version_hash['post_sw_bl2']
    version_hash['post_sw_bl2'] = {BOOT_L2_MAJOR: post_sw_bl2[0].to_i, BOOT_L2_MINOR: post_sw_bl2[1].to_i, BOOT_L2_PATCH: post_sw_bl2[2].to_i}
    version_hash['fw_version'] = version_hash['fw_version'][0]
    version_hash['pre_fpga'] = version_hash['pre_fpga']
    version_hash['post_fpga'] = version_hash['post_fpga']
    version_hash['post_fpga'] = version_hash['post_fpga'][0]
    version_hash['fpga_file'] = version_hash['fpga_file'][0]
    version_hash['dsa_val'] = version_hash['dsa_val'][0]
    version_hash['down_link_freq'] = version_hash['down_link_freq'][0]
    version_hash['up_link_freq'] = version_hash['up_link_freq'][0]
    version_hash['gps_limit_x'] = version_hash['gps_limit_x'][0]
    version_hash['gps_limit_y'] = version_hash['gps_limit_y'][0]
    version_hash['gps_limit_z'] = version_hash['gps_limit_z'][0]
    version_hash['golden_image_version'] = version_hash['golden_image_version'][0]
    version_hash['main_image_corrupted'] = version_hash['main_image_corrupted'][0]
    main_image_corrupted = version_hash['main_image_corrupted_info']
    version_hash['with_pcdu'] = version_hash['with_pcdu'][0]
    version_hash['main_image_corrupted_info'] = {APP_MAJOR: main_image_corrupted[0].to_i, APP_MINOR: main_image_corrupted[1].to_i, APP_PATCH: main_image_corrupted[2].to_i}
    return version_hash
end