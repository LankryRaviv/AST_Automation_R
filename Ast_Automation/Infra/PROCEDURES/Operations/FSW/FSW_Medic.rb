load 'Operations/FSW/FSW_Config.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'

class ModuleMedic
  def initialize
    @cmd_sender = CmdSender.new
    @module_config = ModuleConfig.new
    @type_u8 = 0 # Index of U8 in type_id_array
    
    #This needs to be updated manually
    @nodes = {
      "APC_YP" => {id_of_num_of_rows: 24,  id_of_start_of_fdir_configs: 25},
      "FC_YP" => {id_of_num_of_rows: 11,  id_of_start_of_fdir_configs: 12}
    }
    
  end

  # board: board to send the command to (APC_YP, APC_YM, FC_YP, FC_YM, DPC)
  # state: stack state to be set to (primary=0, secondary=1)
  def set_stack_state(board, state, no_hazardous_check = false)
    cmd_name = "MEDIC_SET_STACK_STATE"
    cmd_params = {
      "STACK_STATE": state
    }
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end

  # board: board to send the command to (APC_YP, APC_YM, FC_YP, FC_YM, DPC)
  # location: stack location to be set as (YP=0, YM=1)
  def set_stack_location(board, location, no_hazardous_check = false)
    cmd_name = "MEDIC_SET_STACK_LOCATION"
    cmd_params = {
      "MEDIC_STACK_LOCATION": location
    }
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end

  # The stack state must be in secondary in order to set the MeOkEnable to disable, or else the binary cmd function will return with an error code
  # board: board to send the command to (APC_YP or APC_YM)
  # enable: value to set me_ok enable to (enable=0, disable=1)
  def set_me_ok_enable(board, enable, no_hazardous_check = false)
    cmd_name = "MEDIC_SET_ME_OK_ENABLE"
    cmd_params = {
      "MEDIC_ENABLE": enable
    }
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end

  # Sends an set_stack_state command to the APC in the stack of the board being sent this binary command
  # board: board to send this command to (FC_YP, FC_YM, DPC), that will then transmit the APC command
  # state: stack state to be set to (primary=0, secondary=1)
  def send_set_stack_state_cmd(board, state, no_hazardous_check = false)
    cmd_name = "MEDIC_SEND_SET_STACK_STATE_CMD"
    cmd_params = {
      "STACK_STATE": state
    }
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end

  # Sends an set_me_ok_enable command to the APC in the stack of the board being sent this binary command
  # board: board to send this command to (FC_YP, FC_YM, DPC), that will then transmit the APC command
  # enable: value to set me_ok enable to (enable=0, disable=1)
  def send_set_me_ok_enable_cmd(board, enable, no_hazardous_check = false)
    cmd_name = "MEDIC_SEND_SET_ME_OK_ENABLE_CMD"
    cmd_params = {
      "MEDIC_ENABLE": enable
    }
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end

  # Sends the LVC a command to toggle an output
  # board: board to send this command to (LVC_YP, LVC_YM)
  # output_channel: channel to toggle the state of ('UHF_DEPLOY', 'UHF', 'CAMERAS', 'APC_FC', 'GPS', 'SUN_SENSOR', 'DPC', 'IMU')
  # state: value to set output to ('ON' or 'OFF')
  # delay_in_Sec: amount of seconds to delay before setting the output channel
  def set_lvc_output(board, output_channel, state, delay_in_sec=0, no_hazardous_check = false)
    cmd_name = "APC_LVC_OUTPUT_SINGLE"
    cmd_params = {
      "OUTPUT_CHANNEL": output_channel,
      "STATE_ONOFF": state,
      "DELAY": delay_in_sec
    }
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end


  

end 