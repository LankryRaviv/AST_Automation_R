load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load('Operations/Micron/turn_on_off_CPBF.rb')

out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
#Read arguments
for data in ARGV
    out_file.write(data + " ")
end
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
micron_id = ARGV[ARGV.length()-1].strip
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
out_file.puts(builded_string)
out_file.flush

all_cw_dl_pass = true
testResult = "FAIL"
fs = MICRON_MODULE.new 
pcdu = TurnOnOffCPBF.new

#turning on the CPBF
# pcdu.set_BFCP(apc, 1, true, cpbf)
# sleep 20
#CW DL
power, index = set_target_ps2_traj_ps2(micron_id.to_i,apc, out_file, ARGV[1], true, true, true)
id_list = get_micron_id_list(micron_id.to_i).reverse()

if(power)
    #loop over on all the Microns in the list
    for id in id_list
        micronID = "MICRON_" + id.to_s
        ret_cw_dl = cw_pd_dl_test(micronID, out_file, ARGV[1])
        if(!ret_cw_dl)
            all_cw_dl_pass = false
        end
        reboot = fs.sys_reboot("MIC_LSL", micronID)
        puts "SYS REBOOT - MICRON_ID = #{micronID}"
        sleep 15
        if(ping_by_micron_id(id, out_file, board="MIC_LSL",ARGV[1],false) == "FAIL")
            puts "REBOOT MICRON_ID = #{micronID}  - PASS"
        else
            puts "REBOOT MICRON_ID = #{micronID}  - FAIL"
            
        end
    end
end
# pcdu.set_BFCP(apc, 0, true, cpbf)
# sleep 5
if(!power_off_power_supply(micron_id.to_i,apc))
    testResult = "FAIL"
end

if(power && all_cw_dl_pass)
    testResult = "PASS"
end

#write final status result

out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
exit!