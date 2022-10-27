load_utility('Operations/Micron/TrajectoryControlFunctions.rb')

#Init variables
number_of_iterations = 3
power_mode = "ps1"
move_ps2 = true
microns = [77]
out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")

time = Time.now
run_id = "01#{time.strftime("%d%m%Y%H%M%S")}"
out_file.write("\n")
builded_string = "\nRUN_ID: " + run_id + " TEST_START"
out_file.puts(builded_string)
out_file.flush

#Step 1 is in user responsibility to turn on the power share in
    #Please turn on power sharing to the micron 
    # message_box("Please turn on power sharing to the micron.", "CONTINUE", false)
    # if power_mode.to_s.downcase == "ps2"
    #     resPowerUp,index = set_target_ps2_traj_ps2(microns[0].to_i,"",file_info, run_id)
    #     if resPowerUp == false
    #         puts "Failed to move to ps2."
    #         return false
    #     end
    # end
sleep 10

if power_mode.to_s.downcase == "ps2"
    #move to ps2
    moved_to_ps2 = move_ring_to_mode_and_validate("", "PS2", run_id, false, microns, out_file)
    if !moved_to_ps2
        puts "Failed to move ps2."
        move_ps2 = false
    end
end

#Step 2 - Upload main image
version_hash = get_micron_version()
firmwareVersion = version_hash['fw_version']
version_info_app = version_hash['post_sw_app']

path = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcApplication.bin"
if move_ps2
    res,status = firmware_update("MIC_LSL", 'app', path, version_info_app, file_id = 12, from_golden = 0, microns, broadcast_all: true, reboot: true, use_automations: true, check_version: false)
    if res
        keys = status.keys
        values = status.values
        for i in 0..keys.length()
            if(keys[i] == nil)
                next
            end
            bool_status = false
            if(values[i] == "PASS")
                bool_status = true
            end
            time = Time.new
            write_to_log_file(run_id, time, "APPLICATION_FIRMWARE_UPLOAD_VERSION_#{firmwareVersion}_MICRON_#{get_micron_id_filterd(keys[i])}",
            "TRUE", "TRUE", bool_status, "BOOLEAN", values[i], "BW3_COMP_GOLDEN_TEST", out_file)

        end

        #Step 3 - verify image version
        verify_main_image = verify_micron_software_version(microns, run_id, out_file)
        if !verify_main_image
            puts "Fail to verify software version."
        
        else
            #Repeat steps
            all_regression_pass = "PASS"
            for i in 1..number_of_iterations
                
                ret = golden_test_sequence(microns, power_mode, out_file, run_id)
                if !ret
                    puts "Failed golden regression in iteration #{i}"
                    all_regression_pass = "FAIL"
                end
                time = Time.new
                write_to_log_file(run_id, time, "GOLDEN_TEST_SEQUENCE_ITERATION_#{i}",
            "TRUE", "TRUE", ret, "BOOLEAN", ((ret == true) ? "PASS": "FAIL"), "BW3_COMP_GOLDEN_TEST", out_file)
            end
        end

        puts "Regression - #{all_regression_pass}"
        time = Time.new
        write_to_log_file(run_id, time, "GOLDEN_TEST_REGRESSION_FINAL_RESULT",
        "TRUE", "TRUE", ((all_regression_pass == "PASS") ? true : false), "BOOLEAN", all_regression_pass, "BW3_COMP_GOLDEN_TEST", out_file)
    end
end