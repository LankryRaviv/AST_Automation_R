load_utility('Operations/MICRON/MICRON_FS_Upload.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')


def micron_fpga_update(link, image_loc, version_info, micron_list, file_id, from_golden, entry_size, broadcast_all, reboot, do_file_check, use_automations)
    # user can pass in single micron or array of microns
    if !micron_list.kind_of?(Array)
        micron_list_temp = micron_list
        micron_list.append(micron_list_temp)
    end

    err_arr = []
    failed_microns = []
    err_count = 0

    micron_module = MICRON_MODULE.new

    ### STEP 1 ###
    # script supports passing in list of microns. script performs file info check,
    # file format, and file check
    MICRON_FS_Upload(entry_size, file_id, image_loc, link, micron_list, broadcast_all: broadcast_all, do_file_check: do_file_check)

    ### STEP 2 ###
    # perform FPGA check before installing.  Only check file system
    micron_list.each do |micron_id|
        mic_res = micron_module.fpga_check(link, micron_id, "FILE_SYSTEM", "MAIN", file_id, true, false)[0]
        if mic_res.nil? 
            err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_CHECK command."
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 2 FPGA Check"])
            next
        end
        if mic_res["MIC_FPGA_RESULT_CODE"] != "SUCCESS"
            err_msg = "ERROR: MIC FPGA Check command was not successful for Micron #{mic_res["MICRON_ID"]}. Result was #{mic_res["MIC_FPGA_RESULT_CODE"]}. Continuing with next Micron"
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 2 FPGA Check"])
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
                failed_microns.append([micron_id, "Step 2 FPGA Check"])
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
                failed_microns.append([micron_id, "Step 2 FPGA Check"])
                status = false
            else
                err_msg = "ERROR: FPGA image CRC Check unknown status #{crc_check_status} for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron."
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 2 FPGA Check"])
                status = false
            end
        end
		if status
			err_msg = "Micron #{micron_id} timed out while performing CRC check."
			puts(err_msg)
			err_count += 1
			err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 2 FPGA Check"])
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end

    ### STEP 3 ###
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
            failed_microns.append([micron_id, "Step 3 FPGA Install"])
            next
        end
        install_res = mic_res["MIC_FPGA_RESULT_CODE"]
        if ['POWER_MODE_MISMATCH', "GENERAL_ERROR"].include?(install_res)
            err_msg = "ERROR: Micron #{micron_id} Install result is not SUCCESS or INSTALL_IN_PROGRESS. Continuing with next micron"
            puts(err_msg)
            err_count += 1
            err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 3 FPGA Install"])
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
                failed_microns.append([micron_id, "Step 3 FPGA Install"])
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
                failed_microns.append([micron_id, "Step 3 FPGA Install"])
                mic_status_dict[micron_id][0] = "failed"
            else
                # there is an INSTALL_IDLE value, not sure how to handle this
                err_msg = "ERROR: Unknown installation status #{install_status} for Micron #{mic_res["MICRON_ID"]}. Continuing with next Micron"
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 3 FPGA Install"])
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

    ### STEP 4 ###
    # fpga check post install
    micron_list.each do |micron_id|
        mic_res = micron_module.fpga_check(link, micron_id, "FPGA_NOR", "MAIN", file_id, true, false)[0]
        if mic_res.nil? 
            err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_CHECK command."
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 4 FPGA Check"])
            next
        end
        if mic_res["MIC_FPGA_RESULT_CODE"] != "SUCCESS"
            err_msg = "ERROR: MIC FPGA Check command was not successful for Micron #{mic_res["MICRON_ID"]}. Result was #{mic_res["MIC_FPGA_RESULT_CODE"]}. Continuing with next Micron"
            puts(err_msg)
            err_arr.append(err_msg)
            micron_list.delete(micron_id)
            failed_microns.append([micron_id, "Step 4 FPGA Post-Install Check"])
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
                failed_microns.append([micron_id, "Step 4 FPGA Check"])
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
                failed_microns.append([micron_id, "Step 4 FPGA Post-Install Check"])
                status = false
            else
                err_msg = "ERROR: FPGA image CRC Check unknown status #{crc_check_status} for Micron #{mic_res["MICRON_ID"]}. Continuing to next Micron."
                puts(err_msg)
                err_count += 1
                err_arr.append(err_msg)
                failed_microns.append([micron_id, "Step 4 FPGA Post-Install Check"])
                status = false
            end
        end
		if status
			err_msg = "Micron #{micron_id} timed out while performing CRC check."
			puts(err_msg)
			err_count += 1
			err_arr.append(err_msg)
            failed_microns.append([micron_id, "Step 4 FPGA Post-Install Check"])
		end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end
	
	### STEP 5 ####
    # Verify FPGA image
    micron_list.each do |micron_id|
        #mic_result = micron_module.fpga_info(link, micron_id, "MAIN", "DESCRIPTOR", true, false)[0]
        mic_result = mic_status_dict[micron_id][1]
        if mic_result.nil?
            err_msg = "ERROR: Micron #{micron_id} did not respond to FPGA_INFO command."
            puts(err_msg)
            err_arr.append(err_msg)
            err_count += 1
            failed_microns.append([micron_id, "Step 5 FPGA Info"])
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
            failed_microns.append([micron_id, "Step 5 FPGA Image Version Check"])
        else
            puts("Successfully installed FPGA version #{mic_result["MIC_IMAGE_VERSION"]} for Micron #{micron_id}")
        end
    end
    failed_microns.each do |micron_id|
        micron_list.delete_if{|x| x==micron_id[0]}
    end
    
    ### STEP 6 ###
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