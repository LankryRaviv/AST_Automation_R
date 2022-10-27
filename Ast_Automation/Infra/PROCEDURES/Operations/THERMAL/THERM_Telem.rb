load_utility('Operations/FSW/UTIL_CmdSender')

class ModuleTelem
  def initialize
    @cmd_sender = CmdSender.new
  end

  def bms_set_heater_auto(board, bcu_num, state)
    # Formulate parameters
    cmd_name = "BCU_SET_HEATER_AUTO"
    params = {
      "BCU_NUM": bcu_num,
      "STATE": state
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def bms_set_heater_on_threshold(board, bcu_num, threshold)
    # Formulate parameters
    cmd_name = "BCU_SET_HEATER_ON_THRESHOLD"
    params = {
      "BCU_NUM": bcu_num,
      "THRESHOLD": threshold
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def bms_set_heater_off_threshold(board, bcu_num, threshold)
    # Formulate parameters
    cmd_name = "BCU_SET_HEATER_OFF_THRESHOLD"
    params = {
      "BCU_NUM": bcu_num,
      "THRESHOLD": threshold
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def bms_set_heater_state(board, bcu_num, state)
    # Formulate parameters
    cmd_name = "BCU_SET_HEATER_STATE"
    params = {
      "BCU_NUM": bcu_num,
      "STATE": state
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def pcdu_set_ds_switch(board, switch_num, switch_state)
    # Formulate parameters
    cmd_name = "PCDU_SET_DS_SWITCH"
    params = {
      "SWITCH_NUM": switch_num,
      "SWITCH_STATE": switch_state
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def lvc_battery_heater_mode(board, mode)
    # Formulate parameters
    cmd_name = "LVC_BATTERY_HEATER_MODE"
    params = {
      "MODE": mode
    }
    @cmd_sender.send(board, cmd_name, params)
  end

  def lvc_battery_heater_state(board, state)
    # Formulate parameters
    cmd_name = "LVC_BATTERY_HEATER_STATE"
    params = {
      "STATE": state
    }
    @cmd_sender.send(board, cmd_name, params)
  end

end