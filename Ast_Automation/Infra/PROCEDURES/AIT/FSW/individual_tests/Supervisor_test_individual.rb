load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_Telem.rb')
load('Operations/FSW/UTIL_CmdSender.rb')
load("Operations/FSW/FSW_CSP.rb")

def check_task_count(collector_list, realtime_dest, tlm_mod_instance, apc_count, fc_count, dpc_count)
  collector_list.each do | collector |
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
	full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    if collector[:board] == "APC_YP" || collector[:board] == "APC_YM"
        check("BW3", full_pkt_name, "SUPERVISOR_TASK_COUNT", "== #{apc_count}")
    elsif collector[:board] == "FC_YP" || collector[:board] == "FC_YM"
        check("BW3", full_pkt_name, "SUPERVISOR_TASK_COUNT", "== #{fc_count}")
    else
        check("BW3", full_pkt_name, "SUPERVISOR_TASK_COUNT", "== #{dpc_count}")
    end
  end
  status_bar("test_task_count")
end

def check_task_status(collector_list, tlm_mod_instance, realtime_dest, apc_status, fc_status, dpc_status)
  collector_list.each do | collector |
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
	full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    if collector[:board] == "APC_YP"
      for i in 0..24 do
        wait_check("BW3", full_pkt_name, "SUPERVISOR_TASK_STATUS_#{i}", "== #{apc_status[i]}",10)
      end
    elsif collector[:board] == "FC_YP"
      for i in 0..14 do
        wait_check("BW3", full_pkt_name, "SUPERVISOR_TASK_STATUS_#{i}", "== #{fc_status[i]}",10)
      end
    else
      for i in 0..10 do
        wait_check("BW3", full_pkt_name, "SUPERVISOR_TASK_STATUS_#{i}", "== #{dpc_status[i]}",10)
      end
    end
  end
  status_bar("test_task_status")
end

def check_failed_count(collector_list, tlm_mod_instance, realtime_dest, fail_count)
  collector_list.each do | collector |
    tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 1)
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
	wait("BW3", full_pkt_name, "SUPERVISOR_FAILED_TASK_COUNT", "< #{fail_count}", 10)
  end
  status_bar("test_failed_task_count")
end