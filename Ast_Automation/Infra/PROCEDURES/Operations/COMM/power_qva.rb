load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('Operations/EPS/EPS_PCDU')
load_utility('TestRunnerUtils/test_case_utils.rb')

$cmd_sender = CmdSender.new
$module_telem = ModuleTelem.new
$csp_destination = "COSMOS_UMBILICAL"
$pcdu = PCDU.new

$board = combo_box("Select APC Side", "APC_YP", "APC_YM")

$module_telem.set_realtime($board, "COMM_TLM", $csp_destination, 1) 
$module_telem.set_realtime($board, "POWER_PCDU_LVC_TLM", $csp_destination, 1)
$module_telem.set_realtime($board, "FSW_TLM_APC", $csp_destination, 1)


def power_on_yp
    # Turn on the 28V switch
    $pcdu.set_QVA_YP_V28($board, 1)

    # Turn on the 12V switch
    $pcdu.set_QVA_YP_V12($board, 1)

    # Turn on the 5V switch
    $pcdu.set_QVA_YP_V5($board, 1)

    # Send QVA_ENABLE
    cmd_name = "QVA_SET_ENABLE"
    params = {
        "STATE": "ENABLE",
        "SIDE": "YP"
    }
    $cmd_sender.send_with_cmd_count_check($board, cmd_name, params, "COMM")

    # Send QVA RESET
    cmd_name = "QVA_RESET"
    params = {
        "SIDE": "YP",
    }
    $cmd_sender.send_with_cmd_count_check($board, cmd_name, params, "COMM")
end

def power_off_yp
    # Disable QVA_ENABLE
    cmd_name = "QVA_SET_ENABLE"
    params = {
        "STATE": "DISABLE",
        "SIDE": "YP"
    }
    $cmd_sender.send_with_cmd_count_check($board, cmd_name, params, "COMM")

    # Turn off the 5V switch
    $pcdu.set_QVA_YP_V5($board, 0)

    # Turn off the 12V switch
    $pcdu.set_QVA_YP_V12($board, 0)

    # Turn on the 28V switch
    $pcdu.set_QVA_YP_V28($board, 0)

    # Manually turn off upstream switches
    $pcdu.set_upstream_unreg($board, "BATT_28V_5", 0)
    $pcdu.set_upstream_reg($board, "MPPT_12V_7", 0)
    $pcdu.set_upstream_reg($board, "MPPT_5V_2", 0)
end


def power_on_ym
    # Turn on the 28V switch
    $pcdu.set_QVA_YM_V28($board, 1)

    # Turn on the 12V switch
    $pcdu.set_QVA_YM_V12($board, 1)

    # Turn on the 5V switch
    $pcdu.set_QVA_YM_V5($board, 1)

    # Send QVA_ENABLE
    cmd_name = "QVA_SET_ENABLE"
    params = {
        "STATE": "ENABLE",
        "SIDE": "YM"
    }
    $cmd_sender.send_with_cmd_count_check($board, cmd_name, params, "COMM")

    # Send QVA RESET
    cmd_name = "QVA_RESET"
    params = {
        "SIDE": "YM"
    }
    $cmd_sender.send_with_cmd_count_check($board, cmd_name, params, "COMM")
end

def power_off_ym
    # Disable QVA_ENABLE
    cmd_name = "QVA_SET_ENABLE"
    params = {
        "STATE": "DISABLE",
        "SIDE": "YM"
    }
    $cmd_sender.send_with_cmd_count_check($board, cmd_name, params, "COMM")

    # Turn off the 5V switch
    $pcdu.set_QVA_YM_V5($board, 0)

    # Turn off the 12V switch
    $pcdu.set_QVA_YM_V12($board, 0)

    # Turn on the 28V switch
    $pcdu.set_QVA_YM_V28($board, 0)

    # Manually turn off upstream switches
    $pcdu.set_upstream_unreg($board, "BATT_28V_6", 0)
    $pcdu.set_upstream_reg($board, "MPPT_12V_8", 0)
    $pcdu.set_upstream_reg($board, "MPPT_5V_4", 0)
end



while true
    qva_side = combo_box("Select QVA Side", "YP", "YM")
    on_or_off = combo_box("Turn on or turn off?", "ON", "OFF")

    if qva_side == "YP"
        if on_or_off == "ON"
            power_on_yp()
        elsif on_or_off == "OFF"
            power_off_yp()
        end
    elsif qva_side == "YM"
        if on_or_off == "ON"
            power_on_ym()
        elsif on_or_off == "OFF"
            power_off_ym()
        end
    end
end