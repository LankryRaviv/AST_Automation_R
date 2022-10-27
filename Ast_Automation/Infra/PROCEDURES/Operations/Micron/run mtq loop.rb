load_utility('Operations/MICRON/MTQ_Command_Driver.rb')

# function takes as an argument:
#   - mtqa_state - ON/OFF
#   - mtqa_polarity - POSITIVE/NEGATIVE
#   - mtqa_time - centiseconds(INT) time mtqa will be powered on
#   - mtqb_state - ON/OFF
#   - mtqb_polarity - POSITIVE/NEGATIVE
#   - mtqb_time - centiseconds(INT) time mtqb will be powered on
#   - loop_until_abort - true/false set to true to run in continuous loop
#   - duration - if loop_until_abort=false, sets the time duration for the loop

link = "MIC_LSL"
micron_id = 104
mtqa_state = "ON"
mtqa_polarity = "POSITIVE"
mtqa_time = 200
mtqb_state = "ON"
mtqb_polarity = "NEGATIVE"
mtqb_time = 200
loop_until_abort = false
duration = 300

mtq = MTQCommandDriver.new

mtq.mtq_command_loop(link, micron_id, mtqa_state, mtqa_polarity, mtqa_time, mtqb_state, mtqb_polarity, 
                     mtqb_time, loop_until_abort, duration)

# To send just a single command, use the following script:

# send_mtq_command(micron_id, mtqa_state, mtqa_polarity, mtqa_time, mtqb_state, mtqb_polarity, mtqb_time)