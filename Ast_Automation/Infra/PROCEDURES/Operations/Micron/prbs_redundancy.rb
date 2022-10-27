load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load('Operations/Micron/PRBS_SECONDARY_RING_X.rb')
require 'date'    

out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
#Read arguments
for data in ARGV
    out_file.write(data + " ")
end
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
out_file.puts(builded_string)
out_file.flush
testResult = "FAIL"
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip
prbs_result = false

#Option to validate if moved to reduced can be added
move_ring_to_mode_and_validate(ring, 'REDUCED', ARGV[1], true, nil)

if ring.match?(/[[:alpha:]]/)
    if ring == 'A'
        prbs_result = prbs_secondary_ring_a(ring, ARGV[1], apc, cpbf)
    elsif ring == 'B'
        prbs_result = prbs_secondary_ring_b(ring, ARGV[1], apc, cpbf)
    elsif ring == 'C'
        prbs_result = prbs_secondary_ring_c(ring, ARGV[1], apc, cpbf)
    elsif ring == 'D'
        prbs_result = prbs_secondary_ring_d(ring, ARGV[1], apc, cpbf)
    elsif ring == 'E'
        prbs_result = prbs_secondary_ring_e(ring, ARGV[1], apc, cpbf)
    elsif ring == 'F'
        prbs_result = prbs_secondary_ring_f(ring, ARGV[1], apc, cpbf)
    else
        prbs_result = prbs_secondary_ring_a(ring, ARGV[1], apc, cpbf)
        prbs_result &= prbs_secondary_ring_b(ring, ARGV[1], apc, cpbf)
        prbs_result &= prbs_secondary_ring_c(ring, ARGV[1], apc, cpbf)
        prbs_result &= prbs_secondary_ring_d(ring, ARGV[1], apc, cpbf)
        prbs_result &= prbs_secondary_ring_e(ring, ARGV[1], apc, cpbf)
        prbs_result &= prbs_secondary_ring_f(ring, ARGV[1], apc, cpbf)
    end
end
#Validate if return back to ps2
moved_to_ps2 = move_ring_to_mode_and_validate(ring, 'PS2', ARGV[1], true, nil)

if prbs_result && moved_to_ps2
    testResult = "PASS"
end


out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
start_new_scriptrunner_message_log()
exit!
