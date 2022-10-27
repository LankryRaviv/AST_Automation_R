load_utility('Operations/FSW/UTIL_CmdSender')

class PCDU
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end

  def set_upstream_unreg_ppu(board, val)
    # Formulate parameters
    cmd_name = "PCDU_SET_US_UNREG_PPU_SWITCH"
    params = {
      "SWITCH_STATE": val
    }
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, params, "POWER", wait_time=4)
  end

  def set_upstream_unreg(board, switch_num, val)
    # Formulate parameters
    cmd_name = "PCDU_SET_US_UNREG_SWITCH"
    params = {
      "SWITCH_NUM_US_UNREG": switch_num,
      "SWITCH_STATE_US_UNREG": val
    }
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, params, "POWER", wait_time=4)
  end

  def set_upstream_reg(board, switch_num, val)
    # Formulate parameters
    cmd_name = "PCDU_SET_US_REG_SWITCH"
    params = {
      "SWITCH_NUM_US_REG": switch_num,
      "SWITCH_STATE": val
    }
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, params, "POWER", wait_time=4)
  end

  def set_downstream(board, switch_num, val)
    # Formulate parameters
    cmd_name = "PCDU_SET_DS_SWITCH"
    params = {
      "SWITCH_NUM_DS": switch_num,
      "SWITCH_STATE": val
    }
    @cmd_sender.send_with_cmd_count_check(board, cmd_name, params, "POWER", wait_time=4)
  end

  def get_converted_val(val)
    if val == 1
      return 'ON'
    else
      return 'OFF'
    end
  end

  def set_RWA_YP0_Z(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_2", 1)
    end
    # Always set downstream
    set_downstream(board, "RWA_YP0_Z", val)
    val = get_converted_val(val)

    # Check that downstream is in proper state
    full_pkt_name = CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM")
    wait_check(@target, full_pkt_name, "PCDU_BATT_RWA_YP0_Z", "== '#{val}'", 4)
  end

  def set_RWA_YM0_Z(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_2", 1)
    end
    # Always set downstream
    set_downstream(board, "RWA_YM0_Z", val)
    val = get_converted_val(val)

    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_RWA_YM0_Z", "== '#{val}'", 4)
  end

  def set_RWA_YP1_X(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_2", 1)
    end
    # Always set downstream
    set_downstream(board, "RWA_YP1_X", val)
    val = get_converted_val(val)

    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_RWA_YP1_X", "== '#{val}'", 4)
  end

  def set_RWA_YM1_X(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_2", 1)
    end
    # Always set downstream
    set_downstream(board, "RWA_YM1_X", val)
    val = get_converted_val(val)

    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_RWA_YM1_X", "== '#{val}'", 4)
  end

  def set_ROD_POS(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_2", 1)
    end
    # Always set downstream
    set_downstream(board, "ROD_POS", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_MTQ_POS", "== '#{val}'", 4)
  end

  def set_ROD_NEG(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_2", 1)
    end
    # Always set downstream
    set_downstream(board, "ROD_NEG", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_MTQ_NEG", "== '#{val}'", 4)
  end

  def set_ST_XP(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_5V_1", 1)
    end
    # Always set downstream
    set_downstream(board, "ST_XP", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_ST_XP", "== '#{val}'", 4)
  end

  def set_ST_XM(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_5V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "ST_XM", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_ST_XM", "== '#{val}'", 4)
  end

  def set_UHF_NADIR_V28_A(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "UHF_NADIR_V28_A", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_UHF_NADIR_V28_A", "== '#{val}'", 4)
  end

  def set_UHF_NADIR_V5_B(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_5V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "UHF_NADIR_V5_B", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_UHF_NADIR_V5_B", "== '#{val}'", 4)
  end

  def set_QVA_SW_RX(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_8", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_SW_RX", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_TTC_SW_QVA_RX_AND_SBAND_YM", "== '#{val}'", 4)
  end

  def set_QVA_SW_TX(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_7", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_SW_TX", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_TTC_SW_QVA_TX_AND_SBAND_YP", "== '#{val}'", 4)
  end

  def set_QVA_YM_V28(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_6", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YM_V28", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_QVA_YM_V28", "== '#{val}'", 4)
  end

  def set_QVA_YP_V28(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_5", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YP_V28", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_QVA_YP_V28", "== '#{val}'", 4)
  end

  def set_QVA_YM_V5(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_5V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YM_V5", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_QVA_YM_V5", "== '#{val}'", 4)
  end

  def set_QVA_YP_V5(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_5V_2", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YP_V5", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_QVA_YP_V5", "== '#{val}'", 4)
  end

  def set_QVA_YM_V12(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_8", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YM_V12", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_QVA_YM_V12", "== '#{val}'", 4)
  end

  def set_QVA_YP_V12(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_7", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YP_V12", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_QVA_YP_V12", "== '#{val}'", 4)
  end

  def set_QV_TRANSCEIVER_YM_5V(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_5V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "QV_TRANSCEIVER_YM_5V", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_QVT_YM_V5", "== '#{val}'", 4)
  end

  def set_QV_TRANSCEIVER_YP_5V(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_5V_1", 1)
    end
    # Always set downstream
    set_downstream(board, "QV_TRANSCEIVER_YP_5V", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_QVT_YP_V5", "== '#{val}'", 4)
  end

  def set_QVA_YP_LNA_RH(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "BATT_12V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YP_LNA_RH", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_LNA_YP_RH", "== '#{val}'", 4)
  end

  def set_QVA_YP_LNA_LH(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "BATT_12V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YP_LNA_LH", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_LNA_YP_LH", "== '#{val}'", 4)
  end

  def set_QVA_YM_LNA_RH(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "BATT_12V_5", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YM_LNA_RH", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_LNA_YN_RH", "== '#{val}'", 4)
  end

  def set_QVA_YM_LNA_LH(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_6", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YM_LNA_LH", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_LNA_YN_LH", "== '#{val}'", 4)
  end

  def set_QVA_YP_PA_RH(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "BATT_12V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YP_PA_RH", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_PA_YP_RH", "== '#{val}'", 4)
  end

  def set_QVA_YP_PA_LH(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "BATT_12V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YP_PA_LH", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_PA_YP_LH", "== '#{val}'", 4)
  end

  def set_QVA_YM_PA_RH(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "BATT_12V_5", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YM_PA_RH", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_PA_YN_RH", "== '#{val}'", 4)
  end

  def set_QVA_YM_PA_LH(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_6", 1)
    end
    # Always set downstream
    set_downstream(board, "QVA_YM_PA_LH", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_PA_YN_LH", "== '#{val}'", 4)
  end

  def set_SBAND_YM(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_8", 1)
    end
    # Always set downstream
    set_downstream(board, "SBAND_YM", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_TTC_SW_QVA_RX_AND_SBAND_YM", "== '#{val}'", 4)
  end

  def set_SBAND_YP(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_7", 1)
    end
    # Always set downstream
    set_downstream(board, "SBAND_YP", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_TTC_SW_QVA_TX_AND_SBAND_YP", "== '#{val}'", 4)
  end

  def set_POWER_SHARE_MICRON_104(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MICRON_12V_11", 1)
    end
    # Always set downstream
    set_downstream(board, "POWER_SHARE_MICRON_104", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MICRON_POWER_SHARE_MICRON_104", "== '#{val}'", 4)
  end

  def set_POWER_SHARE_MICRON_107(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MICRON_12V_12", 1)
    end
    # Always set downstream
    set_downstream(board, "POWER_SHARE_MICRON_107", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MICRON_POWER_SHARE_MICRON_107", "== '#{val}'", 4)
  end

  def set_POWER_SHARE_MICRON_78(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MICRON_12V_13", 1)
    end
    # Always set downstream
    set_downstream(board, "POWER_SHARE_MICRON_78", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MICRON_POWER_SHARE_MICRON_78", "== '#{val}'", 4)
  end

  def set_POWER_SHARE_MICRON_120(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MICRON_12V_14", 1)
    end
    # Always set downstream
    set_downstream(board, "POWER_SHARE_MICRON_120", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MICRON_POWER_SHARE_MICRON_120", "== '#{val}'", 4)
  end

  def set_POWER_SHARE_MICRON_77(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MICRON_12V_15", 1)
    end
    # Always set downstream
    set_downstream(board, "POWER_SHARE_MICRON_77", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MICRON_POWER_SHARE_MICRON_77", "== '#{val}'", 4)
  end

  def set_POWER_SHARE_MICRON_119(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MICRON_12V_16", 1)
    end
    # Always set downstream
    set_downstream(board, "POWER_SHARE_MICRON_119", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MICRON_POWER_SHARE_MICRON_119", "== '#{val}'", 4)
  end

  def set_POWER_SHARE_MICRON_90(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MICRON_12V_17", 1)
    end
    # Always set downstream
    set_downstream(board, "POWER_SHARE_MICRON_90", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MICRON_POWER_SHARE_MICRON_90", "== '#{val}'", 4)
  end

  def set_POWER_SHARE_MICRON_93(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MICRON_12V_18", 1)
    end
    # Always set downstream
    set_downstream(board, "POWER_SHARE_MICRON_93", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MICRON_POWER_SHARE_MICRON_93", "== '#{val}'", 4)
  end

  def set_HEATER_SSYPXM_SSYPXP(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "HEATER_SSYPXM_SSYPXP", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_HEATER_SSYPXM", "== '#{val}'", 4)
  end

  def set_HEATER_CAMYPXM_CAMYPXP(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "HEATER_CAMYPXM_CAMYPXP", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_HEATER_CAMYPXM", "== '#{val}'", 4)
  end

  def set_TTC_SW_SBAND(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "TTC_SW_SBAND", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_TTC_SW_SBAND", "== '#{val}'", 4) # TODO Name
  end

  def set_TTC_SW_UHF(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "TTC_SW_UHF", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_TTC_SW_UHF", "== '#{val}'", 4) # TODO Name
  end

  def set_HEATER_SSYMXM_SSYMXP(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "HEATER_SSYMXM_SSYMXP", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_HEATER_SSYMXM_SSYMXP", "== '#{val}'", 4)
  end

  def set_HEATER_CAMYMXM_CAMYMXP(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "HEATER_CAMYMXM_CAMYMXP", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_HEATER_CAMYMXM", "== '#{val}'", 4)
  end

  def HEATER_GPSYP_GPSYM(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "HEATER_GPSYP_GPSYM", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_HEATER_GPSXM_GPSYM", "== '#{val}'", 4)
  end

  def set_BFCP_XP(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "BFCP_XP", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_BFCP_XP", "== '#{val}'", 4)
  end

  def set_BFCP_XM(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_4", 1)
    end
    # Always set downstream
    set_downstream(board, "BFCP_XM", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_BFCP_XM", "== '#{val}'", 4)
  end

  def set_QV_TRANSCEIVER_YM_12V(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_8", 1)
    end
    # Always set downstream
    set_downstream(board, "QV_TRANSCEIVER_YM_12V", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_QVT_YM_V12", "== '#{val}'", 4)
  end

  def set_QV_TRANSCEIVER_YP_12V(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_7", 1)
    end
    # Always set downstream
    set_downstream(board, "QV_TRANSCEIVER_YP_12V", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_QVT_YP_V12", "== '#{val}'", 4)
  end

  def set_UHF_NADIR_V28_B(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_unreg(board, "BATT_28V_3", 1)
    end
    # Always set downstream
    set_downstream(board, "UHF_NADIR_V28_B", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_BATT_UHF_NADIR_V28_B", "== '#{val}'", 4)
  end

  def set_UHF_NADIR_V5_A(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_5V_2", 1)
    end
    # Always set downstream
    set_downstream(board, "UHF_NADIR_V5_A", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_UHF_NADIR_V5_A", "== '#{val}'", 4)
  end

  def set_LVC_BACKUP_12V_YM(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_8", 1)
    end
    # Always set downstream
    set_downstream(board, "LVC_BACKUP_12V_YM", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_LVC_BACKUP_12V_YM", "== '#{val}'", 4)
  end

  def set_LVC_BACKUP_12V_YP(board, val)
    # Set upstream only if turning on
    if val == 1
      set_upstream_reg(board, "MPPT_12V_7", 1)
    end
    # Always set downstream
    set_downstream(board, "LVC_BACKUP_12V_YP", val)

    val = get_converted_val(val)
    # Check that downstream is in proper state
    wait_check(@target, CmdSender.get_full_pkt_name(board, "POWER_PCDU_LVC_TLM"), "PCDU_MPPT_LVC_BACKUP_12V_YP", "== '#{val}'", 4)
  end

end