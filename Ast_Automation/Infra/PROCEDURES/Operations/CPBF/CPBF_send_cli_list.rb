load('Operations/CPBF/CPBF_MODULE.rb')

require 'csv'
require 'date'

def send_cli_cmds_from_file(filename, cmd_rate = 0.05, wait_time=1)
    
    # check if file exists
    if !(File.exist?(filename))
        puts("File #{filename} does not exist")
        return false
    end
    cpbf = ModuleCPBF.new

    #file is csv/comma delimited, read using CSV
    table = CSV.parse(File.read(filename), headers: true)
    File.readlines(filename).each do |line|
        # entry index 0 is cmd, 1 is response
        entry = line.split(':')
        if entry.length > 1
            res = cpbf.cpbf_remote_cli_cmd(entry[0], true, wait_time)
            if res.eql? entry[1]
                puts("CLI cmd #{entry[0]} successful with #{entry[1]}")
            else
                puts("CLI cmd #{entry[0]} not successful. Result is #{res}")
            end
        else
            cpbf.cpbf_remote_cli_cmd(entry[0], false, wait_time)
            puts("CLI cmd #{entry[0]} sent.")
        end
        wait(cmd_rate)
    end
    puts("All CLI cmds in #{filename} have been issued.")

end
