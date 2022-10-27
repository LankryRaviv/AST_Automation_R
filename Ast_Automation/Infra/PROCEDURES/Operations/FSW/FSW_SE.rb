load 'Operations/FSW/UTIL_CmdSender.rb'

class ModuleSE
  def initialize
    @cmd_sender = CmdSender.new
  end

  def script_run(board, file_id, manual_run, start_time, param1, param2, param3, param4, param5)
    # Formulate parameters
    cmd_name = "FSW_SE_RUN"

    cmd_params = {
      "FILE_ID": file_id,
      "MANUAL_RUN": manual_run,
      "START_TIME": start_time,
      "PARAM1": param1,
      "PARAM2": param2,
      "PARAM3": param3,
      "PARAM4": param4,
      "PARAM5": param5
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  def script_set_log_file_id(board, file_id, value)
    # Formulate parameters
    cmd_name = "FSW_SE_SET_LOG_ID"

    cmd_params = {
      "FILE_ID": file_id,
      "LOG_FILE_ID": value
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  def script_set_manual(board, file_id)
    # Formulate parameters
    cmd_name = "FSW_SE_MANUAL_RUN"

    cmd_params = {
      "FILE_ID": file_id,
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  def script_abort(board, file_id)
    # Formulate parameters
    cmd_name = "FSW_SE_ABORT"

    cmd_params = {
      "FILE_ID": file_id,
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  def script_set_block(board, script_id, value)
    # Formulate parameters
    cmd_name = "FSW_SE_SET_BLOCK"

    cmd_params = {
      "SCRIPT_ID": script_id,
      "BLOCK": value
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  def script_set_start(board, file_id, value)
    # Formulate parameters
    cmd_name = "FSW_SE_SET_START"

    cmd_params = {
      "FILE_ID": file_id,
      "START_TIME": value
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  def send_instantaneous_tlm(board, file_id, tlm_destination)
    # Formulate parameters
    cmd_name = "FSW_SE_SEND_INSTANTANEOUS_TLM"

    cmd_params = {
      "FILE_ID": file_id,
      "DESTINATION_CSP_ID": tlm_destination
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end

  def remove_single_time_tag(board, file_id, start_time_index)
    # Formulate parameters
    cmd_name = "FSW_SE_REMOVE_TIME_TAG"

    cmd_params = {
      "FILE_ID": file_id,
      "START_TIME_INDEX": start_time_index
    }

    @cmd_sender.send(board, cmd_name, cmd_params)
  end
end