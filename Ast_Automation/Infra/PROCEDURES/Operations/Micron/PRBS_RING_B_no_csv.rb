load_utility('Operations/Micron/TrajectoryControlFunctions.rb')

require_relative 'MICRON_PRBS no csv'

include MICRON_PRBS


cpbf_master = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip

testResult = "FAIL"

out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
#Read arguments
for data in ARGV
    out_file.write(data + " ")
end
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
out_file.puts(builded_string)
out_file.close

$result_collector = []
prbs_test = true
# power ring A to reduced
#power_on, ring_list = power_on_ring_to_reduced(ring,apc, ARGV[1])
#if(power_on)



    # Test PRBS on ring B -hard codded with error force:
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=61, chk_micron_id=62, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=62, chk_micron_id=63, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0303, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=63, chk_micron_id=77, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3300, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=66, chk_micron_id=65, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=65, chk_micron_id=64, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0230, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=64, chk_micron_id=78, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3200, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=75, chk_micron_id=76, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0003, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=80, chk_micron_id=77, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0030, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=89, chk_micron_id=90, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0003, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=94, chk_micron_id=93, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0030, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=103, chk_micron_id=104, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0003, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=108, chk_micron_id=107, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0030, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=117, chk_micron_id=118, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0003, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=122, chk_micron_id=121, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0030, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=131, chk_micron_id=132, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=132, chk_micron_id=133, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0303, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=133, chk_micron_id=119, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x3300, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=136, chk_micron_id=135, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=135, chk_micron_id=134, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0330, run_id_str=RUN_ID)
    prbs_test = prbs_test & test_prbs_micron_single_line_err_force(gen_micron_id=134, chk_micron_id=120, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x3300, run_id_str=RUN_ID)

#end
power_off = power_off_ring(ring,apc, ARGV[1])

if(power_on && prbs_test && power_off)
    testResult = "PASS"
end


puts("-------------------------------------TEST PRBS RING B RESULT SUMMARY----------------------------------")
#for x in $result_collector do
 #   puts x
#end

num_of_res_lines = 0
fail_flag = false
for x in $result_collector do
	puts x
	if x.include? "Connection" and x.include? "BER"
		num_of_res_lines = num_of_res_lines + 1 
	end
	if x.include? "FAIL" or x.include? "Fail"
		fail_flag = true
	end
end
if num_of_res_lines = 80 and fail_flag == false
	puts("Ring B Final Status = Pass")
else 
	puts("Ring B Final Status = Fail")
end

out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!