require_relative 'MICRON_PRBS Debug'

include MICRON_PRBS

RUN_ID = "1234567891011120"

CPBF_MICRON_LIST = [77, 78, 93, 107, 120, 119, 104, 90]
RING_A = [118, 119, 120, 121, 107, 93, 79, 78, 77, 76, 90, 104]

test_prbs_cpbf_to_micron(CPBF_MICRON_LIST, RUN_ID)
test_prbs_micron_to_micron(RING_A, RUN_ID)

# Test PRBS on ring A -hard codded:
test_prbs_micron_cpbf_single_link(micron_id=77, link=1, micron_pcs=2, run_id_str=RUN_ID)
test_prbs_micron_cpbf_single_link(micron_id=78, link=2, micron_pcs=2, run_id_str=RUN_ID)
test_prbs_micron_cpbf_single_link(micron_id=93, link=3, micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_cpbf_single_link(micron_id=107, link=4, micron_pcs=0, run_id_str=RUN_ID)
test_prbs_micron_cpbf_single_link(micron_id=120, link=5, micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_cpbf_single_link(micron_id=119, link=6, micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_cpbf_single_link(micron_id=104, link=7, micron_pcs=1, run_id_str=RUN_ID)
test_prbs_micron_cpbf_single_link(micron_id=90, link=8, micron_pcs=1, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=76, chk_micron_id=90, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=79, chk_micron_id=93, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=104, chk_micron_id=118, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)
test_prbs_micron_single_line(gen_micron_id=107, chk_micron_id=121, gen_micron_pcs=2, chk_micron_pcs=3, run_id_str=RUN_ID)



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