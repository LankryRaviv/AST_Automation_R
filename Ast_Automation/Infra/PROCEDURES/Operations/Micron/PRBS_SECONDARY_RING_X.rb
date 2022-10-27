#load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/routing_operations_delegate_cosmos_lsl.rb')
load('Operations/MICRON/Routing/routing.rb')


require_relative 'MICRON_PRBS no csv'

include MICRON_PRBS



$result_collector = []

def prbs_secondary_ring_a(ring, run_id, apc, cpbf_master)

	prbs_test = true
	# Run with GUI
	


	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 
	
	# Reroute Ring A
	options = RoutingOptions.hsl_reroute_ym
	options[:rings_filter] = ['A']
	options[:rings_chain_length] = true # Calculate maximum chain length according to ring
	delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
    routing = Routing.new(options, delegate)
    routing.reroute


	
	if cpbf_master[-2..-1] == "XP"				   													  
		# Test PRBS on ring A with error force -hard codded:
		prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=93, link=8, micron_pcs=0, pcs_status=0x2003, run_id_str=run_id)
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=79, chk_micron_id=93, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3003, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=78, chk_micron_id=79, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0303, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=77, chk_micron_id=78, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0033, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=76, chk_micron_id=77, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0033, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=90, chk_micron_id=76, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0330, run_id_str=run_id)
		prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=104, link=1, micron_pcs=1, pcs_status=0x0230, run_id_str=run_id)
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=118, chk_micron_id=104, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x0330, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=119, chk_micron_id=118, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x3030, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=120, chk_micron_id=119, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0033, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=121, chk_micron_id=120, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x0033, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=107, chk_micron_id=121, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3003, run_id_str=run_id, cpbf = cpbf_master[-2..-1])

		
	else
		# Test PRBS on ring A with error force -hard codded:
		prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=93, link=4, micron_pcs=0, pcs_status=0x2003, run_id_str=run_id)
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=79, chk_micron_id=93, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3003, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=78, chk_micron_id=79, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0303, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=77, chk_micron_id=78, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0033, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=76, chk_micron_id=77, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0033, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		tprbs_test = prbs_test & est_prbs_micron_single_line_err_force(gen_micron_id=90, chk_micron_id=76, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0330, run_id_str=run_id)
		prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=104, link=5, micron_pcs=1, pcs_status=0x0230, run_id_str=run_id)
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=118, chk_micron_id=104, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x0330, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=119, chk_micron_id=118, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x3030, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=120, chk_micron_id=119, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0033, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=121, chk_micron_id=120, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x0033, run_id_str=run_id, cpbf = cpbf_master[-2..-1])
		prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=107, chk_micron_id=121, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3003, run_id_str=run_id, cpbf = cpbf_master[-2..-1])

	end
	
	
	# Return back to main routing
	routing.reroute_default
	
	puts("---------------------------------------TEST PRBS RING A SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end



def prbs_secondary_ring_b(ring, run_id, apc, cpbf_master)

	prbs_test = true


	# Run with GUI
	


	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 
	
	# Reroute Ring B
	options = RoutingOptions.hsl_reroute_ym
	options[:rings_filter] = ['A', 'B']
	options[:rings_chain_length] = true # Calculate maximum chain length according to ring
	delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
    routing = Routing.new(options, delegate)
    routing.reroute

	
	# Test PRBS on ring B -hard codded with error force:
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=75, chk_micron_id=76, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=89, chk_micron_id=75, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0330, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=63, chk_micron_id=77, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=64, chk_micron_id=63, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0330, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=80, chk_micron_id=79, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=94, chk_micron_id=80, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0303, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=122, chk_micron_id=121, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=108, chk_micron_id=122, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3003, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=134, chk_micron_id=120, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x0322, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=133, chk_micron_id=134, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x3003, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=117, chk_micron_id=118, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=103, chk_micron_id=117, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3030, run_id_str=run_id)


	# Return back to main routing
	routing.reroute_default

	puts("---------------------------------------TEST PRBS RING B SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end



def prbs_secondary_ring_c(ring, run_id, apc, cpbf_master)

	prbs_test = true


	
	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 
	
	
	# Reroute Ring C
	options = RoutingOptions.hsl_reroute_ym
	options[:rings_filter] = ['A', 'B', 'C']
	options[:rings_chain_length] = true # Calculate maximum chain length according to ring
	delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
    routing = Routing.new(options, delegate)
    routing.reroute

	
	# # Test PRBS on ring C -hard codded with error force:
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=116, chk_micron_id=117, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=102, chk_micron_id=116, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=147, chk_micron_id=133, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3022, chk_pcs_status=0x0320, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=146, chk_micron_id=147, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=132, chk_micron_id=146, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3020, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=131, chk_micron_id=132, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0232, chk_pcs_status=0x0203, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=130, chk_micron_id=131, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=144, chk_micron_id=130, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=145, chk_micron_id=131, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=148, chk_micron_id=147, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=149, chk_micron_id=148, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=135, chk_micron_id=149, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3002, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=136, chk_micron_id=135, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0230, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=150, chk_micron_id=136, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=137, chk_micron_id=136, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=151, chk_micron_id=137, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=123, chk_micron_id=122, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=109, chk_micron_id=123, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3002, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=81, chk_micron_id=80, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=95, chk_micron_id=81, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=50, chk_micron_id=64, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0322, chk_pcs_status=0x3002, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=51, chk_micron_id=50, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=65, chk_micron_id=51, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x0302, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=66, chk_micron_id=65, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2023, chk_pcs_status=0x2030, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=67, chk_micron_id=66, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=53, chk_micron_id=67, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3002, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=52, chk_micron_id=66, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=49, chk_micron_id=50, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=48, chk_micron_id=49, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=62, chk_micron_id=48, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x0320, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=61, chk_micron_id=62, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2003, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=47, chk_micron_id=61, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=60, chk_micron_id=61, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=46, chk_micron_id=60, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=74, chk_micron_id=75, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=88, chk_micron_id=74, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=run_id)

	# Return back to main routing
	routing.reroute_default

	puts("---------------------------------------TEST PRBS RING C SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end


def prbs_secondary_ring_d(ring, run_id, apc, cpbf_master)

	prbs_test = true


	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 

	# Reroute Ring D
	options = RoutingOptions.hsl_reroute_ym
	options[:rings_filter] = ['A', 'B', 'C', 'D']
	options[:rings_chain_length] = true # Calculate maximum chain length according to ring
	delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
    routing = Routing.new(options, delegate)
    routing.reroute

   # # Test PRBS on ring D -hard codded with error force:
    prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=115, chk_micron_id=116, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=101, chk_micron_id=115, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=129, chk_micron_id=130, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=143, chk_micron_id=129, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=138, chk_micron_id=137, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=152, chk_micron_id=138, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=124, chk_micron_id=123, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2030, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=110, chk_micron_id=124, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3002, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=82, chk_micron_id=81, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=96, chk_micron_id=82, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=68, chk_micron_id=67, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=54, chk_micron_id=68, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3002, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=59, chk_micron_id=60, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=45, chk_micron_id=59, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=73, chk_micron_id=74, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=87, chk_micron_id=73, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=run_id)

	
	# Return back to main routing
	routing.reroute_default
	
	puts("---------------------------------------TEST PRBS RING D SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end

def prbs_secondary_ring_e(ring, run_id, apc, cpbf_master)

	prbs_test = true



	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 
	
	# Reroute Ring E
	options = RoutingOptions.hsl_reroute_ym
	options[:rings_filter] = ['A', 'B', 'C', 'D', 'E']
	options[:rings_chain_length] = true # Calculate maximum chain length according to ring
	delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
    routing = Routing.new(options, delegate)
    routing.reroute

	
 # # Test PRBS on ring E -hard codded with error force:
    prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=167, chk_micron_id=166, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=166, chk_micron_id=165, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=179, chk_micron_id=165, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=165, chk_micron_id=164, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0322, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=178, chk_micron_id=164, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=164, chk_micron_id=163, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0232, run_id_str=run_id)
 	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=177, chk_micron_id=163, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=run_id)
 	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=163, chk_micron_id=162, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=162, chk_micron_id=161, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=176, chk_micron_id=161, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x2032, run_id_str=run_id)
 	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=175, chk_micron_id=161, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x0322, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=161, chk_micron_id=160, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0232, run_id_str=run_id)
 	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=174, chk_micron_id=160, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=160, chk_micron_id=159, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0232, run_id_str=run_id)
 	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=173, chk_micron_id=159, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=run_id)
 	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=159, chk_micron_id=158, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0232, run_id_str=run_id)
 	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=172, chk_micron_id=158, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0322, run_id_str=run_id)
 	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=158, chk_micron_id=157, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0223, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=157, chk_micron_id=156, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2030, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=156, chk_micron_id=142, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x2300, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=142, chk_micron_id=128, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3200, chk_pcs_status=0x0320, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=128, chk_micron_id=129, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=153, chk_micron_id=139, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=139, chk_micron_id=138, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0203, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=114, chk_micron_id=100, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x2300, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=100, chk_micron_id=86, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3200, chk_pcs_status=0x2300, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=86, chk_micron_id=72, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3200, chk_pcs_status=0x2320, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=72, chk_micron_id=73, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0230, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=83, chk_micron_id=97, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3200, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=97, chk_micron_id=111, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x2300, chk_pcs_status=0x3200, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=111, chk_micron_id=125, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x2300, chk_pcs_status=0x3002, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=125, chk_micron_id=124, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=30, chk_micron_id=31, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=31, chk_micron_id=32, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=18, chk_micron_id=32, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=32, chk_micron_id=33, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=19, chk_micron_id=33, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=33, chk_micron_id=34, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=20, chk_micron_id=34, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=34, chk_micron_id=35, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x0023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=35, chk_micron_id=36, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=21, chk_micron_id=22, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0230, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=22, chk_micron_id=36, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=36, chk_micron_id=37, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=23, chk_micron_id=37, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=37, chk_micron_id=38, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=24, chk_micron_id=38, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=38, chk_micron_id=39, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=25, chk_micron_id=39, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=39, chk_micron_id=40, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=40, chk_micron_id=41, gen_micron_pcs=1, chk_micron_pcs=1, gen_pcs_status=0x0032, chk_pcs_status=0x0203, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=41, chk_micron_id=55, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3200, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=55, chk_micron_id=69, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x2300, chk_pcs_status=0x3002, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=69, chk_micron_id=68, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x2003, chk_pcs_status=0x2032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=44, chk_micron_id=58, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line(gen_micron_id=58, chk_micron_id=59, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x2030, chk_pcs_status=0x2023, run_id_str=run_id)
	
	# Return back to main routing
	routing.reroute_default
	
	puts("---------------------------------------TEST PRBS RING E SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end

def prbs_secondary_ring_f(ring, run_id, apc, cpbf_master)

	prbs_test = true



	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 

	# Reroute Ring F
	options = RoutingOptions.hsl_reroute_ym
	#options[:rings_filter] = ['A', 'B', 'C', 'D', 'E']
	#options[:rings_chain_length] = true # Calculate maximum chain length according to ring
	delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
    routing = Routing.new(options, delegate)
    routing.reroute

	

   # # Test PRBS on ring F -hard codded with error force:
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=4, chk_micron_id=5, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=5, chk_micron_id=6, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=6, chk_micron_id=7, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0223, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=7, chk_micron_id=21, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0322, chk_pcs_status=0x3022, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=11, chk_micron_id=10, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=10, chk_micron_id=9, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=9, chk_micron_id=8, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=8, chk_micron_id=7, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0232, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=186, chk_micron_id=187, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=187, chk_micron_id=188, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=188, chk_micron_id=189, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=189, chk_micron_id=190, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2023, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=193, chk_micron_id=192, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=192, chk_micron_id=191, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=191, chk_micron_id=190, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2030, run_id_str=run_id)
	prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=190, chk_micron_id=176, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x2322, run_id_str=run_id)
	
	
	# Return back to main routing
	routing.reroute_default
	
	puts("---------------------------------------TEST PRBS RING F SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end



