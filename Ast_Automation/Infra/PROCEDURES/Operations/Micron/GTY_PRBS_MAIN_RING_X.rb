load_utility('Operations/MICRON/GTY_PRBS_MODULE.rb')

@gp = GTY_PRBS.new




$result_collector = []

def prbs_main_ring_a(ring, run_id, apc, cpbf_master)

	prbs_test = true
	
	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 


	# Test PRBS on ring A with error force
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 76, mic_id_b= 90, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 79, mic_id_b= 93, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=118, mic_id_b=104, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=121, mic_id_b=107, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)

	puts("---------------------------------------TEST PRBS RING A SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end



def prbs_main_ring_b(ring, run_id, apc, cpbf_master)

	prbs_test = true


	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 

	
	# Test PRBS on ring B with error force:
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 61, mic_id_b= 62, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 62, mic_id_b= 63, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 63, mic_id_b= 77, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 66, mic_id_b= 65, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 65, mic_id_b= 64, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 64, mic_id_b= 78, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 75, mic_id_b= 76, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 80, mic_id_b= 79, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 89, mic_id_b= 90, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)		
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 94, mic_id_b= 93, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=103, mic_id_b=104, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=108, mic_id_b=107, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=117, mic_id_b=118, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=122, mic_id_b=121, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=131, mic_id_b=132, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=132, mic_id_b=133, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=133, mic_id_b=119, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=136, mic_id_b=135, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=135, mic_id_b=134, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=134, mic_id_b=120, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	
	puts("---------------------------------------TEST PRBS RING B SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end



def prbs_main_ring_c(ring, run_id, apc, cpbf_master)

	prbs_test = true


	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 

	
	# # Test PRBS on ring C with error force:
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 46, mic_id_b= 47, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 47, mic_id_b= 48, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 48, mic_id_b= 49, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	    
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 49, mic_id_b= 63, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 53, mic_id_b= 52, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 52, mic_id_b= 51, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 51, mic_id_b= 50, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 50, mic_id_b= 64, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 60, mic_id_b= 61, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 67, mic_id_b= 66, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 74, mic_id_b= 75, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 81, mic_id_b= 80, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 88, mic_id_b= 89, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 95, mic_id_b= 94, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=102, mic_id_b=103, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=109, mic_id_b=108, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=116, mic_id_b=117, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=123, mic_id_b=122, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=130, mic_id_b=131, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=137, mic_id_b=136, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=144, mic_id_b=145, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=145, mic_id_b=146, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=146, mic_id_b=147, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=147, mic_id_b=133, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=151, mic_id_b=150, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=150, mic_id_b=149, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=149, mic_id_b=148, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=148, mic_id_b=134, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	
	puts("---------------------------------------TEST PRBS RING C SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end


def prbs_main_ring_d(ring, run_id, apc, cpbf_master)

	prbs_test = true

	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 

	

   # # Test PRBS on ring D with error force:
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 45, mic_id_b= 46, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 59, mic_id_b= 60, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 73, mic_id_b= 74, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 87, mic_id_b= 88, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=101, mic_id_b=102, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=115, mic_id_b=116, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=129, mic_id_b=130, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=143, mic_id_b=144, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 54, mic_id_b= 53, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 68, mic_id_b= 67, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 82, mic_id_b= 81, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 96, mic_id_b= 95, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=110, mic_id_b=109, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=123, mic_id_b=122, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=138, mic_id_b=137, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=152, mic_id_b=151, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	
	puts("---------------------------------------TEST PRBS RING D SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end

def prbs_main_ring_e(ring, run_id, apc, cpbf_master)

	prbs_test = true

	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 

	
 # # Test PRBS on ring E with error force:
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 18, mic_id_b= 19, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 19, mic_id_b= 20, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 20, mic_id_b= 21, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 21, mic_id_b= 35, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 35, mic_id_b= 34, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 34, mic_id_b= 33, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 33, mic_id_b= 32, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 32, mic_id_b= 31, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 31, mic_id_b= 30, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 30, mic_id_b= 44, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 44, mic_id_b= 45, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 58, mic_id_b= 59, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 72, mic_id_b= 73, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 86, mic_id_b= 87, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=100, mic_id_b=101, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=114, mic_id_b=115, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=128, mic_id_b=129, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=172, mic_id_b=173, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=173, mic_id_b=174, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=174, mic_id_b=175, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=175, mic_id_b=161, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=161, mic_id_b=160, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=160, mic_id_b=159, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=159, mic_id_b=158, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=158, mic_id_b=157, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=157, mic_id_b=156, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=156, mic_id_b=142, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=142, mic_id_b=143, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=179, mic_id_b=178, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=178, mic_id_b=177, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=177, mic_id_b=176, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=176, mic_id_b=162, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=162, mic_id_b=163, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=163, mic_id_b=164, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=164, mic_id_b=165, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=165, mic_id_b=166, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=166, mic_id_b=167, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=167, mic_id_b=153, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=153, mic_id_b=152, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=139, mic_id_b=138, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=125, mic_id_b=124, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=111, mic_id_b=110, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 97, mic_id_b= 96, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 83, mic_id_b= 82, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 69, mic_id_b= 68, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 25, mic_id_b= 24, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 24, mic_id_b= 23, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 23, mic_id_b= 22, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 22, mic_id_b= 36, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 36, mic_id_b= 37, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 37, mic_id_b= 38, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 38, mic_id_b= 39, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 39, mic_id_b= 40, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 40, mic_id_b= 41, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 41, mic_id_b= 55, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 55, mic_id_b= 54, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	
	puts("---------------------------------------TEST PRBS RING E SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end

def prbs_main_ring_f(ring, run_id, apc, cpbf_master)

	prbs_test = true


	puts("CPBF #{cpbf_master[-2..-1]} is set to master") 

	

   # # Test PRBS on ring F -hard codded with error force:
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=  4, mic_id_b=  5, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=  5, mic_id_b=  6, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=  6, mic_id_b=  7, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=  7, mic_id_b= 21, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 11, mic_id_b= 10, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a= 10, mic_id_b=  9, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=  9, mic_id_b=  8, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=  8, mic_id_b= 22, mic_pcs_a=2, mic_pcs_b=3, run_id=run_id, error_force=true)	
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=186, mic_id_b=187, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=187, mic_id_b=188, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=188, mic_id_b=189, mic_pcs_a=1, mic_pcs_b=0, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=189, mic_id_b=175, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=193, mic_id_b=192, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=192, mic_id_b=191, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=191, mic_id_b=190, mic_pcs_a=0, mic_pcs_b=1, run_id=run_id, error_force=true)
	prbs_test = prbs_test &	@gp.gty_prbs_test(mic_id_a=190, mic_id_b=176, mic_pcs_a=3, mic_pcs_b=2, run_id=run_id, error_force=true)

	puts("---------------------------------------TEST PRBS RING F SUMMARY--------------------------------------")
	for x in $result_collector do
		puts x
	end
	return prbs_test
end






