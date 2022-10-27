load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/ast_test_base.rb'
load_utility("Operations/FSW/FSW_CSP")
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility("Operations/FSW/FSW_Telem")
load_utility('Operations/AOCS/AOCS_ST')
load_utility('TestRunnerUtils/test_case_utils.rb')


class STTest_SOH < ASTCOSMOSTestAOCS
    def initialize
        @telem = ModuleTelem.new
        @ST = ModuleST.new
        @cmd_sender = CmdSender.new
        @target = "BW3"
        @realtime_destination = 'COSMOS_UMBILICAL'
        @test_util = ModuleTestCase.new
        @module_csp = ModuleCSP.new
        super()
      end
    
      def setup
        @st_num = ask("Enter the RST NUM")
        stack = @test_util.initialize_test_case('test_case_tag')
        @apc_num = "APC_" + stack
        @fc_num = "FC_" + stack
        @module_csp.reboot(@fc_num)
        wait(7)
        @module_csp.reboot(@apc_num)
        wait(7)
        @telem.set_realtime(@apc_num, "FSW_TLM_APC", @realtime_destination, 1)
        @telem.set_realtime(@apc_num, "POWER_PCDU_LVC_TLM", @realtime_destination, 1)
        @telem.set_realtime(@apc_num, "POWER_CSBATS_TLM", @realtime_destination, 1)
        @telem.set_realtime(@fc_num, "FSW_TLM_FC", @realtime_destination, 1)
        @telem.set_realtime(@fc_num, "AOCS_TLM", @realtime_destination, 1)
        status_bar("setup")
        start_logging("ALL","ST_AIT_SOH")
        puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    end

    def test_a_power_on_ST_SOH()
        @ST.power_on_ST(@apc_num,@st_num)
    end

    def test_b_get_ST_mode_SOH()
        @ST.get_ST_mode(@st_num, @fc_num)
    end
        
    def test_c_get_ST_time_measurements_SOH()
        @ST.get_ST_time_measurements(@st_num, @fc_num)
    end

    def test_d_get_ST_temp_measurements_SOH()
        @ST.get_ST_temp_measurements(@st_num, @fc_num)
    end

    def teardown()
        start_logging("ALL")
    end
end
