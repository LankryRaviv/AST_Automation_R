require 'csv'
require 'cosmos'
require 'cosmos/script'

class CSVReader
    def extract_test_setup_obj 
        @objs = []
        values = CSV.read('C:/COSMOS/ast-master/procedures/utils/test.csv', headers: false)
        values.each do | row |
            generic_test = GenericTLMTest.new
            generic_test.set_board(row)
            @objs << generic_test
        end
        return @obj
    end
    def extract_test_setup
        return CSV.read('C:/COSMOS/ast-master/procedures/utils/test.csv', headers: false)
    end

# require 'csv'
    def doit
        values = CSV.read('C:/COSMOS/ast-master/procedures/utils/cmd_input.csv', headers: false)
        values.each do | row |
            output = {}
            row.each do | item |
                k,v = item.split(':')
                output[k] = v
            end
            target = output.fetch('TAR')
            cmd_name = output.fetch('CMD_NAME')
            wait_interval = output.fetch('TO_WAIT')
            params = output.select { |key, value| /^PARAM_/.match(key.to_s) }
            check_params = output.select { |key, value| /^CHECK_PARAM_/.match(key.to_s) }
            pkt_name = output.fetch ('PKT_NAME')
            perform_test(target,cmd_name,params,wait_interval,pkt_name,check_params)
        end
    end
    def perform_test(target,cmd_name,params,wait_interval,pkt_name,check_params)
        cmd_string = target + " " + cmd_name + " with " + get_param_string(6, params)
        puts "Cmd to send --- " + cmd_string
        cmd(cmd_string)
        puts "params to check --- " + check_params.to_s
        check_params.each do |key,value|
            puts "Checking telem --- " + target + "," + pkt_name + "," + key[12..-1] + "," + value + "," + wait_interval
            #wait_check(target,pkt_name,key[12..-1],value,wait_interval.to_i)
        end
    end
    def get_param_string(offset, params)
        to_return = ""
        params.each do |key, value|
            to_return = to_return + key[offset..-1] + " " + value + " ,"
        end
        to_return[0..(to_return.length - 2)]
    end
end