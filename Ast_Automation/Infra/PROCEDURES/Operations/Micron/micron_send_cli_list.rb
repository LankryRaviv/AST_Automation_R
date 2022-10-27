load('Operations/Micron/MICRON_MODULE.rb')

require 'csv'
require 'date'

def send_cli_cmds_from_file(micron_list, filename, cmd_rate = 0.05, wait_time=1)
    # check if file exists
    if !(File.exist?(filename))
        puts("File #{filename} does not exist")
        return false
    end

    #file is csv/comma delimited, read using CSV
    table = CSV.parse(File.read(filename), headers: true)
    micron_list.each do |micron_id|
        table.each do |entry|
            # entry index 0 is cmd, 1 is response
            res = send_cli_get_res(micron_id, entry[0], wait_time)
            if entry.length > 1
                if res.eql? entry[1]
                    puts("CLI cmd #{entry[0]} successful with #{entry[1]}")
                else
                    puts("CLI cmd #{entry[0]} not successful. Result is #{res}")
                end
            else
                puts("CLI cmd #{entry[0]} sent. Response is #{res}")
            end
            wait(cmd_rate)
        end
    end

end

def send_cli_get_res(micron_id, cli_cmd, wait_time=1)
    # need to upload in 21 character chunks
    mic = MICRON_MODULE.new
    link = 'MIC_LSL'

    cli_cmd_len = cli_cmd.length  
    if cli_cmd_len <= 21
        res = mic.remote_cli(link, micron_id, 0, cli_cmd, "COMPLETED", wait_time)
    else
        cli_str_arr = cli_cmd.split(' ') 
        iter_arr = cli_str_arr.take(cli_str_arr.length() - 1)
        iter_arr.each do |cli_str| 
        puts("sending #{cli_str}") 
        mic.remote_cli(link, micron_id, 0, cli_str, "CONTINUE")
     end
     res = mic.remote_cli(link, micron_id, 0, cli_str_arr.last, "COMPLETED", wait_time)
    end
    return res
end