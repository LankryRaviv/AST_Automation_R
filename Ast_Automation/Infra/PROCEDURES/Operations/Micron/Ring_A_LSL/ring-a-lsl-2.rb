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

# Microns order is important!!! for returning to default route
microns_array = [77,78,90,104,107,119,76,79,118,121,93,120]

micron = MICRON_MODULE.new
dpc = ModuleDPC.new

dpc.set_micron_uart('DPC_3', 'UART2', 'OFF') # Turn DPC off to Chain 3
dpc.set_micron_uart('DPC_4', 'UART2', 'OFF') # Turn DPC off to Chain 5

def ping_microns(micron, microns_array)
	microns_array.each do |micron_id|
	    ping_res = micron.ping_micron('MIC_LSL', micron_id, converted=false, raw=false, wait_check_timeout=0.3)
	    puts "*** PING ERR: #{micron_id}" unless ping_res
	end
end

ping_microns(micron, microns_array)
