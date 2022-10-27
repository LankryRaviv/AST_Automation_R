load('cosmos/tools/test_runner/test.rb')
load('Operations/FSW/FSW_FS_Upload.rb')
load('Operations/FSW/FSW_FS.rb')
load('TestRunnerUtils/AST_Test_Base.rb')
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")
load_utility('Operations/AOCS/AOCS_RWA')
load_utility('Operations/FSW/FSW_FS')
load_utility('Operations/FSW/UTIL_CmdSender')


class TestAPCcross < ASTCOSMOSTestCDH
    def initialize
        @module_telem = ModuleTelem.new
        @module_csp = ModuleCSP.new
        @module_fs = ModuleFS.new
        @cmd_sender = CmdSender.new
        @RWA = ModuleRWA.new
        @pcdu = PCDU.new
        @target = "BW3"
        @realtime_destination = 'COSMOS_UMBILICAL'
        super()
    end

    def test_apc_cross()
        puts "Running APC to APC data test"
        stack = combo_box("Select test stack", "YP", "YM")
        @apc_num = "APC_" + stack
        @fc_num = "FC_" + stack

        if stack == "YP"
            @apc_other = "APC_YM" 
            @fc_other = "FC_YM"
        else 
            @apc_other = "APC_YP" 
            @fc_other = "FC_YP"
        end

        @collectors = [
            {board: @apc_num, pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
            {board: @apc_num, pkt_name: 'POWER_PCDU_LVC_TLM',  sid: "FSW", tid: "NORMAL"},
            {board: @apc_num, pkt_name: 'POWER_CSBATS_TLM',  sid: "FSW", tid: "NORMAL"},
            {board: @apc_num, pkt_name: 'COMM_TLM',  sid: "FSW", tid: "NORMAL"},
            {board: @fc_num, pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"},
            {board: @fc_num, pkt_name: 'AOCS_TLM',  sid: "FSW", tid: "NORMAL"},
        ]

        @collectors.each do | collector |
            # Turn on FSW telemetry for all tests
            @module_telem.set_realtime(collector[:board], collector[:pkt_name], @realtime_destination, 1)
            wait(3)            
        end

        #*************************************QVT DATA**************************************************
        qvt_num = combo_box("Enter the QVT NUM", "YP", "YM")
        @cmd_sender.send_with_cmd_count_check(@apc_num, "QVT_SET_CURRENT_QVT", {"SIDE": qvt_num}, "COMM", 4)
        method_name = "set_QV_TRANSCEIVER_#{qvt_num}_5V"
        @pcdu.public_send(method_name, @apc_num, 1)
        wait(3)
        qvt_presence = @cmd_sender.get_current_val(@apc_num, "COMM_TLM", "QVT_PRESENCE")
        check_expression("\'#{qvt_presence}\' == \'PRESENT\'")
        qvt_temp = @cmd_sender.get_current_val(@apc_num, "COMM_TLM", "QVT_TEMP")
        check_expression("#{qvt_temp} > 0 && #{qvt_temp} != 1234")


        #*************************************MAG DATA**************************************************

        pMag_presence = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "MAG_PRIMARY_PRESENCE")
        check_expression("\'#{pMag_presence}\' == \'PRESENT\'")
        pMag_temp = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "MAG_PRIMARY_TEMP")
        check_expression("#{pMag_temp} > 0 && #{pMag_temp} != 1234")

        sMag_presence = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "MAG_SECONDARY_PRESENCE")
        check_expression("\'#{sMag_presence}\' == \'PRESENT\'")
        sMag_temp = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", "MAG_SECONDARY_TEMP")
        check_expression("#{sMag_temp} > 0 && #{sMag_temp} != 1234")


        #*************************************RWA DATA**************************************************

        @rwa_num = combo_box("Enter the RWA NUM", "RWA_YP0_Z", "RWA_YM0_Z", "RWA_YP1_X", "RWA_YM1_X")
        @RWA.power_on_RWA(@apc_num, @rwa_num)
        wait(3)
        #@RWA.actuator_ground_mode(@fc_num, "GROUND")
        #wait(3)
        #@RWA.set_wheel_mode_RWA(@fc_num, @rwa_num, "EXTERNAL")
        #wait(3)
        #@RWA.set_wheel_timeout_protection(@fc_num, @rwa_num)
        #wait(3)
        wheel_presence = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", @rwa_num + "_PRESENCE")
        check_expression("\'#{wheel_presence}\' == \'PRESENT\'")
        #@RWA.set_wheel_torque_RWA(@fc_num,@rwa_num, 0.03)
        #wait(10)
        #wheel_current = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", @rwa_num + "_CURRENT")
        #check_expression("#{wheel_current} > 0.0")
        #@RWA.set_wheel_torque_RWA(@fc_num,@rwa_num, -0.06)
        #wait(10)
        #wheel_current = @cmd_sender.get_current_val(@fc_num, "AOCS_TLM", @rwa_num + "_CURRENT")
        #check_expression("#{wheel_current} > 0.0")
        #wait(3)
        #@RWA.set_wheel_speed_RWA(@fc_num,@rwa_num, 0.0)
        #wait(3)
        #@RWA.power_off_RWA(@apc_num, @rwa_num)
        wait(3)
    end

end
