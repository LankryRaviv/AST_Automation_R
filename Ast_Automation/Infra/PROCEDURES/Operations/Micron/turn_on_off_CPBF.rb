load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem')

class TurnOnOffCPBF
    def initialize
      @cmd_sender = CmdSender.new
      @target = "BW3"
      @realtime_destination = "COSMOS_UMBILICAL"
      @telem = ModuleTelem.new
    end

    def set_upstream_unreg(board, switch_num, val, no_hazardous_check = false)
      # Formulate parameters
      cmd_name = "PCDU_SET_US_UNREG_SWITCH"
      params = {
        "SWITCH_NUM": switch_num,
        "SWITCH_STATE": val
      }
      @cmd_sender.send_with_cmd_count_check(board, cmd_name, params, "POWER", wait_time=4, no_hazardous_check)
    end

    def set_downstream(board, switch_num, val, no_hazardous_check = false)
      # Formulate parameters
      cmd_name = "PCDU_SET_DS_SWITCH"
      params = {
        "SWITCH_NUM": switch_num,
        "SWITCH_STATE": val
      }
      @cmd_sender.send_with_cmd_count_check(board, cmd_name, params, "POWER", wait_time=4, no_hazardous_check)
    end
  
    def get_converted_val(val, no_hazardous_check = false)
      if val == 1
        return 'ON'
      else
        return 'OFF'
      end
    end

    def set_BFCP_XP(board, val, no_hazardous_check = false)

        @telem.set_realtime(board, "POWER_PCDU_LVC_TLM", @realtime_destination, 1)
        @telem.set_realtime(board, "FSW_TLM_APC", @realtime_destination, 1)
        # Set upstream only if turning on
        if val == 1
          set_upstream_unreg(board, "BATT_28V_3", 1, no_hazardous_check)
        end
        # Always set downstream
        set_downstream(board, "BFCP_XP", val, no_hazardous_check)
    
        val = get_converted_val(val)
        # Check that downstream is in proper state
        wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_BFCP_XP", "== '#{val}'", 4)
    end
    
    def set_BFCP_XM(board, val, no_hazardous_check = false)
        @telem.set_realtime(board, "POWER_PCDU_LVC_TLM", @realtime_destination, 1)
        @telem.set_realtime(board, "FSW_TLM_APC", @realtime_destination, 1)
        # Set upstream only if turning on
        if val == 1
          set_upstream_unreg(board, "BATT_28V_4", 1, no_hazardous_check)
        end
        # Always set downstream
        set_downstream(board, "BFCP_XM", val, no_hazardous_check)
    
        val = get_converted_val(val)
        # Check that downstream is in proper state
        wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_BFCP_XM", "== '#{val}'", 4)
    end

    def set_BFCP(board, val, no_hazardous_check, bfcp_side)
      if bfcp_side.eql? "CPBF_XM"
        set_BFCP_XM(board, val, no_hazardous_check)
      elsif bfcp_side.eql? "CPBF_XP"
        set_BFCP_XP(board, val, no_hazardous_check)
      else
        puts("Invalid BFCP selection: #{bfcp_side}")
      end
    end
    
end