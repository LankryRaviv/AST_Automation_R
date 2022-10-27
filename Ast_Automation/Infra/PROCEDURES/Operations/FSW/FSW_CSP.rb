load 'Operations/FSW/UTIL_CmdSender.rb'

## TODO: Cannot implement uptime because there is no predictable command code
class ModuleCSP
    def initialize
      @cmd_sender = CmdSender.new
      @target = "BW3"
    end

    def reboot(board, no_hazardous_check=false)
        # Formulate cmd and tlm parameters
        cmd_name = "FSW_CSP_REBOOT"
        cmd_params = {
        "CSP_REBOOT_MAGIC_VALUE": "REBOOT"
        }
        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
    end

    def ping(board, timeout=2)
        # Formulate cmd and tlm parameters
        cmd_name = "CSP_PING"
        mnemonic = "RECEIVED_COUNT"
        comparison = ">"
        params = {}
        pkt_name = "CSP_PING"
        @cmd_sender.send_with_wait_check(board, cmd_name, params, pkt_name, mnemonic, comparison, timeout)
    end
end


