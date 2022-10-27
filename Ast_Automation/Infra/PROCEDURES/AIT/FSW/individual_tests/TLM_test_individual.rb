load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/FSW_Telem.rb'
load 'Operations/FSW/FSW_CSP.rb'

def set_realtime_on(collector_list, tlm_mod_instance, cmd_sender, process_delay, check_delay, target, point_to_check)
  status_bar("test_realtime_on")
  collector_list.each do | board |
    board[:pkts].each do | pkt |
      tlm_mod_instance.set_realtime(board[:board_name], pkt[:name], board[:destination_csp_id], 1)
      # Wait for the telemetry vendor to process the command
      wait(process_delay)
      # Give the system enough time to send/not send telem packets
      current_recv_count = cmd_sender.get_current_val(board[:board_name], pkt[:name], point_to_check)
      wait(check_delay)
      # Check for the condition to be met
      full_pkt_name = CmdSender.get_full_pkt_name(board[:board_name], pkt[:name])
      comparison = ">"
      check(target, full_pkt_name, point_to_check, "#{comparison} #{current_recv_count}")
    end
  end
end

def set_realtime_off(collector_list, tlm_mod_instance, cmd_sender, process_delay, check_delay, target, point_to_check)
  status_bar("test_realtime_off")
  collector_list.each do | board |
    board[:pkts].each do | pkt |
      tlm_mod_instance.set_realtime(board[:board_name], pkt[:name], board[:destination_csp_id], 0)

      # Wait for the telemetry vendor to process the command
      wait(process_delay)
      # Give the system enough time to send/not send telem packets
      current_recv_count = cmd_sender.get_current_val(board[:board_name], pkt[:name], point_to_check)
      wait(check_delay)
      # Check for the condition to be met
      full_pkt_name = CmdSender.get_full_pkt_name(board[:board_name], pkt[:name])
      comparison = "=="
      check(target, full_pkt_name, point_to_check, "#{comparison} #{current_recv_count}")
  	end
  end
end

def check_instantaneous_tlm(collector_list, tlm_mod_instance)
  status_bar("test_instantaneous_tlm")
  collector_list.each do | board |
    board[:pkts].each do | pkt |
      tlm_mod_instance.send_instantaneous_tlm(board[:board_name], pkt[:name], board[:destination_csp_id])
    end
  end
end

def set_temp_realtime_on(collector_list, tlm_mod_instance, cmd_sender, process_delay, check_delay, point_to_check, target, misses_allowed, ms_duration, s_duration)
  status_bar("test_temp_realtime_on")

  # Turn temp telem on for every packet at 1 Hz for 100 seconds
  collector_list.each do | board |
    board[:pkts].each do | pkt |
      pkt[:count] = cmd_sender.get_current_val(board[:board_name], pkt[:name], point_to_check)
      # Calculate the number of anticipated packets we should receive
      for num_added_pkts in 1...200 do
        if (ms_duration - (num_added_pkts * (1000/pkt[:freq])) < (1000/pkt[:freq]))
          pkt[:expected_pkts] = pkt[:count] + num_added_pkts
          break
        end
      end

      puts "\n\n#{pkt[:name]} current pkts = #{pkt[:count]}, expected pkts = #{pkt[:expected_pkts]}\n\n"
      tlm_mod_instance.set_temp_realtime(board[:board_name], pkt[:name], board[:destination_csp_id], pkt[:freq], ms_duration)
      wait(process_delay)
    end
  end

  status_bar("waiting for packets to come in from temp realtime")
  puts "waiting for packets to come in from temp realtime"
  wait(s_duration + check_delay) # Wait the entire duration temp realtime should be on, plus the neccessary delays

  collector_list.each do | board |
    board[:pkts].each do | pkt |
      # Check for the condition to be met
      full_pkt_name = CmdSender.get_full_pkt_name(board[:board_name], pkt[:name])
      count = tlm(target, full_pkt_name, point_to_check)
      check_expression("#{count} >= #{pkt[:expected_pkts]} - #{misses_allowed} && #{count} <= #{pkt[:expected_pkts]}")

    end
  end
end

def check_tlm_stability(collector_list, tlm_mod_instance, realtime_dest, target, freq, duration_ms, misses_allowed)
  collector_list.each do | collector |
      wait(2)
      # Step 1 - Turn on live telem and set period to zero, should not get any more telem
      tlm_mod_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 0)

      # Wait for any outstanding packets to clear out
      wait(3)

      # Check current count
      full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
      collector[:start_recv] = tlm(target, full_pkt_name, "RECEIVED_COUNT")
      puts "Starting at #{collector[:start_recv]}"

      # Step 3 - Calculate the expected number of packets we should receive
      for num_added_pkts in 1...3000 do
        if (duration_ms - (num_added_pkts * (1000/freq)) < (1000/freq))
            collector[:expected_pkts] = num_added_pkts
            collector[:end_recv] = collector[:start_recv] + num_added_pkts
            break
        end
      end

      # Step 4 - Set period and wait for expected number of packets
      tlm_mod_instance.set_temp_realtime(collector[:board], collector[:pkt_name], realtime_dest, freq, duration_ms)
  end

  # Wait a little longer than needed to be sure
  wait((duration_ms / 1000.0) + 10)

  # Step 4 - Collect results
  collector_list.each do |collector |
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    collector[:end_recv] = tlm(target, full_pkt_name, "RECEIVED_COUNT")
    puts "#{collector[:pkt_name]}: #{collector[:end_recv]-collector[:start_recv]} / #{collector[:expected_pkts]}"
  end

  # Validate results
  collector_list.each do |collector |
    check_expression("#{collector[:end_recv] - collector[:start_recv]} >= #{collector[:expected_pkts]} - #{misses_allowed} && #{collector[:end_recv] - collector[:start_recv]} <= #{collector[:expected_pkts]}")
  end
  status_bar("test_realtime_on")
end