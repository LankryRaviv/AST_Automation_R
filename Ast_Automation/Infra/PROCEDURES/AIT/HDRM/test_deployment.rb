load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/FSW_FS_Upload.rb'
load 'AIT/FSW/individual_tests/FDIR_test_individual.rb'
load 'Operations/FSW/FSW_Telem.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'
load 'Operations/FSW/FSW_CSP.rb'
load 'Operations/FSW/FSW_FDIR.rb'
load 'Operations/FSW/FSW_MEDIC.rb'
load 'Operations/FSW/FSW_SE.rb'


class TestDeployment < ASTCOSMOSTestHDRM
    def initialize
        @module_telem = ModuleTelem.new
        @module_csp = ModuleCSP.new
        @module_fs = ModuleFS.new
        @cmd_sender = CmdSender.new
        @medic = ModuleMedic.new
        @module_SE = ModuleSE.new
        @entry_size = 186
        @deployment_2_script_file_id = 4620
        @fire_bottom_and_top_lva_script_file_id = 4621
        @deployment_1_script_file_id = 4622
        @check_aspect = "CRC"
        @target = "BW3"
        @fr_packet_name = 'FUNCTION_RUNNER_TLM_APC'

        # Default realtime destination of cosmos dev/dpc
        @realtime_destination = 'COSMOS_DPC'
        super()
      end
    
      def setup
        @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
        @test_case_util = ModuleTestCase.new(@realtime_destination)
        @run_for_record = combo_box("Run for record?", "YES", "NO")

        if @run_for_record.eql?("YES")
          @test_case_util.initialize_test_case("HDRM_TestDeploy2Demo")
        end

        @board = combo_box("Select Side", "APC_YP", "APC_YM")
        @tlm_packets = ['FSW_TLM_APC', 'MEDIC_LEADER_TLM', 'FUNCTION_RUNNER_TLM_APC']

        if @board == "APC_YP"
            @medic_task = {board: "APC_YP", other_board: "APC_YM", location: "YP", pkt_name: "MEDIC_LEADER_TLM",
                sid: "MEDIC", tid: "NORMAL"}
            @module_csp.reboot("FC_YP", true)
            @module_csp.reboot("APC_YP", true)
        elsif @board == "APC_YM"
            @medic_task = {board: "APC_YM", other_board: "APC_YM", location: "YM", pkt_name: "MEDIC_LEADER_TLM",
                sid: "MEDIC", tid: "NORMAL"}
            @module_csp.reboot("FC_YM", true)
            @module_csp.reboot("APC_YM", true)
        end
        
        wait(7)
        status_bar("setup")
      end
        
    def test_a_deploy_2_demo
        # Select the location of the script file
        script_file_location = open_file_dialog("/", "Select the script file for the deploy 2 test", "*.txt")

        # Turn on live telem for fsw, medic and FR
        @tlm_packets.each do | tlm_packet |
            @module_telem.set_realtime(@board, tlm_packet, @realtime_destination, 1)
        end

        # Check all Medic Leader telemetry values are admissible
        puts "Verifying that this stacks Medic telemetry has admissible values"
        full_pkt_name = CmdSender.get_full_pkt_name(@medic_task[:board], @medic_task[:pkt_name])

        # Check the Medic Leader telemetry are admissible values
        check(@target, full_pkt_name, "MEDIC_SC_MODE", "== 'WAKEUP'") 
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{@medic_task[:location]}'")

        # Check all FR telemetry values are admissible
        full_pkt_name = CmdSender.get_full_pkt_name(@board, 'FUNCTION_RUNNER_TLM_APC')
        check(@target, full_pkt_name, "FR_FUNCTION_ID_1", "== 'APC_DEPLOY_2'") 
        check(@target, full_pkt_name, "FR_FUNCTION_STAGE_1", "== 'IDLE'")
        initial_pass_count = tlm(@target, full_pkt_name, "FR_FUNCTION_PASS_COUNT_1")
        initial_fail_count = tlm(@target, full_pkt_name, "FR_FUNCTION_FAIL_COUNT_1")

        # Clear the file that will contain the script file and wait for operation to be completed
        @module_fs.file_clear(@board, @deployment_2_script_file_id)
        file_status = @module_fs.wait_for_file_ok(@board, @deployment_2_script_file_id, 30)

        # Check for nil first
        if file_status == nil
        check_expression("false")
        end
        check_expression("#{file_status} != ''")
        check_expression("#{file_status} == 55")

        # Upload the script file to the board's file system
        FSW_FS_Upload(@entry_size, @deployment_2_script_file_id, script_file_location, @board, @check_aspect)

        # Send the command to SE to manually run the script
        @module_SE.script_run(@board, @deployment_2_script_file_id, 1, 0, "*", "*", "*", "*", "*")

        # Wait for the script to run
        wait(20)

        # Check the FR telemetry
        full_pkt_name = CmdSender.get_full_pkt_name(@board, 'FUNCTION_RUNNER_TLM_APC')
        final_pass_count = tlm(@target, full_pkt_name, "FR_FUNCTION_PASS_COUNT_1")
        final_fail_count = tlm(@target, full_pkt_name, "FR_FUNCTION_FAIL_COUNT_1")
        check_expression("#{final_pass_count} == #{initial_pass_count + 1}")
        check_expression("#{final_fail_count} == #{initial_pass_count}")

        # Clear the script file and wait for operation to be complete
        @module_fs.file_clear(@board, @deployment_2_script_file_id)
        file_status = @module_fs.wait_for_file_ok(@board, @deployment_2_script_file_id, 60)
        # Check for nil first
        if file_status == nil
        check_expression("false")
        end
        check_expression("#{file_status} != ''")
        check_expression("#{file_status} == 55")
    end

    def test_b_deploy_bottom_and_top_of_lva_demo
        # Select the location of the script file
        script_file_location = open_file_dialog("/", "Select the script file for the deploy bottom and top bands of lva test", "*.txt")

        # Turn on live telem for fsw, medic and FR
        @tlm_packets.each do | tlm_packet |
            @module_telem.set_realtime(@board, tlm_packet, @realtime_destination, 1)
        end

        # Check all Medic Leader telemetry values are admissible
        puts "Verifying that this stacks Medic telemetry has admissible values"
        full_pkt_name = CmdSender.get_full_pkt_name(@medic_task[:board], @medic_task[:pkt_name])

        # Check the Medic Leader telemetry are admissible values
        check(@target, full_pkt_name, "MEDIC_SC_MODE", "== 'WAKEUP'") 
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{@medic_task[:location]}'")

        # Check all FR telemetry values are admissible
        full_pkt_name = CmdSender.get_full_pkt_name(@board, 'FUNCTION_RUNNER_TLM_APC')
        check(@target, full_pkt_name, "FR_FUNCTION_ID_2", "== 'APC_FIRE_BOTTOM_AND_TOP_BANDS_OF_LVA'") 
        check(@target, full_pkt_name, "FR_FUNCTION_STAGE_2", "== 'IDLE'")
        initial_pass_count = tlm(@target, full_pkt_name, "FR_FUNCTION_PASS_COUNT_2")
        initial_fail_count = tlm(@target, full_pkt_name, "FR_FUNCTION_FAIL_COUNT_2")

        # Clear the file that will contain the script file and wait for operation to be completed
        @module_fs.file_clear(@board, @fire_bottom_and_top_lva_script_file_id)
        file_status = @module_fs.wait_for_file_ok(@board, @fire_bottom_and_top_lva_script_file_id, 30)

        # Check for nil first
        if file_status == nil
        check_expression("false")
        end
        check_expression("#{file_status} != ''")
        check_expression("#{file_status} == 55")

        # Upload the script file to the board's file system
        FSW_FS_Upload(@entry_size, @fire_bottom_and_top_lva_script_file_id, script_file_location, @board, @check_aspect)

        # Send the command to SE to manually run the script
        @module_SE.script_run(@board, @fire_bottom_and_top_lva_script_file_id, 1, 0, "*", "*", "*", "*", "*")

        # Wait for the script to run
        wait(90)

        # Check the FR telemetry
        full_pkt_name = CmdSender.get_full_pkt_name(@board, 'FUNCTION_RUNNER_TLM_APC')
        final_pass_count = tlm(@target, full_pkt_name, "FR_FUNCTION_PASS_COUNT_2")
        final_fail_count = tlm(@target, full_pkt_name, "FR_FUNCTION_FAIL_COUNT_2")
        check_expression("#{final_pass_count} == #{initial_pass_count + 1}")
        check_expression("#{final_fail_count} == #{initial_fail_count}")

        # Clear the script file and wait for operation to be complete
        @module_fs.file_clear(@board, @fire_bottom_and_top_lva_script_file_id)
        file_status = @module_fs.wait_for_file_ok(@board, @fire_bottom_and_top_lva_script_file_id, 60)
        # Check for nil first
        if file_status == nil
        check_expression("false")
        end
        check_expression("#{file_status} != ''")
        check_expression("#{file_status} == 55")
    end

    def test_c_deploy_1_demo
        # Select the location of the script file
        script_file_location = open_file_dialog("/", "Select the script file for the deploy 1 test", "*.txt")

        # Turn on live telem for fsw, medic and FR
        @tlm_packets.each do | tlm_packet |
            @module_telem.set_realtime(@board, tlm_packet, @realtime_destination, 1)
        end

        # Check all Medic Leader telemetry values are admissible
        puts "Verifying that this stacks Medic telemetry has admissible values"
        full_pkt_name = CmdSender.get_full_pkt_name(@medic_task[:board], @medic_task[:pkt_name])

        # Check the Medic Leader telemetry are admissible values
        check(@target, full_pkt_name, "MEDIC_SC_MODE", "== 'WAKEUP'") 
        check(@target, full_pkt_name, "MEDIC_STACK_STATE", "== 'PRIMARY'")
        check(@target, full_pkt_name, "MEDIC_STACK_LOCATION", "== '#{@medic_task[:location]}'")

        # Check all FR telemetry values are admissible
        full_pkt_name = CmdSender.get_full_pkt_name(@board, 'FUNCTION_RUNNER_TLM_APC')
        check(@target, full_pkt_name, "FR_FUNCTION_ID_3", "== 'APC_DEPLOY_1'") 
        check(@target, full_pkt_name, "FR_FUNCTION_STAGE_3", "== 'IDLE'")
        initial_pass_count = tlm(@target, full_pkt_name, "FR_FUNCTION_PASS_COUNT_3")
        initial_fail_count = tlm(@target, full_pkt_name, "FR_FUNCTION_FAIL_COUNT_3")

        # Clear the file that will contain the script file and wait for operation to be completed
        @module_fs.file_clear(@board, @deployment_1_script_file_id)
        file_status = @module_fs.wait_for_file_ok(@board, @deployment_1_script_file_id, 30)

        # Check for nil first
        if file_status == nil
        check_expression("false")
        end
        check_expression("#{file_status} != ''")
        check_expression("#{file_status} == 55")

        # Upload the script file to the board's file system
        FSW_FS_Upload(@entry_size, @deployment_1_script_file_id, script_file_location, @board, @check_aspect)

        # Send the command to SE to manually run the script
        @module_SE.script_run(@board, @deployment_1_script_file_id, 1, 0, "*", "*", "*", "*", "*")

        # Wait for the script to run
        wait(20)

        # Check the FR telemetry
        full_pkt_name = CmdSender.get_full_pkt_name(@board, 'FUNCTION_RUNNER_TLM_APC')
        final_pass_count = tlm(@target, full_pkt_name, "FR_FUNCTION_PASS_COUNT_3")
        final_fail_count = tlm(@target, full_pkt_name, "FR_FUNCTION_FAIL_COUNT_3")
        check_expression("#{final_pass_count} == #{initial_pass_count + 1}")
        check_expression("#{final_fail_count} == #{initial_fail_count}")

        # Clear the script file and wait for operation to be complete
        @module_fs.file_clear(@board, @deployment_1_script_file_id)
        file_status = @module_fs.wait_for_file_ok(@board, @deployment_1_script_file_id, 60)
        # Check for nil first
        if file_status == nil
        check_expression("false")
        end
        check_expression("#{file_status} != ''")
        check_expression("#{file_status} == 55")
    end

    def teardown
        @test_case_util.teardown_test_case()
        status_bar("teardown")
    end

end