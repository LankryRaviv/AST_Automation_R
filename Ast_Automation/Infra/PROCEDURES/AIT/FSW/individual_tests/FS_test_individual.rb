load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS_Continue_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")

def clear_file_on_boards(collector_list, telem_module_instance, fs_module_instance, harvester_id, tlm_file_id, realtime_dest)
  collector_list.each do | collector |
    # Turn off the 1 Hz Harvester and set the vendor freq to 0 so we can check for an empty file
    telem_module_instance.set_collection(collector[:board], harvester_id, 0, true)
    telem_module_instance.set_realtime(collector[:board], collector[:pkt_name], realtime_dest, 0)
    wait(7)

    # Clear the file and wait for operation to be complete
    fs_module_instance.file_clear(collector[:board], tlm_file_id)
    file_status = fs_module_instance.wait_for_file_ok(collector[:board], tlm_file_id, 60)
    # Check for nil first
    if file_status == nil
      check_expression("false")
    end
    check_expression("#{file_status} != ''")
    check_expression("#{file_status} == 55")
  end
  status_bar("test_file_clear")
end

def download_test_file(collector_list, tlm_mod_instance, fs_mod_instance, target, download_time, realtime_dest, tlm_file_id)
  collector_list.each do | collector |
    # Turn the harvestor on
    tlm_mod_instance.set_collection(collector[:board], 'HARVESTER_1_HZ', 1, true)
    # Wait 10 seconds
    wait(10)
    # Check current count
    full_pkt_name = CmdSender.get_full_pkt_name(collector[:board], collector[:pkt_name])
    current_recv = tlm(target, full_pkt_name, "RECEIVED_COUNT")
    fs_mod_instance.file_download(collector[:board], tlm_file_id, 1, 10, 0, 50, 900,1754)
    wait(15)
    # Check that we have exactly 10 more packets
    wait_check(target, full_pkt_name, "RECEIVED_COUNT", "== #{current_recv+10}", 2)
  end
  status_bar("test_file_download")
end

def upload_test_file(collector_list, entry_size, fw_file_id, bin_name, check_aspect)
  collector_list.each do | collector |
    FSW_FS_Upload(entry_size, fw_file_id, bin_name, collector[:board], check_aspect)
  end
  status_bar("test_file_upload")
end

def continue_upload_test_file(collector_list, entry_size, fw_file_id, bin_name, check_aspect)
  collector_list.each do | collector |
    FSW_FS_Upload(entry_size, fw_file_id, bin_name, collector[:board], check_aspect, "TEST")
    FSW_FS_Continue_Upload(entry_size, fw_file_id, bin_name, collector[:board], check_aspect)
  end
  status_bar("test_file_continue_upload")
end

def clear_some_files(collector_list, min_file_id, max_file_id, fs_mod_instance)
  collector_list.each do | collector |
    if ((min_file_id < 0) || (max_file_id < 0) || (min_file_id > max_file_id))
      check_expression("false")
    end
    file_id_check = min_file_id
    puts file_id_check
    loop do 
    # Clear the file and wait for operation to be complete
      fs_mod_instance.file_clear(collector[:board], file_id_check)
      file_status = fs_mod_instance.wait_for_file_ok(collector[:board], file_id_check, 30)
      puts file_status
      # Check for nil first
      if file_status == nil
        check_expression("false")
      end
      check_expression("#{file_status} != ''")
      check_expression("#{file_status} == 55 || #{file_status} == 63 ||  #{file_status} == 0")
      if (file_id_check == max_file_id)
          break
      end
      file_id_check += 1
    end
  end
  status_bar("test_file_clear_specific_ids")
end