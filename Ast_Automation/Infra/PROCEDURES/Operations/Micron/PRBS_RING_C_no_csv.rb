load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
require_relative 'MICRON_PRBS no csv'

include MICRON_PRBS

# RUN_ID = "1234567891011133"

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
power_on, ring_list = power_on_ring_to_reduced(ring, ARGV[1])
if(power_on)

    # Test PRBS on ring B -hard codded:
    # test_prbs_micron_single_line(gen_micron_id=46, chk_micron_id=47, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=47, chk_micron_id=48, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=48, chk_micron_id=49, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0203, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=49, chk_micron_id=63, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3202, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=53, chk_micron_id=52, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=52, chk_micron_id=51, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=51, chk_micron_id=50, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0230, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=50, chk_micron_id=64, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3020, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=60, chk_micron_id=61, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=67, chk_micron_id=66, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=74, chk_micron_id=75, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=81, chk_micron_id=80, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=88, chk_micron_id=89, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=95, chk_micron_id=94, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=102, chk_micron_id=103, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=109, chk_micron_id=108, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=116, chk_micron_id=117, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=123, chk_micron_id=122, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=130, chk_micron_id=131, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=137, chk_micron_id=136, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=144, chk_micron_id=145, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=145, chk_micron_id=146, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=146, chk_micron_id=147, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2003, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=147, chk_micron_id=133, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x0302, chk_pcs_status=0x2302, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=151, chk_micron_id=150, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=150, chk_micron_id=149, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=149, chk_micron_id=148, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2030, run_id_str=RUN_ID)
    # test_prbs_micron_single_line(gen_micron_id=148, chk_micron_id=134, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x2300, run_id_str=RUN_ID)



    # # Test PRBS on ring B -hard codded with error force:
    test_prbs_micron_single_line_err_force(gen_micron_id=46, chk_micron_id=47, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=47, chk_micron_id=48, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=48, chk_micron_id=49, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0203, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=49, chk_micron_id=63, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3202, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=53, chk_micron_id=52, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=52, chk_micron_id=51, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=51, chk_micron_id=50, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0230, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=50, chk_micron_id=64, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3020, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=60, chk_micron_id=61, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=67, chk_micron_id=66, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=74, chk_micron_id=75, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=81, chk_micron_id=80, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=88, chk_micron_id=89, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=95, chk_micron_id=94, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=102, chk_micron_id=103, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=109, chk_micron_id=108, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=116, chk_micron_id=117, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=123, chk_micron_id=122, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=130, chk_micron_id=131, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=137, chk_micron_id=136, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=144, chk_micron_id=145, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=145, chk_micron_id=146, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0023, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=146, chk_micron_id=147, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x2003, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=147, chk_micron_id=133, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x0302, chk_pcs_status=0x2302, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=151, chk_micron_id=150, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=150, chk_micron_id=149, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0032, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=149, chk_micron_id=148, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x2030, run_id_str=RUN_ID)
    test_prbs_micron_single_line_err_force(gen_micron_id=148, chk_micron_id=134, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x2300, run_id_str=RUN_ID)

end
power_off = power_off_ring(ring, ARGV[1])

if(power_on && prbs_test && power_off)
    testResult = "PASS"
end


puts("-------------------------------------------------------------------------------------------------")
for x in $result_collector do
    puts x
end


out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!