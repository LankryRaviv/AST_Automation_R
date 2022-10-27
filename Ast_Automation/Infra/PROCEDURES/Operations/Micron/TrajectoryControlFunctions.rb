load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/HandleRouting.rb')
load_utility('Operations/Micron/ChangeToPS2MicronsInChain.rb')
load_utility('Operations/Micron/ChangeToOperationalMicronsInChain.rb')
load_utility('Operations/Micron/Ping.rb')
load_utility('Operations/Micron/RebootMicronsInChain.rb')
load_utility('Operations/Micron/ChangeMode.rb')
load_utility('Operations/Micron/SaveMicronStatusMode.rb')
load_utility('Operations/Micron/MICRON_ROUTING.rb')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/Micron/MICRON_POWER_SHARE.rb')
load_utility('Operations/CPBF/CPBF_MODULE.rb')
load_utility('Operations/Micron/MICRON_FPGA_Update.rb')
load_utility('Operations/MICRON/MICRON_FS_Upload.rb')
load_utility('Operations/Micron/MICRON_Firmware_Update.rb')
load_utility('Operations/Micron/MICRON_FPGA_THERMAL.rb')
load_utility('Operations/Micron/ChangeToReducedMicronsInChain.rb')
load_utility('Operations/Micron/get_micron_version.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/micron_rapid_power.rb')
load('Operations/MICRON/micron_golden_image.rb')

require 'date'

$micron_id_ring_A = [119, 120, 77,93, 118, 76]
$micron_id_ring_B = [136, 122, 108, 94, 80, 66, 61, 75, 89, 103, 117, 131]
$micron_id_ring_C = [151, 137, 123, 109, 95, 81, 67, 53, 46, 60, 74, 88, 102, 116, 130, 144]
$micron_id_ring_D = [152,138, 124, 110, 96, 82, 68, 54, 45, 59, 73,87,101, 115,129,143]
$micron_id_ring_E = [18,25,69,83,97,111,125,139,128,114,100,86,72,58, 179, 172]
$micron_id_ring_F = [4,11,186,193]
$chains = {77=>[4, 18, 58], 78=>[11, 25, 69, 83, 97], 107=>[111, 125, 139, 179, 193],
     119=>[128, 172, 186], 104=>[100,114], 90=>[72,86]}


def reboot_chain(microns, apc)
    fs = MICRON_MODULE.new
    result = Array.new(microns.length) { true }
    power_share_first_micron = microns[-1]
    #Turning off PCDU in the chain.
    power_off_power_supply(power_share_first_micron, apc)
    sleep 4
    microns.each_with_index do |micron_id, i|
        micron = "MICRON_#{micron_id}"
        fs.sys_reboot("MIC_LSL", micron, false, false, 0.2)
        sleep 4
        #Validating that ping faild to micron
        result[i] = fs.ping_micron("MIC_LSL", micron, false, false, 0.1)
        puts "REBOOT #{micron} = #{(result[i] == false ? "PASS": "FAIL")}"
    end
    #If one in the list is true, thats mean the reboot faild in at least one micron.
    result.any?
end

def chain_list_by_micron_id(micron_id)
    #get a list of microns until specific micron_id
    list_until_micron_id = get_micron_id_list(micron_id.to_i)

    turn_off_chain_list = []
    $chains.each do |chain|
        if list_until_micron_id[0] == chain[0]
            chain[1].reverse().each do |micron_id|
                list_until_micron_id = get_micron_id_list(micron_id.to_i)
                list_until_micron_id.each do |id|
                    next if turn_off_chain_list.include? id
                    turn_off_chain_list.append(id)
                end
            end
            break
        end
    end
    return turn_off_chain_list.reverse()
end

def power_off_chain(micron_id, apc)
    turn_off_chain_list = chain_list_by_micron_id(micron_id)
    return reboot_chain(turn_off_chain_list, apc)
end

# All the functions return True/False if target and all Microns in trajectory were set correctly
# def set_target_reduce_traj_ps1(micron_id,run_id = "")
#     if(!power_on_power_supply(micron_id))
#         return false
#     end
#     resChangingMode = change_to_ps2_microns_in_chain(micron_id_target,"MIC_LSL",run_id,true,true)
#     resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
#     resChangeModeOperational = change_mode("MICRON_" + micron_id.to_s,"OPERATIONAL")
#     resChangeModeReduced = "FAIL"
#     if(resChangeModeOperational == "PASS")
#         resChangeModeReduced = change_mode("MICRON_" + micron_id.to_s,"REDUCED")
#     end
    
#     resReboot = reboot_microns_in_chain(micron_id,false,board="MIC_LSL")
#     if(resChangingMode == "PASS" && resPing == "PASS" && resReboot == "PASS" && resChangeModeReduced == true && resChangeModeOperational == true)
#         return true
#     end
#     return false
# end


# def set_target_reduce_traj_off(micron_id,run_id = "")
#     if(!power_on_power_supply(micron_id))
#         return false
#     end
#     resChangingMode = change_to_ps2_microns_in_chain(micron_id_target,"MIC_LSL",run_id,true,true)
#     resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
#     resChangeModeOperational = change_mode("MICRON_" + micron_id.to_s,"OPERATIONAL")
#     resChangeModeReduced = "FAIL"
#     if(resChangeModeOperational == "PASS")
#         resChangeModeReduced = change_mode("MICRON_" + micron_id.to_s,"REDUCED")
#     end
    
#     resReboot = reboot_microns_in_chain(micron_id,false,board="MIC_LSL")
#     if(!power_off_power_supply(micron_id))
#         return false
#     end
#     if(resChangingMode == "PASS" && resPing == "PASS" && resReboot == "PASS" && resChangeModeReduced == true && resChangeModeOperational == true)
#         return true
#     end
#     return false
# end


# def set_target_operational_traj_ps1(micron_id,run_id = "")
#     if(!power_on_power_supply(micron_id))
#         return false
#     end
#     resChangingMode = change_to_ps2_microns_in_chain(micron_id_target,"MIC_LSL",run_id,true,true)
#     resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
#     resChangeModeOperational = change_mode("MICRON_" + micron_id.to_s,"OPERATIONAL")
#     resReboot = reboot_microns_in_chain(micron_id,false,board="MIC_LSL")
#     if(resChangingMode == "PASS" && resPing == "PASS" && resReboot == "PASS" && resChangeModeOperational == true)
#         return true
#     end
#     return false
# end


# def set_target_operational_traj_off(micron_id,run_id = "")
#     if(!power_on_power_supply(micron_id))
#         return false
#     end
#     resChangingMode = change_to_ps2_microns_in_chain(micron_id,board="MIC_LSL")
#     resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
#     resChangeModeOperational = change_mode("MICRON_" + micron_id.to_s,"OPERATIONAL")
#     resReboot = reboot_microns_in_chain(micron_id,false,board="MIC_LSL")
#     if(!power_off_power_supply(micron_id))
#         return false
#     end
#     if(resChangingMode == "PASS"  && resReboot == "PASS" && resChangeModeOperational == true)
#         return true
#     end
#     return false
# end





def set_target_operational_traj_operational(micron_id,apc,run_id = "")

    resChangingMode = change_to_ps2_microns_in_chain(micron_id,board="MIC_LSL",run_id,true,true)
    resChangingModeOperational = change_to_operational_microns_in_chain(micron_id,apc,board="MIC_LSL",run_id,true,true)
    #resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
    #resChangeMode = change_mode("MICRON_" + micron_id.to_s,"OPERATIONAL")
    #resReboot = reboot_microns_in_chain(micron_id,false,board="MIC_LSL")
    #power_off_power_supply()
    if(resChangingMode == "PASS" && resChangingModeOperational == "PASS")
        return true
    end
    return false
end


# def set_target_ps2_traj_ps1(micron_id)
#     if(!power_on_power_supply(micron_id))
#         return false
#     end
#     resChangingMode = change_to_ps2_microns_in_chain(micron_id,board="MIC_LSL")
#     resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
#     resReboot = reboot_microns_in_chain(micron_id,false,board="MIC_LSL")
#     if(resChangingMode == "PASS" && resPing == "PASS" && resReboot == "PASS")
#         return true
#     end
#     return false
# end


# def set_target_ps2_traj_off(micron_id)
#     if(!power_on_power_supply(micron_id))
#         return false
#     end
#     resChangingMode = change_to_ps2_microns_in_chain(micron_id,board="MIC_LSL")
#     resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
#     resReboot = reboot_microns_in_chain(micron_id,false,board="MIC_LSL")
#     if(!power_off_power_supply(micron_id))
#         return false
#     end
#     if(resChangingMode == "PASS" && resPing == "PASS" && resReboot == "PASS")
#         return true
#     end
#     return false
# end

#DOES not fully working!!!!!
# def set_target_off_traj_no_change(micron_id)
#     isRebooted = "PASS"
#     fs = MICRON_MODULE.new 
#     resNoChangeTraj = save_microns_status_mode(micron_id,true)
#     reboot = fs.sys_reboot(board="MIC_LSL", "MICRON_" + micron_id.to_s, converted=false, raw=false, wait_check_timeout=2)
#     puts "SYS REBOOT - MICRON_ID = #{"MICRON_" + micron_id.to_s}"
#     sleep 8
#     ret = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
#     if(resNoChangeTraj == "PASS" && ret == "FAIL")
#         return true
#     end
#     return false
# end

#DOES not fully working!!!!!
# def set_target_ps1_traj_no_change(micron_id)
#     isRebooted = "PASS"
#     fs = MICRON_MODULE.new 
#     resNoChangeTraj = save_microns_status_mode(micron_id)
#     reboot = fs.sys_reboot(board="MIC_LSL", "MICRON_" + micron_id.to_s, converted=false, raw=false, wait_check_timeout=2)
#     puts "SYS REBOOT - MICRON_ID = #{"MICRON_" + micron_id.to_s}"
#     sleep 8
#     get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", "MICRON_" + micron_id.to_s, true, false,wait_check_timeout=2)[0]
#     power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]

#     if power_mode_status == "PS1"
#         puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{"MICRON_" + micron_id.to_s}"
#     else
#         isRebooted = "FAIL"
#         puts "REBOOT FAILED to #{"MICRON_" + micron_id.to_s}"
#     end
#     if(resNoChangeTraj == "PASS" && isRebooted == "PASS")
#         return true
#     end
#     return false
# end

#DOES not fully working!!!!!
# def set_target_ps2_traj_no_change(micron_id)
    
#     resNoChangeTraj = save_microns_status_mode(micron_id,false)
#     resChangeMode = change_mode(micron_id,"PS2")
#     if(resNoChangeTraj == "PASS" && resChangeMode == true)
#         return true
#     end
#     return false
# end

#DOES not fully working!!!!!
# def set_target_reduce_traj_no_change(micron_id)
#     resNoChangeTraj = save_microns_status_mode(micron_id)
#     resChangeMode = change_mode(micron_id,"REDUCED")
#     if(resNoChangeTraj == "PASS" && resChangeMode == true)
#         return true
#     end
#     return false
# end

#DOES not fully working!!!!!
# def set_target_operational_traj_no_change(micron_id)
#     resNoChangeTraj = save_microns_status_mode(micron_id)
#     resChangeMode = change_mode(micron_id,"OPERATIONAL")
#     if(resNoChangeTraj == "PASS" && resChangeMode == true)
#         return true
#     end
#     return false
# end


def set_target_off_traj_off(micron_id, out_file, apc,run_id = "", routing = false, socAndTemp = false,modeOperational = false)

    if(!power_on_power_supply(micron_id,apc))
        return false
    end
    resChangingMode,startRebootIndex = change_to_ps2_microns_in_chain(micron_id, out_file, board="MIC_LSL",run_id,routing, socAndTemp)
    puts resChangingMode, startRebootIndex
    #sleep(30)
    if(modeOperational)
        if(resChangingMode == "PASS")
            resChangingModeOperational = change_to_operational_mode_microns_in_chain(micron_id, out_file, apc,board="MIC_LSL",run_id,routing, socAndTemp)
        end
    else
        modeOperational = "PASS"
    end
    #resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL",run_id,false)
    #res_routing = "PASS"
    #if(routing)
     #   ping_pass = false
     ##   if(resPing == "PASS" && resChangingMode == "PASS")
           # ping_pass = true
    #    end
     #   res_routing_bool = get_micron_default_routing("MICRON_" + micron_id.to_s,run_id,ping_pass)
    #    if(res_routing_bool == false)
            #res_routing = "FAIL"
     #   end
   # end
    if(!power_off_power_supply(micron_id,apc))
        return false
    end
    resReboot = reboot_microns_in_chain(micron_id, out_file, true,board="MIC_LSL",run_id,startRebootIndex)
   
    # && resPing == "PASS"
    if(resChangingMode == "PASS" && resReboot == "PASS" && resChangingModeOperational = "PASS")
        #if(routing)
            #if(res_routing == "FAIL")
             #   return false
            #end
        #end
        return true
    end
    return false
end

# def set_ps2_and_operational_all_linkage(micron_id,run_id = "")
#     resChangingMode = change_to_ps2_microns_in_chain(micron_id,board="MIC_LSL",run_id,true,true)
#     if(resChangingMode == "PASS")
#         if(change_to_operational_mode_microns_in_chain(micron_id,board="MIC_LSL",run_id,true,true) == "PASS")
#             return true
#         end
#     end
#     return false
# end

#Power supply off at the end of the operation.
def set_target_ps2_traj_ps2(micron_id, apc, out_file, run_id = "",routing = true, socAndTemp = true, disabledDoner = true)
    index = 0
    if(!power_on_power_supply(micron_id,apc))
        return false, index
    end
    
    resChangingMode, index = change_to_ps2_microns_in_chain(micron_id, out_file, board="MIC_LSL",run_id,routing, socAndTemp,disabledDoner)
    #resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL",run_id,false)
    #power_off_power_supply(micron_id)
    if(resChangingMode == "PASS")
        return true, index
    end
    return false, index
end



#DOES not fully working!!!!!
# def ping_target_traj_no_change(micron_id)
#     resNoChangeTraj = save_microns_status_mode(micron_id)
#     resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
#     if(resNoChangeTraj == "PASS" && resPing == "PASS")
#         return true
#     end
#     return false
# end

def reboot_target_and_traj(micron_id,apc)
    if(!power_on_power_supply(micron_id,apc))
        return false
    end
    resChangingMode = change_to_ps2_microns_in_chain(micron_id,board="MIC_LSL")
    #resPing = ping_by_micron_id("MICRON_" + micron_id.to_s,board="MIC_LSL")
    resReboot = reboot_microns_in_chain(micron_id,true,board="MIC_LSL")
    if(resChangingMode == "PASS" && resPing == "PASS" && resReboot == "PASS")
        return true
    end
    return false
end

def ping_target_traj_off(micron_id, out_file, apc,run_id = "", operational = false)
    return set_target_off_traj_off(micron_id, out_file, apc,run_id, false,false, operational)
end

#Including routing and ping 
def ping_target_routing_traj_off(micron_id, out_file, apc,run_id = "", operational = false)
    return set_target_off_traj_off(micron_id, out_file, apc,run_id,true,false, operational)
end

#Including routing, ping, SOC and Temperature check
def ping_target_routing_safety_traj_off(micron_id, out_file, apc,run_id = "", operational = false)
    return set_target_off_traj_off(micron_id, out_file, apc,run_id,true, true, operational)
end



#Update firmware version
def update_firmware(micron_id, apc, file_info, run_id = "",microns_list = nil,is_ring = false)
    version_hash = get_micron_version()
    firmwareVersion = version_hash['fw_version']
    version_info_app = version_hash['post_sw_app']
    version_info_bl1 = version_hash['post_sw_bl1']
    version_info_bl2 = version_hash['post_sw_bl2']

    path = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcApplication.bin"
    pathBootl2 = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcBootloaderL2.bin"
    pathBootl1 = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcBootloaderL1.bin"

    statusAllFirmware = true
    fsRes = false
    fsResBootl2 = false
    fsResBootl1 = false
    resPowerUp = true
    all_ring_microns_id = []

    if(microns_list == nil)
        microns_list = get_micron_id_list(micron_id).reverse()
    end
    # else
    #     for micron_idd in microns_list
    #         micron_id_list = get_micron_id_list(micron_idd)
    #         for id in micron_id_list
    #             all_ring_microns_id.append(id)
    #         end
    #     end
        
    #     microns_list = all_ring_microns_id.uniq.reverse()
    #     puts microns_list
    #     #sleep 20
    # end
    if(!is_ring)
        #resPowerUp = true
        resPowerUp,index = set_target_ps2_traj_ps2(micron_id.to_i, apc, file_info, run_id,true,true,false)
    end
    #set_target_operational_traj_off(micron_id.to_i,ARGV[1])
    #Added SW upload version

    #for id in microns_list
        time = Time.new
        firmwareAppStatus = "FAIL"
        firmwareBootl2Status = "FAIL"
        firmwareBootl1Status = "FAIL"
        id = microns_list[0]
        microns_id = [id]
        if(resPowerUp)
            #firmwareBootl2Status = "PASS"
            fsResBootl1,status = firmware_update("MIC_LSL", "bl1", pathBootl1, version_info_bl1, file_id = 12, from_golden = 0, microns_list, broadcast_all: true, reboot: false, use_automations: true, check_version: true)
            #Set next power mode to ps2
            #ret_change_mode = change_mode("MICRON_" + id.to_s,"PS2")&& ret_change_mode
            #sleep 2
            #write result of sw upgrade
            
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
                write_to_log_file(run_id, time, "BOOTLOADERL1_FIRMWARE_UPGRADE_VERSION_#{version_info_bl1[:BOOT_L1_MAJOR]}.#{version_info_bl1[:BOOT_L1_MINOR]}.#{version_info_bl1[:BOOT_L1_PATCH]}_MICRON_#{get_micron_id_filterd(keys[i])}",
                "TRUE", "TRUE", bool_status, "BOOLEAN", values[i], "BW3_COMP_SW_UPLOAD", file_info)

            end
       
            if(fsResBootl1)
                firmwareBootl1Status = "PASS"
                fsResBootl2,status = firmware_update("MIC_LSL", "bl2", pathBootl2, version_info_bl2, file_id = 12, from_golden = 0, microns_list, broadcast_all: true, reboot: false, use_automations: true, check_version: true)
                #fsResBootl2 = firmware_update("MIC_LSL", "bl2", pathBootl2, version_info_bl2, file_id = 12, from_golden = 0, microns_id, broadcast_all: false, reboot: true, use_automations: true)
                #Set next power mode to ps2
                #ret_change_mode = change_mode("MICRON_" + id.to_s,"PS2")&& ret_change_mode
                #sleep 2    
                #write result of sw upgrade
                
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
                    write_to_log_file(run_id, time, "BOOTLOADERL2_FIRMWARE_UPGRADE_VERSION_#{version_info_bl2[:BOOT_L2_MAJOR]}.#{version_info_bl2[:BOOT_L2_MINOR]}.#{version_info_bl2[:BOOT_L2_PATCH]}_MICRON_#{get_micron_id_filterd(keys[i])}",
                    "TRUE", "TRUE", bool_status, "BOOLEAN", values[i], "BW3_COMP_SW_UPLOAD", file_info)
                end
                  
                if(fsResBootl2)
                    firmwareBootl2Status = "PASS"
                    if(resPowerUp)
                        fsRes,status = firmware_update("MIC_LSL", "app", path, version_info_app, file_id = 12, from_golden = 0, microns_list, broadcast_all: true, reboot: false, use_automations: true, check_version: false)
                        
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
                            write_to_log_file(run_id, time, "APPLICATION_FIRMWARE_UPGRADE_VERSION_#{firmwareVersion}_MICRON_#{get_micron_id_filterd(keys[i])}",
                            "TRUE", "TRUE", bool_status, "BOOLEAN", values[i], "BW3_COMP_SW_UPLOAD", file_info)
                        end
                      
                        if(fsRes)
                            firmwareAppStatus = "PASS"
                        end
                    end
                end
            end     
        end
        
        #write result of bootloaderl1 firmware upgrade
        # out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
        # builded_string = "RUN_ID: " + run_id + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: BOOTLOADERL1_FIRMWARE_UPGRADE_VERSION_#{version_info_bl1[:BOOT_L1_MAJOR]}.#{version_info_bl1[:BOOT_L1_MINOR]}.#{version_info_bl1[:BOOT_L1_PATCH]}_MICRON_" + get_micron_id_filterd(id.to_s) + ", PROCESS_NAME: BW3_COMP_SW_UPLOAD" + ", LL: TRUE, " +
        # "RESULT: " + fsResBootl1.to_s.upcase + ", HL: TRUE, MU: BOOLEAN, STATUS: " + firmwareBootl1Status 
      
        # out_file.close
        # sleep 1
        # #write result of bootloaderl2 firmware upgrade
        # out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
        # builded_string = "RUN_ID: " + run_id + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: BOOTLOADERL2_FIRMWARE_UPGRADE_VERSION_#{version_info_bl2[:BOOT_L2_MAJOR]}.#{version_info_bl2[:BOOT_L2_MINOR]}.#{version_info_bl2[:BOOT_L2_PATCH]}_MICRON_" + get_micron_id_filterd(id.to_s) + ", PROCESS_NAME: BW3_COMP_SW_UPLOAD" + ", LL: TRUE, " +
        # "RESULT: " + fsResBootl2.to_s.upcase + ", HL: TRUE, MU: BOOLEAN, STATUS: " + firmwareBootl2Status 
        
        # out_file.close
        # sleep 1
        # #write result of application firmware upgrade
        # out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
        # builded_string = "RUN_ID: " + run_id + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: APPLICATION_FIRMWARE_UPGRADE_VERSION_" + firmwareVersion + "_MICRON_" + get_micron_id_filterd(id.to_s) + ", PROCESS_NAME: BW3_COMP_SW_UPLOAD" + ", LL: TRUE, " +
        # "RESULT: " + fsRes.to_s.upcase + ", HL: TRUE, MU: BOOLEAN, STATUS: " + firmwareAppStatus 
        
        # out_file.close
        
        if(!resPowerUp || !fsRes || !fsResBootl2 || !fsResBootl1)
            statusAllFirmware = false
        end
    
    #end
    
    #if(resPowerUp)
     #   fsResBootl1 = firmware_update("MIC_LSL", "bl1", pathBootl1, version_info_bl1, file_id = 12, from_golden = 0, microns_list,
     #       broadcast_all: true, reboot: true, use_automations: true)
    #        sleep 2
    #    if(fsResBootl1)
     #       firmwareBootl1Status = "PASS"
     #       resPowerUp,index = change_to_ps2_microns_in_chain(micron_id.to_i,"MIC_LSL",run_id,true, true,false)
     #       if(resPowerUp)
     #           fsResBootl2 = firmware_update("MIC_LSL", "bl2", pathBootl2, version_info_bl2, file_id = 12, from_golden = 0, microns_list,
     #               broadcast_all: true, reboot: true, use_automations: true)
      #              sleep 2        
      #          if(fsResBootl2)
     #               resPowerUp,index = change_to_ps2_microns_in_chain(micron_id.to_i,"MIC_LSL",run_id,true, true,false)
     #               firmwareBootl2Status = "PASS"
     #               if(resPowerUp)
     #                   fsRes = firmware_update("MIC_LSL", "app", path, version_info_app, file_id = 12, from_golden = 0, microns_list,
      #                  broadcast_all: true, reboot: true, use_automations: true)
      #                  if(fsRes)
      #                      firmwareAppStatus = "PASS"
     #                   end
     #               end
     #           end
     #       end
                
     #   end

    #end
    #write result of bootloaderl1 firmware upgrade
   # out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
   # builded_string = "RUN_ID: " + run_id + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: BOOTLOADERL1_FIRMWARE_UPGRADE_MICRON_" + micron_id.to_s + ", LL: TRUE, " +
   # "RESULT: " + fsResBootl1.to_s.upcase + ", HL: TRUE, MU: BOOLEAN, STATUS: " + firmwareBootl1Status
   
    
    #write result of bootloaderl2 firmware upgrade
   # out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
   # builded_string = "RUN_ID: " + run_id + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: BOOTLOADERL2_FIRMWARE_UPGRADE_MICRON_" + micron_id.to_s + ", LL: TRUE, " +
    #"RESULT: " + fsResBootl2.to_s.upcase + ", HL: TRUE, MU: BOOLEAN, STATUS: " + firmwareBootl2Status
   

    #write result of application firmware upgrade
   # builded_string = "RUN_ID: " + run_id + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: APPLICATION_" + firmwareVersion + " _FIRMWARE_UPGRADE_MICRON_" + micron_id.to_s + ", LL: TRUE, " +
   # "RESULT: " + fsRes.to_s.upcase + ", HL: TRUE, MU: BOOLEAN, STATUS: " + firmwareAppStatus
   
   # out_file.close
 
    if(!is_ring)
        if(!power_off_power_supply(micron_id,apc))
            return false
        end
        resReboot = reboot_microns_in_chain(micron_id.to_i, file_info, true,"MIC_LSL",run_id ,index)
        if(!resReboot)
            return false
        end
    end
    #    #write result of sw upgrade
    #    out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
    #    keys = status.keys
    #    values = status.values
    #    for i in 0..keys.length()
    #        if(keys[i] == nil)
    #            next
    #        end
    #        bool_status = false
    #        if(values[i] == "PASS")
    #            bool_status = true
    #        end
    #        builded_string = "RUN_ID: " + run_id + " DATE_TIME: " + time.strftime("%Y-%m-%d %H:%M:%S") + ", TEST_NAME: " + version_info + " _FPGA_UPGRADE_MICRON_" + get_micron_id_filterd(keys[i]) + ", PROCESS_NAME: BW3_COMP_FPGA_UPLOAD" + ", LL: TRUE, " +
    #        "RESULT: " + bool_status.to_s.upcase + ", HL: TRUE, MU: BOOLEAN, STATUS: " + values[i]
    
           
    #    end
    #    out_file.close
        #resReboot = set_target_off_traj_off(micron_id.to_i,run_id, true,true,false) && resReboot
    #if(resPowerUp && fsRes && fsResBootl2 && fsResBootl1)
       #return true
    #end
    return statusAllFirmware
end


#Update FPGA version
def update_FPGA(micron_id, file_info, apc, run_id = "", microns_list = nil, is_ring = false)
    version_hash = get_micron_version()
    version_info = version_hash['post_fpga']
    fpga_filename = version_hash['fpga_file']

    path = "C:\\Cosmos\\ATE\\FPGA_VERSION\\" + version_info + "\\" + fpga_filename
    fsRes = false
    fpgaStatus = "FAIL"
    time = Time.new
    resPowerUp = true
    resReboot = true
    all_ring_microns_id = []
    if(microns_list == nil)
        microns_list = get_micron_id_list(micron_id).reverse()
    end
    # else
    #     for micron_idd in microns_list
    #         micron_id_list = get_micron_id_list(micron_idd)
    #         for id in micron_id_list
    #             all_ring_microns_id.append(id)
    #         end
    #     end
    #     microns_list = all_ring_microns_id.uniq.reverse()
    #     #puts all_ring_microns_id.sort
    # end
    #sleep(30)
    if(!is_ring)
        #resPowerUp = true
        resPowerUp = set_target_ps2_traj_ps2(micron_id.to_i, apc, file_info, run_id)
    end
    #resPowerUp = true
    #set_target_operational_traj_off(micron_id.to_i,ARGV[1])
    #Added SW upload version
    if(resPowerUp)
        #added FPGA upload
        begin
            #sleep 30
 
            fpgaRes, status = micron_fpga_update("MIC_LSL", path, version_info, microns_list, file_id: 25, entry_size: 1754, broadcast_all: true, reboot: false, do_file_check: false, use_automations: true)
            #if exception didnt accured
            if(fpgaRes)
                fpgaStatus = "PASS"
            end
            
            # if no exception, will execute successfully
        rescue TypeError
            puts "Error in fpga update, see logs"
            #puts TestException.msg
           
    
        end
   
        #write result of fpga upgrade
        
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

            write_to_log_file(run_id, time, "#{version_info}_FPGA_UPGRADE_MICRON_#{get_micron_id_filterd(keys[i])}",
            "TRUE", "TRUE", bool_status, "BOOLEAN", values[i], "BW3_COMP_FPGA_UPLOAD", file_info)
            
        end
       
    end
   
   

    if(!is_ring)
        resReboot = set_target_off_traj_off(micron_id.to_i, apc,run_id, true,true,false)
    end
    if(resPowerUp && fpgaRes && resReboot)
       return true
    end
    return false
end

#Update FPGA and firmware version
def update_FPGA_and_firmware(micron_id,apc,run_id = "",is_ring = false, microns_list = nil)
    
    microns_list = get_micron_id_list(micron_id)
    firmwareAppStatus = "FAIL"
    firmwareBootl2Status = "FAIL"
    fpgaStatus= "FAIL"
    fsResBootl2 = false
    fsRes = false
    fpgaRes = false
    time = Time.new

    update_firmware = update_firmware(micron_id,apc,run_id,microns_list,is_ring)
    update_fpga = update_FPGA(micron_id,apc,run_id, microns_list, is_ring)
    
end

def get_micron_id_filterd(micron_id)
    filtered = ("MICRON_" + micron_id.to_s)[-3..-1].delete('ON_')
    if(filtered.to_s.length() == 1)
        filtered = "00" + filtered.to_s
    end
    if(filtered.to_s.length() == 2)
        filtered = "0" + filtered.to_s
    end
    return filtered.to_s
end

def get_micron_id_list(micron_id)
    microns_list = []
    handle_routing = HandleRouting.new
    micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id)
    for id in micron_id_ring
        microns_list.append(id[-3..-1].delete('ON_').to_i)
    end
    
    microns_list.append(micron_id)
    return microns_list
end

# def ping_target_traj_ps2(micron_id)
#     return set_target_ps2_traj_ps2(micron_id)
# end

def convert_string_ring_to_list(ring)
    selected_ring = $micron_id_ring_A
    if(ring == "B")
        selected_ring = $micron_id_ring_B
    end
    if(ring == "C")
        selected_ring = $micron_id_ring_C
    end
    if(ring == "D")
        selected_ring = $micron_id_ring_D
    end
    if(ring == "E")
        selected_ring = $micron_id_ring_E
    end
    if(ring == "F")
        selected_ring = $micron_id_ring_F
    end
    return selected_ring
end

def get_rings_list(ring)

    if ring.to_s.upcase == 'A'
        return ['A']
    end
    if ring.to_s.upcase == 'B'
        return ['A','B']
    end
    if ring.to_s.upcase == 'C'
        return ['A','B','C']
    end
    if ring.to_s.upcase == 'D'
        return ['A','B','C','D']
    end
    if ring.to_s.upcase == 'E'
        return ['A','B','C','D','E']
    end
    if ring.to_s.upcase == 'F' || ring.to_s.upcase == 'ARRAY'
        return ['A','B','C','D','E','F']
    end

end

def power_on_ring_to_ps2(ring, apc, out_file, run_id = "", safety = true)
    
    version_hash = get_micron_version()
    with_pcdu = version_hash['with_pcdu'].to_s.downcase == 'true'

    # all_ring_is_on = true
    
    # for micron_id in selected_ring
	
    #     #power on and send ping to micron 
    #     #ping_res = ping_target_traj_off(micron_id,ARGV[1])
    #     power = set_target_ps2_traj_ps2(micron_id, apc, out_file, run_id,true,true,disabledDoner)
    #     if(!power)
    #         all_ring_is_on = false
    #     end
        
    # end
    # return all_ring_is_on,selected_ring

    #if ring is F, turn on trajectory
    if ring == "F" && ring != "Array"
        all_ring_is_on = true
        selected_ring = convert_string_ring_to_list(ring)
        selected_ring.each do |micron_id|
            power = set_target_ps2_traj_ps2(micron_id, apc, out_file, run_id, safety, safety, true)
            if !power
                all_ring_is_on = false
            end
        end
        return all_ring_is_on
    else
        if apc.to_s.upcase == "APC_YM" 
            options = RoutingOptions.lsl_reroute_ym
        else
            options = RoutingOptions.lsl_reroute_yp
        end

        options[:rings_filter] = get_rings_list(ring)

        board = 'MIC_LSL'

        powering = ModuleMicronRapidPower.new(board, options)

        return powering.power_up('PS2',run_id, out_file, safety, with_pcdu)
    end
end

def change_to_reduced(micron_id,run_id)
      # send ping to micron 
      ret_ping = ping_by_micron_id(micron_id,"MIC_LSL",run_id)
      if(ret_ping == "FAIL")
          return false
      end
      
      #Set next power mode
      return change_mode(micron_id,"REDUCED")
     
end
# def power_on_ring(ring)
#     ring_list = get_specific_ring(ring).reverse()

#     ring_list.each do |micron_id|
#         ps2 = change_mode(micron_id,"PS2")
        
#     end
# end

def check_mode(micron_id, out_file, mode, run_id = "", with_check = true)
    #Checking if micron changed already to mode
    mode = mode.to_s.upcase.strip
    fs = MICRON_MODULE.new 
    time = Time.new
    power_mode_status = "PS1"
    get_power_mode_hash_converted = fs.get_system_power_mode(board="MIC_LSL", micron_id, true, false,1)
    if get_power_mode_hash_converted != []
        get_power_mode_hash_converted = get_power_mode_hash_converted[0]
        power_mode_status = get_power_mode_hash_converted["MIC_CURRENT_SYSTEM_POWER_MODE"]
    end
    
    state = (power_mode_status == mode)
    status = (state ? "PASS": "FAIL")
    #if without checking mode validation then print pass
    if !with_check
        state = true
        status = "PASS"
        mode = power_mode_status
    end
    if out_file != nil
        write_to_log_file(run_id, time, "GET_POWER_MODE_#{mode.to_s.upcase}_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE", state, "BOOLEAN", status, "BW3_COMP_SAFETY", out_file)
    end

    if power_mode_status == mode
        puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id}"
        return true, power_mode_status
    end
    return false, power_mode_status
end



def reboot_ring(ring, file_info, run_id = "")
    time = Time.new
    fs = MICRON_MODULE.new 
    isAllReboot = "PASS"
    all_reboot = get_specific_ring(ring,true)
   
    all_reboot.each do |micron_id|
        micron = "MICRON_#{micron_id}"
        reboot = fs.sys_reboot(board="MIC_LSL",micron , converted=false, raw=false, wait_check_timeout=1)
        puts "SYS REBOOT - MICRON_ID = #{micron}"
        sleep 4
        #Validating that ping faild to micron 
        if(ping_by_micron_id(micron,board="MIC_LSL",run_id,false) == "FAIL")
            bool_flag = true
            #isAllReboot = "PASS"
            specific_reboot = "PASS"
            #isAllReboot = "PASS"
            puts "REBOOT MICRON_ID = #{micron}  - PASS"
        else
            bool_flag = false
            isAllReboot = "FAIL"
            specific_reboot = "FAIL"
            puts "REBOOT MICRON_ID = #{micron}  - FAIL"
        end
        write_to_log_file(run_id, time, "SET_POWER_MODE_PS1_MICRON_#{get_micron_id_filterd(micron)}",
        "TRUE", "TRUE", bool_flag, "BOOLEAN", specific_reboot, "BW3_COMP_SAFETY", file_info)
        
    end
    
    return isAllReboot
end
def change_to_reduced_broadcast(ring, apc,run_id = "", is_ring = true, micron_id = 0)
    threads = []
    if(!is_ring)
        ring_list = get_micron_id_list(micron_id).reverse()
    else
        ring_list = get_specific_ring(ring)
    end
    
    all_reduced_successed = true
 
    ring_list.each do |micron_id|
        threads << Thread.new { Thread.current[:output] = change_to_reduced(micron_id,run_id) }
    end  
      threads.each do |t|
        t.join
        if t[:output] == false
            all_reduced_successed = false
        end
      end
      return all_reduced_successed
end

def power_on_ring_to_reduced(ring, out_file, apc,run_id = "")
    selected_ring = convert_string_ring_to_list(ring)
    board = "MIC_LSL"
    all_ring_is_on = true
    power = power_on_ring_to_ps2(ring, out_file, apc,run_id)
    if(!power)
        return power_off_ring(ring, out_file, apc, run_id)
    end
    # return change_to_reduced_broadcast(ring, apc,run_id)
    for micron_id in selected_ring
	
    #     #power on and send ping to micron 
    #     #ping_res = ping_target_traj_off(micron_id,ARGV[1])
    #     power = set_target_ps2_traj_ps2(micron_id,apc,run_id,true,true,true)
    #     if(power)
        reduced = change_to_reduced_mode_microns_in_chain(micron_id, out_file, apc,run_id,board)
        if(reduced == "FAIL")
            all_ring_is_on = false
        end
    #     end
    end

    return all_ring_is_on,selected_ring
end

def verify_micron_software_version(microns, run_id, out_file)
    start_time = Time.now
    result = Array.new(microns.length) { false }
      microns.each_with_index do |micron_id, i|
        result[i] = verify_sw_version(micron_id, out_file, run_id)
      end
    return result.all?
end

def verify_micron_fpga_version(microns, run_id, out_file)
    start_time = Time.now
    result = Array.new(microns.length) { false }
      microns.each_with_index do |micron_id, i|
        result[i] = verify_fpga_version(micron_id, out_file, run_id)
      end
    return result.all?
end

def move_ring_to_mode_and_validate(ring, mode, run_id = "", all_rings_until = false, microns = nil, out_file = nil)
    micron = MICRON_MODULE.new
    if microns == nil
        microns = get_specific_ring(ring, all_rings_until)
    end

    #try to ping all the microns
    #if(ping_microns(microns))
         #send move to reduced to all the ring
        microns.each do |micron_id|
            micron.set_system_power_mode("MIC_LSL", "MICRON_#{micron_id}", mode, true, false, 0.1)[0]
        end
    #else
        #return false
    #end

    sleep 15

    return check_change_mode(microns, ring, mode, run_id, out_file)
    
end

def config_fpga(microns)
    fs = MICRON_MODULE.new 
    dl_freq = get_micron_version()['down_link_freq'].to_f
    ul_freq = get_micron_version()['up_link_freq'].to_f
    microns.each do |micron_id|
        set_fpga = fs.set_fpga_freq_param("MIC_LSL", micron_id, true, false, 0.2, "10MHz", dl_freq, "10MHz", ul_freq)
        if set_fpga != []
            set_fpga = set_fpga[0]
        end
        puts "Config FPGA to CW for micron id - #{micron_id}"
    end  
end

def config_fpga_w_params(microns, dl_freq, ul_freq)
    fs = MICRON_MODULE.new
    responses = {} 
    microns.each do |micron_id|
        set_fpga = fs.set_fpga_freq_param("MIC_LSL", micron_id, true, false, 0.2, "10MHz", dl_freq, "10MHz", ul_freq)
        if set_fpga != []
            responses[micron_id.to_s] = set_fpga[0]
        end
    end 
    return responses 
end



def fpga_temperature(microns, file_info, run_id)
    result = Array.new(microns.length) { false }   
        microns.each_with_index do |micron_id, i|
            result[i] = check_fpga_temperature(micron_id, file_info, run_id.to_s)
        end 
    return result.all?
end

def ping_all(microns, out_file, run_id)
    result = Array.new(microns.length) { false }   
    microns.each_with_index do |micron_id, i|
        result[i] = (ping_by_micron_id(micron_id, out_file, "MIC_LSL", run_id) == "PASS" ? true: false)
    end
    return result.all?
end

def default_routing_check(microns, out_file, run_id)
    result = Array.new(microns.length) { false }   
    microns.each_with_index do |micron_id, i|
        result[i] = get_micron_default_routing("MICRON_#{micron_id}", out_file, run_id)
    end
    return result.all?
end

def power_mode_scan(microns, out_file, run_id, mode = "PS2", with_check = true)
    result = Hash.new
    final_status = true
    microns.each do |micron_id|
        status, mode = check_mode(micron_id, out_file, mode, run_id, with_check)
        final_status &= status
        result[micron_id] = mode
    end
    return result, final_status
end

def configure_cpbf_read_pd(microns, run_id, file_info, ll_pd_before, hl_pd_before)
    result = Array.new(microns.length) { false }
    fs = MICRON_MODULE.new 
    cpbf = ModuleCPBF.new

    microns.each_with_index do |micron_id, i|
        result_fems = Array.new(16) { false }
        for fem_id in 0x0..0xf
            time = Time.new
            reg1_addr = 0x0817c
            reg2_addr = 0x08180
            shifting = fem_id << 2**4 #shifting to the MSB 0x10000 for example
            res_reg1 = reg1_addr|shifting #adding the shifted number to the address
            res_reg2 = reg2_addr|shifting
            cpbf_write_reg1 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", res_reg1, 0x1, 1000, 0.1)[0]
            cpbf_write_reg2 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", res_reg2, 0x0b680000, 1000, 0.1)[0]
            #Uncomment if you want to read PD after CW
            sleep 0.5
            det_meas_before_dsa = -1
            det_meas = fs.get_det_meas("MIC_LSL", micron_id, true, false, 0.5,fem_id)
            if det_meas != []
                det_meas = det_meas[0]
                det_meas_before_dsa = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
            end
            
            # result_fems[fem_id] = (det_meas_before_dsa < hl_pd_before && det_meas_before_dsa > ll_pd_before)
            # fem_string = "FEM_"
            # if(fem_id < 10)
            #     fem_string = fem_string + "0"
            # end
            # #write result pd before dsa
            # write_to_log_file(run_id, time, "DL_#{fem_string}#{fem_id}_PD_BEFORE_DSA_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
            # hl_pd_before.to_s, ll_pd_before.to_s, det_meas_before_dsa, "FLOAT", (result_fems[fem_id] ? "PASS": "FAIL"), "BW3_COMP_RF", file_info)
            puts "FEM_#{fem_id} - MIC_FEM_TX_FWD_DETECTOR_BEFORE_DSA_for_micron_id_#{micron_id} - #{det_meas_before_dsa.to_s}"
            # puts "FEM_#{fem_id} - MIC_FEM_RESULT_CODE_BEFORE_DSA - #{det_meas["MIC_FEM_RESULT_CODE"]}"
        end
        #Uncomment if you want to read PD after CW
        #result[i] = result_fems.all?
    end
    #Uncomment if you want to read PD after CW
    #return result.all?
end

def set_dsa_read_pd(microns, run_id, out_file, ll_after_dsa, hl_after_dsa, ll_dbm, hl_dbm)
    result = Array.new(microns.length) { false }
    fs = MICRON_MODULE.new 
    # timeout = 2
    # while !result.all? && timeout.positive?
    #     next if result[i]
    dsa_val = get_micron_version()['dsa_val'].to_f
        microns.each_with_index do |micron_id, i|
            result_fems = Array.new(16) { false }
            for fem_id in 0x0..0xf
                time = Time.new
                fs.set_dsa_val("MIC_LSL", micron_id, true, false, 0.2, fem_id, "TX", dsa_val)
                #Uncomment if PD reading needed
                #Read FEM Vfw detector and verify signal detected
                sleep 0.5
                det_meas = fs.get_det_meas("MIC_LSL", micron_id, true, false, 0.5,fem_id)
                det_meas_after_dsa = -1
                if det_meas != []
                    det_meas = det_meas[0]
                    det_meas_after_dsa = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
                end
              
                
                #det_meas_after_dsa = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
                # result_fems[fem_id] = (det_meas_after_dsa < hl_after_dsa && det_meas_after_dsa > ll_after_dsa)
                # fem_string = "FEM_"
                # if(fem_id < 10)
                #     fem_string = fem_string + "0"
                # end
                # #write result pd after dsa
                # write_to_log_file(run_id, time, "DL_#{fem_string}#{fem_id}_PD_AFTER_DSA_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                # hl_after_dsa.to_s, ll_after_dsa.to_s, det_meas_after_dsa, "FLOAT", (result_fems[fem_id] ? "PASS": "FAIL"), "BW3_COMP_RF", out_file)
                
                # dbm =  (24.2*det_meas_after_dsa -11.33)
                # puts "FEM_#{fem_id} - PD_DBM_AFTER_DSA - #{dbm.to_s}"
                # dbm_status = "FAIL"
                # if(dbm < hl_dbm && dbm > ll_dbm)
                #     dbm_status = "PASS"
                # end
                # #write result in dbm after dsa
                # write_to_log_file(run_id, time, "DL_#{fem_string}#{fem_id}_PD_AFTER_DSA_IN_DBM_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                # hl_dbm.to_s, ll_dbm.to_s, dbm, "FLOAT", dbm_status, "BW3_COMP_RF", out_file)
                puts "FEM_#{fem_id} - MIC_FEM_TX_FWD_DETECTOR_AFTER_DSA_for_micron_id_#{micron_id} - #{det_meas_after_dsa.to_s}"
                # puts "FEM_#{fem_id} - MIC_FEM_RESULT_CODE_AFTER_DSA - #{det_meas["MIC_FEM_RESULT_CODE"]}"
            end
            #Uncomment if PD reading needed
            #result[i] = result_fems.all?
        end
        #Uncomment if PD reading needed
    #     timeout -= 1 
    # end
    #return result.all?
end





def verify_battries(microns, run_id, out_file, ll = 50, hl = 100)
    start_time = Time.now
    result = Array.new(microns.length) { false }

      microns.each_with_index do |micron_id, i|
        result[i] = check_batteries_soc(micron_id, out_file, run_id)
      end

    # NOTICE: if one micron does not report battery OK, return false
    result.all?
end

def verify_battries_temperature(microns, run_id, out_file)
    start_time = Time.now
    result = Array.new(microns.length) { false }

      microns.each_with_index do |micron_id, i|
        result[i] = check_batteries_temperature(micron_id, out_file, run_id)
      end

    # NOTICE: if one micron does not report battery OK, return false
    result.all?
end

def power_off_cw(microns)
    cpbf = ModuleCPBF.new
    microns.each_with_index do |micron_id, i|
        for fem_id in 0x0..0xf
            reg1_addr = 0x0817c
            reg2_addr = 0x08180
            shifting = fem_id << 2**4 #shifting to the MSB 0x10000 for example
            res_reg1 = reg1_addr|shifting #adding the shifted number to the address
            res_reg2 = reg2_addr|shifting
            cpbf_write_reg1 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE",res_reg1, 0, 1000 )[0]
            cpbf_write_reg2 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", res_reg2, 0, 1000)[0]
        end
    end
end

def validate_pd_value(microns, run_id, out_file, ll, hl, text)
    fs = MICRON_MODULE.new
    result = Array.new(microns.length) { false }
    
    microns.each_with_index do |micron_id, i|
        fem_result = Array.new(16) { false }
        for fem_id in 0x0..0xf
            pdet_meas = -1
            det_meas = fs.get_det_meas("MIC_LSL", micron_id, true, false, 1,fem_id)
            if det_meas != []
                det_meas = det_meas[0]
                puts "MIC_FEM_TX_FWD_DETECTOR - #{det_meas["MIC_FEM_TX_FWD_DETECTOR"]}"
                puts "MIC_FEM_RESULT_CODE - #{det_meas["MIC_FEM_RESULT_CODE"]}"
                pdet_meas = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
            end
            
            fem_result[fem_id] = ((pdet_meas < hl) && (pdet_meas > ll))
            puts "Start PD Value - #{pdet_meas}"
            write_to_log_file(run_id, time, "DL_#{fem_string}#{fem_id}_PD_#{text}_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
            hl.to_s, ll.to_s, pdet_meas, "FLOAT", (fem_result[fem_id] ? "PASS": "FAIL"), "BW3_COMP_RF", out_file)
            
            
        end
        result[i] = fem_result.all?
    end
    return result.all?
end

def new_cw_dl(ring, run_id, out_file, ll_pd_before = 0.8, hl_pd_before = 1.7, ll_after_dsa = 1.2, hl_after_dsa = 1.8, ll_dbm = 4, hl_dbm = 6, cw_on = true)
    fs = MICRON_MODULE.new 
    cpbf = ModuleCPBF.new
    #Iterate over microns list on each operation
    microns = get_specific_ring(ring)
    #If the battery level is lower then 90, stop the test
    return false unless verify_battries(microns, run_id, out_file, 90)
    #configure the FPGA
    config_fpga(microns)
    #move all the microns to operational mode
    return false unless move_ring_to_mode_and_validate(ring, "OPERATIONAL", run_id, false)
    #verify the temperature of the battery
    return false unless verify_battries_temperature(microns, run_id, out_file)
    #verify the temperature of the FPGA
    return false unless fpga_temperature(microns, out_file, run_id)
    #validate that the PD is equal to ~0
    return false unless validate_pd_value(microns, run_id, out_file, 0, 0.5,"START_VALUE")
    #configure the cw and read PD after
    return false unless configure_cpbf_read_pd(microns, run_id, out_file, ll_pd_before, hl_pd_before)
    #verify the temperature of the FPGA
    return false unless fpga_temperature(microns, out_file, run_id)
    #configure DSA and read PD after
    return false unless set_dsa_read_pd(microns, run_id, out_file, ll_after_dsa, hl_after_dsa, ll_dbm, hl_dbm)
    #verify the temperature of the FPGA
    return false unless fpga_temperature(microns, out_file, run_id)
    #Power off cw
    power_off_cw(microns) unless cw_on
end



def cw_pd_dl_test(micron_id, file_info, run_id = "", ll_pd_before = 0, hl_pd_before = 2, ll_after_dsa = 1.2, hl_after_dsa = 1.8, ll_dbm = 4, hl_dbm = 6)
    fs = MICRON_MODULE.new 
    cpbf = ModuleCPBF.new
    time = Time.new
    board = "MIC_LSL"
    all_fems_pass_test = false
    fem_pass = true
    loop_tracker = true
    dsa_val = get_micron_version()['dsa_val'].to_f
    #low limit to start the test is 90
    soc = check_batteries_soc(micron_id, file_info, run_id.to_s,90)
    if(!soc)
        return false
    end
    #resPowerUp = set_target_ps2_traj_ps2(micron_id.to_i,run_id)
    #if(resPowerUp)
    #Configure FPGA HLP 
    fpga_hlp = fs.set_fpga_freq_param(board, micron_id)[0]
    #Verify the FPGA HLP command is succeeded 
    puts "MIC_FPGA_RESULT_CODE - #{fpga_hlp["MIC_FPGA_RESULT_CODE"]}"
    #puts "MIC_FEM_RX_FWD_DETECTOR - #{fpga_hlp["MIC_FEM_RX_FWD_DETECTOR"]}"
    if(fpga_hlp["MIC_FPGA_RESULT_CODE"] == "SUCCESS")
        #Move UUT to Operational power mode 
        #if(change_to_operational_mode_microns_in_chain(micron_id,board,run_id,true,true) == "PASS")
        #Set next power mode to operational
        ret_change_mode = change_mode(micron_id,"OPERATIONAL")
        sleep 8
        write_to_log_file(run_id, time, "SET_POWER_MODE_OPERATIONAL_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE", ret_change_mode, "BOOLEAN", (ret_change_mode ? "PASS": "FAIL"), "BW3_COMP_SAFETY", file_info)

        soc = check_batteries_soc(micron_id, file_info, run_id.to_s)
        bat_temperature = check_batteries_temperature(micron_id, file_info, run_id.to_s, 20, 50)
        fpga_temperature = check_fpga_temperature(micron_id, file_info, run_id.to_s)
        if(!bat_temperature || !soc || !fpga_temperature)
            return false
        end
        if(ret_change_mode == true)
            #for all the FEM's in the Micron
            for fem_id in 0x0..0xf
                time = Time.new
                fem_pass = false
                fem_status = "FAIL"
                fem_before_status = "FAIL"
                det_meas_after_dsa = -1
                det_meas_before_dsa = -1
                fpga_temperature = check_fpga_temperature(micron_id, run_id.to_s)
                if(!fpga_temperature)
                    break
                end
                #Read FEM Vfw detector and verify no signal detected 
                det_meas = fs.get_det_meas(board, micron_id, true, false, 1,fem_id)[0]
                puts "MIC_FEM_TX_FWD_DETECTOR - #{det_meas["MIC_FEM_TX_FWD_DETECTOR"]}"
                puts "MIC_FEM_RESULT_CODE - #{det_meas["MIC_FEM_RESULT_CODE"]}"
                pdet_meas = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
                if(pdet_meas >= 0 && pdet_meas < 0.5  && det_meas["MIC_FEM_RESULT_CODE"] == "SUCCESS")
                    reg1_addr = 0x0817c
                    reg2_addr = 0x08180
                    shifting = fem_id << 2**4 #shifting to the MSB 0x10000 for example
                    res_reg1 = reg1_addr|shifting #adding the shifted number to the address
                    res_reg2 = reg2_addr|shifting
                    #Turn ON CW – 15 dBFS from FPGA source
                    #try write to the second register 0xccd0000
                   # cpbf_micron_rw_reg_cmd(micron_id, rw_flag, reg_addr, data, timeout_ms, wait_check_timeout=0.2)
                    cpbf_write_reg1 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", 0x1, 1000, res_reg1)[0]
                    cpbf_write_reg2 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", 0x0b680000, 1000, res_reg2)[0]
                    puts "FEM_#{fem_id} - WRITE_0x1_TO_REG_ADDR - #{res_reg1} - #{cpbf_write_reg1["RESPONSE_CODE"]}"
                    puts "FEM_#{fem_id} - WRITE_0x0b680000_TO_REG_ADDR - #{res_reg2} - #{cpbf_write_reg2["RESPONSE_CODE"]}"
                    sleep 1
                    if(cpbf_write_reg1["RESPONSE_CODE"] == "SUCCESS" && cpbf_write_reg2["RESPONSE_CODE"] == "SUCCESS")
                        #Read FEM Vfw detector and verify signal detected
                        det_meas = fs.get_det_meas(board, micron_id, true, false, 1,fem_id)[0]
                        det_meas_before_dsa = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
                        puts "FEM_#{fem_id} - MIC_FEM_TX_FWD_DETECTOR_BEFORE_DSA - #{det_meas_before_dsa.to_s}"
                        puts "FEM_#{fem_id} - MIC_FEM_RESULT_CODE_BEFORE_DSA - #{det_meas["MIC_FEM_RESULT_CODE"]}"
                        
                        if(det_meas_before_dsa < hl_pd_before && det_meas_before_dsa > ll_pd_before)
                            fem_before_status = "PASS"
                            #Set DSA to 10 
                            fs.set_dsa_val(board, micron_id, true, false, 0.2, fem_id, "TX", dsa_val)
                            #Read FEM Vfw detector and verify signal detected
                            sleep 1
                            det_meas = fs.get_det_meas(board, micron_id, true, false, 1,fem_id)[0]
                            det_meas_after_dsa = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
                            puts "FEM_#{fem_id} - MIC_FEM_TX_FWD_DETECTOR_AFTER_DSA - #{det_meas_after_dsa.to_s}"
                            puts "FEM_#{fem_id} - MIC_FEM_RESULT_CODE_AFTER_DSA - #{det_meas["MIC_FEM_RESULT_CODE"]}"

                            if(det_meas_before_dsa < hl_after_dsa && det_meas_after_dsa > ll_after_dsa)
                                fem_pass = true
                                fem_status = "PASS"
                                puts "FEM_#{fem_id} - #{fem_status}"
                            end
                        end
                    end
                    
                    #Turn off the CW of specific FEM
                    #cpbf_write_reg1 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE",res_reg1, 0, 1000 )[0]
                    #cpbf_write_reg2 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", res_reg2, 0, 1000)[0]
                    sleep 1 
                end
                #write result of each fem
                fem_string = "FEM_"
                if(fem_id < 10)
                    fem_string = fem_string + "0"
                end
                dbm =  (24.2*det_meas_after_dsa -11.33)
                puts "FEM_#{fem_id} - PD_DBM_AFTER_DSA - #{dbm.to_s}"
                dbm_status = "FAIL"
                if(dbm < hl_dbm && dbm > ll_dbm)
                    dbm_status = "PASS"
                end
                #write result pd before dsa
                write_to_log_file(run_id, time, "DL_#{fem_string}#{fem_id}_PD_BEFORE_DSA_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                hl_pd_before.to_s, ll_pd_before.to_s, det_meas_before_dsa, "FLOAT", fem_before_status, "BW3_COMP_RF", file_info)

                #write result pd after dsa
                write_to_log_file(run_id, time, "DL_#{fem_string}#{fem_id}_PD_AFTER_DSA_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                hl_after_dsa.to_s, ll_after_dsa.to_s, det_meas_after_dsa, "FLOAT", fem_status, "BW3_COMP_RF", file_info)

                #write result in dbm after dsa
                write_to_log_file(run_id, time, "DL_#{fem_string}#{fem_id}_PD_AFTER_DSA_IN_DBM_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                hl_dbm.to_s, ll_dbm.to_s, dbm, "FLOAT", dbm_status, "BW3_COMP_RF", file_info)

                loop_tracker = loop_tracker & fem_pass
            end
            if(loop_tracker)
                all_fems_pass_test = true
            else
                write_to_log_file(run_id, time, "DL_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                "TRUE", "TRUE", loop_tracker, "BOOLEAN", "FAIL", "BW3_COMP_RF", file_info)

            end
        end
    end

    return all_fems_pass_test
    
end



def write_to_log_file(run_id, time, test_name, hl, ll, result, mu, status, process, file_info)
    begin
        builded_string = "RUN_ID: #{run_id.to_s} DATE_TIME: #{time.strftime("%Y-%m-%d %H:%M:%S")}, TEST_NAME: #{test_name}, PROCESS_NAME: #{process}, LL: #{ll}, " +
        "RESULT: #{result.to_s.upcase}, HL: #{hl}, MU: #{mu}, STATUS: #{status}"
        file_info.puts(builded_string)
        file_info.flush
    rescue
    end
end

def check_change_mode(microns, ring, mode, run_id = "", out_file = nil)
    #check if the mode changed
    result = Array.new(microns.length) { false }
 
      microns.each_with_index do |micron_id, i|
        next if result[i]
        #check if all the ring moved to reduced
        ret, mo = check_mode(micron_id, out_file, mode, run_id)
        result[i] = ret
        puts "RET - #{ret}, MODE - #{mo}"
        puts "Move to #{mode} for Micron - #{micron_id} - #{result[i]}"
      end
    puts "Move to #{mode} for all ring #{ring} - #{result.all?}"
    
    return result.all?
end

def ping_microns(microns)
    micron = MICRON_MODULE.new
    timeout = 5
    result = Array.new(microns.length) { false }
    while !result.all? && timeout.positive?
      microns.each_with_index do |micron_id, i|
        next if result[i]

        result[i] = micron.ping_micron("MIC_LSL", "MICRON_#{micron_id}", false, false, 0.2)
        puts "Ping Micron #{micron_id} - #{result[i]}"
      end

      next if result.all?

      sleep(1)
      timeout -= 1
    end

    return result.all?
  end

  def power_off_ring(ring, file_info, apc, run_id = "")
    # selected_ring = convert_string_ring_to_list(ring)
    # power_ring = [104,93,120,107,77,78,119,90]
    # all_ring_is_off = true
    # board="MIC_LSL"
    
    # for micron_id in power_ring
	
    #     #power on and send ping to micron 
    #     #ping_res = ping_target_traj_off(micron_id,ARGV[1])
    #     if(!power_off_power_supply(micron_id, apc))
    #         all_ring_is_off = false
    #     end
    #     #power_off = reboot_microns_in_chain(micron_id,true,board,run_id,1,true)
    # end
    # power_off = reboot_ring(ring, file_info, run_id)
    # #power_off = set_target_off_traj_off(micron_id,run_id, false, false, false)
    # if(power_off == "FAIL")
    #     all_ring_is_off = false
    # end
    # return all_ring_is_off,selected_ring

    version_hash = get_micron_version()
    with_pcdu = version_hash['with_pcdu'].to_s.downcase == 'true'
    
    if apc.to_s.upcase == "APC_YM" 
        options = RoutingOptions.lsl_reroute_ym
    else
        options = RoutingOptions.lsl_reroute_yp
    end
    options[:rings_filter] = get_rings_list(ring)

    board = 'MIC_LSL'

    powering = ModuleMicronRapidPower.new(board, options)

    return powering.power_down(run_id, file_info, with_pcdu)
end

def cw_pd_dl_ota_test(micron_id, file_info, run_id = "")
    fs = MICRON_MODULE.new 
    cpbf = ModuleCPBF.new
    time = Time.new
    board = "MIC_LSL"
    all_fems_pass_test = false
    fem_pass = true
    loop_tracker = true
    ll_pd = 1.27
    hl_pd = 1.5
    #low limit to start the test is 90
    soc = check_batteries_soc(micron_id, file_info, run_id.to_s,90)
    if(!soc)
        return false
    end
    #resPowerUp = set_target_ps2_traj_ps2(micron_id.to_i,run_id)
    #if(resPowerUp)
    #Configure FPGA HLP 
    fpga_hlp = fs.set_fpga_freq_param(board, micron_id)[0]
    #Verify the FPGA HLP command is succeeded 
    puts "MIC_FPGA_RESULT_CODE - #{fpga_hlp["MIC_FPGA_RESULT_CODE"]}"
    #puts "MIC_FEM_RX_FWD_DETECTOR - #{fpga_hlp["MIC_FEM_RX_FWD_DETECTOR"]}"
    if(fpga_hlp["MIC_FPGA_RESULT_CODE"] == "SUCCESS")
        #Move UUT to Operational power mode 
        #if(change_to_operational_mode_microns_in_chain(micron_id,board,run_id,true,true) == "PASS")
        #Set next power mode to operational
        ret_change_mode = change_mode(micron_id,"OPERATIONAL")
        sleep 8
        write_to_log_file(run_id, time, "SET_POWER_MODE_OPERATIONAL_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE", ret_change_mode, "BOOLEAN", (ret_change_mode ? "PASS": "FAIL"), "BW3_COMP_SAFETY", file_info)

        pd_fems_befor_sa = []
        if(ret_change_mode == true)
            #for all the FEM's in the Micron
            message_box("PLEASE READ SPECTRUM ANALYZER AND VERIFY\nTHAT THERE IS NO SIGNAL DETECTED.", "CONTINUE", false)
            #prompt("PLEASE READ SPECTRUM ANALYZER AND VERIFY THAT THERE IS NO SIGNAL DETECTED.")
            puts "PLEASE READ SPECTRUM ANALYZER AND VERIFY THAT THERE IS NO SIGNAL DETECTED."
            soc = check_batteries_soc(micron_id, file_info, run_id.to_s)
            bat_temperature = check_batteries_temperature(micron_id, file_info, run_id.to_s, 20, 40)
            fpga_temperature = check_fpga_temperature(micron_id, file_info, run_id = "")
            if(!bat_temperature || !soc || !fpga_temperature)
                return false
            end
            #TODO:: Comment the lines 856 - 872 if only check needed
            for fem_id in 0x0..0xf
                fem_pass = false
                fem_status = "FAIL"
                fpga_temperature = check_fpga_temperature(micron_id, run_id.to_s)
                if(!fpga_temperature)
                    break
                end
                #Read FEM Vfw detector and verify no signal detected 
                det_meas = fs.get_det_meas(board, micron_id, true, false, 4,fem_id)[0]
                puts "MIC_FEM_TX_FWD_DETECTOR - #{det_meas["MIC_FEM_TX_FWD_DETECTOR"]}"
                puts "MIC_FEM_RESULT_CODE - #{det_meas["MIC_FEM_RESULT_CODE"]}"
                pdet_meas = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
                pd_fems_befor_sg << pdet_meas
            end
            
            soc = check_batteries_soc(micron_id, file_info, run_id.to_s)
            bat_temperature = check_batteries_temperature(micron_id, file_info, run_id.to_s, 20, 50)
            fpga_temperature = check_fpga_temperature(micron_id, file_info, run_id = "")
            if(!bat_temperature || !soc || !fpga_temperature)
                return false
            end
            #TURNING ON CW
            puts "Turning CW ON"
            message_box("Starting transmit CW signal... ","OK",false)
            for fem_id in 0x0..0xf
                fem_pass = false
                fem_status = "FAIL"
                fpga_temperature = check_fpga_temperature(micron_id, run_id.to_s)
                if(!fpga_temperature)
                    break
                end
                reg1_addr = 0x0817c
                reg2_addr = 0x08180
                shifting = fem_id << 2**4 #shifting to the MSB 0x10000 for example
                res_reg1 = reg1_addr|shifting #adding the shifted number to the address
                res_reg2 = reg2_addr|shifting
                #Turn ON CW – 15 dBFS from FPGA source
                #try write to the second register 0xccd0000
                cpbf_write_reg1 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", 0x1, 1000, res_reg1)[0]
                cpbf_write_reg2 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", 0x0b680000, 1000, res_reg2)[0]
                puts "FEM_#{fem_id} - WRITE_0x1_TO_REG_ADDR - #{res_reg1} - #{cpbf_write_reg1["RESPONSE_CODE"]}"
                puts "FEM_#{fem_id} - WRITE_0x0b680000_TO_REG_ADDR - #{res_reg2} - #{cpbf_write_reg2["RESPONSE_CODE"]}"
                sleep 3
                if(cpbf_write_reg1["RESPONSE_CODE"] == "SUCCESS" && cpbf_write_reg2["RESPONSE_CODE"] == "SUCCESS")
                    #TODO:: add power detector between limits
                    #Read FEM Vfw detector and verify signal detected
                    det_meas = fs.get_det_meas(board, micron_id, true, false, 2,fem_id)[0]
                    det_meas_after_signal = det_meas["MIC_FEM_TX_FWD_DETECTOR"].to_f
                    puts "FEM_#{fem_id} - MIC_FEM_TX_FWD_DETECTOR_AFTER_SIGNAL - #{det_meas_after_signal.to_s}"
                    puts "FEM_#{fem_id} - MIC_FEM_RESULT_CODE_AFTER_SIGNAL - #{det_meas["MIC_FEM_RESULT_CODE"]}"     
                    if(pd_fems_befor_sa[fem_id] == 0 && det_meas_after_signal != 0)
                        fem_pass = true
                        fem_status = "PASS"
                        puts "FEM_#{fem_id} - #{fem_status}"
                    end
                end
                message_box("PLEASE READ SPECTRUM ANALYZER AND VERIFY\nTHAT THERE IS A SIGNAL - CW IS ON.", "CONTINUE", false)
                #write result of each fem
                fem_string = "FEM_"
                if(fem_id < 10)
                    fem_string = fem_string + "0"
                end

                loop_tracker = loop_tracker & fem_pass
                #Turn off the CW of specific FEM
                cpbf_write_reg1 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", 0, 1000, res_reg1)[0]
                cpbf_write_reg2 = cpbf.cpbf_micron_rw_reg_cmd(micron_id, "WRITE", 0, 1000, res_reg2)[0]
                sleep 1

                write_to_log_file(run_id, time, "DL_OTA_#{fem_string}#{fem_id}_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                hl_pd, ll_pd, det_meas_after_signal, "FLOAT", fem_status, "BW3_COMP_RF", file_info)
        
            end

            if(loop_tracker)
                all_fems_pass_test = true
            else
                write_to_log_file(run_id, time, "DL_OTA_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                "TRUE", "TRUE", loop_tracker, "BOOLEAN", "FAIL", "BW3_COMP_RF", file_info)
            end
        end
    end
    
    return all_fems_pass_test
    
end

def cw_pd_ul_test(micron_id, file_info, run_id = "", ll_after_Signal = 0, hl_after_signal = 2.5,ll_after_dsa = 1.42, hl_after_dsa = 1.63)
    fs = MICRON_MODULE.new 
    cpbf = ModuleCPBF.new
    time = Time.new
    board = "MIC_LSL"
    all_fems_pass_test = false
    fem_pass = true
    loop_tracker = true
    #low limit to start the test is 90
    soc = check_batteries_soc(micron_id, file_info, run_id.to_s,80)
    if(!soc)
        return false
    end
    #resPowerUp = set_target_ps2_traj_ps2(micron_id.to_i,run_id)
    #TODO:: add limits
    #Configure FPGA HLP 
    #Can call also to this function with another parameters:
    #set_fpga_freq_param(board, micron_id, converted=true, raw=false, wait_check_timeout=2,dl_ban = "10MHz",dl_freq = 881500, ul_ban = "10MHz", ul_freq = 836500)
    fpga_hlp = fs.set_fpga_freq_param(board, micron_id)[0]

    #Verify the FPGA HLP command is succeeded 
    if(fpga_hlp["MIC_FPGA_RESULT_CODE"] == "SUCCESS")
        #Move UUT to Operational power mode 
        #Set next power mode to operational
        ret_change_mode = change_mode(micron_id,"OPERATIONAL")
        sleep 8
        write_to_log_file(run_id, time, "SET_POWER_MODE_OPERATIONAL_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE", ret_change_mode, "BOOLEAN", (ret_change_mode ? "PASS": "FAIL"), "BW3_COMP_SAFETY", file_info)

        pd_fems_befor_sg = []
        soc = check_batteries_soc(micron_id, file_info,run_id.to_s)
        bat_temperature = check_batteries_temperature(micron_id, file_info, run_id.to_s,20,50)
        fpga_temperature = check_fpga_temperature(micron_id, file_info, run_id = "")
        if(!bat_temperature || !soc || !fpga_temperature)
            return false
        end
        #pd_fems_befor_sg.fill(0, 0,16)
         if(ret_change_mode == true)
            #for all the FEM's in the Micron
            #Sample all the fem's pdet before power on the sg.
            for fem_id in 0x0..0xf                  
                fem_pass = false
                fem_status = "FAIL"

                #Read FEM Pdet detector and verify no signal detected
                det_meas = fs.get_det_meas(board, micron_id, true, false, 2,fem_id)[0]
                det_meas_befor_signal = det_meas["MIC_FEM_RX_FWD_DETECTOR"].to_f
                puts "FEM_#{fem_id} - MIC_FEM_RX_FWD_DETECTOR_BEFORE_SIGNAL - #{det_meas_befor_signal}"
                puts "FEM_#{fem_id} - MIC_FEM_RESULT_CODE_BEFORE_SIGNAL - #{det_meas["MIC_FEM_RESULT_CODE"]}"
                pd_fems_befor_sg << det_meas_befor_signal
                fs.set_dsa_val(board, micron_id, true, false, 1, fem_id, "RX", 10)
                sleep 1
                det_meas = fs.get_det_meas(board, micron_id, true, false, 2,fem_id)[0]
                det_meas_after_dsa = det_meas["MIC_FEM_RX_FWD_DETECTOR"].to_f
                puts "FEM_#{fem_id} - MIC_FEM_RX_FWD_DETECTOR_AFTER_DSA - #{det_meas_after_dsa}"
                fem_after_dsa_status = "FAIL"
                if(det_meas_after_dsa < hl_after_dsa && det_meas_after_dsa > ll_after_dsa)
                    fem_after_dsa_status = "PASS"
                end
                #write result pd after dsa
                
                write_to_log_file(run_id, time, "UL_FEM_#{fem_id}_PD_AFTER_DSA_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                hl_after_dsa, ll_after_dsa, det_meas_after_dsa, "FLOAT", fem_after_dsa_status, "BW3_COMP_RF", file_info)

            end
            puts "PLEASE TURN ON THE SG."
            message_box("PLEASE TURN ON SIGNAL GENERATOR.\nCLICK CONTINUE WHEN YOU DONE.", "CONTINUE", false)

            soc = check_batteries_soc(micron_id, file_info, run_id.to_s)
            bat_temperature = check_batteries_temperature(micron_id, file_info, run_id.to_s,20,50)
            fpga_temperature = check_fpga_temperature(micron_id, file_info, run_id.to_s)
            if(!bat_temperature || !soc || !fpga_temperature)
                return false
            end
            #power on the sg
            #for all the FEM's in the Micron
            for fem_id in 0x0..0xf                  
                fem_pass = false
                fem_status = "FAIL"

                #Read FEM Vfw detector and verify signal detected
                det_meas = fs.get_det_meas(board, micron_id, true, false, 2,fem_id)[0]
                det_meas_after_signal = det_meas["MIC_FEM_RX_FWD_DETECTOR"].to_f
                puts "FEM_#{fem_id} - MIC_FEM_RX_FWD_DETECTOR_AFTER_SIGNAL - #{det_meas_after_signal.to_s}"
                puts "FEM_#{fem_id} - MIC_FEM_RESULT_CODE_AFTER_SIGNAL - #{det_meas["MIC_FEM_RESULT_CODE"]}"
                #sleep 60
                
                if(det_meas_after_signal > ll_after_Signal && det_meas_after_signal < hl_after_signal)
                    fem_pass = true
                    fem_status = "PASS"
                    puts "FEM_#{fem_id} - #{fem_status}"
                end
                message_box("MIC_FEM_RX_FWD_DETECTOR_AFTER_SIGNAL = " + det_meas_after_signal.to_s, "OK", false)
                #write result of each fem
                fem_string = "FEM_"
                if(fem_id < 10)
                    fem_string = fem_string + "0"
                end
                #write result of PD before signal generated
                write_to_log_file(run_id, time, "UL_#{fem_string}#{fem_id}_PD_BEFORE_SIGNAL_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                "0", "0", pd_fems_befor_sg[fem_id], "FLOAT", (pd_fems_befor_sg[fem_id] == 0 ? "PASS" : "FAIL"), "BW3_COMP_RF", file_info)

                #write result of PD after signal generated    
                write_to_log_file(run_id, time, "UL_#{fem_string}#{fem_id}_PD_AFTER_SIGNAL_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                hl_after_signal, ll_after_Signal, det_meas_after_signal, "FLOAT", fem_status, "BW3_COMP_RF", file_info)

                loop_tracker = loop_tracker & fem_pass
            end
            if(loop_tracker)
                all_fems_pass_test = true
            else

                write_to_log_file(run_id, time, "UL_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
                "TRUE", "TRUE", loop_tracker, "BOOLEAN", "FAIL", "BW3_COMP_RF", file_info)
            end
        end
    end

    return all_fems_pass_test
end

def dsa_upload(micron_id, run_id, file_info, folder_path, mcf_micron_id_filename)
    file_path = ""
    dsa_result = false
    serial = "INVALID"
    mic = "INVALID"
    final_status = "FAIL"

    table = CSV.parse(File.read(mcf_micron_id_filename), headers: true)
    table.each do |entry|
        if entry[1] != nil
            if entry[1].to_i == micron_id
                file_path = folder_path + "#{entry[0]}.bin"
                serial = entry[0]
                mic = entry[1]
            end
        end
    end
    time = Time.now
    if file_path != ""
        puts "Serial : #{serial}"
        puts "Micron id: #{mic}"
        dsa_result, status = MICRON_FS_Upload(230, 26, file_path, "MIC_LSL", micron_id)
        final_status = status.values[0].to_s.upcase
        puts "DSA Calibration file upload - #{dsa_result}"
    end
    #Write dsa result
    if file_info != nil
        write_to_log_file(run_id, time, "DSA_UPLOAD_SERIAL_#{serial}_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
        "TRUE", "TRUE", dsa_result, "BOOLEAN",final_status , "BW3_COMP_CAL_UPLOAD", file_info)
    end
    return dsa_result
end

def fdir_upload(microns, run_id, out_file)

    # 1. file id 1005 - exit_to_ps2
    # 2. file id 1006 - reset_to_ps1
    # 3. file id 1007 - battery_heaters_on
    # 4. file id 1008 - battery_heaters_off
    # 5. file id 1009 - charger_on
    # 6. file id 1010 - charger_off
    # 7. file id 1011 - mb_heater_on
    # 8. file id 1012 - mb_heater_off
    # 9. file id 1013 - fem_heaters_turn_on_all
    # 10.file id 1014 - fem_heaters_turn_off_all
    # 11.file id 1015 - fem_heaters_turn_off_all_switch_PS2

    scripts = 
        ['exit_to_ps2', 'reset_to_ps1', 'battery_heaters_on',
        'battery_heaters_off', 'charger_on', 'charger_off',
        'mb_heaters_on', 'mb_heaters_off', 'fem_heaters_turn_on_all',
        'fem_heaters_turn_off_all', 'fem_heaters_turn_off_all_switch_PS2']
        
    path = 'C:/Cosmos/ATE/FDIR_scripts/'
    result = Array.new(scripts.length) { false }
    scripts.each_with_index do |script_name, i|
        time = Time.new
        index = 1005 + i
        ret, status = MICRON_FS_Upload(230, index, (path + script_name + ".txt"), "MIC_LSL", microns, max_entry_size=80, broadcast_all: true, do_file_check: true)
        puts "INDEX #{index}: #{ret}"
        result[i] = ret

        keys = status.keys
        values = status.values
        puts keys
        puts values
        for i in 0..keys.length()
            if(keys[i] == nil)
                next
            end
            bool_status = false
            if(values[i] == "PASS")
                bool_status = true
            end
            write_to_log_file(run_id, time, "FDIR_UPLOAD_SCRIPT_#{script_name.upcase}_FILE_ID_#{index}_MICRON_#{get_micron_id_filterd(keys[i])}",
            "TRUE", "TRUE", bool_status, "BOOLEAN", values[i], "BW3_COMP_FDIR_UPLOAD", out_file)
        end
    end
    return result.all?
end

# "MIC_GPS_POS_X"=>-2181202.0, "MIC_GPS_POS_Y"=>4378930.0, "MIC_GPS_POS_Z"=>4078882.0
def gps_fast(micron_id, file_info, apc, limit_x = -2181202.0, limit_y = 4378930.0, limit_z = 4078882.0, run_id = "",microns_list = nil, is_ring = false)
    fs = MICRON_MODULE.new 
    time = Time.now
    delta = 10.0
    all_ring_microns_id = []
    all_pos_res_flag = true
    index = 1
    resPowerUp = true

    if(microns_list == nil)
        microns_list = get_micron_id_list(micron_id).reverse()
    end
    # else
        
    #     for micron_idd in microns_list
    #         micron_id_list = get_micron_id_list(micron_idd)
    #         for id in micron_id_list
    #             all_ring_microns_id.append(id)
    #         end
    #     end
    #     microns_list = all_ring_microns_id.uniq.reverse()
    #     #puts all_ring_microns_id.sort
    # end
    #sleep(30)
    if(!is_ring)
        #resPowerUp = true
        resPowerUp,index = set_target_ps2_traj_ps2(micron_id.to_i,apc,file_info, run_id)
    end

    
    if(resPowerUp)
        for id in microns_list
            fast = fs.gps_fast("MIC_LSL",id,true, false, 0.4)
            if fast == nil
                next
            end
            fast = fast[0]
        end
            #Retrive gps data
            sleep 180 
        for id in microns_list 
            
            gps_data = fs.gps_fast("MIC_LSL",id)
            pos_x = 0
            pos_y = 0
            pos_z = 0
            if gps_data != []
                gps_data = gps_data[0]
                pos_x = gps_data["MIC_GPS_POS_X"].to_f
                pos_y = gps_data["MIC_GPS_POS_Y"].to_f
                pos_z = gps_data["MIC_GPS_POS_Z"].to_f
            end
          
            puts "POS X = #{pos_x}" 
            puts "POS Y = #{pos_y}" 
            puts "POS Z = #{pos_z}" 
            flag_res_x = false
            flag_res_y = false
            flag_res_z = false

            if((pos_x < limit_x + delta) && (pos_x > limit_x - delta))
                flag_res_x = true
            end
            pos_x_status = flag_res_x ? "PASS" : "FAIL"
            all_pos_res_flag = all_pos_res_flag & flag_res_x

            if((pos_y < limit_y + delta) && (pos_y > limit_y - delta))
                flag_res_y = true
            end
            pos_y_status = flag_res_y ? "PASS" : "FAIL"
            all_pos_res_flag = all_pos_res_flag & flag_res_y

            if((pos_z < limit_z + delta) && (pos_z > limit_z - delta))
                flag_res_z = true
            end
            pos_z_status = flag_res_z ? "PASS" : "FAIL"    
            all_pos_res_flag = all_pos_res_flag & flag_res_z
            
            
            #Write x position
            write_to_log_file(run_id, time, "GPS_POS_X_MICRON_#{get_micron_id_filterd(id.to_s)}",
            (limit_x + delta.to_f), (limit_x - delta.to_f), pos_x.round(2), "BOOLEAN", pos_x_status, "BW3_COMP_GPS", file_info)

            #Write y position
            write_to_log_file(run_id, time, "GPS_POS_Y_MICRON_#{get_micron_id_filterd(id.to_s)}",
            (limit_y + delta.to_f), (limit_y - delta.to_f), pos_y.round(2), "BOOLEAN", pos_y_status, "BW3_COMP_GPS", file_info)

            #Write z position
            write_to_log_file(run_id, time, "GPS_POS_Z_MICRON_#{get_micron_id_filterd(id.to_s)}",
            (limit_z + delta.to_f), (limit_z - delta.to_f), pos_z.round(2), "BOOLEAN", pos_z_status, "BW3_COMP_GPS", file_info)
        end

    end

    if(!is_ring)
        if(!power_off_power_supply(micron_id, apc))
            return false
        end
        resReboot = reboot_microns_in_chain(micron_id,true,board="MIC_LSL",run_id,index)
        if(!resReboot)
            return false
        end
       
    end

    return all_pos_res_flag

end

def verify_fpga_version(micron_id, out_file, run_id)
    fs = MICRON_MODULE.new 
    time = Time.now
    fpgaStatus = "FAIL"
    version_hash = get_micron_version()
    version_info = version_hash['post_fpga']
    mic_result = fs.fpga_info("MIC_LSL", micron_id, "MAIN", "DESCRIPTOR", true, false,1)
    result_version = "NA"
    fpga_check = false
    if mic_result != []
        mic_result = mic_result[0]
        if mic_result["MIC_IMAGE_VERSION"] == version_info
            fpgaStatus = "PASS"
            fpga_check = true
        end
        version_result_splited = mic_result["MIC_IMAGE_VERSION"].split('.')
        version_info_splited = version_info.split('.')
        puts "FPGA Version for micron #{micron_id} is - #{mic_result["MIC_IMAGE_VERSION"]}"
        puts "FPGA Version required for micron #{micron_id} is - #{version_info}"
        puts "FPGA Version check status for micron #{micron_id} - #{fpgaStatus}"
        result_version = "#{version_result_splited[0]}.#{version_result_splited[1]}.#{version_result_splited[2]}"
        puts "RESULT_VERSION: #{result_version}"
    end
    write_to_log_file(run_id, time, "FPGA_VERSION_#{version_info}_VERIFY_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
    "#{version_info_splited[0]}.#{version_info_splited[1]}.#{version_info_splited[2]}",
     "#{version_info_splited[0]}.#{version_info_splited[1]}.#{version_info_splited[2]}", result_version,
       "VERSION", fpgaStatus, "BW3_COMP_SAFETY", out_file)

    return fpga_check
end

def verify_sw_version(micron_id, file_info, run_id)
    fs = MICRON_MODULE.new 
    time = Time.now
    firmwareBootl1Status = "FAIL"
    firmwareBootl2Status = "FAIL"
    firmwareAppStatus = "FAIL"
    bl1_ret_version = -999
    bl2_ret_version = -999
    app_ret_version = -999
    version_hash = get_micron_version()
    version_info_app = version_hash['pre_sw_app']
    version_info_bl1 = version_hash['pre_sw_bl1']
    version_info_bl2 = version_hash['pre_sw_bl2']

    res_versions = fs.get_micron_sw_version("MIC_LSL",micron_id, true, false)

    if res_versions != []
        res_versions = res_versions[0]
        sw_versions_check = true
        bl1_ret_version = "#{res_versions["MIC_BOOT_L1_MAJOR"]}.#{res_versions["MIC_BOOT_L1_MINOR"]}.#{res_versions["MIC_BOOT_L1_PATCH"]}"
        if res_versions["MIC_BOOT_L1_MAJOR"] == version_info_bl1[:BOOT_L1_MAJOR] &&
            res_versions["MIC_BOOT_L1_MINOR"] == version_info_bl1[:BOOT_L1_MINOR] &&
            res_versions["MIC_BOOT_L1_PATCH"] == version_info_bl1[:BOOT_L1_PATCH]
            puts "Bootloader L1 Version check for micron #{micron_id} - PASS"
            firmwareBootl1Status = "PASS"
            
        else
            puts "Bootloader L1 Version check for micron #{micron_id} - FAIL" 
            sw_versions_check = false
        end
        puts "Bootloader L1 Firmware  = #{res_versions["MIC_BOOT_L1_MAJOR"]}.#{res_versions["MIC_BOOT_L1_MINOR"]}.#{res_versions["MIC_BOOT_L1_PATCH"]} for micron #{micron_id}"
        bl2_ret_version = "#{res_versions["MIC_BOOT_L2_MAJOR"]}.#{res_versions["MIC_BOOT_L2_MINOR"]}.#{res_versions["MIC_BOOT_L2_PATCH"]}"
        if res_versions["MIC_BOOT_L2_MAJOR"] == version_info_bl2[:BOOT_L2_MAJOR] &&
            res_versions["MIC_BOOT_L2_MINOR"] == version_info_bl2[:BOOT_L2_MINOR] &&
            res_versions["MIC_BOOT_L2_PATCH"] == version_info_bl2[:BOOT_L2_PATCH] 
            puts "Bootloader L2 Version check for micron #{micron_id} - PASS"
            firmwareBootl2Status = "PASS"
           
        else
            puts "Bootloader L2 Version check for micron #{micron_id} - FAIL" 
            sw_versions_check = false
        end
        puts "Bootloader L2 Firmware  = #{res_versions["MIC_BOOT_L2_MAJOR"]}.#{res_versions["MIC_BOOT_L2_MINOR"]}.#{res_versions["MIC_BOOT_L2_PATCH"]} for micron #{micron_id}"
        app_ret_version = "#{res_versions["MIC_APP_MAJOR"]}.#{res_versions["MIC_APP_MINOR"]}.#{res_versions["MIC_APP_PATCH"]}"
        if res_versions["MIC_APP_MAJOR"] == version_info_app[:APP_MAJOR] &&
            res_versions["MIC_APP_MINOR"] == version_info_app[:APP_MINOR] &&
            res_versions["MIC_APP_PATCH"] == version_info_app[:APP_PATCH] 
            puts "Application Version check for micron #{micron_id} - PASS"
            firmwareAppStatus = "PASS"
            
        else
            puts "Application Version check for micron #{micron_id} - FAIL" 
            sw_versions_check = false
        end
        puts "Application Firmware  = #{res_versions["MIC_APP_MAJOR"]}.#{res_versions["MIC_APP_MINOR"]}.#{res_versions["MIC_APP_PATCH"]} for micron #{micron_id}"
    end
      #write result of bootloaderl1 firmware upgrade
      ll = "#{version_info_bl1[:BOOT_L1_MAJOR]}.#{version_info_bl1[:BOOT_L1_MINOR]}.#{version_info_bl1[:BOOT_L1_PATCH]}"
      hl = "#{version_info_bl1[:BOOT_L1_MAJOR]}.#{version_info_bl1[:BOOT_L1_MINOR]}.#{version_info_bl1[:BOOT_L1_PATCH]}"
      ver = "#{version_info_bl1[:BOOT_L1_MAJOR]}.#{version_info_bl1[:BOOT_L1_MINOR]}.#{version_info_bl1[:BOOT_L1_PATCH]}"
      if file_info != nil 
        write_to_log_file(run_id, time, "VERIFY_BOOTLOADERL1_FIRMWARE_VERSION_#{ver}_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
        hl, ll, bl1_ret_version,
        "VERSION", firmwareBootl1Status, "BW3_COMP_SAFETY", file_info)
      end
      #write result of bootloaderl2 firmware upgrade
      #out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
      ll = "#{version_info_bl2[:BOOT_L2_MAJOR]}.#{version_info_bl2[:BOOT_L2_MINOR]}.#{version_info_bl2[:BOOT_L2_PATCH]}"
      hl = "#{version_info_bl2[:BOOT_L2_MAJOR]}.#{version_info_bl2[:BOOT_L2_MINOR]}.#{version_info_bl2[:BOOT_L2_PATCH]}"
      ver = "#{version_info_bl2[:BOOT_L2_MAJOR]}.#{version_info_bl2[:BOOT_L2_MINOR]}.#{version_info_bl2[:BOOT_L2_PATCH]}"
      if file_info != nil 
        write_to_log_file(run_id, time, "VERIFY_BOOTLOADERL2_FIRMWARE_VERSION_#{ver}_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
        hl, ll, bl2_ret_version,
        "VERSION", firmwareBootl2Status, "BW3_COMP_SAFETY", file_info)
      end
      #write result of application firmware upgrade
      #out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
      ll = "#{version_info_app[:APP_MAJOR]}.#{version_info_app[:APP_MINOR]}.#{version_info_app[:APP_PATCH]}"
      hl = "#{version_info_app[:APP_MAJOR]}.#{version_info_app[:APP_MINOR]}.#{version_info_app[:APP_PATCH]}"
      ver = "#{version_info_app[:APP_MAJOR]}.#{version_info_app[:APP_MINOR]}.#{version_info_app[:APP_PATCH]}"
      if file_info != nil 
        write_to_log_file(run_id, time, "VERIFY_APPLICATION_FIRMWARE_VERSION_#{ver}_MICRON_#{get_micron_id_filterd(micron_id.to_s)}",
        hl, ll, app_ret_version,
        "VERSION", firmwareAppStatus, "BW3_COMP_SAFETY", file_info)
      end
     
    return sw_versions_check

end

def get_specific_ring(ring, all_until = false)
    list_of_rings = []
    all_ring_microns_id = []
    ring_id_only = []
    
    if ring == "A"
        list_of_rings << "A"
    elsif ring == "B"
        list_of_rings << "A"
        list_of_rings << "B"
    elsif ring == "C"
        list_of_rings << "B"
        list_of_rings << "C"    
    elsif ring == "D"
        list_of_rings << "C"
        list_of_rings << "D"     
    elsif ring == "E"
        list_of_rings << "D"
        list_of_rings << "E"      
    elsif ring == "F" || ring == "Array"
        list_of_rings << "E"
        list_of_rings << "F"
    end

    for r in list_of_rings
        microns_list = convert_string_ring_to_list(r)
        for micron_idd in microns_list
            micron_id_list = get_micron_id_list(micron_idd)
            for id in micron_id_list
                if r == ring
                    ring_id_only.append(id)
                else
                    all_ring_microns_id.append(id)
                end
            end
        end
    end
    if(all_until || ring == "Array")
        return (ring_id_only + all_ring_microns_id).uniq().reverse()
    end
    return (ring_id_only - all_ring_microns_id).reverse().uniq()

end


def get_microns_list_by_ring_or_id(ring)
    microns_list = get_specific_ring(ring)
    if !ring.match?(/[[:alpha:]]/)
        microns_list = get_micron_id_list(ring.to_i).reverse()
    end
    return microns_list

end


def upload_golden_image(microns, run_id, out_file)
    #get the golden version
    version_hash = get_micron_version()
    goldenFirmwareVersion = version_hash['golden_image_version']
    time = Time.now
    path = "C:\\Cosmos\\ATE\\Golden_FSW\\" + goldenFirmwareVersion + "\\fcApplication.bin"
    file_id = 14
    file_descriptor_id = 13
    res,status = golden_image_update('MIC_LSL', 'app', path, microns, file_id, file_descriptor_id,
        broadcast_all: true, reboot: false, use_automations: true)

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
        write_to_log_file(run_id, time, "APPLICATION_GOLDEN_FIRMWARE_UPLOAD_VERSION_#{goldenFirmwareVersion}_MICRON_#{get_micron_id_filterd(keys[i])}",
        "TRUE", "TRUE", bool_status, "BOOLEAN", values[i], "BW3_COMP_GOLDEN_UPLOAD", out_file)

    end
    return res
            
end

def golden_test_sequence(microns, power_mode, out_file, run_id)

    version_hash = get_micron_version()
    firmwareVersion = version_hash['fw_version']
    version_info_app = version_hash['post_sw_app']
    path_main = "C:\\Cosmos\\ATE\\FSW\\" + firmwareVersion + "\\fcApplication.bin"
    
    fs = MICRON_MODULE.new

    #Step 4 - upload golden image
    ret_upload_golden = upload_golden_image(microns, run_id, out_file)

    #Step 5 - Upload corrupted main image from the st-link
    version_hash = get_micron_version()
    firmwareVersionCorrupted = version_hash['main_image_corrupted']
    version_info_app_corrupted = version_hash['main_image_corrupted_info']
    path_main_corrupted = "C:\\Cosmos\\ATE\\FSW_CORRUPTED\\" + firmwareVersionCorrupted + "\\fcApplication.bin"
    str_path = "\"C:/Program Files (x86)/STMicroelectronics/STM32 ST-LINK Utility/ST-LINK Utility/ST-LINK_CLI.exe\" -c -p #{path_main_corrupted} 0x08040000 -Rst"
    ret_upload_corrupted = system str_path
    time = Time.new
    write_to_log_file(run_id, time, "UPLOAD_CORRUPTED_MAIN_IMAGE_MICRON_#{get_micron_id_filterd(microns[0])}",
    "TRUE", "TRUE", ret_upload_corrupted, "BOOLEAN", (ret_upload_corrupted == true ? "PASS" : "FAIL"), "BW3_COMP_GOLDEN_TEST", out_file)
    timeout = 0
    ping_res = false
    while ping_res == false && timeout < 40
        sleep 1
        ping_res = fs.ping_micron(board="MIC_LSL", microns[0], converted=false, raw=false, wait_check_timeout=0.1, 1)
        timeout +=1
    end
    time = Time.new
    write_to_log_file(run_id, time, "PING_MICRON_#{get_micron_id_filterd(microns[0])}",
    "TRUE", "TRUE", ping_res, "BOOLEAN", (ping_res == true ? "PASS" : "FAIL"), "BW3_COMP_GOLDEN_TEST", out_file)

    if power_mode.to_s.downcase == "ps2"
        #return to ps2
        moved_to_ps2 = move_ring_to_mode_and_validate("", "PS2", run_id, false, microns, out_file)
        if !moved_to_ps2
            puts "Failed to move ps2."
            return false
        end
    end
   
    #Step 6 - verify switch to golden image
    result = Array.new(microns.length) { false }
    microns.each_with_index do |micron_id, i|
        firmwareAppStatus = "FAIL"
        res_versions = fs.get_micron_sw_version("MIC_LSL",micron_id, true, false)
        goldenFirmwareVersion = version_hash['golden_image_version']
        if res_versions == []
            puts "Micron #{micron_id} - does not responed"
            next
        end
        res_versions = res_versions[0]
        app_ret_version = "#{res_versions["MIC_APP_MAJOR"]}.#{res_versions["MIC_APP_MINOR"]}.#{res_versions["MIC_APP_PATCH"]}"
        if app_ret_version == goldenFirmwareVersion
            result[i] = true
            puts "Application Version check for micron #{micron_id} - PASS"
            firmwareAppStatus = "PASS"
        else
            puts "Application Version check for micron #{micron_id} - FAIL" 
        end
        time = Time.new
        write_to_log_file(run_id, time, "SWITCH_TO_GOLDEN_VERSION_#{goldenFirmwareVersion}_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE", result[i], "BOOLEAN", firmwareAppStatus, "BW3_COMP_GOLDEN_TEST", out_file)
    end

    return false unless result.all?

    time = Time.new
    #Step 7 - upload main image
    res,status = firmware_update("MIC_LSL", 'app', path_main, version_info_app, file_id = 12, from_golden = 0, microns, broadcast_all: true, reboot: true, use_automations: true, check_version: false)
    
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
        write_to_log_file(run_id, time, "APPLICATION_FIRMWARE_UPLOAD_VERSION_#{firmwareVersion}_MICRON_#{get_micron_id_filterd(keys[i])}",
        "TRUE", "TRUE", bool_status, "BOOLEAN", values[i], "BW3_COMP_SW_UPLOAD", out_file)

    end

    sleep 8
    if power_mode.to_s.downcase == "ps2"
        #return to ps2
        moved_to_ps2 = move_ring_to_mode_and_validate("", "PS2", run_id, false, microns, out_file)
        if !moved_to_ps2
            puts "Failed to move ps2."
            return false
        end
    end

    #Step 8 - verify image version
    verify_main_image = verify_micron_software_version(microns, run_id, out_file)
    if !verify_main_image
        return false
    end

    #Step 9+10 - File clear & verify
    if !golden_file_clear(microns, out_file, run_id)
        return false
    end

    #Step 11 - verify log files include activities
    #??

    return true
end

def golden_file_clear(microns, out_file, run_id)
    file_id = 14
    file_descriptor_id = 13
    result = Array.new(microns.length) { false }
    fs = MicronFS.new
    fwupd = MicronFWUPD.new
    link = 'MIC_LSL'
    

    microns.each do |micron_id|
        fwupd_version_hash_converted, fwupd_version_hash_raw = fwupd.firmware_info(link, micron_id, true, true)
        #convert to hex
        mcu_uid_0 = fwupd_version_hash_raw["MIC_MCU_UID_0"]
        # perform XOR
        xor_val = 'AAAAAAAA'.to_i(16)
        pass_val = mcu_uid_0 ^ xor_val
        cli_cmd = "fs locking #{file_id} unlock #{pass_val}"
        # send CLI command
        send_mic_cli(link, micron_id, cli_cmd)

        cli_cmd = "fs locking #{file_descriptor_id} unlock #{pass_val}"
        send_mic_cli(link, micron_id, cli_cmd)
    end

    microns.each_with_index do |micron_id, i|
        status_clear = "PASS"
        puts("Clearing file id - #{file_id} for micron #{micron_id} and wait 10s")
        res = fs.file_clear("MIC_LSL", micron_id, file_id, true, false, 10)[0]
        if res['MIC_STATUS'] == 0 
            result[i] = true
            puts("File #{file_id} cleared for micron #{micron_id}.")
        else
            err_msg = "File clear for #{file_id} on micron #{micron_id} failed with code #{res}"
            puts(err_msg)
            status_clear = "FAIL"
        end
        time = Time.new
        write_to_log_file(run_id, time, "FILE_CLEAR_ID_#{file_id}_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE",result[i] , "BOOLEAN", status_clear, "BW3_COMP_GOLDEN_TEST", out_file)
        
        status_clear = "PASS"
        puts("Clearing file id - #{file_descriptor_id} for micron #{micron_id} and wait 10s")
        res = fs.file_clear("MIC_LSL", micron_id, file_descriptor_id, true, false, 10)[0]
        if res['MIC_STATUS'] == 0
            puts("File #{file_descriptor_id} cleared for micron #{micron_id}.")
        else
            err_msg = "File clear for #{file_descriptor_id} on micron #{micron_id} failed with code #{res}"
            puts(err_msg)
            result[i] = false
            status_clear = "FAIL"
        end

        time = Time.new
        write_to_log_file(run_id, time, "FILE_CLEAR_ID_#{file_descriptor_id}_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE",result[i] , "BOOLEAN", status_clear, "BW3_COMP_GOLDEN_TEST", out_file)
    end

    return result.all?
end



def send_mic_cli(link, micron_id, cli_cmd)
    mic = MICRON_MODULE.new
    cli_cmd_len = cli_cmd.length  
    if cli_cmd_len <= 21
        res = mic.remote_cli(link, micron_id, 0, cli_cmd, "COMPLETED")
    else
        remainder = cli_cmd_len%21
        iterations = (cli_cmd_len/21).floor()
        start_idx = 0
        end_idx = 20
        iterations.times {
            puts("sending #{cli_cmd[start_idx..end_idx]}") 
            mic.remote_cli(link, micron_id, 0, cli_cmd[start_idx..end_idx], "CONTINUE")
            start_idx = end_idx + 1
            end_idx = end_idx + 21
        }
        res = mic.remote_cli(link, micron_id, 0, cli_cmd[start_idx..(start_idx + remainder)], "COMPLETED")
    end
    puts("Micron #{micron_id} responded with #{res}")
end

def power_on_power_supply(micron_id, apc)
    version_hash = get_micron_version()
    with_pcdu = version_hash['with_pcdu'].to_s.downcase == 'true'

    if with_pcdu
        power_ring = [104,93,107,77,78,119,120,90]
        handle_routing = HandleRouting.new
        micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id)
        if(micron_id_ring.length() > 0)
            micron_id = micron_id_ring[0]
        else
            if(!power_ring.include? micron_id)
                return false
            else
                micron_id = "MICRON_" + micron_id.to_s
            end
        end

        if(micron_id == "MICRON_93")
            micron_id = "MICRON_78"
        end
        if(micron_id == "MICRON_120")
            micron_id = "MICRON_107"
        end
            # @pwr_share = ModuleMicronPower.new
            # telem = ModuleTelem.new
            # telem.set_realtime("APC_YM", "FSW_TLM_APC", "COSMOS_UMBILICAL", 1)
            # telem.set_realtime("APC_YM", "POWER_PCDU_LVC_TLM", "COSMOS_UMBILICAL", 1)
            # @pwr_share.set_individual_micron_power_share_switch("APC_YM", "POWER_SHARE_" + micron_id.to_s, "ON", TRUE)
            # telem.set_realtime("APC_YM", "FSW_TLM_APC", "COSMOS_UMBILICAL", 0)
            # telem.set_realtime("APC_YM", "POWER_PCDU_LVC_TLM", "COSMOS_UMBILICAL", 0)
            # #system 'C:\Python\python.exe C:\Cosmos\PROCEDURES\Operations\TestEquipment\CPBF_POWER_SHARING_ON.py'
            # #return true
            # sleep 7

            # #Set the next Micron to PS2 befor reboot the current Micron
            # ret_change_mode = change_mode("MICRON_78","PS2")


            # telem.set_realtime("APC_YM", "FSW_TLM_APC", "COSMOS_UMBILICAL", 1)
            # telem.set_realtime("APC_YM", "POWER_PCDU_LVC_TLM", "COSMOS_UMBILICAL", 1)
            # @pwr_share.set_individual_micron_power_share_switch("APC_YM", "POWER_SHARE_MICRON_93", "ON", TRUE)
            # telem.set_realtime("APC_YM", "FSW_TLM_APC", "COSMOS_UMBILICAL", 0)
            # telem.set_realtime("APC_YM", "POWER_PCDU_LVC_TLM", "COSMOS_UMBILICAL", 0)

        #     share_mode = "DONOR"
        #     fs.set_power_sharing(board="MIC_LSL", "MICRON_78", "WEST_CLOSED", share_mode, converted=false, raw=false, wait_check_timeout=2)
        #     puts "Micron id = MICRON_78 Donor to Micron id = MICRON_79 on direction WEST_CLOSED"
        #     sleep 3

        #     #Set the next Micron to PS2 befor reboot the current Micron
        #     ret_change_mode = change_mode("MICRON_79","PS2")
            
            
        #     ret_value = ret_value & ret_change_mode
        #     #return power sharing to be disabled.
        #     if(disabledDoner)
        #         t1 = Time.now
        #         t2 = Time.now
        #         while(t2-t1 < 35)
        #             fs.set_power_sharing(board="MIC_LSL", micron_id_ring[micron_id], "ALL_DISCONNECTED", "DISABLED", converted=false, raw=false, wait_check_timeout=2)
        #             #Validating that power sharing is disabled.
        #             last_mode = fs.get_power_sharing(board="MIC_LSL", micron_id_ring[micron_id], "ALL_DISCONNECTED", "DISABLED", converted=true, raw=false, wait_check_timeout=2)[0]
        #             power_sharing_mode_status = last_mode["MIC_SHARE_MODE"]
                    
        #             if(power_sharing_mode_status == "DISABLED")
        #                 puts "Micron id = #{micron_id_ring[micron_id]} Disabled donor to Micron id = #{next_micron_id}"
        #                 break
        #             else
        #                 puts "Micron id = #{micron_id_ring[micron_id]} Failed to disabled donor to Micron id = #{next_micron_id}"
        #             end
        #             t2 = Time.now  
        #         end
        #     end
        #     if(ret_change_mode == false)
        #         break
        #     end
            

        # end
        
        @pwr_share = ModuleMicronPower.new
        telem = ModuleTelem.new
        telem.set_realtime(apc, "FSW_TLM_APC", "COSMOS_UMBILICAL", 1)
        telem.set_realtime(apc, "POWER_PCDU_LVC_TLM", "COSMOS_UMBILICAL", 1)
        @pwr_share.set_individual_micron_power_share_switch(apc, "POWER_SHARE_" + micron_id.to_s, "ON", TRUE)
        #telem.set_realtime(apc, "FSW_TLM_APC", "COSMOS_UMBILICAL", 0)
        #telem.set_realtime(apc, "POWER_PCDU_LVC_TLM", "COSMOS_UMBILICAL", 0)
        #system 'C:\Python\python.exe C:\Cosmos\PROCEDURES\Operations\TestEquipment\CPBF_POWER_SHARING_ON.py'
    end
    return true
end

def power_off_power_supply(micron_id, apc)
    version_hash = get_micron_version()
    with_pcdu = version_hash['with_pcdu'].to_s.downcase == 'true'

    if with_pcdu
        power_ring = [104,93,107,77,78,119,120,90]
        handle_routing = HandleRouting.new
        micron_id_ring,directions = handle_routing.getRoutingPathWithMicronID(micron_id)

        if(micron_id_ring.length() >= 1)
            micron_id = micron_id_ring[0]
        else
            if(!power_ring.include? micron_id)
                return false
            else
                micron_id = "MICRON_" + micron_id.to_s
            end
        end    
        if(micron_id == "MICRON_93")
            micron_id = "MICRON_78"
        end
        if(micron_id == "MICRON_120")
            micron_id = "MICRON_107"
        end
        
        @pwr_share = ModuleMicronPower.new
        telem = ModuleTelem.new
        telem.set_realtime(apc, "FSW_TLM_APC", "COSMOS_UMBILICAL", 1)
        telem.set_realtime(apc, "POWER_PCDU_LVC_TLM", "COSMOS_UMBILICAL", 1)
        @pwr_share.set_individual_micron_power_share_switch(apc, "POWER_SHARE_" + micron_id.to_s, "OFF", TRUE)
        #telem.set_realtime(apc, "FSW_TLM_APC", "COSMOS_UMBILICAL", 0)
        #telem.set_realtime(apc, "POWER_TLM", "COSMOS_UMBILICAL", 0)
        #system 'C:\Python\python.exe C:\Cosmos\PROCEDURES\Operations\TestEquipment\CPBF_POWER_SHARING_OFF.py'
    end
    return true
end