load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
load('Operations/FSW/FSW_Telem.rb')
load('Operations/FSW/FSW_SE.rb')
load('Operations/FSW/FSW_CSP.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')

  def se_basic_functions(collectors, module_telem, module_csp, module_fs, module_SE, target, exec_file_id_0,exec_file_id_1,exec_file_id_2,log_tlm_file_id,entry_size,check_aspect, script_id_0, script_id_1,script_id_2,test_file_name_0,test_file_name_1,test_file_name_2,wait_time,realtime_destination)
    collectors.each do | collector |
      module_telem.set_realtime(collector[:board], collector[:pkt_name], realtime_destination, 1)

      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])

      #Upload the script text files
      FSW_FS_Upload(entry_size, exec_file_id_0, test_file_name_0, collector[:board], check_aspect) 
      FSW_FS_Upload(entry_size, exec_file_id_1, test_file_name_1, collector[:board], check_aspect) 

      wait(10)

      # Get current values for script engine
      current_subsystem_rec = tlm(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER")
      current_subsystem_err = tlm(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER")

      ## Setting Log File ID
      module_SE.script_set_log_file_id(collector[:board], 0, log_tlm_file_id) 
      
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_69", "== 4610", wait_time)
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_70", "== 4611", wait_time)
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_EXEC_FILE_ID_71", "== 4612", wait_time)

      #check to see if script engine is in the ready state
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_STATE", "== #{0}", wait_time) #SE_STATE_READY = 0

      #Wait to make sure there's no error than the one we trigger
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+1}", wait_time)   
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err}", wait_time)

      # Clear the log file and wait for operation to be complete
      module_fs.file_clear(collector[:board], log_tlm_file_id)
      file_status = module_fs.wait_for_file_ok(collector[:board], log_tlm_file_id)
      check_expression("#{file_status} == 55")
     
      script_done_counter_69 = tlm(target, full_pkt_name, "SCRIPT_DONE_69")

      ##
      #   SINGLE SCRIPT EXEC
      ##
      module_SE.script_run(collector[:board], exec_file_id_0, 1, 0, "*", "*", "*", "*", "*")            # 5 cmds + 1 RUN

      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 1", wait_time)                    ## SE_STATE_ARMED = 1
      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 2", wait_time)                    ## SE_STATE_BUSY = 2
      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 4", wait_time)                    ## SE_STATE_DONE = 4
      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 0", wait_time)                    ## SE_STATE_READY = 0

      wait_check(target, full_pkt_name, "SCRIPT_DONE_69", "== #{script_done_counter_69 + 1}", wait_time)                    ## SE_STATE_DONE = 4

      ##
      #   SCRIPT ABORT
      ##
      module_SE.script_run(collector[:board], exec_file_id_0, 1, 0, "*", "*", "*", "*", "*")            # 1 RUN

      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== #{1}", wait_time)     #SE_STATE_ARMED = 1

      module_SE.script_abort(collector[:board], exec_file_id_0)  # 1 ABORT

      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_ABORT_69", "== #{1}", wait_time) #SE_STATE_ABORTED = 5

      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 0", wait_time)                    ## SE_STATE_READY = 0

      ##
      #   RUN NON-EXISTING SCRIPTS
      ##
      module_SE.script_run(collector[:board], 3, 1, 0, "*", "*", "*", "*", "*")

      ##
      #   MULTI-SCRIPT EXECUTION, SCRIPT TIME TAG, & INVALID CMDS
      ##
      script_done_counter_69 = tlm(target, full_pkt_name, "SCRIPT_DONE_69")
      script_done_counter_70 = tlm(target, full_pkt_name, "SCRIPT_DONE_70")
      script_done_counter_71 = tlm(target, full_pkt_name, "SCRIPT_DONE_71")
      
      se_now_time = tlm(target, full_pkt_name, "RTC_TIME")   # Get current time

      file = File.new(test_file_name_2, "w")
      file << "@4610 ##{se_now_time+40}\n@4611 ##{se_now_time+40}\nscript stat 60\n"
      file.close

      # Upload edited script
      FSW_FS_Upload(entry_size, exec_file_id_2, test_file_name_2, collector[:board], check_aspect)

      wait(5)

      # Run script12
      module_SE.script_run(collector[:board], exec_file_id_2, 1, 0, "*", "*", "*", "*", "*")

      wait_check(target, full_pkt_name, "SCRIPT_DONE_71", "== #{script_done_counter_71 + 1}", wait_time)                    ## SE_STATE_DONE = 4

      # Wait to make sure there's no error at subsystem
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+13}", wait_time)   # cmds = 17 cmds+(6xRUN/SET/ABORT)
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err+1}", wait_time)

      wait_check(target, full_pkt_name, "SCRIPT_DONE_69", "== #{script_done_counter_69 + 1}", wait_time)                    ## SE_STATE_DONE = 4
      wait_check(target, full_pkt_name, "SCRIPT_DONE_70", "== #{script_done_counter_70 + 1}", wait_time)                    ## SE_STATE_DONE = 4

      # Wait to make sure there's no error at subsystem
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_CMD_REC_COUNTER", "== #{current_subsystem_rec+23}", wait_time)   # cmds = 17 cmds+(6xRUN/SET/ABORT)
      wait_check(target, full_pkt_name, "SCRIPT_ENGINE_ERR_COUNTER", "== #{current_subsystem_err+1}", wait_time)

      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_71", "== 0", wait_time)                    ## SE_STATE_READY = 0
      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_69", "== 0", wait_time)                    ## SE_STATE_READY = 0
      wait_check_raw(target, full_pkt_name, "SCRIPT_ENGINE_STATES_70", "== 0", wait_time)                    ## SE_STATE_READY = 0
  end
end