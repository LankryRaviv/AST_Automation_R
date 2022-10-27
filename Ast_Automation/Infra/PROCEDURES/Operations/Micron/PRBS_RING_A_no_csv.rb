load_utility('Operations/Micron/TrajectoryControlFunctions.rb')

require_relative 'MICRON_PRBS no csv'

include MICRON_PRBS

xp_master = true # XP is master - true, XM is master - false


testResult = "FAIL"

# Run with GUI
ring = ARGV[ARGV.length()-1].strip
out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
#Read arguments
for data in ARGV
   out_file.write(data + " ")
end
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
#builded_string = "\nRUN_ID: " + RUN_ID + " TEST_START"
out_file.puts(builded_string)
out_file.close
cpbf_master = ARGV[ARGV.length()-7].strip()
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip
puts("CPBF #{cpbf_master[-2..-1]} is set to master") 
RUN_ID = ARGV[1]


# Run with Script Runner
#RUN_ID = "21111111111111110"
#ring = "A"
#out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
#out_file.write("\n")
#out_file.write("\n")
#builded_string = "\nRUN_ID: " + RUN_ID + " TEST_START"
#out_file.puts(builded_string)
#out_file.close
#cpbf_master = "XP"
#puts("CPBF #{} is set to master" 



$result_collector = []
prbs_test = true

# power ring A to reduced
#power_on, ring_list = power_on_ring_to_reduced(ring, apc, ARGV[1]) # Run with GUI
power_on = true
#power_on, ring_list = power_on_ring_to_reduced(ring, RUN_ID) # Run with script runner
#if(power_on)	 
if cpbf_master[-2..-1] == "XP"				   													  

  cpbf_master = ARGV[ARGV.length()-7].strip
  apc = ARGV[ARGV.length()-5].strip
  ring = ARGV[ARGV.length()-1].strip
  #puts "CPBF #{} is set to master" 

  $result_collector = []
  prbs_test = true
  pcdu = TurnOnOffCPBF.new
  # pcdu.set_BFCP_XM("APC_YM", 1,true)
  # power ring A to reduced
  power_on, ring_list = power_on_ring_to_reduced(ring,apc, ARGV[1])
  #power_on, ring_list = power_on_ring_to_reduced(ring, RUN_ID)
  #if(power_on)


  power_on = true
  # Test PRBS on ring A with error force -hard codded:
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=77, link=5, micron_pcs=2, pcs_status = 0x0300, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=78, link=3, micron_pcs=2, pcs_status = 0x0300, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=93, link=8, micron_pcs=0, pcs_status = 0x2003, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=107, link=2, micron_pcs=0, pcs_status = 0x0003, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=120, link=4, micron_pcs=3, pcs_status = 0x3000, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=119, link=6, micron_pcs=3, pcs_status = 0x3000, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=104, link=1, micron_pcs=1, pcs_status = 0x0030, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=90, link=7, micron_pcs=1, pcs_status = 0x0030, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=76, chk_micron_id=90, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=RUN_ID)
  prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=79, chk_micron_id=93, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3002, run_id_str=RUN_ID)
  prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=118, chk_micron_id=104, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=RUN_ID)
  prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=121, chk_micron_id=107, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=RUN_ID)

else
  # Test PRBS on ring A with error force -hard codded:
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=77, link=1, micron_pcs=2, pcs_status = 0x0300, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=78, link=7, micron_pcs=2, pcs_status = 0x0300, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=93, link=4, micron_pcs=0, pcs_status = 0x2003, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=107, link=6, micron_pcs=0, pcs_status = 0x0003, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=120, link=8, micron_pcs=3, pcs_status = 0x3000, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=119, link=2, micron_pcs=3, pcs_status = 0x3000, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=104, link=5, micron_pcs=1, pcs_status = 0x0030, run_id_str=RUN_ID, cpbf_master=cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_cpbf_single_link_err_force(micron_id=90, link=3, micron_pcs=1, pcs_status = 0x0030, run_id_str=RUN_ID, cpbf = cpbf_master[-2..-1])
  prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=76, chk_micron_id=90, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3020, run_id_str=RUN_ID)
  prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=79, chk_micron_id=93, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0300, chk_pcs_status=0x3002, run_id_str=RUN_ID)
  prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=118, chk_micron_id=104, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0320, run_id_str=RUN_ID)
  prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=121, chk_micron_id=107, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3000, chk_pcs_status=0x0302, run_id_str=RUN_ID)

end
#end
power_off = power_off_ring(ring, apc, ARGV[1]) #Run with GUI
#power_off = power_off_ring(ring, RUN_ID) #Run with script runner

if(power_on && prbs_test && power_off)
    testResult = "PASS"
end


puts("---------------------------------------TEST PRBS RING A SUMMARY--------------------------------------")
for x in $result_collector do
    puts x
end


num_of_res_lines = 0
fail_flag = false
for x in $result_collector do
	if x.include? "Connection" and x.include? "BER"
		num_of_res_lines = num_of_res_lines + 1 
	end
	if x.include? "FAIL" or x.include? "Fail"
		fail_flag = true
	end
end
if num_of_res_lines = 48 and fail_flag == false
	puts("Ring A Final Status = Pass")
else 
	puts("Ring A Final Status = Fail")
end



out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult) # Run with GUI
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
#out_file.puts("\nRUN_ID: " + RUN_ID + "TEST RESULT = " + testResult) # Run with script runner
#builded_string = "RUN_ID: " + RUN_ID + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!





