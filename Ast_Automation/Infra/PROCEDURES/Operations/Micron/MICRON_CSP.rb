load('Operations/FSW/UTIL_CmdSender.rb')

## TODO: IMPLEMENT SYS INFO AND CHECK UPTIME

class MicronCSP
    def initialize
      @cmd_sender = CmdSender.new
      @target = "BW3"
    end

    
    def reboot(board, micron_id, no_hazardous_check = false)
        # Formulate cmd and tlm parameters
        cmd_name = "MIC_CSP_REBOOT"
        cmd_params = {
		"MICRON_ID": micron_id,
        "CSP_REBOOT_MAGIC_VALUE": "REBOOT"
        }
        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
    end
end


