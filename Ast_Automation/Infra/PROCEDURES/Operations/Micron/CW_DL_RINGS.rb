load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
require 'date'    

out_file = File.new("C:\\Cosmos\\ATE\\ATE_LOG_OUTPUT.txt", "a")
out_file.write("\n")
#Read arguments
for data in ARGV
    out_file.write(data + " ")
end
out_file.write("\n")
builded_string = "\nRUN_ID: " + ARGV[1] + " TEST_START"
out_file.puts(builded_string)
out_file.flush
testResult = "FAIL"
cpbf = ARGV[ARGV.length()-7].strip
apc = ARGV[ARGV.length()-5].strip
ring = ARGV[ARGV.length()-1].strip
all_cw_dl_pass = true
power_on = true
power_off = true
low_limit_battery = 90
ll_pd = 0
hl_pd = 2
ll_after_dsa = 0
hl_after_dsa = 2
ll_dbm = 0
hl_dbm = 23

microns_list = get_specific_ring(ring)
if !ring.match?(/[[:alpha:]]/)
    microns_list = get_micron_id_list(ring.to_i).reverse()
end

config_fpga(microns_list)
moved_to_operational = move_ring_to_mode_and_validate(ring, "OPERATIONAL", ARGV[1], false, microns_list, out_file)
#Config cpbf CW
config_cpbf = configure_cpbf_read_pd(microns_list, ARGV[1], out_file, ll_pd, hl_pd)
fpga_temperature_result = fpga_temperature(microns_list, out_file, ARGV[1])
if fpga_temperature_result
    #Set DSA value
    set_dsa_res = set_dsa_read_pd(microns_list, ARGV[1], out_file, ll_after_dsa, hl_after_dsa, ll_dbm, hl_dbm)
    fpga_temperature_result &= fpga_temperature(microns_list, out_file, ARGV[1])
end

# for id in microns_list
#     micronID = "MICRON_" + id.to_s
#     ret_cw_dl = cw_pd_dl_test(micronID, out_file, ARGV[1])
#     if(!ret_cw_dl)
#         all_cw_dl_pass = false
#     end
#     #reboot = fs.sys_reboot("MIC_LSL", micronID)
#     #puts "SYS REBOOT - MICRON_ID = #{micronID}"
#     #sleep 15
# end


#power_off = power_off_ring(ring, out_file, apc, ARGV[1])

if(moved_to_operational && config_cpbf && fpga_temperature_result && set_dsa_res)
    testResult = "PASS"
end


out_file.puts("\nRUN_ID: " + ARGV[1] + "TEST RESULT = " + testResult)
builded_string = "RUN_ID: " + ARGV[1] + " TEST_END"
out_file.puts(builded_string)
out_file.close
STDOUT.write '\n\n'
start_new_scriptrunner_message_log()
exit!
