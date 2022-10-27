
# #load_utility('Operations/Micron/PingByMicronID.rb')
# load_utility('Operations/Micron/ChangeToPS2MicronsInChain.rb')
# load_utility('Operations/Micron/Ping.rb')
# load_utility('Operations/Micron/RebootMicronsInChain.rb')
# # system 'python script.py', params1, params2
# #system 'C:\Python\python.exe C:\Cosmos\PROCEDURES\Operations\TestEquipment\CPBF_POWER_SHARING_ON.py'
# #Read argument
# #v1 = ARGV[0].to_i 
# while true
#     puts "AA"
# end
# #ping_by_micron_id(107,board="MIC_LSL")
# #puts "PS2 - #{change_to_ps2_microns_in_chain(v1,board="MIC_LSL")}"
# #puts "PING - #{ping_by_micron_id("MICRON_" + v1.to_s,board="MIC_LSL")}"
# #puts "REBOOT - #{reboot_microns_in_chain(v1,board="MIC_LSL")}"
# # system 'python script.py', params1, params2
# #system 'C:\Python\python.exe C:\Cosmos\PROCEDURES\Operations\TestEquipment\CPBF_POWER_SHARING_OFF.py'

# STDOUT.write 'Example To C# Printed Value\n\n'

def dec2bin(number, width)
    puts("start dec2bin method")
    number = number.to_i
    if(number == 0) then 0 end
        
    ret_bin = ""
    while(number != 0)
        ret_bin = String(number % 2) + ret_bin
        number = number / 2
    end
    ret_bin.rjust(width, "0")
end

#puts (data.is_a?(String))
#puts (data.is_a?(Integer))
data = 11
#data = data.to_i
data = Integer(data)
bin_data = data.to_s(2).rjust(16, "0")[-14..-1] 
puts bin_data
# puts dec2bin(data, 16)