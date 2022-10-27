load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")
load_utility('Operations/AOCS/AOCS_GPS')
load_utility('Operations/FSW/FSW_FS')
load_utility('Operations/FSW/UTIL_CmdSender')


class TestAvionicsG < ASTCOSMOSTestCDH
    def initialize
        @module_telem = ModuleTelem.new
        @module_csp = ModuleCSP.new
        @module_fs = ModuleFS.new
        @cmd_sender = CmdSender.new
        @GPS = ModuleGPS.new
        @target = "BW3"
        @dpcs = [
            {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
            {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
            {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
            {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"},
            {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: "FSW", tid: "NORMAL"}
        ]
        @realtime_destination = 'COSMOS_UMBILICAL'
        super()
    end

    def setup
        @module_csp.reboot("FC_YP")
        @module_csp.reboot("APC_YP")
        wait(5)
        
        @collectors.each do | collector |
            # Turn on FSW telemetry for all tests
            @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)            
        end
        # Wait for 10 seconds after rebooting and turning on realtime to start getting packets
        wait(10)
        status_bar("setup")
    end

    def test_ping()
        puts "Running Ping Test"
        stack = combo_box("Select test stack", "YP", "YM")
        @apc_num = "APC_#{stack}"
        @fc_num = "FC_#{stack}"

        @collectors = [
            {board: @apc_num, pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
            {board: @fc_num, pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}
        ]

        @collectors.each do | collector |
            # Turn on FSW telemetry for all tests
            @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)            
        end
         
        puts "Running Ping Test"
        @collectors.each do | collector |
            @module_csp.ping(collector[:board])
        end

        @cmd_sender.send(@apc_num, "APC_LVC_OUTPUT_SINGLE", {"OUTPUT_CHANNEL": 7, "STATE_ONOFF": "ON", "DELAY": 0})
        wait(7)
        @dpcs.each do | dpc |
            @module_csp.ping(dpc[:board])
            wait(2)
        end
        status_bar("test_ping")
    end

    def test_FC_ON()
        puts "Running FC on test"
        @collectors.each do | collector |
            puts "Checking #{collector[:board]} system info"
            initial_uptime = @cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "UPTIME_IN_S")
            initial_bootcount = @cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "BOOTCOUNT")
            puts "init uptime: #{initial_uptime}\n\n"
            # Wait 30 seconds
            wait(30)
            final_uptime = @cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "UPTIME_IN_S")
            puts "init uptime: #{final_uptime}\n\n"
            final_bootcount = @cmd_sender.get_current_val(collector[:board], collector[:pkt_name], "BOOTCOUNT")
            # Uptime should be about 30 seconds more, hard to get exact timing with
            # COSMOS delays task frequency of 1hz
            check_expression("#{final_uptime} >= #{initial_uptime + 30} && #{final_uptime} <= #{initial_uptime + 31}")
            check_expression("#{initial_bootcount} == #{final_bootcount}")
          end

        #@module_telem.set_realtime("APC_YP", "THERMAL_TLM", @realtime_destination, 1)
        #apc_board_temp = @cmd_sender.get_current_val("APC_YP", "THERMAL_TLM", "TEMP_APC_MCU")
        #check_expression("#{apc_board_temp} != 0 ")
        status_bar("test_uptime")
     end
     

     def test_GPS_ON() # Emulator must be on and Simulation running
        puts "Running GPS on test"
        @cmd_sender.send(@apc_num, "APC_LVC_OUTPUT_SINGLE", {"OUTPUT_CHANNEL": 5, "STATE_ONOFF": "ON", "DELAY": 0})
        wait(3)
    
        @collectors.each do | collector |
          @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)
          wait(3)
        end
        @module_telem.set_realtime(@fc_num, 'AOCS_TLM', @realtime_destination, 1)

          wait(10) # takes a while for GPS TLM to come in

            initial_uptime = @cmd_sender.get_current_val(@fc_num, 'AOCS_TLM', 'RECEIVED_TIMESECONDS')
            puts "init uptime: #{initial_uptime}\n\n"
            # Wait 30 seconds
            wait(30)
            final_uptime = @cmd_sender.get_current_val(@fc_num, 'AOCS_TLM', 'RECEIVED_TIMESECONDS')
            puts "final uptime: #{final_uptime}\n\n"
            # Uptime should be about 30 seconds more, hard to get exact timing with
            # COSMOS delays task frequency of 1hz
            check_expression("#{final_uptime} < #{initial_uptime + 31}")

          #initial_time = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_TIME_SEC")
          #initial_V0 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_V0")
          #initial_V1 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_V1")
          #initial_V2 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_V2")
          #initial_X0 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_X0")
          #initial_X1 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_X1")
          #initial_X2 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_X2")

          #wait(30)
            
          #final_time = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_TIME_SEC")
          #final_V0 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_V0")
          #final_V1 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_V1")
          #final_V2 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_V2")
          #final_X0 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_X0")
          #final_X1 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_X1")
          #final_X2 = @cmd_sender.get_current_val("FC_YP", "AOCS_TLM", "GPS_X2")

          #check_expression("#{final_time} >= #{initial_time+ 30} && #{final_time} <= #{initial_time + 31}")
          #check_expression("#{final_V0} != #{initial_V0}")
          #check_expression("#{final_V1} != #{initial_V1}")
          #check_expression("#{final_V2} != #{initial_V2}")
          #check_expression("#{final_X0} != #{initial_X0}")
          #check_expression("#{final_X1} != #{initial_X1}")
          #check_expression("#{final_X2} != #{initial_X2}")          

          #@module_telem.set_realtime("APC_YP", "THERMAL_TLM", @realtime_destination, 1)
          #gps_board_temp = @cmd_sender.get_current_val("APC_YP", "THERMAL_TLM", "GPS_BOARD_TEMP")
          #check_expression("#{gps_board_temp} != 0 ")

          gps_presence = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_PRESENCE")
          #check_expression("\'#{gps_presence}\' == \'PRESENT\'")       
    end

    def test_GPS_OFF() # Emulator must be on and Simulation running
        puts "Running GPS off test"
        @cmd_sender.send(@apc_num, "APC_LVC_OUTPUT_SINGLE", {"OUTPUT_CHANNEL": 5, "STATE_ONOFF": "OFF", "DELAY": 0})
        wait(3)
    
        @collectors.each do | collector |
          @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)
          wait(3)
        end

          initial_time = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_TIME_SEC")
          initial_V0 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_V0")
          initial_V1 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_V1")
          initial_V2 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_V2")
          initial_X0 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_X0")
          initial_X1 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_X1")
          initial_X2 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_X2")

          wait(10)
            
          final_time = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_TIME_SEC")
          final_V0 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_V0")
          final_V1 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_V1")
          final_V2 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_V2")
          final_X0 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_X0")
          final_X1 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_X1")
          final_X2 = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_X2")

          check_expression("#{final_time} == #{initial_time}")
          check_expression("#{final_V0} == #{initial_V0}")
          check_expression("#{final_V1} == #{initial_V1}")
          check_expression("#{final_V2} == #{initial_V2}")
          check_expression("#{final_X0} == #{initial_X0}")
          check_expression("#{final_X1} == #{initial_X1}")
          check_expression("#{final_X2} == #{initial_X2}")   

          gps_presence = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "GPS_PRESENCE")
          check_expression("\'#{gps_presence}\' == \'NOT_PRESENT\'")        
    end


    def test_DPC_ON()
        puts "Running DPC on test"
        @cmd_sender.send(@apc_num, "APC_LVC_OUTPUT_SINGLE", {"OUTPUT_CHANNEL": 7, "STATE_ONOFF": "ON", "DELAY": 0})
        wait(10)

        @dpcs.each do | dpc |
            @module_telem.set_realtime(dpc[:board], dpc[:pkt_name], @realtime_destination, 1)
            puts "Checking #{dpc[:board]} system info"
            initial_uptime = @cmd_sender.get_current_val(dpc[:board], dpc[:pkt_name], "UPTIME_IN_S")
            initial_bootcount = @cmd_sender.get_current_val(dpc[:board], dpc[:pkt_name], "BOOTCOUNT")
            puts "init uptime: #{initial_uptime}\n\n"
            # Wait 30 seconds
            wait(30)
            final_uptime = @cmd_sender.get_current_val(dpc[:board], dpc[:pkt_name], "UPTIME_IN_S")
            puts "init uptime: #{final_uptime}\n\n"
            final_bootcount = @cmd_sender.get_current_val(dpc[:board], dpc[:pkt_name], "BOOTCOUNT")
            # Uptime should be about 30 seconds more, hard to get exact timing with
            # COSMOS delays task frequency of 1hz
            check_expression("#{final_uptime} >= #{initial_uptime + 30} && #{final_uptime} <= #{initial_uptime + 31}")
            check_expression("#{initial_bootcount} == #{final_bootcount}")
          end
          
          # Check Board Temp
          #dpc_board_temp = @cmd_sender.get_current_val("APC_YP", "THERMAL_TLM", "DPC_BOARD_TEMP")
          #check_expression("#{dpc_board_temp} != 0 ") # && #{dpc_board_temp} != 123.4567
          
          status_bar("test_DPC_ON teardown")
    end

    def test_DPC_OFF()
        puts "Running DPC off test"
        @cmd_sender.send(@apc_num, "APC_LVC_OUTPUT_SINGLE", {"OUTPUT_CHANNEL": 7, "STATE_ONOFF": "OFF", "DELAY": 0})
        wait(3)

        @dpcs.each do | dpc |
            puts "Checking #{dpc[:board]} system info"
            initial_uptime = @cmd_sender.get_current_val(dpc[:board], dpc[:pkt_name], "UPTIME_IN_S")
            initial_bootcount = @cmd_sender.get_current_val(dpc[:board], dpc[:pkt_name], "BOOTCOUNT")
            puts "init uptime: #{initial_uptime}\n\n"
            # Wait 30 seconds
            wait(10)
            final_uptime = @cmd_sender.get_current_val(dpc[:board], dpc[:pkt_name], "UPTIME_IN_S")
            puts "init uptime: #{final_uptime}\n\n"
            final_bootcount = @cmd_sender.get_current_val(dpc[:board], dpc[:pkt_name], "BOOTCOUNT")
            # Uptime should be about 30 seconds more, hard to get exact timing with
            # COSMOS delays task frequency of 1hz
            check_expression("#{final_uptime} == #{initial_uptime}")
            check_expression("#{initial_bootcount} == #{final_bootcount}")
            status_bar("test_uptime")
          end
          status_bar("test_DPC_OFF teardown")
    end

    def test_UHF_pres()
        @module_telem.set_realtime(@apc_num,'COMM_TLM', @realtime_destination, 1)
        wait(10)
        init_cnt = tlm(@target, @apc_num + "-COMM_TLM", "RECEIVED_COUNT")
        wait_check(@target, @apc_num + "-COMM_TLM", "RECEIVED_COUNT", " > #{init_cnt}", 3)
        wait_check(@target, @apc_num + "-COMM_TLM", "UHF_PRESENCE", "=='PRESENT'", 2)

        initial_uptime = @cmd_sender.get_current_val(@apc_num, 'COMM_TLM', 'UHF_UPTIME_IN_SEC')
        initial_bootcount = @cmd_sender.get_current_val(@apc_num, 'COMM_TLM', 'UHF_BOOTCOUNT')
        puts "init uptime: #{initial_uptime}\n\n"
        # Wait 30 seconds
        wait(30)
        final_uptime = @cmd_sender.get_current_val(@apc_num, 'COMM_TLM', 'UHF_UPTIME_IN_SEC')
        puts "init uptime: #{final_uptime}\n\n"
        final_bootcount = @cmd_sender.get_current_val(@apc_num, 'COMM_TLM', 'UHF_BOOTCOUNT')
        # Uptime should be about 30 seconds more, hard to get exact timing with
        # COSMOS delays task frequency of 1hz
        check_expression("#{final_uptime} >= #{initial_uptime + 30} && #{final_uptime} <= #{initial_uptime + 31}")
        check_expression("#{initial_bootcount} == #{final_bootcount}")
    end

    def test_all()
        test_ping()
        test_FC_ON()
        wait(5)
        test_GPS_ON()
        wait(5)
        test_GPS_OFF()
        wait(5)
        test_GPS_ON()
        wait(5)
        test_DPC_ON()
        wait(5)
        test_DPC_OFF()
        wait(5)
        test_DPC_ON()
        wait(5)
        test_UHF_pres()
    end

    def teardown
        status_bar("teardown")
    end
end
