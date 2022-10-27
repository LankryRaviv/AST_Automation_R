require_relative 'MICRON_PRBS no csv'
include MICRON_PRBS

$result_collector = []

RUN_ID = "1234567891011133"
RING_B = [131, 132, 133, 134, 135, 136, 122, 108, 94, 80, 66, 65, 64, 63, 62, 61, 75, 89, 103, 117]

# test_prbs_micron_to_micron(RING_B, RUN_ID)

# Test PRBS on ring B -hard codded:
test_prbs_micron_single_line(gen_micron_id=61, chk_micron_id=62, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=62, chk_micron_id=63, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=63, chk_micron_id=77, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=64, chk_micron_id=78, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=64, chk_micron_id=65, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=65, chk_micron_id=66, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=75, chk_micron_id=76, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=79, chk_micron_id=80, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=89, chk_micron_id=90, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=93, chk_micron_id=94, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=103, chk_micron_id=104, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=107, chk_micron_id=108, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=117, chk_micron_id=118, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=119, chk_micron_id=133, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=120, chk_micron_id=134, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=121, chk_micron_id=122, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=131, chk_micron_id=132, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=132, chk_micron_id=133, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=134, chk_micron_id=135, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=135, chk_micron_id=136, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)

# Test PRBS on ring B -hard codded with error force:
test_prbs_micron_single_line_err_force(gen_micron_id=61, chk_micron_id=62, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=62, chk_micron_id=63, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=63, chk_micron_id=77, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=64, chk_micron_id=78, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=64, chk_micron_id=65, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=65, chk_micron_id=66, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=75, chk_micron_id=76, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=79, chk_micron_id=80, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=89, chk_micron_id=90, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=93, chk_micron_id=94, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=103, chk_micron_id=104, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=107, chk_micron_id=108, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=117, chk_micron_id=118, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=119, chk_micron_id=133, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=120, chk_micron_id=134, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=121, chk_micron_id=122, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=131, chk_micron_id=132, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=132, chk_micron_id=133, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=134, chk_micron_id=135, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=135, chk_micron_id=136, gen_micron_pcs=1, chk_micron_pcs=0, run_id_str=RUN_ID)

# # Test PRBS on ring B -hard codded with error force:
#test_prbs_micron_single_line_err_force(gen_micron_id=61, chk_micron_id=62, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=62, chk_micron_id=63, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0303, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=63, chk_micron_id=77, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0302, chk_pcs_status=0x3300, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=66, chk_micron_id=65, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=65, chk_micron_id=64, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0230, run_id_str=RUN_ID)
test_prbs_micron_single_line_err_force(gen_micron_id=64, chk_micron_id=78, gen_micron_pcs=2, chk_micron_pcs=3, gen_pcs_status=0x0320, chk_pcs_status=0x3200, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=75, chk_micron_id=76, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0003, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=80, chk_micron_id=77, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0030, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=89, chk_micron_id=90, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0003, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=94, chk_micron_id=93, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0030, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=103, chk_micron_id=104, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0003, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=108, chk_micron_id=107, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0030, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=117, chk_micron_id=118, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0003, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=122, chk_micron_id=121, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0030, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=131, chk_micron_id=132, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0030, chk_pcs_status=0x0023, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=132, chk_micron_id=133, gen_micron_pcs=1, chk_micron_pcs=0, gen_pcs_status=0x0032, chk_pcs_status=0x0303, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=133, chk_micron_id=119, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3002, chk_pcs_status=0x3300, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=136, chk_micron_id=135, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0003, chk_pcs_status=0x0032, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=135, chk_micron_id=134, gen_micron_pcs=0, chk_micron_pcs=1, gen_pcs_status=0x0023, chk_pcs_status=0x0330, run_id_str=RUN_ID)
#test_prbs_micron_single_line_err_force(gen_micron_id=134, chk_micron_id=120, gen_micron_pcs=3, chk_micron_pcs=2, gen_pcs_status=0x3020, chk_pcs_status=0x3300, run_id_str=RUN_ID)


puts("-------------------------------------------------------------------------------------------------")
for x in $result_collector do
    puts x
end





# RING_A = [118, 119, 120, 121, 107, 93, 79, 78, 77, 76, 90, 104]
# RING_B = [131, 132, 133, 134, 135, 136, 122, 108, 94, 80, 66, 65, 64, 63, 62, 61, 75, 89, 103, 117]
# RING_C = [144, 145, 146, 147, 148, 149, 150, 151, 37, 123, 109, 95, 81, 67, 53, 52, 51, 50, 49, 48, 47, 46, 60, 74, 88, 102, 116, 130]
# RING_D = [152,138,124,110,96,82,68,54,45,59,73,87,101,115,129,143]
# RING_E = [156,157,158,159,160,161,162,163,164,165,166,167, 172, 173,174,175,176,177,178,179,153,139,125,111,97,83,69,55,142,128,114,100,86,72,58,44,30,31,32,33,34,35,36,37,38,39,40,41,18,19,20,21,22,23,24,25]
# RING_F = [186,187,188,189,190,191,192,193,11,10,9,8,7,6,5,4]

# test_prbs_cpbf_to_micron(CPBF_MICRON_LIST, run_id_str)
# test_prbs_micron_to_micron(RING_A)
# test_prbs_micron_to_micron(RING_B)
# test_prbs_micron_to_micron(RING_C)
# test_prbs_micron_to_micron(RING_D)
# test_prbs_micron_to_micron(RING_E)
# test_prbs_micron_to_micron(RING_F)
# puts("-------------------------------------------------------------------------------------------------")
# for x in $result_collector do
#     puts x
# end
