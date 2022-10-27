load 'Operations/FSW/UTIL_CmdSender.rb'

class ModuleConfig
  def initialize
    @cmd_sender = CmdSender.new
  end
 

  def config_set(board, property_id, type_id, value, no_hazardous_check = false)
    # Formulate parameters
    type_id_array = ['U8','I8','U16','I16','U32','I32','F','D','A8','A16','A32','A64','FDIR_CONFIG','A128','S8','S16','S32','S64','S128','UNKNOWN']

    cmd_name = "FSW_SET_CONFIG_PARAMETER_" + type_id_array[type_id]

    cmd_params = {
      "ID": property_id,
      "TYPE_ID": type_id,
      "DATA_#{type_id_array[type_id]}": value
    }
    
    @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
  end

end 