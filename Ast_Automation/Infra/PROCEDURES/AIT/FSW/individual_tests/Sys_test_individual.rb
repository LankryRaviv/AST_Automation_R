load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")
load("TestRunnerUtils/test_case_utils.rb")

def check_uptimes(collector_list, cmd_sender)
  collector_list.each do | collector |
    puts "Checking #{collector[:board]} system info"
    initial_uptime = cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "UPTIME_IN_S")
    initial_bootcount = cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "BOOTCOUNT")
    puts "init uptime: #{initial_uptime}\n\n"
    # Wait 10 seconds
    wait(10)
    final_uptime = cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "UPTIME_IN_S")
    puts "final uptime: #{final_uptime}\n\n"
    final_bootcount = cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "BOOTCOUNT")
    # Uptime should be about 30 seconds more, hard to get exact timing with
    # COSMOS delays task frequency of 1hz
    check_expression("#{final_uptime} >= #{initial_uptime + 10} && #{final_uptime} <= #{initial_uptime + 11}")
    check_expression("#{initial_bootcount} == #{final_bootcount}")
  end
  status_bar("test_uptime")
end

def check_cpu_utilization(collector_list, cmd_sender, max_util_percent)
  collector_list.each do | collector |
    idle_percentage = cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "IDLE_CLOCK")
    cpu_percentage = 100 - idle_percentage
    check_expression("#{cpu_percentage} < #{max_util_percent}")
  end
  status_bar("test_cpu_percentage")
end