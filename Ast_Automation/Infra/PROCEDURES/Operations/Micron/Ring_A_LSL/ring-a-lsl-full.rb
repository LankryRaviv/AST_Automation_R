#Reading: Rings
#Reading: Matrix
#Reading: Map
#Reading: Chains
#Reading: Default Routing Table
#WARN: 93   EWS !=  E S
#WARN: 120 NEWS != NEW 
#Reading: SecondaryRouting Table
#WARN: 93   EWS !=  E S
#WARN: 120 NEWS != NEW 
#WARNING: Reroute and validation is limited to Rings: A
#WARNING: High Speed Reroute Disabled
#INFO: DPC is YP

# Rev 12

load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/FSW/FSW_DPC.rb')

### Turn ON Microns ###

returnVal = power_on_ring_to_ps2('A')
puts "power_on_ring_to_ps2 #{returnVal}"

########## Code Start ##########

# Microns order is important!!! for returning to default route
microns_array = [77,78,90,104,107,119,76,79,118,121,93,120]

micron = MICRON_MODULE.new
dpc = ModuleDPC.new

dpc.set_micron_uart('DPC_3', 'UART2', 'OFF') # Turn DPC off to Chain 3
dpc.set_micron_uart('DPC_4', 'UART2', 'OFF') # Turn DPC off to Chain 5

def ping_microns(microns_array)
	microns_array.each do |micron_id|
	    ping_res = micron.ping_micron('MIC_LSL', micron_id, converted=true, raw=false, wait_check_timeout=0.3)
	    puts "*** PING ERR: #{micron_id}" unless ping_res
	end
end

ping_microns(microns_array)

# UART_CONTROL:  Chain 1 DPC: 5 UART: 4 Control false
dpc.set_micron_uart('DPC_5', 'UART4', 'OFF')
# SET_ROUTING:  MicronID 76  LSL 99  (01100011) HSL 130 (10000010) WFD 86  TTD 35  [LS-E] (Location 18)
micron.set_micron_routing('MIC_LSL', 0, 76, 99, 130, 86, 35)
# SET_ROUTING:  MicronID 77  LSL 40  (00101000) HSL 142 (10001110) WFD 91  TTD 37  [LS-B] (Location 19)
micron.set_micron_routing('MIC_LSL', 0, 77, 40, 142, 91, 37)
ping_microns(microns_array)
# UART_CONTROL:  Chain 2 DPC: 2 UART: 2 Control false
dpc.set_micron_uart('DPC_2', 'UART2', 'OFF')
# SET_ROUTING:  MicronID 77  LSL 42  (00101010) HSL 142 (10001110) WFD 91  TTD 37  [LS-E] (Location 19)
micron.set_micron_routing('MIC_LSL', 0, 77, 42, 142, 91, 37)
# SET_ROUTING:  MicronID 78  LSL 42  (00101010) HSL 142 (10001110) WFD 91  TTD 37  [LS-B] (Location 19)
micron.set_micron_routing('MIC_LSL', 0, 78, 42, 142, 91, 37)
ping_microns(microns_array)
# UART_CONTROL:  Chain 6 DPC: 4 UART: 4 Control false
dpc.set_micron_uart('DPC_4', 'UART4', 'OFF')
# SET_ROUTING:  MicronID 120 LSL 69  (01000101) HSL 139 (10001011) WFD 91  TTD 37  [LS-E] (Location 19)
micron.set_micron_routing('MIC_LSL', 0, 120, 69, 139, 91, 37)
# SET_ROUTING:  MicronID 119 LSL 68  (01000100) HSL 139 (10001011) WFD 91  TTD 37  [LS-B] (Location 19)
micron.set_micron_routing('MIC_LSL', 0, 119, 68, 139, 91, 37)
ping_microns(microns_array)
# SET_ROUTING:  MicronID 104 LSL 65  (01000001) HSL 65  (01000001) WFD 91  TTD 37  [LS-D] (Location 19)
micron.set_micron_routing('MIC_LSL', 0, 104, 65, 65, 91, 37)
# 118 Will return error
ping_microns(microns_array)
# SET_ROUTING:  MicronID 119 LSL 69  (01000101) HSL 139 (10001011) WFD 91  TTD 37  [LS-E] (Location 19)
micron.set_micron_routing('MIC_LSL', 0, 119, 69, 139, 91, 37)
# SET_ROUTING:  MicronID 118 LSL 65  (01000001) HSL 131 (10000011) WFD 86  TTD 35  [LS-B] (Location 18)
micron.set_micron_routing('MIC_LSL', 0, 118, 65, 131, 86, 35)
ping_microns(microns_array)
# UART_CONTROL:  Chain 7 DPC: 2 UART: 4 Control false
dpc.set_micron_uart('DPC_2', 'UART4', 'OFF')
# SET_ROUTING:  MicronID 118 LSL 73  (01001001) HSL 131 (10000011) WFD 86  TTD 35  [LS-E] (Location 18)
micron.set_micron_routing('MIC_LSL', 0, 118, 73, 131, 86, 35)
# SET_ROUTING:  MicronID 104 LSL 97  (01100001) HSL 65  (01000001) WFD 91  TTD 37  [LS-B] (Location 19)
micron.set_micron_routing('MIC_LSL', 0, 104, 97, 65, 91, 37)
ping_microns(microns_array)
########## Code End ##########

### RETURN TO DEFAULT Start ###

# Because we are turning on all DPC UARTs again - we don't care about the actual micron order, just the ring order
dpc.set_micron_uart('DPC_5', 'UART4', 'ON')
dpc.set_micron_uart('DPC_2', 'UART2', 'ON')
dpc.set_micron_uart('DPC_4', 'UART4', 'ON')
dpc.set_micron_uart('DPC_2', 'UART4', 'ON')

microns_array.each do |micron_id|
	result = micron.set_micron_default_routing('MIC_LSL', micron_id, converted=true, raw=false, wait_check_timeout=0.3)
    if result
		puts "*** SET ROUTE OK : #{micron_id} ***"
    else
    	puts "*** SET ROUTE ERR: #{micron_id} ***"
    end
    
    result = micron.get_micron_routing('MIC_LSL', micron_id)
    puts "#{micron_id} #{result}"
end

ping_microns(microns_array)

### RETURN TO DEFAULT End ###

### Turn OFF Microns ###
returnVal = power_off_ring('A')
puts "power_on_ring_to_ps2 #{returnVal}"
###