load_utility('Operations/CPBF/CPBF_MODULE.rb')

require 'csv'
require 'date'

def send_bf_cmds_from_file(filename, cmd_rate = 0.05)
    # check if file exists
    if !(File.exist?(filename))
        puts("File #{filename} does not exist")
        return false
    end
    cpbf = ModuleCPBF.new

    #file is csv/comma delimited, read using CSV
    table = CSV.parse(File.read(filename), headers: true)
    table.each do |entry|
        if entry.length != 4
            puts("Incorrect length for row: #{entry}")
            next
        end
        # entry format is micron_id, R/W flag, Reg Addr, Reg Data
        cpbf.cpbf_micron_rw_reg_cmd(entry[0].to_i, entry[1].to_i, Integer(entry[2]),Integer(entry[3]), cmd_rate * 100)
        wait(cmd_rate)
    end

end