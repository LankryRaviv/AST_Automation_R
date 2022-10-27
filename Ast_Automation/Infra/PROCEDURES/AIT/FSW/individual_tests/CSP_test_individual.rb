load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/FSW_Telem.rb' 
load 'Operations/FSW/FSW_CSP.rb'

def ping_collectors (collector_list, csp_module_instance)
  collector_list.each do | collector |
    csp_module_instance.ping(collector[:board])
  end
  status_bar("test_ping")
end

def reboot_collectors (collector_list, csp_module_instance, telem_module_instance, cmd_sender, check_delay, realtime_destination)
    collector_list.each do | collector |
      # Turn on FSW telemetry to get current boot count
      if collector[:board] == "APC_YP"
        telem_module_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_destination, 1)
      else
        telem_module_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_destination, 1)
      end
      wait(check_delay)
      initial_bootcount = cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "BOOTCOUNT")
      # Reboot and wait for startup
      csp_module_instance.reboot(collector[:board], true)
      wait(5)

      # Turn FSW telem back on and check boot count
      if collector[:board] == "APC_YP"
        telem_module_instance.set_realtime(collector[:board], "FSW_TLM_APC", realtime_destination, 1)
      elsif collector[:board] == "FC_YP"
        telem_module_instance.set_realtime(collector[:board], "FSW_TLM_FC", realtime_destination, 1)
      else
        telem_module_instance.set_realtime(collector[:board], "FSW_TLM_DPC", realtime_destination, 1)
      end
      wait(check_delay)
      final_bootcount = cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "BOOTCOUNT")
      check_expression("#{final_bootcount} == #{initial_bootcount + 1}")
    end
    status_bar("test_reboot")
  end