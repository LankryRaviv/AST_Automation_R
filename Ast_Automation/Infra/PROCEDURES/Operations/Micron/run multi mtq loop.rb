load_utility('Operations/MICRON/Micron_IMU_MTQ_tests.rb')

# function takes as an argument:
#   - cmd_param_array - Array of arrays of mtq command parameter selections
#        -each array of command parameter selections includes four entries:
#          - mtqa_state - ON/OFF
#          - mtqa_polarity - POSITIVE/NEGATIVE
#          - mtqb_state - ON/OFF
#          - mtqb_polarity - POSITIVE/NEGATIVE
#   - mtq_time - centiseconds(INT) time mtqs will be powered on
#   - loop_until_abort - true/false set to true to run in continuous loop
#   - duration - if loop_until_abort=false, sets the time duration for the loop

link = "MIC_LSL"
micron_id = 104
mtq_time = 200
mtqa_state = "ON"
mtqa_polarity = "POSITIVE"
mtqb_state = "ON"
mtqb_polarity = "NEGATIVE"

cmd_param_array = []
cmd_param_array.append([mtqa_state, mtqa_polarity, mtqb_state, mtqb_polarity])
cmd_param_array.append([mtqa_state, "NEGATIVE", "OFF", mtqb_polarity])

loop_until_abort = false
duration = 300


mtq_multicommand_loop(link, micron_id, cmd_param_array, mtq_time, loop_until_abort, duration)

