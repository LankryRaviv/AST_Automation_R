load('Operations/FSW/FSW_FWUPD.rb')
load 'Operations/FSW/FSW_Telem.rb'  
fwupd = ModuleFWUPD.new
module_telem = ModuleTelem.new
csp_destination = "COSMOS_UMBILICAL"
stack = "YP"
boards = [
      {board: "APC_YP", pkt_name: "FSW_TLM_APC"},
      {board: "FC_YP", pkt_name: "FSW_TLM_FC"},
      {board: "DPC_1", pkt_name: "FSW_TLM_DPC"},
      {board: "DPC_2", pkt_name: "FSW_TLM_DPC"},
      {board: "DPC_3", pkt_name: "FSW_TLM_DPC"},
      {board: "DPC_4", pkt_name: "FSW_TLM_DPC"},
      {board: "DPC_5", pkt_name: "FSW_TLM_DPC"},
       ]
       
       
image = [0,1,2]
### VERSION NUMBER ####
boards.each do |cur_board|
  module_telem.set_realtime(cur_board[:board], cur_board[:pkt_name], csp_destination, 1) 
end

# Capture APC FSW Version
puts("\n\n\n\n\n\nAPC FSW Versions:")
puts("Boot L1 Major: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L1_MAJOR")}")
puts("Boot L1 Minor: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L1_MINOR")}")
puts("Boot L1 Patch: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L1_PATCH")}")
puts("Boot L2 Major: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L2_MAJOR")}")
puts("Boot L2 Minor: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L2_MINOR")}")
puts("Boot L2 Patch: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L2_PATCH")}")
puts("App Major: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC APP_MAJOR")}")
puts("App Minor: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC APP_MINOR")}")
puts("App Patch: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC APP_PATCH")}\n\n\n\n\n\n")

# Capture FC FSW Version
puts("\n\n\n\n\n\nFC FSW Versions:")
puts("Boot L1 Major: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L1_MAJOR")}")
puts("Boot L1 Minor: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L1_MINOR")}")
puts("Boot L1 Patch: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L1_PATCH")}")
puts("Boot L2 Major: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L2_MAJOR")}")
puts("Boot L2 Minor: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L2_MINOR")}")
puts("Boot L2 Patch: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L2_PATCH")}")
puts("App Major: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC APP_MAJOR")}")
puts("App Minor: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC APP_MINOR")}")
puts("App Patch: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC APP_PATCH")}\n\n\n\n\n\n")


# Capture DPC FSW Version
puts("\n\n\n\n\n\nDPC FSW Versions: DPC_1, \t DPC_2, \t DPC_3, \t DPC_4, \t DPC_5")
puts("Boot L1 Major: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L1_MAJOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L1_MAJOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L1_MAJOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L1_MAJOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L1_MAJOR")}")
puts("Boot L1 Minor: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L1_MINOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L1_MINOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L1_MINOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L1_MINOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L1_MINOR")}")
puts("Boot L1 Patch: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L1_PATCH")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L1_PATCH")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L1_PATCH")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L1_PATCH")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L1_PATCH")}")
puts("Boot L2 Major: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L2_MAJOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L2_MAJOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L2_MAJOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L2_MAJOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L2_MAJOR")}")
puts("Boot L2 Minor: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L2_MINOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L2_MINOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L2_MINOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L2_MINOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L2_MINOR")}")
puts("Boot L2 Patch: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L2_PATCH")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L2_PATCH")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L2_PATCH")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L2_PATCH")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L2_PATCH")}")
puts("App Major: #{tlm("BW3 DPC_1-FSW_TLM_DPC APP_MAJOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC APP_MAJOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC APP_MAJOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC APP_MAJOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC APP_MAJOR")}")
puts("App Minor: #{tlm("BW3 DPC_1-FSW_TLM_DPC APP_MINOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC APP_MINOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC APP_MINOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC APP_MINOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC APP_MINOR")}")
puts("App Patch: #{tlm("BW3 DPC_1-FSW_TLM_DPC APP_PATCH")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC APP_PATCH")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC APP_PATCH")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC APP_PATCH")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC APP_PATCH")}\n\n\n\n\n\n")


boards.each {|cur_board|
module_telem.set_realtime(cur_board[:board], cur_board[:pkt_name], csp_destination, 0) 
}

boards.each {|cur_board|


### IMAGE VALIDITY CHECK ####

  image.each {|image_code|
 
    fwupd_validate_hash_converted, fwupd_validate_hash_raw  = fwupd.validate_signature(cur_board[:board], image_code, true, true)
    validity_code = fwupd_validate_hash_raw["FWUPD_ERROR_CODE"]
    
  if validity_code == SUCCESS
      puts "\n\n\n\n\n\n #{cur_board[:board]} - #{image_code} is valid\n\n\n\n\n\n"
   else
      puts "\n\n\n\n\n\n\ #{cur_board[:board]} - #{image_code} Image contains an invalid signature."
      puts "Validity Code #{validity_code}\n\n\n\n\n\n"       
   end


  }

}


