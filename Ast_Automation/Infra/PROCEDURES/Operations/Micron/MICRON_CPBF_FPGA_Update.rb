load_utility('Operations/MICRON/MICRON_FS_Upload.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/CPBF/CPBF_MODULE.rb')
load_utility('Operations/CPBF/CPBF_FS_Upload.rb')
load_utility('Operations/MICRON/MICRON_FS.rb')
require 'zip'
require 'fileutils'

# This script will perform the following:
#  1) Check whether fpga_img file has correct filename (uc_fpga.bin), if not copy to this filename
#  2) zip file to uc_fpga.zip
#  3) Upload file to CPBF file id 9
#  4) Send CPBF command to unzip file
#  5) Verify unzip results are as expected
#  6) Format microns in prep for broadcasting
#  6) Send CPBF command to broadcast file to micron array over desired link (HSL or LSL)
#  7) Perform rest of FPGA install steps per normal install script, using LSL
def micron_cpbf_fpga_update(cpbf_to_mic_link, fpga_img, version_info, micron_list, entry_size: 1754, reboot: false, use_automations: false)
    # user can pass in single micron or array of microns
    if !micron_list.kind_of?(Array)
        micron_list_temp = micron_list
        micron_list.append(micron_list_temp)
    end

    # hardcode link value used for direct to micron commands to "MIC_LSL"
    link = 'MIC_LSL'

    err_arr = []
    failed_microns = []
    err_count = 0

    micron_module = MICRON_MODULE.new
    cpbf_module = ModuleCPBF.new
	fs = MicronFS.new
    # file id of fpga file on cpbf and microns
	file_id = 25

    # pre-step; Make sure CPBF responds to ping
    if !cpbf_module.cpbf_ping()
        # return special hash- {CPBF: "failed to contact CPBF"}
        err_msg = 'ERROR: Failed to contact CPBF'
        puts(err_msg)
        return false, { 'CPBF': err_msg }
    end

    ### Step 1 ###
    # Check whether fpga_img file has correct filename (uc_fpga.bin), if not copy to this filename
    if !File.file?(fpga_img)
        err_msg = "ERROR: Unable to locate file #{fpga_img}"
        return false, { 'CPBF': err_msg }
    end
    file_as_path = Pathname.new(fpga_img)
    expected_filename = 'uc_fpga.bin'
    file_size = File.size(file_as_path)
    file_dir, file_name = File.split(file_as_path)
    unless file_name == expected_filename
        # filename is not as it should be, copy file.  First delete any previous instance of uc_fpga.bin
        File.delete(File.join(file_dir, expected_filename)) if File.file?(File.join(file_dir, expected_filename))
        FileUtils.cp(file_as_path, File.join(file_dir, expected_filename))
    end

    ### Step 2 ###
    # uc_fpga.bin is present, now zip to uc_fpga.zip
    zip_file = File.join(file_dir, 'uc_fpga.zip')
    # delete zip file before recreating if exists
    File.delete(zip_file) if File.file?(zip_file)
        
    Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
        zipfile.add(expected_filename, File.join(file_dir, expected_filename))
    end

    # check that zip file now exists
    if !File.file?(zip_file)
        err_msg = 'ERROR: Failed to zip fpga image file'
        puts(err_msg)
        return false, { 'CPBF': err_msg }
    end
    puts('FPGA Image file zipped successfully.')


    ### STEP 3 ###
    # Upload zip file to CPBF
    # note that since this uses FSW utility, there is no true/false status returned from util
    unless CPBF_FS_Upload(1754, 9, zip_file)
        err_msg = 'ERROR: Failed to upload zipped image to CPBF.  See log for details'
        puts(err_msg)
        return false, { 'CPBF': err_msg }
    end
    puts('FPGA zipped file upload successful.')

    ### STEP 4 & 5 ###
    #  Send CPBF command to unzip file
    #  Verify unzip results
	
	cpbf_file_id = 25
	cpbf_res = cpbf_module.cpbf_prepare_micfw(cpbf_file_id)[0]
	
    if cpbf_res['RESPONSE_CODE'] != 'SUCCESS'
        err_msg = "ERROR: CPBF Prepare Micron Firmware response was not SUCCESS: #{cpbf_res['RESPONSE_CODE']}"
        puts(err_msg)
        return false, { 'CPBF': err_msg }
    end

#### AVIAD: I put the fie size check in a command, you can remove it.
	
#    # check file size.  Maybe don't need this, so remove if it doesn't work correctly
#    prep_res = cpbf_res['CPBF_PREP_MICFW_RESPONSE']
#    pre_byte_size = prep_res.split(':')[1]
#    pre_byte_size.strip!
#    byte_size = pre_byte_size.split(' ')[0]
#	puts "#{byte_size.to_i}"
#	puts "#{byte_size}"
#    if file_size != byte_size.to_i
#        err_msg = "ERROR: CPBF unzipped file size not equal to original file size: #{byte_size}"
#        puts(err_msg)
#        return false, { 'CPBF': err_msg }
#    end
    
    ### STEP 6 ###
    # Format microns
    entries_quantity = (file_size.to_f / entry_size.to_f).ceil
    puts("Entries quantity is #{entries_quantity}")
    # first loop will do a file info request followed by starting the file format
	micron_list.each do |micron_id|

        ##
        ## STEP 6-1 - FILE INFO REQUEST + RESPONSE      
        
        file_info_hash_converted, file_info_hash_raw = fs.file_info(link, micron_id, file_id, true, true)
        if file_info_hash_converted.nil?  
        err_msg = "ERROR: Micron #{micron_id} did not respond to File Info command."
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 6-1 File Info"])
        err_count += 1
        next
        end

        # check status and file_status before continuing with step 2 (format request)
        info_request_status = file_info_hash_converted["MIC_STATUS"]
        if info_request_status == 0
        puts "FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - status ok. confirming FILE_INFO_CMD file_status is 0"

        info_request_file_status = file_info_hash_raw["MIC_FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
        if info_request_file_status == 0 || info_request_file_status == -2
            puts "MIC_FILE_INFO_CMD file_status for Micron #{micron_id} was #{info_request_file_status} - continuing with format request"

        else
            err_msg= "ERROR: MIC_FILE_INFO_CMD file_status for Micron #{micron_id} was #{info_request_file_status} - unknown error, continuing with next micron"
            puts(err_msg)
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 6-1 File Info"])
            err_count += 1
            next
        end

        else
        err_msg = "ERROR: FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - unknown error, continuing with next micron"
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 6-1 File Info"])
        err_count += 1
        next
        end
        # calculate available space
        info_request_sector_qty = file_info_hash_converted["MIC_SECTOR_QTY"]
        info_request_sector_size = file_info_hash_converted["MIC_SECTOR_SIZE"]

        available_space = info_request_sector_qty * info_request_sector_size

        # check the file will actually fit
        if file_size > available_space
        err_msg = "ERROR: file size [#{file_size}] larger than available space [#{available_space}] for Micron #{micron_id}, continuing with next micron"
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 6-2 Format request"])
        err_count += 1
        next
        end
   
        file_format_hash_converted = fs.file_format(link, micron_id, file_id, entries_quantity, entry_size, true, false)[0]
        if file_format_hash_converted.nil?  
        err_msg = "ERROR: Micron #{micron_id} did not respond to File Format command."
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 6-2 Format request"])
        err_count += 1
        next
        end

        # check status before continuing with step 6-3 (polling for complete format)
        format_request_status = file_format_hash_converted["MIC_STATUS"]
        if format_request_status == 0
        puts "MIC_FILE_FORMAT status for Micron #{micron_id} was #{format_request_status} - continuing with file format"
        else
        err_msg = "ERROR: MIC_FILE_FORMAT status for Micron #{micron_id} was #{format_request_status} - unknown error, continuing with next micron"
        puts(err_msg)
        err_arr.append(err_msg)
        failed_microns.append([micron_id, "Step 6-2 Format request"])
        err_count += 1
        end
    end
#### ons.delete_if{|x| x==micron_id[0]} --> micron_list.delete_if{|x| x==micron_id[0]}
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    ## Second loop will verify format status
    ## STEP 6-3 - POLL FILE INFO
    format_timeout = 10 * 60
    poll_interval = 1
    micron_list.each do |micron_id|
        starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < format_timeout
        puts "polling file info"

        file_info_hash_converted, file_info_hash_raw = fs.file_info(link, micron_id, file_id, true, true)
        if file_info_hash_converted.nil?  
            err_msg = "ERROR: Micron #{micron_id} did not respond to File Info command."
            puts(err_msg)
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 6-3 Poll file info"])
            err_count += 1
            next
        end

        # check status and file_status before continuing with step 4 (upload)
        info_request_status = file_info_hash_converted["MIC_STATUS"]
        if info_request_status == -4
            puts "FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - file busy formatting"

        elsif info_request_status == 0
            puts "FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - formatting complete. confirming file info request file status is 0"

            info_request_file_status = file_info_hash_raw["MIC_FILE_STATUS"] # use raw here to get int val or it comes in as formatted text
            if [0, -2].include?(info_request_file_status.to_i)
            puts "FILE_INFO_CMD file_status for Micron #{micron_id} was #{info_request_file_status} - continuing with upload"
            break
            else
            err_msg =  "ERROR: FILE_INFO_CMD file_status for Micron #{micron_id} was #{info_request_file_status} - continuing with next micron"
            puts(err_msg)
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 6-3 Poll file info"])
            err_count += 1
            end

        else
            err_msg = "FILE_INFO_CMD status for Micron #{micron_id} was #{info_request_status} - unknown error, continuing with next micron"
            puts(err_msg)
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 6-3 Poll file info"])
            err_count += 1
        end

        sleep(poll_interval)
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    ### STEP 8 ###
    # Command CPBF to broadcast fpga image, then monitor status

    duration = (0.06 * entries_quantity * 1.1).ceil
    cpbf_res = cpbf_module.cpbf_broadcast_micronfw(1, entries_quantity, 60, duration, 25, cpbf_to_mic_link)[0]
    if cpbf_res['BROADCAST_MICRONFW_RESPONSE_CODE'].eql? "SUCCESS"
        puts("CPBF Broadcast Micron FW command successful. Monitoring upload status")
    else
        err_msg = "ERROR: CPBF Broadcast Micron FW command unsuccessful: #{cpbf_res['BROADCAST_MICRONFW_RESPONSE_CODE']}"
        puts(err_msg)
        return false, { 'CPBF': err_msg }
    end
    sleep(10)

    # not sure what max time should be before timeout. Add some margin to duration value
    broadcast_timeout = duration + 120

    start_time = Time.now
    polling_interval = 30
    last_entry_ul = 0
    while Time.now - start_time < broadcast_timeout
        puts("Polling CPBF FPGA broadcast status")
        cpbf_res = cpbf_module.cpbf_mic_fileul_status()[0]
        if cpbf_res['RESPONSE_CODE'].eql? "SUCCESS"
            case cpbf_res['CPBF_STATUS']
            when 'PROGRESS'
                if cpbf_res['CPBF_SENT_ENTRIES'].to_i > last_entry_ul
                    puts("CPBF FPGA broadcast in progress.  Last sent entry is #{cpbf_res['CPBF_SENT_ENTRIES']}")
                    last_entry_ul = cpbf_res['CPBF_SENT_ENTRIES'].to_i                
                else
                    puts("CPBF FPGA broadcast in progress, but sent entries did not increment. " + 
                        "Last sent entry is #{cpbf_res['CPBF_SENT_ENTRIES']}")
                end
            when 'IDLE'
                err_msg = "ERROR: CPBF FPGA broadcast did not start"
                puts(err_msg)
                return false, { 'CPBF': err_msg }
            when 'TIMEOUT'
                err_msg = "ERROR: CPBF FPGA broadcast timed out before completing. " +
                          "Last sent entry is #{last_entry_ul}"
                puts(err_msg)
                return false, { 'CPBF': err_msg }
            when 'DONE'
                puts("CPBF FPGA broadcast completed. Last sent entry is #{cpbf_res['CPBF_SENT_ENTRIES']}")
                break
            else
                err_msg = "ERROR: CPBF FPGA broadcast unknown response. " +
                          "response is #{cpbf_res['CPBF_STATUS']}"
                puts(err_msg)
                return false, { 'CPBF': err_msg }
            end
            sleep(polling_interval)
        else
            err_msg = "ERROR: CPBF FPGA broadcast cmd status was not SUCCESS: #{cpbf_res['RESPONSE_CODE']}"
            puts(err_msg)
            return false, { 'CPBF': err_msg }
        end
    end

    # check whether sent entries = total entries = expected entries
    if [cpbf_res['CPBF_SENT_ENTRIES'].to_i, cpbf_res['CPBF_TOTAL_ENTRIES'], entries_quantity].uniq.length == 1
        puts("CPBF Sent and Total entries matches expected entries quantity")
    end


    ### STEP 9 ###
    # perform FPGA check before installing.  Only check file system
    micron_list.each do |micron_id|
        mic_res = micron_module.fpga_check(link, micron_id, "FILE_SYSTEM", "MAIN", file_id, true, false)[0]
        if mic_res.nil? 
            err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_CHECK command."
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 9 FPGA Check"])
            next
        end
        if mic_res["MIC_FPGA_RESULT_CODE"] != "SUCCESS"
            err_msg = "ERROR: MIC FPGA Check command was not successful for Micron #{mic_res["MICRON_ID"]}. Result was #{mic_res["MIC_FPGA_RESULT_CODE"]}. Continuing with next Micron"
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 9 FPGA Check"])
            next
        end
        puts("MICRON FPGA Check command successful for Micron #{mic_res["MICRON_ID"]}")
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end
    # wait for arbitrary time.  Can adjust later if needed
    wait(15)
    check_status_wait = 600
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    
    micron_list.each do |micron_id|
        status = true
        while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < check_status_wait && status
    
            mic_res = micron_module.fpga_check_status(link, micron_id, "FILE_SYSTEM", "MAIN", true, false)[0]
            if mic_res.nil? 
                err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_CHECK command."
                puts(err_msg)
                err_arr.append(err_msg)
                err_count += 1
                failed_microns.append([micron_id, "Step 9 FPGA Check"])
                next
            end
            crc_check_status = mic_res["MIC_CRC_CHECK_STATUS"]
            if crc_check_status.eql? "SUCCESS"
                puts("Micron #{mic_res["MICRON_ID"]} passed FPGA image CRC check.")
                check_status_wait = check_status_wait - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting)
                status = false
            elsif crc_check_status.eql? "CRC_IN_PROGRESS"
                puts("FPGA image CRC Check still in progress for Micron #{mic_res["MICRON_ID"]}")
            elsif crc_check_status.eql? "FAIL"
                err_msg = "ERROR: FPGA image CRC Check failed for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron."
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 9 FPGA Check"])
                status = false
            else
                err_msg = "ERROR: FPGA image CRC Check unknown status #{crc_check_status} for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron."
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 9 FPGA Check"])
                status = false
            end
        end
		if status
			err_msg = "Micron #{micron_id} timed out while performing CRC check."
			puts(err_msg)
			err_count += 1
			err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 9 FPGA Check"])
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    ### STEP 10 ###
    # perform the FPGA install

    install_wait = 240
    file_info_wait = 480
    # first send install command to each micron
    micron_list.each do |micron_id|
        mic_res = micron_module.fpga_install(link, micron_id, file_id, "MAIN", true, false)[0]
        if mic_res.nil? 
            err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_INSTALL command."
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 10 FPGA Install"])
            next
        end
        install_res = mic_res["MIC_FPGA_RESULT_CODE"]
        if ['POWER_MODE_MISMATCH', "GENERAL_ERROR"].include?(install_res)
            err_msg = "ERROR: Micron #{micron_id} Install result is not SUCCESS or INSTALL_IN_PROGRESS. Continuing with next micron"
            puts(err_msg)
            err_count += 1
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 10 FPGA Install"])
            next
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end
    puts("Waiting #{install_wait} before checking installation status")
    wait(install_wait)

    # now check each micron's install status
    temp_micron_list = micron_list.clone
    mic_status_dict = micron_list.map {|item| [item, ["working", {}]]}.to_h

    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC) 
    while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < file_info_wait
        puts("Polling FPGA file info for install status")
        temp_micron_list.each do |micron_id|
            if ["done","failed"].include? mic_status_dict[micron_id][0]
                next
            end
            mic_res = micron_module.fpga_info(link, micron_id, "MAIN", "DESCRIPTOR", true, false)[0]
            if mic_res.nil?  
                err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_INFO command."
                puts(err_msg)
                err_arr.append(err_msg)
                err_count += 1
                failed_microns.append([micron_id, "Step 10 FPGA Install"])
                next
            end
            mic_status_dict[micron_id][1] = mic_res
            install_status = mic_res["MIC_INSTALL_STATUS"]
            puts("MIC_INSTALL_STATUS for Micron #{mic_res["MICRON_ID"]} = #{mic_res["MIC_INSTALL_STATUS"]}")
            if install_status.eql? "SUCCESS"
                puts("Installation successful for Micron #{mic_res["MICRON_ID"]}")
                mic_status_dict[micron_id][0] = "done"
            elsif install_status.eql? "INSTALL_IN_PROGRESS"
                puts("Installation still in progress for Micron #{mic_res["MICRON_ID"]}")                
            elsif install_status.eql? "INSTALL_FAIL"
                err_msg = "ERROR: Installation failed for Micron #{mic_res["MICRON_ID"]}. Continuing with next Micron"
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 10 FPGA Install"])
                mic_status_dict[micron_id][0] = "failed"
            else
                # there is an INSTALL_IDLE value, not sure how to handle this
                err_msg = "ERROR: Unknown installation status #{install_status} for Micron #{mic_res["MICRON_ID"]}. Continuing with next Micron"
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 10 FPGA Install"])
                mic_status_dict[micron_id][0] = "failed"
            end
        end
        if check_install_status(mic_status_dict)
            break
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    ### STEP 11 ###
    # fpga check post install
    micron_list.each do |micron_id|
        mic_res = micron_module.fpga_check(link, micron_id, "FPGA_NOR", "MAIN", file_id, true, false)[0]
        if mic_res.nil? 
            err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_CHECK command."
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 11 FPGA Check"])
            next
        end
        if mic_res["MIC_FPGA_RESULT_CODE"] != "SUCCESS"
            err_msg = "ERROR: MIC FPGA Check command was not successful for Micron #{mic_res["MICRON_ID"]}. Result was #{mic_res["MIC_FPGA_RESULT_CODE"]}. Continuing with next Micron"
            puts(err_msg)
            err_arr.append(err_msg)
            micron_list.delete(micron_id)
            failed_microns.append([micron_id, "Step 11 FPGA Post-Install Check"])
            next
        end
        puts("MICRON FPGA Check command successful for Micron #{mic_res["MICRON_ID"]}")
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end
    # wait for arbitrary time.  Can adjust later if needed
    wait(30)
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    micron_list.each do |micron_id|
        status = true
        while Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting < check_status_wait && status
    
            mic_res = micron_module.fpga_check_status(link, micron_id, "FPGA_NOR", "MAIN", true, false)[0]
            if mic_res.nil? 
                err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_CHECK_STATUS command."
                puts(err_msg)
                err_arr.append(err_msg)
                err_count += 1
                failed_microns.append([micron_id, "Step 11 FPGA Check"])
                next
            end
            crc_check_status = mic_res["MIC_CRC_CHECK_STATUS"]
            if crc_check_status.eql? "SUCCESS"
                puts("Micron #{mic_res["MICRON_ID"]} passed FPGA image CRC check.")
                check_status_wait = check_status_wait - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting)
                status = false
            elsif crc_check_status.eql? "IN_PROGRESS"
                puts("FPGA image CRC Check still in progress for Micron #{mic_res["MICRON_ID"]}")
            elsif crc_check_status.eql? "FAIL"
                err_msg = "ERROR: FPGA image CRC Check failed for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron."
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 11 FPGA Post-Install Check"])
                status = false
            else
                err_msg = "ERROR: FPGA image CRC Check unknown status #{crc_check_status} for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron."
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 11 FPGA Post-Install Check"])
                status = false
            end
        end
		if status
			err_msg = "Micron #{micron_id} timed out while performing CRC check."
			puts(err_msg)
			err_count += 1
			err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 11 FPGA Post-Install Check"])
		end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end
	
	### STEP 12 ####
    # Verify FPGA image
    micron_list.each do |micron_id|
        #mic_result = micron_module.fpga_info(link, micron_id, "MAIN", "DESCRIPTOR", true, false)[0]
        mic_result = mic_status_dict[micron_id][1]
        if mic_result.nil?
            err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_INFO command."
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 12 FPGA Info"])
            next
        end
        puts("Version Info results:")
        puts("Image Version is #{mic_result["MIC_IMAGE_VERSION"]} for Micron #{micron_id}")
        puts("File length is #{mic_result["MIC_FILE_LENGTH"]} for Micron #{micron_id}")
        puts("Creation Date is #{mic_result["MIC_CREATION_DATE"]} for Micron #{micron_id}")
        puts("Creation Time is #{mic_result["MIC_CREATION_TIME"]} for Micron #{micron_id}")
        puts("File CRC is #{mic_result["MIC_FILE_CRC"]} for Micron #{micron_id}")
        if mic_result["MIC_IMAGE_VERSION"] != version_info
            err_msg = "ERROR: Installed FPGA Image version is not as expected for Micron #{micron_id} - version is #{mic_result["MIC_IMAGE_VERSION"]}"
            puts(err_msg)
            err_count += 1
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 12 FPGA Image Version Check"])
        else
            puts("Successfully installed FPGA version #{mic_result["MIC_IMAGE_VERSION"]} for Micron #{micron_id}")
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end
    
    ### STEP 13 ###
    # Rebooting the board and check version number 
    if reboot
        csp = MicronCSP.new
        micron_list.each do |micron_id|
            csp.reboot(link, micron_id, use_automations)
        end
    end

    failed_microns.each do |failed_micron|
        puts("Micron #{failed_micron[0]} installation failed: #{failed_micron[1]}")
    end

    if use_automations
        # return hash of micron IDs and status
        mic_status_hash = get_status_hash(micron_list, failed_microns)
        if err_count > 0
            return false, mic_status_hash
        end
        return true, mic_status_hash
    end

    # display and raise errors
    if err_count > 0
        raise TestException.new "Total of #{err_count} Errors during FPGA Upload.  Errors are:\n#{err_arr.join("\n")}"
    end
    
end

def check_install_status(mic_status_dict)
    mic_status_dict.each do |key, value|
        if value[0].eql? "working"
            return false
        end
    end
    return true
end

def get_status_hash(micron_list, failed_microns)
    mic_status_hash = Hash.new
    micron_list.each do |micron_id|
        mic_status_hash["MICRON_#{micron_id}".to_sym] = "PASS"
    end
    failed_microns.each do |micron_arr|
        mic_status_hash["MICRON_#{micron_arr[0]}".to_sym] = "FAILED at #{micron_arr[1]}"
    end
    return mic_status_hash
end

class TestException < StandardError
  def initialize(msg="General Test Error", exception_type="custom")
    @exception_type = exception_type
    super(msg)
  end
end