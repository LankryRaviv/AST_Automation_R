load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/ast_test_base.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'

class CPBFtoBPMSMCCarrier < ASTCOSMOSTestCPBF

    def initialize
        @cmd_sender = CmdSender.new
        @target = "BW3"
        super()
    end

    def test_mc_thresholds

        timeout = 2 # seconds

        # Loop through BPMS values
        (0..400).step(50) do |bpms_val|
            # Set BPMS value
            cmd_params = {"CLI_COMMAND": "modscl=#{bpms_val}"}
            @cmd_sender.send("BPMS", "BPMS_REMOTE_CLI_CMD", cmd_params)

            # Loop through CPBF values
            (0..400).step(50) do |cpbf_val|
                # Set cpbf value
                cmd_params = {"CLI_COMMAND": "modscl=#{cpbf_val}"}
                @cmd_sender.send("CPBF", "CPBF_REMOTE_CLI_CMD", cmd_params)

                # Get initial ping count
                init_ping_count = tlm("BW3", "CPBF-CSP_PING", "RECEIVED_COUNT")

                # Send the ping
                @cmd_sender.send("CPBF", "CSP_PING", {})

                # Check if ping was successful
                start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                while Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time < timeout

                    if tlm("BW3", "CPBF-CSP_PING", "RECEIVED_COUNT") > init_ping_count
                        # Ping successful
                        status = "Success"
                        break
                    else
                        status = "Failed"
                    end
                end

                if status == "Failed"
                    Cosmos::Test.puts("FAILED: Ping failed at BPMS: #{bpms_val}, CPBF: #{cpbf_val}")
                end

            end

        end



    end

end