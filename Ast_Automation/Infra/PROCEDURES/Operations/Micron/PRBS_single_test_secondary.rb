
load('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load_utility('Operations/Micron/ChangeMode.rb')
require_relative 'MICRON_PRBS no csv'

#load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/micron_rapid_power.rb')
#load('Operations/MICRON/Routing/routing_operations_delegate_cosmos_lsl.rb')
#load('Operations/MICRON/Routing/routing.rb')
options = RoutingOptions.hsl_reroute_ym
options[:rings_filter] = ['A', 'B', 'C', 'D', 'E']
options[:rings_chain_length] = true # Calculate maximum chain length according to ring


include MICRON_PRBS
testResult = "FAIL"
$result_collector = []
prbs_test = true



# Run with Script Runner
RUN_ID = "21111111111111110"
ring = "C"
out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
out_file.write("\n")
builded_string = "\nRUN_ID: " + RUN_ID + " TEST_START"
out_file.puts(builded_string)
out_file.close
cpbf_master = "XP"
apc = "APC_YP"
puts("CPBF #{cpbf_master} is set to master")

#power_to_ps2 = set_target_ps2_traj_ps2(121, apc ,RUN_ID,true, true,true) # Power on to PS2
#power_to_ps2 = set_target_ps2_traj_ps2(118, apc ,RUN_ID,true, true,true)
#power_to_ps2 = set_target_ps2_traj_ps2(90, apc ,RUN_ID,true, true,true)
#power_to_ps2 = set_target_ps2_traj_ps2(93, apc ,RUN_ID,true, true,true)



micron =  MICRON_MODULE.new

# Reroute to secondary
#delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
#routing = Routing.new(options, delegate)
#routing.reroute

# Manualy move to REDUCED
#change_mode(107,"REDUCED")
#change_mode(121,"REDUCED")



    # # Test PRBS on ring C -hard codded with error force:

    test_prbs_micron_cpbf_single_link_err_force(micron_id=104, link=1, micron_pcs=1, pcs_status = 0x0030, run_id_str=RUN_ID, cpbf ="XP")
    test_prbs_micron_single_line_err_force(gen_micron_id=118, chk_micron_id=104, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=RUN_ID)
change_mode(118,"PS2")
change_mode(104,"PS2")


#routing.reroute_default # Reroute back to default







#power_off_power_supply(121, apc) # Power off
#reboot_microns_in_chain(121,true,"MIC_LSL",RUN_ID,1,true)  # Power off

puts("-------------------------------------------------------------------------------------------------")
for x in $result_collector do
    puts x
end

#out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")


#out_file.puts("\nRUN_ID: " + RUN_ID + "TEST RESULT = " + testResult) #Run with script runner
#builded_string = "RUN_ID: " + RUN_ID + " TEST_END" # Run with script runner

#out_file.puts(builded_string)
#out_file.close
