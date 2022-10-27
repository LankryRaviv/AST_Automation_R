load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/COMM/UHF_Config_Params.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')

class UHFSetConfig < ASTCOSMOSTestComm 

    def initialize(target = "BW3")
        @cmd_sender = CmdSender.new
        @module_telem = ModuleTelem.new
        @target = target
        @csp_destination = "COSMOS_UMBILICAL"
        @uhf_config = UHFConfig.new
        @test_util = ModuleTestCase.new
        @wait_time = 10

        super()
    end

    def setup(test_case_name = "UHF_SET_CONFIG")

        @stack = @test_util.initialize_test_case(test_case_name)

    end

    def test_UHF_set_1st_contact_main()
        setup("UHF_1st_Contact_Main")

        @uhf_config.UHF_set_1st_contact_main()  
        cmd_param = {"CSP_REBOOT_MAGIC_VALUE":"REBOOT"}
        @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_param)     
        
    end
    
    def test_UHF_set_1st_contact_fallback()
        setup("UHF_1st_Contact_Fallback")

        @uhf_config.UHF_set_1st_contact_fallback()   
        cmd_param = {"CSP_REBOOT_MAGIC_VALUE":"REBOOT"}
        @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_param)
    end

    def test_UHF_set_low_rate_main()

        setup("UHF_low_rate_main")

        @uhf_config.UHF_set_low_rate_main()  
        cmd_param = {"CSP_REBOOT_MAGIC_VALUE":"REBOOT"}
        @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_param)
    end

    def test_UHF_set_low_rate_fallback()
        setup("UHF_low_rate_fallback")

        @uhf_config.UHF_set_low_rate_fallback()  
        cmd_param = {"CSP_REBOOT_MAGIC_VALUE":"REBOOT"}
        @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_param)

    end

    def test_UHF_set_high_rate_main()

        setup("UHF_high_rate_main")

        @uhf_config.UHF_set_high_rate_main()
        cmd_param = {"CSP_REBOOT_MAGIC_VALUE":"REBOOT"}
        @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_param)

    end

    def test_UHF_set_high_rate_fallback()

        setup("UHF_high_rate_fallback")

        @uhf_config.UHF_set_high_rate_fallback()
        cmd_param = {"CSP_REBOOT_MAGIC_VALUE":"REBOOT"}
        @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_param)

    end

    def test_set_uhf_config_from_file()

        file_path = open_file_dialog("Cosmos::USERPATH\\..\\..\\..\\PROCEDURES\\AIT\\COMM")

        @uhf_config.set_config_from_file(file_path)

        cmd_param = {"CSP_REBOOT_MAGIC_VALUE":"REBOOT"}
        @cmd_sender.send("UHF", "FSW_CSP_REBOOT", cmd_param)

    end

    def test_read_Active_UHF_config()
        @uhf_config.read_all_properties("ACTIVE")
    end

    def test_read_Main_UHF_config()
        @uhf_config.read_all_properties("MAIN")

    end

    def test_read_Fallback_UHF_config()
        @uhf_config.read_all_properties("FALLBACK")

    end

end

#handle = UHFSetConfig.new
#handle.test_set_uhf_config_from_file