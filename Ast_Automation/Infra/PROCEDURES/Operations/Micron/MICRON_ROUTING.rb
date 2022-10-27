load_utility('Operations/MICRON/MICRON_MODULE.rb')

require 'csv'
require 'date'

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

def get_micron_default_routing(micron_id, out_file, run_id = "",ping_pass = true)
    m = MICRON_MODULE.new
    board = "MIC_LSL" 
    time = Time.new
    raw_res = m.get_micron_default_routing(board, micron_id)
    
    if(ping_pass && raw_res != [])
        raw_res = raw_res[0]
        puts("##########  Result  #########")
        
        rout_res = raw_res["MIC_CURRENT_ROUTING_LOW_SPEED"]
        puts rout_res
        
        def dec2bin(number)
            number = Integer(number)
            if(number == 0) then 0 end
                
            ret_bin = ""
            while(number != 0)
                ret_bin = String(number % 2) + ret_bin
                number = number / 2
            end
            ret_bin.rjust(8, "0")
        end
    
        # rout_res = 105
        res = dec2bin(rout_res)
        bwd = res[0..2]
        default_routing = ["","","",""]
    
        # Convert BWD FROM BIN TO STRING
        if bwd == "001"
            default_routing[0] = "BWD"
            puts("bwd west")
        end
        if bwd == "010"
            default_routing[1] = "BWD"
            puts("bwd east")
        end
        if bwd == "011"
            default_routing[2] = "BWD"
            puts("bwd north")
        end
        if bwd == "100"
            default_routing[3] = "BWD"
            puts("bwd south")
        end
        if bwd == "101"
            puts("bwd FPAG")
        end
    
        # Convert FWD FROM BIN TO STRING
        if res[4] == "1"
            default_routing[3] = "FWD"
            puts("fwd south")
        end
        if res[5] == "1"
            default_routing[2] = "FWD"
            puts("fwd north")
        end
        if res[6] == "1"
            default_routing[1] = "FWD"
            puts("fwd east")
        end
        if res[7] == "1"
            default_routing[0] = "FWD"
            puts("fwd west")
        end
    
        puts(micron_id + " default routing is:")
        print default_routing
        puts ""
    
        # COMPARE MICRON ROUTING TO DB
        table = CSV.parse(File.read("C:\\Cosmos\\PROCEDURES\\Operations\\Routing\\Micron_ID_PORT_Routing_Table.csv"), headers: true)
        id_index = 1
        col_w = 1
        col_e = 2
        col_n = 3
        col_s = 4
    
        flag = true
        micron_id_list = [*1..196]
        exclude_micron_list = [1,2,3,12,13,14,15,16,17,26,27,28,29,42,43,56,57,70,71,84,85,98,99,112,113,126,127,140,141,154,155,168,169,170,171,180,181,182,183,184,185,194,195,196]
        x = table.by_row[micron_id[7..-1].to_i-1].to_s.split(",")[0..4]
        puts("Real routing:")
        print x
        puts ""
    
    
        if table.by_row[micron_id[7..-1].to_i-1].to_s.split(",")[0..4][col_w] == default_routing[col_w-1]
            puts("WEST routing is OK")
            
        else
            puts("WEST routing is Fault")
            flag = false
        end
    
        if table.by_row[micron_id[7..-1].to_i-1].to_s.split(",")[0..4][col_e] == default_routing[col_e-1]
            puts("EAST routing is OK")
           
        else
            puts("EAST routing is Fault")
            flag = false
        end
    
        if table.by_row[micron_id[7..-1].to_i-1].to_s.split(",")[0..4][col_n] == default_routing[col_n-1]
            puts("NORTH routing is OK")
            
        else
            puts("NORTH routing is Fault")
            flag = false
        end
    
        if table.by_row[micron_id[7..-1].to_i-1].to_s.split(",")[0..4][col_s] == default_routing[col_s-1]
            puts("SOUTH routing is OK")
            
        else
            puts("SOUTH routing is Fault")
            flag = false
        end
    
    
        # if flag == 0
        #     puts(micron_id + " routing PASS")
        # else
        #     puts(micron_id + " routing FAIL")
        # end
    else
        flag = false
    end
    
    test_result = "PASS";
    if(!flag)
        test_result = "FAIL";
    end
    write_to_log_file(run_id, time, "CHECK_ROUTING_MICRON_#{get_micron_id_filterd(micron_id)}",
    "TRUE", "TRUE", flag, "BOOLEAN", test_result, "BW3_COMP_SAFETY", out_file)

    return flag
end

#flag = get_micron_defoult_routing(micron_id)

#if flag == 0
#    puts(micron_id + " routing PASS")
#else
 #   puts(micron_id + " routing FAIL")
#end



