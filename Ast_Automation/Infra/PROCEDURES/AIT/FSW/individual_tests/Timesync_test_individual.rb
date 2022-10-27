load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")

def get_board_timestamps(collector_list, cmd_sender)
    collector_list.each do | collector |
      # Get the current time from the timestamp for comparison in next command.
      cmd_sender.send(collector[:board], "GET_TIMESTAMP", {})
      wait(1)
      # Ensure time is increasing to reflect the value of the get changing.
      cmd_sender.send_with_wait_check(collector[:board], "GET_TIMESTAMP", {}, collector[:pkt_name], "UNIX_TIMESTAMP", ">", 1)
    end
    status_bar("test_get_timestamp")
end

def measure_timesync_accuracy(collector_list, command_sender, target)
  	curr_times = [0, 0, 0, 0, 0, 0, 0]
  	time_index = 0
  	total_iterations = 0
    pkt_failure = 0
	
	collector_list.each do | collector |
		command_sender.send(collector[:board], "FORCE_TIMESYNC", {})
	end
	
  	while total_iterations < 5
  		time_since_last = Time.now
  		collector_list.each do | collector |
        prev_rxd_time = command_sender.get_current_val(collector[:board], collector[:pkt_name], "UNIX_TIMESTAMP")
        command_sender.send(collector[:board], "GET_TIMESTAMP", {})
		wait(1)
        curr_rxd_time = command_sender.get_current_val(collector[:board], collector[:pkt_name], "UNIX_TIMESTAMP")

        if curr_rxd_time != prev_rxd_time
          curr_times[time_index] = command_sender.get_current_val(collector[:board], collector[:pkt_name], "UNIX_TIMESTAMP")

    			full_pkt_name = collector[:board] + "-" + collector[:pkt_name]
    			if time_index > 0
    				# Use the local time to calculate the time offset between the prev. board's timestamp and the current board's timestamp
    				time_since_last_loop = Time.now - time_since_last

    				# Now, check that the current board's time is within +/-100ms of the previous board's offsetted time.
    				check(target, full_pkt_name, "UNIX_TIMESTAMP", "< #{curr_times[time_index - 1] + time_since_last_loop + 0.25}")
    				check(target, full_pkt_name, "UNIX_TIMESTAMP", "> #{curr_times[time_index - 1] + time_since_last_loop - 0.25}")
    			end

    			time_index = time_index + 1
        else
          pkt_failure = 1
        end

  			time_since_last = Time.now
  		end

  		time_index = 0
      if pkt_failure == 0
  		  total_iterations = total_iterations + 1
      end
  	end
  	status_bar("test_timesync_msec")
end

def timesync_health_test_12hr(collector_list, cmd_sender, target)
  # Get user input on the query frequency, test duration.
  query_freq = (ask("Enter query period in minutes"))
  total_iterations = (ask("Enter test duration in hours") * 60) / query_freq

  while (total_iterations > 0)
    # Retrieve timesync status information from all boards.
    collector_list.each do | collector |
      cmd_sender.send(collector[:board], "GET_TIMESYNC_INFO", {})
    end

    # Wait 10 minutes.
    total_iterations = total_iterations - 1
    if (total_iterations > 0)
      wait(query_freq * 60) 
    end
  end
end