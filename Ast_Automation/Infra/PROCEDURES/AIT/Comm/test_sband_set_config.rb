load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/COMM/SBand_Properties.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')
load_utility('Operations/COMM/COMM_TTC.rb')

class SbandSetConfig < ASTCOSMOSTestComm 

    def initialize(target = "BW3")
        @cmd_sender = CmdSender.new
        @module_telem = ModuleTelem.new
        @target = target
        @csp_destination = "COSMOS_UMBILICAL"
        @module_ttc = ModuleTTC.new
        @test_util = ModuleTestCase.new
        @sband_properties = ModuleSBandProperties.new
        @wait_time = 10 

        super()
    end

    def setup(test_case_name = "SBand_SET_CONFIG")

        @stack = @test_util.initialize_test_case(test_case_name)
        @apc_board = "APC_#{@stack}"

    end

    # -------------------------------------------------------
    def test_SBand_set_low_rate_main()
        setup("SBand_low_rate_main")

        @sband_properties.SBand_set_low_rate_main(@apc_board)
        # Reboot the Sband
        cmd_params = {"TIME": 2}
        @cmd_sender.send_with_cmd_count_check(@apc_board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)        
    end

    # -------------------------------------------------------
    def test_SBand_set_low_rate_fallback()
        setup("SBand_low_rate_fallback")

        @sband_properties.SBand_set_low_rate_fallback(@apc_board)
        # Reboot the Sband
        cmd_params = {"TIME": 2}
        @cmd_sender.send_with_cmd_count_check(@apc_board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)
    end

    # -------------------------------------------------------
    def test_SBand_set_med_rate_main()
        setup("SBand_med_rate_main")

        @sband_properties.SBand_set_med_rate_main(@apc_board)
        # Reboot the Sband
        cmd_params = {"TIME": 2}
        @cmd_sender.send_with_cmd_count_check(@apc_board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)

    end

    # -------------------------------------------------------
    def test_SBand_set_med_rate_fallback()
        setup("SBand_med_rate_fallback")

        @sband_properties.SBand_set_med_rate_fallback(@apc_board)
        # Reboot the Sband
        cmd_params = {"TIME": 2}
        @cmd_sender.send_with_cmd_count_check(@apc_board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)
        
    end

    # -------------------------------------------------------
    def test_SBand_set_high_rate_main()
        setup("SBand_high_rate_main")

        @sband_properties.SBand_set_high_rate_main(@apc_board)
        # Reboot the Sband
        cmd_params = {"TIME": 2}
        @cmd_sender.send_with_cmd_count_check(@apc_board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)

    end

    # -------------------------------------------------------
    def test_SBand_set_high_rate_fallback()
        setup("SBand_high_rate_fallback")

        @sband_properties.SBand_set_high_rate_fallback(@apc_board)
        # Reboot the Sband
        cmd_params = {"TIME": 2}
        @cmd_sender.send_with_cmd_count_check(@apc_board, "SBAND_SET_REBOOTTIMER", cmd_params, "COMM", @wait_time)

    end

   
end
