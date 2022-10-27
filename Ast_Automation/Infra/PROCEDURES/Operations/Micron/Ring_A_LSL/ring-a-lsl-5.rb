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

### Turn OFF Microns ###
returnVal = power_off_ring('A', 'APC_YP')
puts "power_on_ring_to_ps2 #{returnVal}"
###