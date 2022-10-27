$LOAD_PATH << File.expand_path('../../',__dir__) #PROCEDURES folder
$LOAD_PATH << File.expand_path('../',__dir__) #Operations folder
$LOAD_PATH << File.expand_path('./',__dir__) #Micron folder
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/MICRON/MICRON_CSP.rb')
load_utility('Operations/MICRON/Element.rb')
load_utility('Operations/MICRON/get_micron_version.rb')
load_utility('Operations/MICRON/HandleRouting.rb')
load_utility('MICRON_FS_Upload.rb')
load_utility('CPBF/CPBF_MODULE.rb')
load('Tools\module_file_tools.rb')
load('Operations\Tools\module_clogger.rb')
include FileTools
include CLogger

def ping_by_micron_id(micron_id_target, board="MIC_LSL")
    test_result = "PASS"
    uut_micron_id = micron_id_target
    fs = MICRON_MODULE.new
    time = Time.new
    ping_res = fs.ping_micron(board="MIC_LSL", uut_micron_id, converted=false, raw=false, wait_check_timeout=0.3)
    # returned status is 0 or 1
    log_message(  "ping result is #{ping_res}")
    if ping_res == false
        test_result = "FAIL"
        log_message(  "Unable to ping micron #{uut_micron_id}. Continuing to next micron.")
    else
        log_message( "ping succeeded to micron #{uut_micron_id}")
    end
    return test_result
end

fs = MICRON_MODULE.new
micron_id = ARGV[0].to_i
downlink_bandwidth = ARGV[1]
downlink_frequency = ARGV[2].to_i
uplink_bandwidth = ARGV[3]
uplink_frequency = ARGV[4]

responses = []
board="MIC_LSL"
#send ping
response = ping_by_micron_id(micron_id)
responses.push(response)

#get power mode
response = fs.get_system_power_mode(board, micron_id)
puts response.inspect
wait 5
log_message(response.class)
log_message(response[0])
log_message(response[1])
log_message(" The system is on #{log_message(response)} mode")
responses.push(response)

#if the power mode is not on ps1 reboot
if response != "PS1"
    response = fs.sys_reboot(board, micron_id)
    log_message(response.inspect)
    responses.push(response.inspect)
    puts response.inspect
    wait 15
end

#set power mode PS2
response = fs.set_system_power_mode(board, micron_id, "PS2")
log_message(response)
responses.push(response)
wait 10

response = fs.get_system_power_mode(board, micron_id)
log_message(" The system is on #{response} mode")
responses.push(response)

if response != "PS2"
  log_error("The system is on #{response} power mode and not changed to PS2")
  puts response.inspect
 
end

#SET BANDS
response = fs.set_fpga_freq_param(board, micron_id,true, false, 0.2, downlink_bandwidth, downlink_frequency, uplink_bandwidth, uplink_frequency)
log_message("#{response}")
responses.push(response)


#set power mode OPERATIONAL
response = fs.set_system_power_mode(board, micron_id, "OPERATIONAL")
log_message(response)
responses.push(response)
wait 15

response = fs.get_system_power_mode(board, micron_id)
log_message(" The system is on #{response} mode")
responses.push(response)

if response != "OPERATIONAL"
  log_error("The system is on #{response} power mode and not changed to OPERATIONAL")
  puts response.inspect
end

#check jeater cleaner status

response = fs.get_fpga_jc_status(board, micron_id)
log_message("#{response}")
responses.push(response)
if responses != "LOCKED"
    log_error("The Jiter cleaner status is #{response} and we exepted to locked status")
    puts response.inspect
   
end

#get bands
response = fs.get_fpga_freq_param(board, micron_id)
log_message("#{response}")
responses.push(response)



#remote cli cpbf csat config
remote_cli_cpbf_path_file= ARGV[5]
File.open(remote_cli_cpbf_path_file).each do |line|
	if line.include? "="
		res = fs.cpbf_remote_cli_cmd(line)
        responses.push(res)
        log_message(res)
	end
end

#read register
rw_reg_path_file = ARGV[6]
allData = read_json_file(rw_reg_path_file)
setupData = allData.fetch("Setup_Band")
response = cpbf_micron_rw_reg_cmd(micron_id, setupData.fetch("rw_flag"),setupData.fetch("reg_addr"),setupData.fetch("reg_data"),setupData.fetch("timeout_ms"))
responses.push(response)
log_message("dec number: #{response}")
responses.push(response)

hex = response.to_s(16)
log_message("hex number: #{hex}")
responses.push(hex)


log_response(responses)
wait 5
exit!
