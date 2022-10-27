load_utility('Operations/Micron/micron_golden_image.rb')

link = 'MIC_LSL'
image_type = 'app'
# not sure where the golden images will be located, need to update the location
image_loc = 'C:/cosmos/ATE/FSW/5.8.99/fcApplication.bin'
micron_list = [78]
# file id for golden image for CS boards is 4110.  Update this if needed for micron FSW
file_id = 14
# file id for golden image descriptor file for CS boards is 4109.  Update this if needed for micron FSW
file_descriptor_id = 13
# broadcast all doesn't work for this operation, but may be possible if all microns use same golden descriptor file
broadcast_all = false
reboot = true
use_automations = true

#golden_image_update(link, image_type, image_loc, micron_list, file_id=4110, file_descriptor_id=4109, broadcast_all: false, reboot: false, use_automations: false)

res = golden_image_update(link, image_type, image_loc, micron_list, file_id, file_descriptor_id,
                          broadcast_all: broadcast_all, reboot: reboot, use_automations: use_automations)
                
puts(res)