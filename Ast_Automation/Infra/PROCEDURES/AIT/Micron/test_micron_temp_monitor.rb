load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'


class MicronTemperature < ASTCOSMOSTestMicron

    def initialize
        @setup_complete = false
        @cmd_sender = CmdSender.new
        @all_microns = ["MICRON_119", "MICRON_120", "MICRON_121", "MICRON_107", "MICRON_93", "MICRON_79", "MICRON_78", "MICRON_77", "MICRON_76", "MICRON_90", "MICRON_104", "MICRON_118",
        "MICRON_133", "MICRON_134", "MICRON_135", "MICRON_136", "MICRON_122", "MICRON_108", "MICRON_94", "MICRON_80", "MICRON_66", "MICRON_65", "MICRON_64", "MICRON_63", "MICRON_62", "MICRON_61",
        "MICRON_75", "MICRON_89", "MICRON_103", "MICRON_117", "MICRON_131", "MICRON_132", "MICRON_146", "MICRON_147", "MICRON_148", "MICRON_149", "MICRON_150", "MICRON_151", "MICRON_137",
        "MICRON_123", "MICRON_109", "MICRON_95", "MICRON_81", "MICRON_67", "MICRON_53", "MICRON_52", "MICRON_51", "MICRON_50", "MICRON_49", "MICRON_48", "MICRON_47", "MICRON_46",
        "MICRON_74", "MICRON_88", "MICRON_102", "MICRON_116", "MICRON_130", "MICRON_144", "MICRON_145", "MICRON_158", "MICRON_159", "MICRON_160", "MICRON_161", "MICRON_162", "MICRON_163",
        "MICRON_164", "MICRON_165", "MICRON_166", "MICRON_152", "MICRON_138", "MICRON_124", "MICRON_110", "MICRON_96", "MICRON_82", "MICRON_68", "MICRON_54", "MICRON_40", "MICRON_39",
        "MICRON_38", "MICRON_37", "MICRON_36", "MICRON_35", "MICRON_34", "MICRON_33", "MICRON_32", "MICRON_31", "MICRON_45", "MICRON_59", "MICRON_73", "MICRON_87", "MICRON_101", "MICRON_115",
        "MICRON_129", "MICRON_143", "MICRON_157", "MICRON_172", "MICRON_173", "MICRON_174", "MICRON_175", "MICRON_176", "MICRON_177", "MICRON_178", "MICRON_179", "MICRON_167", "MICRON_153",
        "MICRON_139", "MICRON_125", "MICRON_111", "MICRON_97", "MICRON_83", "MICRON_69", "MICRON_55", "MICRON_41", "MICRON_25", "MICRON_24", "MICRON_23", "MICRON_22", "MICRON_21", "MICRON_20",
        "MICRON_19", "MICRON_18", "MICRON_30", "MICRON_44", "MICRON_58", "MICRON_72", "MICRON_86", "MICRON_100", "MICRON_114", "MICRON_128", "MICRON_142", "MICRON_156", "MICRON_186", "MICRON_187",
        "MICRON_188", "MICRON_189", "MICRON_190", "MICRON_191","MICRON_192", "MICRON_193", "MICRON_11", "MICRON_10","MICRON_9", "MICRON_8", "MICRON_7", "MICRON_6","MICRON_5", "MICRON_4"]
        
        @fpga_temp_limit = 85
        @fem_temp_limit = 70
        @batt_temp_limit = 35
        @cpbf_temp_limit = 65
        
        super()
    end

    def setup()

        if @setup_complete

            if @request_indefinitely == "User Stops"
                message = "\n\nRequest Type: #{@request_indefinitely}\nRequest temps every: #{@request_time} seconds\nMicron IDs: #{@micron_id}"
            elsif @request_indefinitely == "Duration"
                message = "\n\nRequest Type: #{@request_indefinitely}\nRequest temps every: #{@request_time} seconds\nRun duration: #{@request_duration}\nMicron IDs: #{@micron_id}"
            else
                message = "\n\nRequest Type: #{@request_indefinitely}\nMicron IDs: #{@micron_id}"
            end

            answer = message_box("Running test with the following paramters: #{message} \nPress OK to accept these parameters or Re-Enter to select different parameters", "OK","Re-Enter")

            if answer != "OK"
                @setup_complete = false
            end
        end

        if not @setup_complete
           
            @request_indefinitely  = combo_box("Request temperature data once, until script until user stops or for a set duration?", "Single Request", "User Stops", "Duration")

            if @request_indefinitely  != "Single Request"
                @request_time = ask("Enter the time in seconds between telemetry  requests")
            end

            if @request_indefinitely == "Duration"
                @request_duration = ask("Enter the duration in seconds to run this script")
            end

            @micron_id = combo_box("Select Input Micron ID", "BROADCAST_ALL", "ALL_INDIVIDUALLY")

            @setup_complete = true

            plt = message_box("Would you like to open Telemetry Grapher with Micron Temperatures?", "Yes", "No")
            if plt == "Yes"
                plot_config_file = "./config/tools/tlm_grapher/micron_temperature.txt"
                spawn("./tools/TLMGrapher --start --config #{plot_config_file}")
            end
        end

        @file_name = Cosmos::USERPATH + "/outputs/logs/Micron_Temp_Monitoring_#{Time.now.strftime("%Y_%m_%d_%H_%M_%S")}.csv"
        cmd_params = {"PERIOD_MS":1000}
        @cmd_sender.send("CPBF", "CPBF_SET_TLM_INT_CMD", cmd_params)

    end

    def test_get_thermal_data()
        setup()

        CSV.open(@file_name, "wb") do |csv|
            csv << ["Time", "Micron Max FPGA Temp", "Micron Max Battery Temp", "Micron Max FEM Temp", "CPBF FPGA Temp", "CPBF VUP Temp", "Microns IDs"]
        end

        if @request_indefinitely == "User Stops"
            request_thermal_data_indefinitely()
        elsif @request_indefinitely == "Duration"
            request_thermal_data_duration()
        else
            request_thermal_data_single()
        end
    end

    def request_thermal_data()

        if @micron_id == "ALL_INDIVIDUALLY"
            @micron_list = @all_microns
        else
            @micron_list = [@micron_id]
        end


        # Request the packets
        pkt = subscribe_packet_data([['BW3', 'MIC_LSL-MIC_THERMAL_TLM']])

        disable_instrumentation do
            @micron_list.each do |id|
                cmd_params = {"MICRON_ID": id,
                                "SUBSYSTEM_ID": "THERMAL"}
                @cmd_sender.send("MIC_LSL", "MIC_DETAILED_TELEMETRY", cmd_params)
                #inject_tlm("BW3", "MIC_LSL-MIC_THERMAL_TLM", {"MIC_TEMPERATURE_INSIDE_FPGA"=>rand(22..25), "MICRON_ID"=>micron, "MIC_TEMPERATURE_BATTERY_CELL_0"=>rand(22..25)})
            end
        

            # Wait up to 5 seconds for the microns to respond
            wait(5)
            micron_list = []
            fpga_temp_data = []
            batt_temp_data = []
            fem_temp_data = []
            
            begin 
                while true
                    out_of_limit_message = ""
                    packet = get_packet(pkt, true)
                    micron_list << packet.read('MICRON_ID')
                    fpga_temp_pre = [packet.read('MIC_TEMPERATURE_INSIDE_FPGA')]
                    fpga_temp_pre.delete(65535.0)
                    fpga_temp_data << fpga_temp_pre[0]
                    if fpga_temp_pre[0] >= @fpga_temp_limit
                      out_of_limit_message << "\tFPGA_TEMP out of limits: #{fpga_temp_data}\n\n"
                    end
                    batt_temp_pre = [packet.read('MIC_TEMPERATURE_BATTERY_CELL_0'), packet.read('MIC_TEMPERATURE_BATTERY_CELL_1'),packet.read('MIC_TEMPERATURE_BATTERY_CELL_2'),packet.read('MIC_TEMPERATURE_BATTERY_CELL_3'),
                                    packet.read('MIC_TEMPERATURE_BATTERY_CELL_4'),packet.read('MIC_TEMPERATURE_BATTERY_CELL_5'),packet.read('MIC_TEMPERATURE_BATTERY_CELL_6'),packet.read('MIC_TEMPERATURE_BATTERY_CELL_7')]
                    batt_temp_pre.delete(65535.0)
                    batt_out_of_range_temps = batt_temp_pre.find_all {|n| n>= @batt_temp_limit}
                    if batt_out_of_range_temps.length > 0
                        out_of_limit_message << "\t#{batt_out_of_range_temps.length} BATT temps out of limits: #{batt_out_of_range_temps}\n\n"
                    end
                        
                    batt_temp_data << batt_temp_pre.max()
                    fem_temp_pre = [packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_0'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_1'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_2'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_3'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_5'),
                                       packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_6'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_7'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_8'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_9'),
                                       packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_10'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_11'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_12'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_13'),
                                       packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_14'),packet.read('MIC_TEMPERATURE_FEM_INSIDE_CU_15'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_0'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_1'),
                                       packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_2'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_3'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_5'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_6'),
                                       packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_7'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_8'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_9'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_10'),
                                       packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_11'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_12'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_13'),packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_14'),
                                       packet.read('MIC_TEMPERATURE_FEM_NEAR_PA_15')]
                    fem_temp_pre.delete(65535.0)
                    fem_out_of_range_temps = fem_temp_pre.find_all {|n| n>= @fem_temp_limit}
                    if fem_out_of_range_temps.length > 0
                        out_of_limit_message << "\t#{fem_out_of_range_temps.length} FEM temps out of limits: #{fem_out_of_range_temps}"
                    end
                    
                    fem_temp_data << fem_temp_pre.max()
                    
                    if out_of_limit_message!=""
                      message_box("Out of Limit Temperatures detected! Stop the test immediately and safe the hardware\n\n Micron ID: #{packet.read('MICRON_ID')}\n" + out_of_limit_message,"Acknowledged")
                    end
                    
                    #if 
                    
                end
            rescue => threadError
                puts ""
            end
            fpga_temp_data.delete(nil)
            batt_temp_data.delete(nil)
            fem_temp_data.delete(nil)
            cpbf_fpga_temp = tlm("BW3", "CPBF-CPBF_TLM", "CPBF_RFSOC_FPGA_TEMP")
            cpbf_vup_temp = tlm("BW3", "CPBF-CPBF_TLM", "CPBF_VUP_TEMP")
            if cpbf_fpga_temp >= @cpbf_temp_limit || cpbf_vup_temp >=@cpbf_temp_limit
              message_box("Out of Limit Temperatures detected! Stop the test immediately and safe the hardware\n\nCPBF FPGA Temp: #{cpbf_fpga_temp}\nCPBF VUP Temp: #{cpbf_vup_temp}")
            end
            puts "Data collected from Microns: #{micron_list}"
            puts "Max FPGA Temp: #{fpga_temp_data.max()}, Max Battery Temp: #{batt_temp_data.max()}, Max FEM Temp: #{fem_temp_data.max()}, CPBF FPGA Temp: #{cpbf_fpga_temp}, CPBF VUP Temp: #{cpbf_vup_temp}"
            CSV.open(@file_name, "ab") do |csv|
                csv << [Time.now, fpga_temp_data.max(), batt_temp_data.max(), fem_temp_data.max(), cpbf_fpga_temp, cpbf_vup_temp, micron_list]
            end

            unsubscribe_packet_data(pkt)
        end
    end

    def request_thermal_data_duration()

        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        while Process.clock_gettime(Process::CLOCK_MONOTONIC)-start_time < @request_duration
            request_thermal_data()
            wait(@request_time)
        end
    end

    def request_thermal_data_indefinitely()
        while true
            request_thermal_data()
            wait(@request_time)
        end
      
    end

    def request_thermal_data_single()
        request_thermal_data()
    end

end

#handle = MicronTemperature.new
#handle.test_get_thermal_data()