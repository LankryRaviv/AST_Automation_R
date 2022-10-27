load 'Operations/FSW/UTIL_CmdSender.rb'

class ModuleCamera
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
  end
  
  def get_CAM_Status_DPC_1(dpc_number)
    
	if dpc_number==1
		full_pkt_name = CmdSender.get_full_pkt_name("DPC_1", "CAMERA_TLM")
		current_val = @cmd_sender.get_current_val("DPC_1", "CAMERA_TLM", "CAM_STATUS")
	elsif dpc_number==2
		full_pkt_name = CmdSender.get_full_pkt_name("DPC_2", "CAMERA_TLM")
		current_val = @cmd_sender.get_current_val("DPC_2", "CAMERA_TLM", "CAM_STATUS")
	elsif dpc_number==3
		full_pkt_name = CmdSender.get_full_pkt_name("DPC_3", "CAMERA_TLM")
		current_val = @cmd_sender.get_current_val("DPC_3", "CAMERA_TLM", "CAM_STATUS")
	elsif dpc_number==4
		full_pkt_name = CmdSender.get_full_pkt_name("DPC_4", "CAMERA_TLM")
		current_val = @cmd_sender.get_current_val("DPC_4", "CAMERA_TLM", "CAM_STATUS")
	elsif dpc_number==5
		full_pkt_name = CmdSender.get_full_pkt_name("DPC_5", "CAMERA_TLM")
		current_val = @cmd_sender.get_current_val("DPC_5", "CAMERA_TLM", "CAM_STATUS")
  end

  def take_picture(dpc_number)
	
	if dpc_number==1
		board = "DPC_1"
		cmd_name = "CAM_TAKEPIC"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==2
		board = "DPC_2"
		cmd_name = "CAM_TAKEPIC"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==3
		board = "DPC_3"
		cmd_name = "CAM_TAKEPIC"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==4
		board = "DPC_4"
		cmd_name = "CAM_TAKEPIC"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==5
		board = "DPC_5"
		cmd_name = "CAM_TAKEPIC"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  

  end
  
  def cam_init(dpc_number)
	
	if dpc_number==1
		board = "DPC_1"
		cmd_name = "CAM_INIT"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==2
		board = "DPC_2"
		cmd_name = "CAM_INIT"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==3
		board = "DPC_3"
		cmd_name = "CAM_INIT"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==4
		board = "DPC_4"
		cmd_name = "CAM_INIT"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==5
		board = "DPC_5"
		cmd_name = "CAM_INIT"
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  

  end
  
  def select_mode(dpc_number, mode)
	
	if dpc_number==1
		board = "DPC_1"
		cmd_name = "CAM_MODE"
		cmd_params = {"MODE": mode}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==2
		board = "DPC_2"
		cmd_name = "CAM_MODE"
		cmd_params = {"MODE": mode}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==3
		board = "DPC_3"
		cmd_name = "CAM_MODE"
		cmd_params = {"MODE": mode}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==4
		board = "DPC_4"
		cmd_name = "CAM_MODE"
		cmd_params = {"MODE": mode}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==5
		board = "DPC_5"
		cmd_name = "CAM_MODE"
		cmd_params = {"MODE": mode}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  

  end 

  def save_pic(dpc_number,file_id, offset )
	
	if dpc_number==1
		board = "DPC_1"
		cmd_name = "CAM_SAVE"
		cmd_params = {"FILE_ID": file_id,
							"OFFSET":offset}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==2
		board = "DPC_2"
		cmd_name = "CAM_SAVE"
		cmd_params = {"FILE_ID": file_id,
							"OFFSET":offset}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==3
		board = "DPC_3"
		cmd_name = "CAM_SAVE"
		cmd_params = {"FILE_ID": file_id,
							"OFFSET":offset}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==4
		board = "DPC_4"
		cmd_name = "CAM_SAVE"
		cmd_params = {"FILE_ID": file_id,
							"OFFSET":offset}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==5
		board = "DPC_5"
		cmd_name = "CAM_SAVE"
		cmd_params = {"FILE_ID": file_id,
							"OFFSET":offset}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  

  end
  
  def format_file(dpc_number,file_id,entries_qty,entry_size)
	
	if dpc_number==1
		board = "DPC_1"
		cmd_name = "FSW_FILE_FORMAT"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"ENTRIES_QTY":entries_qty,
							"ENTRY_SIZE":entry_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==2
		board = "DPC_2"
		cmd_name = "FSW_FILE_FORMAT"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"ENTRIES_QTY":entries_qty,
							"ENTRY_SIZE":entry_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==3
		board = "DPC_3"
		cmd_name = "FSW_FILE_FORMAT"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"ENTRIES_QTY":entries_qty,
							"ENTRY_SIZE":entry_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==4
		board = "DPC_4"
		cmd_name = "FSW_FILE_FORMAT"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"ENTRIES_QTY":entries_qty,
							"ENTRY_SIZE":entry_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==5
		board = "DPC_5"
		cmd_name = "FSW_FILE_FORMAT"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"ENTRIES_QTY":entries_qty,
							"ENTRY_SIZE":entry_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  

  end
  
  def download_file(dpc_number,file_id,entry_start,entry_end,offset, period_ms, duration, pkt_size)
	
	if dpc_number==1
		board = "DPC_1"
		cmd_name = "FSW_FILE_DWNLD_BY_RANGE"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"START":entry_start,
							"END":entry_end,
							"FIRST_OFFSET":offset,
							"PERIOD_MS":period_ms,
							"DURATION_S":duration,
							"PKT_SIZE":pkt_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==2
		board = "DPC_2"
		cmd_name = "FSW_FILE_DWNLD_BY_RANGE"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"START":entry_start,
							"END":entry_end,
							"FIRST_OFFSET":offset,
							"PERIOD_MS":period_ms,
							"DURATION_S":duration,
							"PKT_SIZE":pkt_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==3
		board = "DPC_3"
		cmd_name = "FSW_FILE_DWNLD_BY_RANGE"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"START":entry_start,
							"END":entry_end,
							"FIRST_OFFSET":offset,
							"PERIOD_MS":period_ms,
							"DURATION_S":duration,
							"PKT_SIZE":pkt_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==4
		board = "DPC_4"
		cmd_name = "FSW_FILE_DWNLD_BY_RANGE"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"START":entry_start,
							"END":entry_end,
							"FIRST_OFFSET":offset,
							"PERIOD_MS":period_ms,
							"DURATION_S":duration,
							"PKT_SIZE":pkt_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  
	elsif dpc_number==5
		board = "DPC_5"
		cmd_name = "FSW_FILE_DWNLD_BY_RANGE"
		cmd_params = {"FILE_ID": file_id,
							"STATUS":0,
							"START":entry_start,
							"END":entry_end,
							"FIRST_OFFSET":offset,
							"PERIOD_MS":period_ms,
							"DURATION_S":duration,
							"PKT_SIZE":pkt_size}
		# Send command
		@cmd_sender.send(board,cmd_name,cmd_params)  

  end

end
