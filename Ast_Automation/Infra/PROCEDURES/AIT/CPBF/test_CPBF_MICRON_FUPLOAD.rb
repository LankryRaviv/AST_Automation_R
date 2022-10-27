load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/ast_test_base.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'
load_utility('TestRunnerUtils/test_case_utils.rb')
load "Operations/CPBF/CPBF_Telem.rb"
load 'Operations/Micron/Micron_FS.rb'
load_utility("Operations/Micron/MICRON_MODULE")

class TestCPBFMicronFUpload < ASTCOSMOSTestCPBF
  ## ERROR CODES
  SUCCESS = 0
  EMPTY   = 55
  BUSY    = -4
  FORMATTING = 120
  
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @cpbf = ModuleCPBF.new
    @micronfs = MicronFS.new
    @micron = MICRON_MODULE.new
    @link = "MIC_HSL"
    @test_util = ModuleTestCase.new
    super()
  end

  def setup
    @micron_list = ask_string("Enter the Micron ID(s) as a comma separated list")
    @link = combo_box("Enter the Link", 'MIC_LSL', 'MIC_HSL')
    @file_id = ask("Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    # These entry variables can be calculated if we instead ask the user which file will be used
    # or offer a file selection dialog, and calculate the number of entries and entry size based on the 
    # file size. Future work
    @entries_qty = ask("Enter the quantity of entries")
    @entry_size = ask("Enter the entry size")
    # @cpbf.start_soh_tlm()
    status_bar("setup")
    start_logging("ALL","CPBF_MICRON_FUPLOAD")
    Cosmos::Test.puts("Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}")
  end

  def test_file_info()
    err_count = 0
    err_msg = ""
    if @micron_list.nil?
      @micron_list = ask_string("Test File Info: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("File Info: Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    end
    microns = @micron_list.split(",")
    microns.each do |micron_id|
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}", 
        "FILE_ID": @file_id, 
      }
      if @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FILE_INFO",cmd_params,"MIC_FILE_INFO_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FILE_INFO_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_info_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        mic_status = mic_info_res["MIC_STATUS"]
        if mic_info_req_status == 0
          mic_file_status = mic_info_res["MIC_FILE_STATUS"]
          Cosmos::Test.puts("MIC file info results for #{mic_info_res["MICRON_ID"]}")
          Cosmos::Test.puts("MIC_STATUS = #{mic_info_res["MIC_STATUS"]}")
          Cosmos::Test.puts("MIC_FILE_STATUS = #{mic_info_res["MIC_FILE_STATUS"]}")
          Cosmos::Test.puts("MIC_LAST_ENTRY_ID = #{mic_info_res["MIC_LAST_ENTRY_ID"]}")
          Cosmos::Test.puts("MIC_TOTAL_ENTRIES = #{mic_info_res["MIC_TOTAL_ENTRIES"]}")
          Cosmos::Test.puts("MIC_CELL_SIZE = #{mic_info_res["MIC_CELL_SIZE"]}")
          Cosmos::Test.puts("MIC_USED_CELLS = #{mic_info_res["MIC_USED_CELLS"]}")
          Cosmos::Test.puts("MIC_MAX_CELLS = #{mic_info_res["MIC_MAX_CELLS"]}")
          Cosmos::Test.puts("MIC_SECTOR_QTY = #{mic_info_res["MIC_SECTOR_QTY"]}")
          Cosmos::Test.puts("MIC_SECTOR_SIZE = #{mic_info_res["MIC_SECTOR_SIZE"]}")
          Cosmos::Test.puts("MIC_FILE_TYPE = #{mic_info_res["MIC_FILE_TYPE"]}")
          Cosmos::Test.puts("MIC_FILE_NAME = #{mic_info_res["MIC_FILE_NAME"]}")
          if [0, -2].include? mic_file_status
            Cosmos::Test.puts("MIC_FILE_INFO_CMD file_status was #{mic_file_status} - continuing with format request")
          else
            Cosmos::Test.puts("ERROR: MIC_FILE_INFO_CMD file status was #{mic_file_status} - continuing with next Micron")
            err_count += 1
          end
        else
          Cosmos::Test.puts("ERROR: MIC_FILE_INFO_RES status from Micron #{micron_id} was #{mic_status} - unknown error, continuing to next micron.")
          err_count += 1
        end
      else
        Cosmos::Test.puts("ERROR: Unable to retrieve MIC_FILE_INFO_RES packet from Micron #{micron_id}")
        err_count += 1
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in File Info test. See logfile."
    end
    return err_count, err_msg
  end

  def test_file_format()
    err_count = 0
    err_msg = ""
    if @micron_list.nil?
      @micron_list = ask_string("Test File Info: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("File Info: Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    end
    if @entries_qty.nil?
      @entries_qty = ask("Enter the quantity of entries")
    end
    if @entry_size.nil?
      @entry_size = ask("Enter the entry size")
    end
    microns = @micron_list.split(",")
    microns.each do |micron_id|
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}",
        "FILE_ID": @file_id,
        "STATUS": 0,
        "ENTRIES_QTY": @entries_qty,
        "ENTRY_SIZE": @entry_size
      }
      @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FILE_FORMAT",cmd_params,"MIC_FILE_FORMAT_RES",1000,30,3)
      full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FILE_FORMAT_RES")
      res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
      mic_info_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
      Cosmos::Test.puts("MIC_FILE_FORMAT status was #{mic_info_res["MIC_STATUS"]} on first poll")
    
      # Check whether format was successful
      format_timeout = 5 * 60
      poll_interval = 1
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      status = false
      while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < format_timeout
        Cosmos::Test.puts("polling file info")
        cmd_params = {
          "MICRON_ID": "MICRON_#{micron_id}", 
          "FILE_ID": @file_id, 
        }
        @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FILE_INFO",cmd_params,"MIC_FILE_INFO_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FILE_INFO_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_info_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        info_request_status = mic_info_res["MIC_STATUS"]
        puts("info request status is #{info_request_status}")
        if info_request_status == BUSY
          Cosmos::Test.puts("MIC_FILE_INFO status was #{info_request_status} - file busy formatting")

        elsif info_request_status == SUCCESS
          Cosmos::Test.puts("MIC_FILE_INFO status was #{info_request_status} - formatting complete. confirming file info request file status is 0")
          status =  true
          break

        elsif info_request_status == EMPTY
          Cosmos::Test.puts("MIC_FILE_INFO status was #{info_request_status} - file empty. confirming file info request file status is 0")
          res_pkt_raw = get_tlm_packet(@target, full_pkt_name, value_types = :RAW)
          mic_info_res_raw = (res_pkt_raw.map {|item| [item[0], item[1]]}.to_h)
          info_request_file_status = mic_info_res_raw["FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
          if info_request_file_status == SUCCESS
            status = true
            Cosmos::Test.puts("MIC_FILE_INFO file_status for Micron #{micron_id} was #{info_request_file_status} - continue with upload")
            break
          else
            Cosmos::Test.puts("MIC_FILE_INFO file_status for Micron #{micron_id} was #{info_request_file_status} - aborting")
            break
          end
        else
          Cosmos::Test.puts("MIC_FILE_INFO status for Micron #{micron_id} was #{info_request_status} - unknown error (STEP 3), aborting")
          break
        end

        sleep(poll_interval)
      end

      if status != true
        Cosmos::Test.puts("ERROR: Formatting failed")
        err_count += 1
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in File Format test. See logfile."
    end
    return err_count, err_msg
  end

  def test_file_upload()
    err_count = 0
    err_msg = ""
    if @start_entry.nil?
      @start_entry = ask("File Upload to Micron: Enter the file start entry")
    end
    if @end_entry.nil?
      @end_entry = ask("Enter the file end entry")
    end
    if @period.nil?
      @period = ask("Enter the period between packets in ms")
    end
    if @max_fu_duration.nil?
      @max_fu_duration = ask("Enter the file transfer duration before timeout in seconds")
    end
    if @file_id.nil?
      @file_id = ask("Enter the file ID")
    end
    @cpbf.upload_file_to_microns(@start_entry, @end_entry, @period, @max_fu_duration, @file_id)
    #add loop to check file upload status
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    # arbitrary polling period, can adjust
    wait(5)
    while (Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < @max_fu_duration)
      @cpbf.get_mic_fileul_status()
      full_pkt_name = CmdSender.get_full_pkt_name("CPBF", "CPBF_MIC_FILEUL_STATUS_RES")
      res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
      mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
      status = mic_res["CPBF_STATUS"]
      sent_entries = mic_res["CPBF_SENT_ENTRIES"]
      total_entries = mic_res["CPBF_TOTAL_ENTRIES"]
      missed_entries = mic_res["CPBF_MISSED_ENTRIES"]
      status_line = "Status is #{status}, sent_entries=#{sent_entries}, missed_entries=#{missed_entries}, total_entries=#{total_entries}"
      if status.eql? "DONE"
        # done, check entry counts
        if total_entries == sent_entries + missed_entries
          Cosmos::Test.puts("CPBF to Micron File Upload completed. #{status_line}")
		      break
          #test_file_info() #not required here
        else
          Cosmos::Test.puts("ERROR: CPBF to Micron File Upload completed, but entry counts mismatched. #{status_line}")
          err_count += 1
          break
        end
      elsif status.eql? "IDLE"
        # idle, maybe didn't start?
        Cosmos::Test.puts("ERROR: CPBF to Micron File Upload did not start. #{status_line}")
        err_count += 1
        break
      elsif status.eql? "TIMEOUT"
        Cosmos::Test.puts("ERROR: CPBF to Micron File Upload timed out. #{status_line}")
        err_count += 1
        break
      elsif status.eql? "PROGRESS"
        Cosmos::Test.puts("CPBF to Micron File Upload still in progress. #{status_line}")
        # arbitrary polling period, can adjust
        wait(5)
      else
        Cosmos::Test.puts("ERROR: CPBF to Micron File Upload unknown response. #{status_line}")
        err_count += 1
        break
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in File Upload test. See logfile."
    end
    return err_count, err_msg
  end

  def test_file_check(max_entries_per_block=225)
    err_count = 0
    err_msg = ""
    if @micron_list.nil?
      @micron_list = ask_string("Test File Check: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("File Check: Enter the file ID to check. This should be 25 for the Micron FPGA firmware.")
    end
    if @entries_qty.nil?
      @entries_qty = ask("Enter the entries quantity")
    end
    microns = @micron_list.split(",")
    entries_per_block = max_entries_per_block * 8
    start_entry = 1
    microns.each do |micron_id|
      while start_entry < @entries_qty
        end_entry = start_entry + entries_per_block - 1 
        if (end_entry > @entries_qty)
          end_entry = @entries_qty
        end
        cmd_params = {
          "MICRON_ID": "MICRON_#{micron_id}", 
          "FILE_ID": @file_id, 
          "STATUS": 0,
          "ASPECT": "PRESENCE",
          "START_ENTRY_ID": start_entry,
          "END_ENTRY_ID": end_entry
        }
        @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FILE_CHECK",cmd_params,"MIC_FILE_CHECK_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FILE_CHECK_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_check_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        file_check_bitfield = mic_check_res["MIC_ENTRY_BITFIELD"]
        Cosmos::Test.puts("MIC file check results for #{mic_check_res["MICRON_ID"]}")
        Cosmos::Test.puts("MIC_STATUS = #{mic_check_res["MIC_STATUS"]}")
        Cosmos::Test.puts("MIC_ASPECT = #{mic_check_res["MIC_ASPECT"]}")
        Cosmos::Test.puts("MIC_START_ENTRY = #{mic_check_res["MIC_START_ENTRY"]}")
        Cosmos::Test.puts("MIC_END_ENTRY = #{mic_check_res["MIC_END_ENTRY"]}")
        missing_entries = @micronfs.interpet_file_check_bitfield("PRESENCE", (end_entry-start_entry)+1, file_check_bitfield)
        if missing_entries.length == 0
          cmd_params = {
            "MICRON_ID": "MICRON_#{micron_id}", 
            "FILE_ID": @file_id, 
            "STATUS": 0,
            "ASPECT": "CRC",
            "START_ENTRY_ID": start_entry,
            "END_ENTRY_ID": end_entry
          }
          @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FILE_CHECK",cmd_params,"MIC_FILE_CHECK_RES",1000,30,3)
          full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FILE_CHECK_RES")
          res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
          mic_check_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
          file_check_bitfield = mic_check_res["MIC_ENTRY_BITFIELD"]
          incorrect_entries = @micronfs.interpet_file_check_bitfield("CRC", (end_entry-start_entry)+1, file_check_bitfield)
          if incorrect_entries.length > 0
            Cosmos::Test.puts("ERROR: Entries with invalid CRC in target #{incorrect_entries} for Micron #{micron_id}")
            err_count += 1
          else
            Cosmos::Test.puts("All checked entries are present and correct for Micron #{micron_id}")
          end
        else
          Cosmos::Test.puts("ERROR: Entries missing in target #{missing_entries} for Micron #{micron_id}")
          err_count += 1
        end
        start_entry += entries_per_block
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in File Check test. See logfile."
    end
    return err_count, err_msg
  end

  def test_fpga_check_pre_install()
    err_count = 0
    err_msg = ""
    if @micron_list.nil?
      @micron_list = ask_string("Test FPGA Check Pre Install: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("File Info: Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    end
    check_status_wait = 120
    microns = @micron_list.split(",")
    microns.each do |micron_id|
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}",
        "CRC_CHECK_DEST": "FILE_SYSTEM",
        "FPGA_IMAGE_TYPE": "MAIN",
        "FILE_ID": @file_id
      }
      @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FPGA_CHECK",cmd_params,"MIC_FPGA_CHECK_RES",1000,30,3)
      full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FPGA_CHECK_RES")
      res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
      mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
      Cosmos::Test.puts("MIC FPGA Check results for Micron #{micron_id}")
      Cosmos::Test.puts("MIC_RESULT_CODE = #{mic_res["MIC_RESULT_CODE"]}")
      if mic_res["MIC_RESULT_CODE"] != "SUCCESS"
        Cosmos::Test.puts("ERROR: MIC FPGA Check command was not successful for Micron #{mic_res["MICRON_ID"]}. Continuing with next Micron")
        next
      end
      # not sure how long it takes to run the FPGA check.  Can adjust this wait later
      wait(60)
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      status = true
      while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < check_status_wait && status
        cmd_params = {
          "MICRON_ID": "MICRON_#{micron_id}",
          "CRC_CHECK_DEST": "FILE_SYSTEM",
          "IMAGE_TYPE": "MAIN"
        }
        @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FPGA_CHECK_STATUS",cmd_params,"MIC_FPGA_CHECK_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FPGA_CHECK_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        crc_check_status = mic_res["MIC_CRC_CHECK_STATUS"]
        Cosmos::Test.puts("MIC FPGA Check Status results for Micron #{mic_res["MICRON_ID"]}")
        Cosmos::Test.puts("MIC_CRC_CHECK_STATUS = #{mic_res["MIC_CRC_CHECK_STATUS"]}")
        if crc_check_status.eql? "SUCCESS"
          Cosmos::Test.puts("Micron #{mic_res["MICRON_ID"]} passed FPGA image CRC check.")
          status = false
        elsif crc_check_status.eql? "IN_PROGRESS"
          Cosmos::Test.puts("FPGA image CRC Check still in progress for Micron #{mic_res["MICRON_ID"]}")
        elsif crc_check_status.eql? "FAIL"
          Cosmos::Test.puts("ERROR: FPGA image CRC Check failed for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron.")
          err_count += 1
          status = false
        else
          Cosmos::Test.puts("ERROR: FPGA image CRC Check unknown status #{crc_check_status} for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron.")
          err_count += 1
          status = false
        end
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in File FPGA Check Pre-install test. See logfile."
    end
    return err_count, err_msg
  end

  def test_file_install()
    err_count = 0
    err_msg = ""
    if @micron_list.nil?
      @micron_list = ask_string("Test File Install: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("File Check: Enter the file ID to check. This should be 25 for the Micron FPGA firmware.")
    end
    install_wait = 420
    file_info_wait = 180
    # we can script this to check each power state and command to PS2 as necessary
    microns = @micron_list.split(",")
    # for now, lets send install command to each micron, wait 7 minutes, then start
    # checking install results.  Optionally can do this serially, send install command, 
    # wait some timeout, and check results for each micron before proceeding to the next
    microns.each do |micron_id|
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}",
        "MIC_FPGA_FILE_ID": @file_id, 
        "IMAGE_TYPE": "MAIN"
      }
      @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FPGA_INSTALL",cmd_params,"MIC_FPGA_INSTALL_RES",1000,30,3)
      full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FPGA_INSTALL_RES")
      res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
      mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
      install_res = mic_res["MIC_RESULT_CODE"]
      Cosmos::Test.puts("MIC FPGA Install result for Micron #{mic_res["MICRON_ID"]}")
      Cosmos::Test.puts("MIC_RESULT_CODE = #{mic_res["MIC_RESULT_CODE"]}")
      if ['POWER_MODE_MISMATCH', "GENERAL_ERROR"].include?(install_res)
        Cosmos::Test.puts("ERROR: MIC #{micron_id} Install result is not SUCCESS or INSTALL_IN_PROGRESS. Continuing with next micron")
        err_count += 1
        next
      end
    end
    puts("Waiting #{install_wait} before checking installation status")
    wait(install_wait)
    # now check each micron's install status
    microns.each do |micron_id|
      
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      status = true
      # Loop until install status = SUCCESS, for now give it a 3 minute wait. Wait can 
      # be parameterized if desired
      while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < file_info_wait && status
        Cosmos::Test.puts("polling FPGA file info")
        cmd_params = {
          "MICRON_ID": "MICRON_#{micron_id}",
          "IMAGE_TYPE": "MAIN"
        }
        @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FPGA_INFO",cmd_params,"MIC_FPGA_INFO_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FPGA_INFO_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        install_status = mic_res["MIC_INSTALL_STATUS"]
        Cosmos::Test.puts("MIC FPGA Install result for Micron #{mic_res["MICRON_ID"]}")
        Cosmos::Test.puts("MIC_INSTALL_STATUS = #{mic_res["MIC_INSTALL_STATUS"]}")
        if install_status.eql? "SUCCESS"
          Cosmos::Test.puts("Installation successful for Micron #{mic_res["MICRON_ID"]}")
          status = false
        elsif install_status.eql? "INSTALL_IN_PROGRESS"
          Cosmos::Test.puts("Installation still in progress for Micron #{mic_res["MICRON_ID"]}")
          # arbitrary wait time between retries
          wait(20)
        elsif install_status.eql? "INSTALL_FAIL"
          Cosmos::Test.puts("ERROR: Installation failed for Micron #{mic_res["MICRON_ID"]}. Continuing with next Micron")
          err_count += 1
          status = false
        else
          # there is an INSTALL_IDLE value, not sure how to handle this
          Cosmos::Test.puts("ERROR: Unknown installation status #{install_status} for Micron #{mic_res["MICRON_ID"]}. Continuing with next Micron")
          err_count += 1
          status = false
        end
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in File Install test. See logfile."
    end
    return err_count, err_msg
  end

  def test_fpga_check_post_install()
    err_count = 0
    err_msg = ""
    if @micron_list.nil?
      @micron_list = ask_string("Test FPGA Check: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("File Info: Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    end
    check_status_wait = 120
    microns = @micron_list.split(",")
    microns.each do |micron_id|
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}",
        "CRC_CHECK_DEST": "FPGA_NOR",
        "FPGA_IMAGE_TYPE": "MAIN",
        "FILE_ID": @file_id
      }
      @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FPGA_CHECK",cmd_params,"MIC_FPGA_CHECK_RES",1000,30,3)
      full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FPGA_CHECK_RES")
      res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
      mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
      Cosmos::Test.puts("MIC FPGA Check results for Micron #{mic_res["MICRON_ID"]}")
      Cosmos::Test.puts("MIC_RESULT_CODE = #{mic_res["MIC_RESULT_CODE"]}")
      if mic_res["MIC_RESULT_CODE"] != "SUCCESS"
        Cosmos::Test.puts("ERROR: MIC FPGA Check command was not successful for Micron #{mic_res["MICRON_ID"]}. Continuing with next Micron")
        err_count += 1
        next
      end
      # not sure how long it takes to run the FPGA check.  Can adjust this wait later
      wait(60)
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      status = true
      # very bad looping logic, may revisit later
      while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < check_status_wait && status
        cmd_params = {
          "MICRON_ID": "MICRON_#{micron_id}",
          "CRC_CHECK_DEST": "FPGA_NOR",
          "IMAGE_TYPE": "MAIN"
        }
        @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FPGA_CHECK_STATUS",cmd_params,"MIC_FPGA_CHECK_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FPGA_CHECK_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        crc_check_status = mic_res["MIC_CRC_CHECK_STATUS"]
        Cosmos::Test.puts("MIC FPGA Check Status results for Micron #{mic_res["MICRON_ID"]}")
        Cosmos::Test.puts("MIC_CRC_CHECK_STATUS = #{mic_res["MIC_CRC_CHECK_STATUS"]}")
        if crc_check_status.eql? "SUCCESS"
          Cosmos::Test.puts("Micron #{mic_res["MICRON_ID"]} passed FPGA image CRC check.")
          status = false
        elsif crc_check_status.eql? "IN_PROGRESS"
          Cosmos::Test.puts("FPGA image CRC Check still in progress for Micron #{mic_res["MICRON_ID"]}")
        elsif crc_check_status.eql? "FAIL"
          Cosmos::Test.puts("ERROR: FPGA image CRC Check failed for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron.")
          err_count += 1
          status = false
        else
          Cosmos::Test.puts("ERROR: FPGA image CRC Check unknown status #{crc_check_status} for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron.")
          err_count += 1
          status = false
        end
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in FPGA Check Post-Install test. See logfile."
    end
    return err_count, err_msg
  end

  def test_mic_reboot()
    err_count = 0
    err_msg = ""
    if @micron_list.nil?
      @micron_list = ask_string("Test Micron Reboot: Enter the Micron ID(s)")
    end
    microns = @micron_list.split(",")
    microns.each do |micron_id|
      @micron.sys_reboot(@link, "MICRON_#{micron_id}")
      Cosmos::Test.puts("Micron #{micron_id} has been rebooted.")
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in Micron Reboot test. See logfile."
    end
    return err_count, err_msg
  end

  def test_verify_fpga()
    # Currently unable to send the power mode commands over HSL, as the link is not available
    # after reseting the micron.  Try to send it over the LSL instead of the test setup supports it
    # link=@link
    link = "MIC_LSL"
    err_count = 0
    err_msg = ""
    
    if @micron_list.nil?
      @micron_list = ask_string("Test Verify FPGA version: Enter the Micron ID(s)")
    end
    microns = @micron_list.split(",")
    microns.each do |micron_id|
      get_power_mode_hash_converted = @micron.get_system_power_mode(link, "MICRON_#{micron_id}", true, false,wait_check_timeout=2)[0]
      power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
      if power_mode_status.eql? "PS2"
        Cosmos::Test.puts("Micron #{micron_id} is in PS2. Continuing with FPGA version check.")
      else
        Cosmos::Test.puts("Micron #{micron_id} is in #{power_mode_status}. Commanding to PS2 before continuing.")
        set_power_mode_hash_converted = @micron.set_system_power_mode(@link, "MICRON_#{micron_id}", "PS2", true, false,wait_check_timeout=2)[0]
        wait(2)        
        if set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"] != "SYSTEM_OK"
          Cosmos::Test.puts("ERROR: Micron Set Power mode was not set correctly.  Result is #{set_power_mode_hash_converted["MIC_SYSTEM_RESULT_CODE"]}. Continuing to next Micron.")
          err_count += 1
          next
        end
        get_power_mode_hash_converted = @micron.get_system_power_mode(link, "MICRON_#{micron_id}", true, false,wait_check_timeout=2)[0]
        power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
        if power_mode_status != "PS2"
          Cosmos::Test.puts("ERROR: Micron Set Power mode to PS2 was not successful. Continuing with next micron.")
          err_count += 1
          next
        end
      end
      
      # not sure how to retrieve FPGA version from Micron FPGA registers, need some help with this part
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in Verify FPGA test. See logfile."
    end
    return err_count, err_msg
  end

  def test_file_validity()
    errs = 0
    err_count = 0
    if @micron_list.nil?
      @micron_list = ask_string("File Validity: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("File Validity: Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    end
    microns = @micron_list.split(",")
    image_range = (0..2)
    validate_results = []
    microns.each do |micron_id|
      image_range.each do |image|
        cmd_params = {
          "MICRON_ID": "MICRON_#{micron_id}", 
          "IMAGE_TYPE": image 
        }
        if @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FIRMWARE_VALIDATE",cmd_params,"MIC_FIRMWARE_VALIDATE_RES",1000,30,3)
          full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FIRMWARE_VALIDATE_RES")
          res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
          mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
          validity_code = mic_res["MIC_FWUPD_ERROR_CODE"]
          validate_results.append(validity_code)
        else
          Cosmos::Test.puts("ERROR: Unable to retrieve MIC_FIRMWARE_VALIDATE_RES packet from Micron #{micron_id}. Continuing with next Micron.")
          err_count += 1
          next
        end
      end
    end
    if validate_results.count(0) == 3
      Cosmos::Test.puts("All images valid.  Proceed with firmware update.")
    else
      Cosmos::Test.puts("ERROR: One or more images contains an invalid signature.")
      Cosmos::Test.puts("L1 Validaty Code #{validate_results[0]}; L2 Validity Code #{validate_results[1]}; App Validity Code #{validate_results[2]}")
      err_count += 1
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in Verify Firmware test. See logfile.\n"
    end
    return err_count, err_msg
  end

  def test_firmware_install()
    errs = 0
    err_count = 0
    if @micron_list.nil?
      @micron_list = ask_string("Firmware Install: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("Firmware Install: Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    end
    if @image_type.nil?
      @image_type = combo_box("Firmware Install: Enter the firmware image type.", "bl1", "bl2", "app")
    end
    if @image_size.nil?
      size = ask("Enter the image size or path to image file.")
    else
      size = @image_size
    end
    if size.is_a? Integer
      @image_size = size
    else
      # user entered or passed in path to file
      @image_size = File.size(size)
    end  
    if (@image_type == "bl1")
      image_code = 0
    elsif (@image_type == "bl2")
      image_code = 1
    elsif (@image_type == "app")
      image_code = 2
    end
    microns = @micron_list.split(",")
    microns.each do |micron_id|
      # Step 1. Start with firmware info command
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}"
      }
      if @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FIRMWARE_INFO",cmd_params,"MIC_FIRMWARE_INFO_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FIRMWARE_INFO_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :RAW)
        mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        mcu_uid_0 = mic_res["MIC_MCU_UID_0"]
        mic_uid_1 = mic_res["MIC_MCU_UID_1"]
        mic_uid_2 = mic_res["MIC_MCU_UID_2"]
      else
        Cosmos::Test.puts("ERROR: Unable to retrieve MIC_FIRMWARE_INFO_RES packet from Micron #{micron_id}. Continuing with next Micron.")
        err_count += 1
        next
      end
      # Step 2. Send firmware start command and verify
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}",
        "IMAGE_TYPE": @image_code,
        "TARGET_MCU_1": mcu_uid_0,
        "TARGET_MCU_2": mcu_uid_1,
        "TARGET_MCU_3": mcu_uid_2,
        "IMAGE_SIZE": @image_size,
        "FROM_GOLDEN_STORAGE": 0
      }
      if @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FIRMWARE_START",cmd_params,"MIC_FIRMWARE_START_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FIRMWARE_START_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        fwupd_start_code = mic_res["MIC_FWUPD_ERROR_CODE"]
        if fwupd_start_code.eql? "FW_UPDATE_OK"
          Cosmos::Test.puts("Firmware update started for Micron #{micron_id}. Proceeding with firmware update.")
        else
          Cosmos::Test.puts("ERROR: Firmware update failed to start. Start code is #{fwupd_start_code}. Continuing with next Micron.")
          err_count += 1
          next
        end
      else
        Cosmos::Test.puts("ERROR: Unable to retrieve MIC_FIRMWARE_INFO_RES packet from Micron #{micron_id}. Continuing with next Micron.")
        err_count += 1
        next
      end
      # Step 3. Send firmware install command and verify
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}"
      }
      if @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FIRMWARE_INSTALL",cmd_params,"MIC_FIRMWARE_INSTALL_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FIRMWARE_INSTALL_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
        fwupd_install_code = mic_res["MIC_FWUPD_ERROR_CODE"]
        if fwupd_install_code.eql? "FW_UPDATE_OK"
          Cosmos::Test.puts("Firmware update installed. Firmware update complete for Micron #{micron_id}.")
        elsif fwupd_install_code.eql? "FW_UPDATE_RESTART_REQUIRED"
          Cosmos::Test.puts("Firmware update installed. Proceeding with restart for Micron #{micron_id}.")
        else
          Cosmos::Test.puts("Firmware update failed to start. Code is #{fwupd_install_code} for Micron #{micron_id}")
          err_count += 1
          next
        end
      else
        Cosmos::Test.puts("ERROR: Unable to retrieve MIC_FIRMWARE_INSTALL_RES packet from Micron #{micron_id}. Continuing with next Micron.")
        err_count += 1
        next
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in Firmware Install test. See logfile."
    end
    return err_count, err_msg
  end

  def test_verify_firmware()
    errs = 0
    err_count = 0
    if @micron_list.nil?
      @micron_list = ask_string("Verify Firmware Install: Enter the Micron ID(s)")
    end
    if @file_id.nil?
      @file_id = ask("Verify Firmware Install: Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    end
    if @image_type.nil?
      @image_type = combo_box("Verify Firmware Install: Enter the firmware image type.", "bl1", "bl2", "app")
    end
    if (@image_type == "bl1")
      image_code = 0
    elsif (@image_type == "bl2")
      image_code = 1
    elsif (@image_type == "app")
      image_code = 2
    end
    if @version_info.nil?
      major = ask("Enter the major version number")
      minor = ask("Enter the minor version number")
      patch = ask("Enter the patch version number")
      @version_info = {MAJOR: major, MINOR: minor, PATCH: patch}
    end
    microns = @micron_list.split(",")
    validate_results = []
    microns.each do |micron_id|
      cmd_params = {
        "MICRON_ID": "MICRON_#{micron_id}"
      }
      if @cpbf.send_cmd_get_micron_pkt(@link,micron_id,"MIC_FIRMWARE_INFO",cmd_params,"MIC_FIRMWARE_INFO_RES",1000,30,3)
        full_pkt_name = CmdSender.get_full_pkt_name(@link, "MIC_FIRMWARE_INFO_RES")
        res_pkt_converted = get_tlm_packet(@target, full_pkt_name, value_types = :CONVERTED)
        mic_res = (res_pkt_converted.map {|item| [item[0], item[1]]}.to_h)
      else
        Cosmos::Test.puts("ERROR: Unable to retrieve MIC_FIRMWARE_INFO_RES packet from Micron #{micron_id}. Continuing with next Micron.")
        err_count += 1
        next
      end
      if image_code == 0
        if mic_res["MIC_BOOT_L1_MAJOR"] == @version_info[:MAJOR] &&
           mic_res["MIC_BOOT_L1_MINOR"] == @version_info[:MINOR] &&
           mic_res["MIC_BOOT_L1_PATCH"] == @version_info[:PATCH]
           Cosmos::Test.puts("Bootloader L1 Firmware successfully upgraded for Micron #{micron_id}.")
        else
          Cosmos::Test.puts("ERROR: Bootloader L1 Firmware update failed for Micron #{micron_id}.")
          err_count += 1
          next
        end
      elsif image_code == 1
        if mic_res["MIC_BOOT_L2_MAJOR"] == @version_info[:MAJOR] &&
          mic_res["MIC_BOOT_L2_MINOR"] == @version_info[:MINOR] &&
          mic_res["MIC_BOOT_L2_PATCH"] == @version_info[:PATCH]
          Cosmos::Test.puts("Bootloader L2 Firmware successfully upgraded for Micron #{micron_id}.")
       else
         Cosmos::Test.puts("ERROR: Bootloader L2 Firmware update failed for Micron #{micron_id}.")
         err_count += 1
         next
       end
      elsif image_code == 2
        if mic_res["MIC_APP_MAJOR"] == @version_info[:MAJOR] &&
          mic_res["MIC_APP_MINOR"] == @version_info[:MINOR] &&
          mic_res["MIC_APP_PATCH"] == @version_info[:PATCH]
          Cosmos::Test.puts("Bootloader L1 Firmware successfully upgraded for Micron #{micron_id}.")
       else
         Cosmos::Test.puts("ERROR: Bootloader L1 Firmware update failed for Micron #{micron_id}.")
         err_count += 1
         next
       end
      end
    end
    if err_count > 0
      err_msg = "ERROR: #{err_count} Errors in Verify Firmware test. See logfile."
    end
    return err_count, err_msg
  end

  def test_complete_fpga_upload(micron_list=[], file_id=-1, link="", entries_qty=0,entry_size=0,start_entry=0,end_entry=0,period_ms=0,max_fu_duration=0)
    errs = 0
    err_arr = []
    if micron_list.empty?
      @micron_list = ask_string("Enter comma-delimited list of Micron ID(s)")
    else
      @micron_list = micron_list.join(",")
    end
    if link.eql? ""
      @link = combo_box("Enter the Link", 'MIC_LSL', 'MIC_HSL')
    else
      @link = link
    end
    if file_id == -1
      @file_id = ask("Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    else
      @file_id = file_id
    end
    if entries_qty == 0
      @entries_qty = ask("Enter the quantity of entries")
    else
      @entries_qty = entries_qty
    end
    if entry_size == 0
      @entry_size = ask("Enter the entry size")
    else
      @entry_size = entry_size
    end
    if start_entry == 0
      @start_entry = ask("Enter the file start entry")
    else
      @start_entry = start_entry
    end
    if end_entry == 0
      @end_entry = ask("Enter the file end entry")
    else
      @end_entry = end_entry
    end
    if period_ms == 0
      @period = ask("Enter the period between packets in ms")
    else
      @period = period_ms
    end
    if max_fu_duration == 0 
      @max_fu_duration = ask("Enter the file transfer duration before timeout in seconds")
    else
      @max_fu_duration = max_fu_duration
    end
    # 1. file info
    Cosmos::Test.puts("-------- Running File Info test --------")
    temp_err = test_file_info()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 2. file format
    Cosmos::Test.puts("-------- Running File Format test --------")
    temp_err = test_file_format()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 3. file upload to Micron
    Cosmos::Test.puts("-------- Running File Upload to Micron test --------")
    temp_err = test_file_upload()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 4. file check on Micron
    Cosmos::Test.puts("-------- Running File Check on Micron test --------")
    temp_err = test_file_check()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 5. fpga check pre-install
    Cosmos::Test.puts("-------- Running FPGA Pre-Install test --------")
    temp_err = test_fpga_check_pre_install()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 6. file install on each micron
    Cosmos::Test.puts("-------- Running File Install test --------")
    temp_err = test_file_install()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 7. fpga check post-install
    Cosmos::Test.puts("-------- Running FPGA Check Post-Install test --------")
    temp_err = test_fpga_check_post_install()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 8. micron reboot
    Cosmos::Test.puts("-------- Running Micron Reboot test --------")
    temp_err = test_mic_reboot()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 9. verify fpga version
    Cosmos::Test.puts("-------- Running Verify FPGA Version test --------")
    temp_err = test_verify_fpga()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    if errs > 0 
      raise TestException.new "Total of #{errs} Errors in the following tests:\n#{err_arr.join("\n")} Tests"
    end
  end

  def test_complete_firmware_upload(micron_list=[], file_id=-1, link="", entries_qty=0,entry_size=0,start_entry="",end_entry="",period_ms=0,image_type="",image_size=0,version_info={},max_fu_duration=0)
    errs = 0
    err_arr = []
    if micron_list.empty?
      @micron_list = ask_string("Enter comma-delimited list of Micron ID(s)")
    else
      @micron_list = micron_list.join(",")
    end
    if link.eql? ""
      @link = combo_box("Enter the Link", 'MIC_LSL', 'MIC_HSL')
    else
      @link = link
    end
    if file_id == -1
      @file_id = ask("Enter the file ID. This should be 25 for the Micron FPGA firmware.")
    else
      @file_id = file_id
    end
    if entries_qty == 0
      @entries_qty = ask("Enter the quantity of entries")
    else
      @entries_qty = entries_qty
    end
    if entry_size == 0
      @entry_size = ask("Enter the entry size")
    else
      @entry_size = entry_size
    end
    if start_entry == 0
      @start_entry = ask("Enter the file start entry")
    else
      @start_entry = start_entry
    end
    if end_entry == 0
      @end_entry = ask("Enter the file end entry")
    else
      @end_entry = end_entry
    end
    if period_ms == 0
      @period = ask("Enter the period between packets in ms")
    else
      @period = period_ms
    end
    if image_type.eql? ""
      @image_type = combo_box("Enter the firmware image type.", "bl1", "bl2", "app")
    else
      @image_type = image_type
    end
    if image_size == 0
      size = ask("Enter the image size or path to image file.")
    else
      size = image_size
    end
    if size.is_a? Integer
      @image_size = size
    else
      # user entered or passed in path to file
      @image_size = File.size(size)
    end  
    if version_info.empty?
      major = ask("Enter the major version number")
      minor = ask("Enter the minor version number")
      patch = ask("Enter the patch version number")
      @version_info = {MAJOR: major, MINOR: minor, PATCH: patch}
    else
      @version_info = version_info
    end
    if max_fu_duration == 0
      @max_fu_duration = ask("Enter the file transfer duration before timeout in seconds")
    else
      @max_fu_duration = max_fu_duration
    end
    # 1. Check signature validity
    Cosmos::Test.puts("-------- Running File Validity test --------")
    temp_err = test_file_validity()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 1. file info
    Cosmos::Test.puts("-------- Running File Info test --------")
    temp_err = test_file_info()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 2. file format
    Cosmos::Test.puts("-------- Running File Format test --------")
    temp_err = test_file_format()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 3. file upload to Micron
    Cosmos::Test.puts("-------- Running File Upload to Micron test --------")
    temp_err = test_file_upload()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 4. file check on Micron
    Cosmos::Test.puts("-------- Running File Check on Micron test --------")
    temp_err = test_file_check()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 6. firmware install on each micron
    Cosmos::Test.puts("-------- Running Firmware Install test --------")
    temp_err = test_firmware_install()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 8. micron reboot
    Cosmos::Test.puts("-------- Running Micron Reboot test --------")
    temp_err = test_mic_reboot()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    # 9. verify fpga version
    Cosmos::Test.puts("-------- Running Verify Firmware Version test --------")
    temp_err = test_verify_firmware()
    errs += temp_err.first
    err_arr.append(temp_err[1])
    if errs > 0 
      raise TestException.new "Total of #{errs} Errors in the following tests:\n#{err_arr.join("\n")} Tests"
    end
  end

  def teardown()
    start_logging("ALL")
  end
  
 end




