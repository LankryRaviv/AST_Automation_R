load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
load('Operations/FSW/FSW_Telem.rb')
load('Operations/FSW/FSW_SE.rb')
load('Operations/FSW/FSW_CSP.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')


def SE_test_setup(collector_list, tlm_instance, fs_instance, se_instance, target, realtime_dest, check_aspect, wait_time, entry_size, log_tlm_file_id, exec_file_id_0, exec_file_id_1, exec_file_id_2, test_file_name_0, test_file_name_1, test_file_name_2)
    collector_list.each do | collector |
      tlm_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)

      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
      #Upload the script text files
      FSW_FS_Upload(entry_size, exec_file_id_0, test_file_name_0, collector[:board], check_aspect) #9 payload commands, 1 call
      FSW_FS_Upload(entry_size, exec_file_id_1, test_file_name_1, collector[:board], check_aspect) #9 payload commands, 2 waits
      FSW_FS_Upload(entry_size, exec_file_id_2, test_file_name_2, collector[:board], check_aspect) #uploading the third script, 5 payload commands

      # Get current values for script engine
      current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
      current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

      ## Setting Log File ID
      se_instance.script_set_log_file_id(collector[:board], 0, log_tlm_file_id)          

      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_69", "== 4610", wait_time)
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_70", "== 4611", wait_time)
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_71", "== 4612", wait_time)

      #check to see if script engine is in the ready state
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0

      #Wait to make sure there's no error than the one we trigger
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+1}", wait_time)   
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

      # Clear the log file and wait for operation to be complete
      fs_instance.file_clear(collector[:board], log_tlm_file_id)
      file_status = fs_instance.wait_for_file_ok(collector[:board], log_tlm_file_id)
      check_expression("#{file_status} == 55")
    end
    status_bar("test_a_setup")
end

def try_multiple_time_based_scripts(collector_list, target, se_instance, wait_time, exec_file_id_0, exec_file_id_1, exec_file_id_2)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if each script is in the ready state 
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get script done value
    script_done_counter_69 = tlm(target, full_pkt_name, "SCRIPT_DONE_69")
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    # Set up time stamp triggers
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")

    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 30, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_0, 0, se_now_time + 35, "*", "*", "*", "*", "*")   
    se_instance.script_run(collector[:board], exec_file_id_1, 0, se_now_time + 40, "*", "*", "*", "*", "*")

    se_instance.script_run(collector[:board], 3, 1, 0, "*", "*", "*", "*", "*")

    # Check seconds til execution telemetry
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_2SECONDS_TIL_EXEC_71", "== 10", wait_time)         ## 2 seconds/value
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_2SECONDS_TIL_EXEC_69", "== 10", wait_time)         ## 2 seconds/value
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_2SECONDS_TIL_EXEC_70", "== 10", wait_time)         ## 2 seconds/value     

    # Wait for entire script to finish executing
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== 0", wait_time)                  #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 0", wait_time)                  #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== 0", wait_time)                  #SE_STATE_READY = 0

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+23}", wait_time)   # cmds = 9+5+5+(4xRUN)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err+1}", wait_time)

    # Verify all scripts have executed once
    wait_check(target, full_pkt_name, "SCRIPT_DONE_69", "== #{script_done_counter_69+1}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70+1}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+1}", wait_time)
  end
  status_bar("test_trigger_multiple_script_time_based")
end

def try_manual_abort(collector_list, se_instance, target, wait_time, exec_file_id_1, exec_file_id_2)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if each script is in the ready state
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time)    #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time)    #SE_STATE_READY = 0

    # Get script done value
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    se_instance.script_run(collector[:board], exec_file_id_1, 1, 0, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 1, 0, "*", "*", "*", "*", "*")

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{1}", wait_time)     #SE_STATE_ARMED = 1

    se_instance.script_abort(collector[:board], exec_file_id_1)  #abort file ID 4611

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{4}", wait_time)    #SE_STATE_DONE = 4

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+9}", wait_time)   # cmds = 5+1+(2xRUN)+(1xABORT)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

    # Verify all scripts have executed once
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+1}", wait_time)
  end
  status_bar("test_manual_abort")
end

def try_manrun_parameterized_scripts(collector_list, se_instance, target, entry_size, wait_time, check_aspect, exec_file_id_0, exec_file_id_1, exec_file_id_2)
  collector_list.each do | collector |    
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])         

    FSW_FS_Upload(entry_size, exec_file_id_0, "#{__dir__}\\..\\Script4_exe.txt", collector[:board], check_aspect) # 1 commands
    FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script5_exe.txt", collector[:board], check_aspect) # 14 commands
    FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script6_exe.txt", collector[:board], check_aspect) # 6 commands

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get current script done telemetry value
    script_done_counter_69 = tlm(target, full_pkt_name, "SCRIPT_DONE_69")
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    se_instance.script_run(collector[:board], exec_file_id_0, 1, 0, "*", "*", "*", "*", "*")

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{1}", wait_time) #SE_STATE_ARMED = 1
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{2}", wait_time) #SE_STATE_BUSY = 2
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{4}", wait_time) #SE_STATE_DONE = 4

    # Verify all scripts have executed once
    wait_check(target, full_pkt_name, "SCRIPT_DONE_69", "== #{script_done_counter_69+1}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70+1}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+1}", wait_time)

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+22}", wait_time)   # cmds = 1+14+6+(1xRUN)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)
  end
  status_bar("test_ManRun_Parameterized_Scripts")
end

def try_parameterized_timetag_scripts(collector_list, se_instance, target, entry_size, wait_time, check_aspect, exec_file_id_0)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")
    se_now_time = se_now_time.ceil()

    # Add time tags when calling scripts 4611 and 4610 and change telm frequency to 0.25
    file = File.new("#{__dir__}\\..\\Script7_exe.txt", "w")
    file << "@4612 ##{se_now_time+30} &72 &73 &74\n$2\n@4611 ##{se_now_time+45} &55 &56 &57 &58 &59\nscript stat 60\n"
    file.close

    # Upload edited script
    FSW_FS_Upload(entry_size, exec_file_id_0, "#{__dir__}\\..\\Script7_exe.txt", collector[:board], check_aspect) # 1 command

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get current script done telemetry value
    script_done_counter_69 = tlm(target, full_pkt_name, "SCRIPT_DONE_69")
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    # Run script7
    se_instance.script_run(collector[:board], exec_file_id_0, 1, 0, "*", "*", "*", "*", "*")

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+2}", wait_time)   # cmds = 1+14+6+(1xRUN)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

    # Verify all scripts have executed once
    wait_check(target, full_pkt_name, "SCRIPT_DONE_69", "== #{script_done_counter_69+1}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70+1}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+1}", wait_time)
  end
  status_bar("test_Timetag_Parameterized_Scripts")
end

def try_abort_param_script(collector_list, se_instance, target, entry_size, wait_time, check_aspect, exec_file_id_0)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    # Get current script done telemetry value
    script_done_counter_69 = tlm(target, full_pkt_name, "SCRIPT_DONE_69")
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")

    # Upload edited script
    FSW_FS_Upload(entry_size, exec_file_id_0, "#{__dir__}\\..\\Script8_exe.txt", collector[:board], check_aspect) # 1 command

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get current script done telemetry value
    script_done_counter_69 = tlm(target, full_pkt_name, "SCRIPT_DONE_69")
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")

    # Run script8
    se_instance.script_run(collector[:board], exec_file_id_0, 1, 0, "*", "*", "*", "*", "*")

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{5}", wait_time) #SE_STATE_ABORTED = 5

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+2}", wait_time)   # cmds = 1+0+0+(1xRUN)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

    # Verify scripts have executed accordingly
    wait_check(target, full_pkt_name, "SCRIPT_DONE_69", "== #{script_done_counter_69+1}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70}", wait_time)
  end
  status_bar("test_Abort_Parameterized_Script")
end

def try_invalid_num_param_cmd(collector_list, se_instance, entry_size, target, wait_time, check_aspect, exec_file_id_0, exec_file_id_1)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Upload edited script
    FSW_FS_Upload(entry_size, exec_file_id_0, "#{__dir__}\\..\\Script9_exe.txt", collector[:board], check_aspect) # 1 command
    FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script5_exe.txt", collector[:board], check_aspect) # 1 command

    # Get current script done telemetry value
    script_done_counter_69 = tlm(target, full_pkt_name, "SCRIPT_DONE_69")
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")

    # Run Script9
    se_instance.script_run(collector[:board], exec_file_id_0, 1, 0, "*", "*", "*", "*", "*")
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{5}", wait_time) #SE_STATE_ABORTED = 5

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+7}", wait_time)   # cmds = 5+1+(1xRUN)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err+1}", wait_time)

    # Verify all scripts have executed once
    wait_check(target, full_pkt_name, "SCRIPT_DONE_69", "== #{script_done_counter_69+1}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70}", wait_time)
  end
  status_bar("test_Invalid_Num_of_Parameters_and_Commands")
end

def try_multi_time_tagging_script(collector_list, se_instance, entry_size, target, wait_time, check_aspect, exec_file_id_2)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script2_exe.txt", collector[:board], check_aspect) # 5 cmds in script 2

    # Get current script done telemetry value
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME").ceil()

    # Run Script2
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 30, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 40, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 50, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 60, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 70, "*", "*", "*", "*", "*")

    # Script execution check-ins so test doesn't time out
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+2}", wait_time)
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+4}", wait_time)

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+30}", wait_time)   # cmds = (5 script Iterations)*(5 CMD/script)+(5 RUNS)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

    # Verify script have executed 5 times
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+5}", wait_time)
  end
  status_bar("test_Multi_Time_Tagging_Script")
end

def multi_time_tagged_script_with_params(collector_list, se_instance, entry_size, target, wait_time, check_aspect, exec_file_id_1, exec_file_id_2, realtime_dest)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0
    
    # Get current script done telemetry value
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")
    se_now_time = se_now_time.ceil()

    # Add 5 time tags when calling scripts 4612
    file = File.new("#{__dir__}\\..\\Script11_exe.txt", "w")
    file << "script run 4612 0 #{se_now_time+50} * * * * *\nscript run 4612 0 #{se_now_time+70} 80 81 82 83 84\nscript run 4612 0 #{se_now_time+90} * * * * *\n"
    file.close

    FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script11_exe.txt", collector[:board], check_aspect) 
    FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script5_exe.txt", collector[:board], check_aspect) # 5 cmds in script 2

    # Time tag 5x usint SE script '#' symbol method
    se_instance.script_run(collector[:board], exec_file_id_1, 1, 0, "*", "*", "*", "*", "*")

    # Verify script 4611 have finished executing
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70+1}", wait_time)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)
    
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{1}", wait_time) #SE_STATE_ARMED = 1

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+31}", wait_time)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+46}", wait_time)   # cmds = (0 script iterations)*(5 CMD/script)+(2 RUNS/ABORTS)+(2 TLM)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

    # Verify script have executed 0 times
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+3}", wait_time)
    end
  status_bar("test_Multi_Time_Tagged_Script")
end

def try_adding_6th_time_tag_to_script(collector_list, se_instance, entry_size, target, wait_time, check_aspect, exec_file_id_2)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script2_exe.txt", collector[:board], check_aspect) # 5 cmds in script 2

    # Get current script done telemetry value
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")

    # Run Script2
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 30, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 40, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 50, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 60, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 70, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 75, "*", "*", "*", "*", "*")

    # Verify script have executed 2 times
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+2}", wait_time)

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+31}", wait_time)   # cmds = (5 script iterations)*(5 CMD/script)+(6 RUNS)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err+1}", wait_time)

    # Verify script have executed 5 times
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+5}", wait_time)
  end
  status_bar("test_Adding_6th_Time_Tag_To_Script")
end

def try_out_of_order_script_time_tagging(collector_list, se_instance, entry_size, target, wait_time, check_aspect, exec_file_id_2, realtime_dest)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script2_exe.txt", collector[:board], check_aspect) # 5 cmds in script 2

    # Get current script done telemetry value
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")

    # Time tag Script2 from latest time to earliest time
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 70, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 60, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 50, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 40, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time + 30, "*", "*", "*", "*", "*")

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait for start times to shift - 4 start times left
    wait(40)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait for start times to shift- 3 start times left
    wait(10)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)
   
    # Wait for start times to shift- 2 start times left
    wait(10)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait for start times to shift- 1 start times left
    wait(10)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait for start times to shift- 0 start times left
    wait(10)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+36}", wait_time)   # cmds = (5 script iterations)*(5 CMD/script)+(5 RUNS)+(6 TLM)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

    # Verify script have executed 5 times
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71+5}", wait_time)
  end
  status_bar("test_Out_Of_Order_Script_Time_Tagging")
end

def abort_multi_time_tagged_script(collector_list, se_instance, entry_size, target, wait_time, check_aspect, exec_file_id_1, exec_file_id_2, realtime_dest)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")
    se_now_time = se_now_time.ceil()

    # Add 5 time tags when calling scripts 4612
    file = File.new("#{__dir__}\\..\\Script11_exe.txt", "w")
    file << "@4612 ##{se_now_time+1000}\n@4612 ##{se_now_time+1010}\n@4612 ##{se_now_time+1020}\n@4612 ##{se_now_time+1030}\n@4612 ##{se_now_time+1040}\n"
    file.close

    FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script11_exe.txt", collector[:board], check_aspect) 
    FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script2_exe.txt", collector[:board], check_aspect) # 5 cmds in script 2

    # Get current script done telemetry value
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")

    # Time tag 5x usint SE script '#' symbol method
    se_instance.script_run(collector[:board], exec_file_id_1, 1, 0, "*", "*", "*", "*", "*")

    # Verify script 4611 have finished executing
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70+1}", wait_time)

    wait(10)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    wait(10)

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{1}", wait_time) #SE_STATE_BUSY = 1

    # Abort script to clear all time tags
    se_instance.script_abort(collector[:board], exec_file_id_2)

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+4}", wait_time)   # cmds = (0 script iterations)*(5 CMD/script)+(2 RUNS/ABORTS)+(2 TLM)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

    # Verify script have executed 0 times
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71}", wait_time)
    end
  status_bar("test_Abort_Multi_Time_Tagged_Script")
end

def delete_single_script_time_tag(collector_list, se_instance, entry_size, target, wait_time, check_aspect, exec_file_id_1, exec_file_id_2, realtime_dest)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")
    se_now_time = se_now_time.ceil()

    # Add 5 time tags when calling scripts 4612
    file = File.new("#{__dir__}\\..\\Script11_exe.txt", "w")
    file << "@4612 ##{se_now_time+1000}\n@4612 ##{se_now_time+1010}\n@4612 ##{se_now_time+1020}\n@4612 ##{se_now_time+1030}\n@4612 ##{se_now_time+1040}\n"
    file.close

    FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script11_exe.txt", collector[:board], check_aspect) 
    FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script2_exe.txt", collector[:board], check_aspect) # 5 cmds in script 2

    # Get current script done telemetry value
    script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")
    script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")

    #### -----DELETE FROM BACK TO FRONT----- ####

    # Time tag 5x usint SE script '#' symbol method
    se_instance.script_run(collector[:board], exec_file_id_1, 1, 0, "*", "*", "*", "*", "*")

    # Verify script 4611 have finished executing
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70+1}", wait_time)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    wait(10)

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{1}", wait_time) #SE_STATE_ARMED = 1

    # Delete start time index
    se_instance.remove_single_time_tag(collector[:board], exec_file_id_2, 5)

    wait(3)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Delete start time index
    se_instance.remove_single_time_tag(collector[:board], exec_file_id_2, 3)

    wait(3)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Delete start time index
    se_instance.remove_single_time_tag(collector[:board], exec_file_id_2, 1)

    wait(3)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    wait(10)

    # Abort script to clear all time tags
    se_instance.script_abort(collector[:board], exec_file_id_2)

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+10}", wait_time)   # cmds = (0 script iterations)*(5 CMD/script)+(5 RUNS/ABORTS/RM)+(5 TLM)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

    #### -----DELETE FROM FRONT TO BACK----- ####

    # Time tag 5x usint SE script '#' symbol method
    se_instance.script_run(collector[:board], exec_file_id_1, 1, 0, "*", "*", "*", "*", "*")

    # Verify script 4611 have finished executing
    wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70+1}", wait_time)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    wait(10)

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{1}", wait_time) #SE_STATE_ARMED = 1

    # Delete start time index
    se_instance.remove_single_time_tag(collector[:board], exec_file_id_2, 1)

    wait(3)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Delete start time index
    se_instance.remove_single_time_tag(collector[:board], exec_file_id_2, 3)

    wait(3)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Delete start time index
    se_instance.remove_single_time_tag(collector[:board], exec_file_id_2, 5)

    wait(3)

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    wait(10)

    # Abort script to clear all time tags
    se_instance.script_abort(collector[:board], exec_file_id_2)

    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get instantaneous tlm
    se_instance.send_instantaneous_tlm(collector[:board], exec_file_id_2, realtime_dest)

    # Wait to make sure there's no error at subsystem
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+20}", wait_time)   # cmds = (0 script iterations)*(5 CMD/script)+(5 RUNS/ABORTS/RM)+(5 TLM)
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err+1}", wait_time)        # Error = delete empty index

    # Verify script have executed 0 times
    wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71}", wait_time)
    end
  status_bar("test_Delete_Single_Script_Time_Tag")
end

# This is a test proc used testing different scenarios. It should not be included in any functionality tests
def temp_test(collector_list, se_instance, target, entry_size, check_aspect, wait_time, exec_file_id_0, exec_file_id_1, exec_file_id_2)
  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    FSW_FS_Upload(entry_size, exec_file_id_0, "#{__dir__}\\..\\Script1_exe.txt", collector[:board], check_aspect)
    FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script2_exe.txt", collector[:board], check_aspect)
    FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script3_exe.txt", collector[:board], check_aspect)

    # Get current values for script engine
    current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get current time
    se_now_time = tlm(target, full_pkt_name, "RTC_TIME")
    se_now_time = se_now_time.ceil()

    # set start times for script 0
    se_instance.script_run(collector[:board], exec_file_id_0, 0, se_now_time+1000, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_0, 0, se_now_time+1010, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_0, 0, se_now_time+1020, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_0, 0, se_now_time+1030, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_0, 0, se_now_time+1040, "*", "*", "*", "*", "*")

    # set start times for script 1
    se_instance.script_run(collector[:board], exec_file_id_1, 0, se_now_time+1000, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_1, 0, se_now_time+1010, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_1, 0, se_now_time+1020, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_1, 0, se_now_time+1030, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_1, 0, se_now_time+1040, "*", "*", "*", "*", "*")

    # set start times for script 2
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time+1000, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time+1010, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time+1020, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time+1030, "*", "*", "*", "*", "*")
    se_instance.script_run(collector[:board], exec_file_id_2, 0, se_now_time+1040, "*", "*", "*", "*", "*")
  end
  status_bar("test_Temp_Test")
end

# Only works with ALL_YP or ALL_YM
def try_exec_script_on_other_boards(collector_list, se_instance, target, entry_size, check_aspect, wait_time, exec_file_id_1, exec_file_id_2)
  # Upload scripts to APC 
  FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script10_exe.txt", 'APC_YP', check_aspect)
  FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script6_exe.txt", 'APC_YP', check_aspect) # 5 commands

  # Upload scripts to FC 
  FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script10_exe.txt", 'FC_YP', check_aspect)
  FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script6_exe.txt", 'FC_YP', check_aspect) # 5 commands

  # Upload scripts to DPC_1 
  FSW_FS_Upload(entry_size, exec_file_id_1, "#{__dir__}\\..\\Script10_exe.txt", 'DPC_1', check_aspect)
  FSW_FS_Upload(entry_size, exec_file_id_2, "#{__dir__}\\..\\Script6_exe.txt", 'DPC_1', check_aspect) # 5 commands

  collector_list.each do | collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

    full_pkt_name_APC = CmdSender.get_full_pkt_name('APC_YP', 'FSW_TLM_APC')
    full_pkt_name_FC = CmdSender.get_full_pkt_name('FC_YP', 'FSW_TLM_FC')
    full_pkt_name_DPC_1 = CmdSender.get_full_pkt_name('DPC_1', 'FSW_TLM_DPC')

    # Get current values for script engine
    current_subsystem_rec_APC = tlm(target, full_pkt_name_APC, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err_APC = tlm(target, full_pkt_name_APC, "SCRIPT_ENGINE_ERR_COUNTER")

    # Get current values for script engine
    current_subsystem_rec_FC = tlm(target, full_pkt_name_FC, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err_FC = tlm(target, full_pkt_name_FC, "SCRIPT_ENGINE_ERR_COUNTER")

    # Get current values for script engine
    current_subsystem_rec_DPC_1 = tlm(target, full_pkt_name_DPC_1, "SCRIPT_ENGINE_CMD_REC_COUNTER")
    current_subsystem_err_DPC_1 = tlm(target, full_pkt_name_DPC_1, "SCRIPT_ENGINE_ERR_COUNTER")

    #check to see if script engine is in the ready state
    wait_check(target, full_pkt_name_APC, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check(target, full_pkt_name_FC, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check(target, full_pkt_name_DPC_1, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Check that fileIds are in READY state
    wait_check_raw(target, full_pkt_name_APC, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name_APC, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name_FC, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name_FC, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name_DPC_1, "SCRIPT_ENGINE_STATES_70", "== #{0}", wait_time) #SE_STATE_READY = 0
    wait_check_raw(target, full_pkt_name_DPC_1, "SCRIPT_ENGINE_STATES_71", "== #{0}", wait_time) #SE_STATE_READY = 0

    # Get script done telemetry values
    script_done_counter_70_APC = tlm(target, full_pkt_name_APC, "SCRIPT_DONE_70")
    script_done_counter_71_APC = tlm(target, full_pkt_name_APC, "SCRIPT_DONE_71")

    script_done_counter_70_FC = tlm(target, full_pkt_name_FC, "SCRIPT_DONE_70")
    script_done_counter_71_FC = tlm(target, full_pkt_name_FC, "SCRIPT_DONE_71")

    script_done_counter_70_DPC = tlm(target, full_pkt_name_DPC_1, "SCRIPT_DONE_70")
    script_done_counter_71_DPC = tlm(target, full_pkt_name_DPC_1, "SCRIPT_DONE_71")

    # Run Script10
    se_instance.script_run(collector[:board], exec_file_id_1, 1, 0, "4612", "10", "20", "30", "*")

    # Verify cmd receive and error counters
    wait_check(target, full_pkt_name_APC, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec_APC+8}", wait_time)   # cmds = 1+1+(1xRUN)
    wait_check(target, full_pkt_name_APC, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err_APC}", wait_time)
    wait_check(target, full_pkt_name_FC, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec_FC+8}", wait_time)   # cmds = 1+1+(1xRUN)
    wait_check(target, full_pkt_name_FC, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err_FC}", wait_time)
    wait_check(target, full_pkt_name_DPC_1, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec_DPC_1+8}", wait_time)   # cmds = 1+1+(1xRUN)
    wait_check(target, full_pkt_name_DPC_1, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err_DPC_1}", wait_time)

    # Verify all scripts have executed once
    if collector[:board] == 'APC_YP'
      wait_check(target, full_pkt_name_APC, "SCRIPT_DONE_70", "== #{script_done_counter_70_APC+1}", wait_time)
      wait_check(target, full_pkt_name_APC, "SCRIPT_DONE_71", "== #{script_done_counter_71_APC+1}", wait_time)
      wait_check(target, full_pkt_name_FC, "SCRIPT_DONE_71", "== #{script_done_counter_71_FC+1}", wait_time)
      wait_check(target, full_pkt_name_DPC_1, "SCRIPT_DONE_71", "== #{script_done_counter_71_DPC+1}", wait_time)
    elsif collector[:board] == 'FC_YP'
      wait_check(target, full_pkt_name_APC, "SCRIPT_DONE_71", "== #{script_done_counter_71_APC+1}", wait_time)
      wait_check(target, full_pkt_name_FC, "SCRIPT_DONE_70", "== #{script_done_counter_70_FC+1}", wait_time)
      wait_check(target, full_pkt_name_FC, "SCRIPT_DONE_71", "== #{script_done_counter_71_FC+1}", wait_time)
      wait_check(target, full_pkt_name_DPC_1, "SCRIPT_DONE_71", "== #{script_done_counter_71_DPC+1}", wait_time)
    elsif collector[:board] == 'DPC_1'
      wait_check(target, full_pkt_name_APC, "SCRIPT_DONE_71", "== #{script_done_counter_71_APC+1}", wait_time)
      wait_check(target, full_pkt_name_FC, "SCRIPT_DONE_71", "== #{script_done_counter_71_FC+1}", wait_time)
      wait_check(target, full_pkt_name_DPC_1, "SCRIPT_DONE_70", "== #{script_done_counter_70_DPC+1}", wait_time)
      wait_check(target, full_pkt_name_DPC_1, "SCRIPT_DONE_71", "== #{script_done_counter_71_DPC+1}", wait_time)
    else 
      wait_check(target, full_pkt_name_APC, "SCRIPT_DONE_71", "== #{script_done_counter_71_APC+1}", wait_time)
      wait_check(target, full_pkt_name_FC, "SCRIPT_DONE_71", "== #{script_done_counter_71_FC+1}", wait_time)
      wait_check(target, full_pkt_name_DPC_1, "SCRIPT_DONE_71", "== #{script_done_counter_71_DPC+1}", wait_time)
    end
  end  
  status_bar("test_exec_script_on_other_boards")
end
