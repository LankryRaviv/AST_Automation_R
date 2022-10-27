load 'Operations/FSW/FSW_Telem.rb'

class ModuleTestCase

    def initialize(csp_destination = "COSMOS_UMBILICAL")
        @module_telem = ModuleTelem.new
        @csp_destination = csp_destination
        @dpc_list = ["DPC_1", "DPC_2", "DPC_3", "DPC_4", "DPC_5"]
        @stack = "YP"
    end

    def stack
        return @stack
    end


    def initialize_test_case(log_tag='', dpc=false, cpbf = false, micron = false)  
        # log_tag = tag to include in the file names
        # cpbf = is cpbf a component of this test? 
        #       true  = capture cpbf fsw version in test report
        #       false = do not include cpbf fsw version in test report
        # micron = is micron a component of this test?
        #       true  = capture micron fsw version in test report
        #       false = do not include micron fsw version in test report

        # Start logging and output file names
        start_logging("ALL", log_tag)
        Cosmos::Test.puts("File Names:")
        Cosmos::Test.puts("Telemetry file: #{get_tlm_log_filename()}")
        Cosmos::Test.puts("Command file: #{get_cmd_log_filename()}")
        Cosmos::Test.puts("Server Message file: #{get_server_message_log_filename()}\n\n")

        # Ask for the stack side
        @stack = combo_box("Select test stack", "YP", "YM")

        # Turn on FSW packets
        @module_telem.set_realtime("APC_#{@stack}", "FSW_TLM_APC", @csp_destination, 1) 
        @module_telem.set_realtime("FC_#{@stack}", "FSW_TLM_FC", @csp_destination, 1) 
        
        if dpc
            @dpc_list.each do |dpc|
                @module_telem.set_realtime("#{dpc}", "FSW_TLM_DPC", @csp_destination, 1) 
            end
            # Capture DPC FSW Version
            write_dpc_fsw_version(@stack)
        end

        # Capture APC FSW Version
        write_apc_fsw_version(@stack)

        # Capture FC FSW Version
        write_fc_fsw_version(@stack)

        # Capture CPBF FSW Version
        if cpbf
            # Turn on FSW packet

            
            write_cpbf_fsw_version(@stack)
        end

        # Capture Micron Version
        if micron
            # Turn on FSW packet

            write_micron_fsw_version(@stack)
        end

        # Ground Software Version
        Cosmos::Test.puts("Ground Software Versions:")
        # Get Gitlab Branch version
        git_version = `git rev-parse HEAD`

        # Write Hardware Configuration 
        Cosmos::Test.puts("GitLab Version: #{git_version}\n\n")

        # Operator
        operator = ask_string("Enter Test Conductor's name: ")
        Cosmos::Test.puts("Test Conductor: #{operator}\n\n\n")

        return @stack

    end

    def teardown_test_case()

        # Start a new log
        start_logging("ALL")

    end

    def write_apc_fsw_version(stack)
        # stack = "YP" or "YM"
        
        # Write APC versions
        Cosmos::Test.puts("APC FSW Versions:")
        Cosmos::Test.puts("Boot L1 Major: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L1_MAJOR")}")
        Cosmos::Test.puts("Boot L1 Minor: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L1_MINOR")}")
        Cosmos::Test.puts("Boot L1 Patch: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L1_PATCH")}")
        Cosmos::Test.puts("Boot L2 Major: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L2_MAJOR")}")
        Cosmos::Test.puts("Boot L2 Minor: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L2_MINOR")}")
        Cosmos::Test.puts("Boot L2 Patch: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC BOOT_L2_PATCH")}")
        Cosmos::Test.puts("App Major: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC APP_MAJOR")}")
        Cosmos::Test.puts("App Minor: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC APP_MINOR")}")
        Cosmos::Test.puts("App Patch: #{tlm("BW3 APC_#{stack}-FSW_TLM_APC APP_PATCH")}\n\n")

    end

    def write_fc_fsw_version(stack)
        # stack = "YP" or "YM"

        # Write FC versions
        Cosmos::Test.puts("FC FSW Versions:")
        Cosmos::Test.puts("Boot L1 Major: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L1_MAJOR")}")
        Cosmos::Test.puts("Boot L1 Minor: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L1_MINOR")}")
        Cosmos::Test.puts("Boot L1 Patch: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L1_PATCH")}")
        Cosmos::Test.puts("Boot L2 Major: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L2_MAJOR")}")
        Cosmos::Test.puts("Boot L2 Minor: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L2_MINOR")}")
        Cosmos::Test.puts("Boot L2 Patch: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC BOOT_L2_PATCH")}")
        Cosmos::Test.puts("App Major: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC APP_MAJOR")}")
        Cosmos::Test.puts("App Minor: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC APP_MINOR")}")
        Cosmos::Test.puts("App Patch: #{tlm("BW3 FC_#{stack}-FSW_TLM_FC APP_PATCH")}\n\n")

    end

    def write_dpc_fsw_version(stack)
        # stack = "YP" or "YM"

        # Write DPC versions
        Cosmos::Test.puts("DPC FSW Versions: DPC_1, \t DPC_2, \t DPC_3, \t DPC_4, \t DPC_5")
        Cosmos::Test.puts("Boot L1 Major: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L1_MAJOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L1_MAJOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L1_MAJOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L1_MAJOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L1_MAJOR")}")
        Cosmos::Test.puts("Boot L1 Minor: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L1_MINOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L1_MINOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L1_MINOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L1_MINOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L1_MINOR")}")
        Cosmos::Test.puts("Boot L1 Patch: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L1_PATCH")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L1_PATCH")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L1_PATCH")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L1_PATCH")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L1_PATCH")}")
        Cosmos::Test.puts("Boot L2 Major: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L2_MAJOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L2_MAJOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L2_MAJOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L2_MAJOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L2_MAJOR")}")
        Cosmos::Test.puts("Boot L2 Minor: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L2_MINOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L2_MINOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L2_MINOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L2_MINOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L2_MINOR")}")
        Cosmos::Test.puts("Boot L2 Patch: #{tlm("BW3 DPC_1-FSW_TLM_DPC BOOT_L2_PATCH")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC BOOT_L2_PATCH")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC BOOT_L2_PATCH")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC BOOT_L2_PATCH")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC BOOT_L2_PATCH")}")
        Cosmos::Test.puts("App Major: #{tlm("BW3 DPC_1-FSW_TLM_DPC APP_MAJOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC APP_MAJOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC APP_MAJOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC APP_MAJOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC APP_MAJOR")}")
        Cosmos::Test.puts("App Minor: #{tlm("BW3 DPC_1-FSW_TLM_DPC APP_MINOR")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC APP_MINOR")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC APP_MINOR")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC APP_MINOR")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC APP_MINOR")}")
        Cosmos::Test.puts("App Patch: #{tlm("BW3 DPC_1-FSW_TLM_DPC APP_PATCH")},\t#{tlm("BW3 DPC_2-FSW_TLM_DPC APP_PATCH")},\t#{tlm("BW3 DPC_3-FSW_TLM_DPC APP_PATCH")},\t#{tlm("BW3 DPC_4-FSW_TLM_DPC APP_PATCH")},\t#{tlm("BW3 DPC_5-FSW_TLM_DPC APP_PATCH")}\n\n")
    end

    def write_cpbf_fsw_version(stack)


    end

    def write_micron_fsw_version(stack)


    end



end 