load_utility('Operations\FSW\UTIL_CmdSender')

class ModulePPU
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @wait_time = 3
  end
  
  def ready_thruster(board)

    cmd_name = "PPU_RDYTHR"

    # Send command
    @cmd_sender.send(board,cmd_name,{})  
  end

  def reset_error(board)
    cmd_name = "PPU_RESETERR"

    # Send command
    @cmd_sender.send(board,cmd_name,{})  
  end
  
  def reset_PPU(board)
    cmd_name = "PPU_RESETPPU"

    # Send command
    @cmd_sender.send(board,cmd_name,{})    
  end

  def send_status(board)
    cmd_name = "PPU_SENDSTAT"

    # Send command
    @cmd_sender.send(board,cmd_name,{})    
  end

  def send_telemetry(board)
    cmd_name = "PPU_SENDTELE"

    # Send command
    @cmd_sender.send(board,cmd_name,{})    
  end

  def start_thruster(board)
    cmd_name = "PPU_STARTTHR"

    # Send command
    @cmd_sender.send(board,cmd_name,{})    
  end

  def stop_thruster(board)
    cmd_name = "PPU_STOPTHR"

    # Send command
    @cmd_sender.send(board,cmd_name,{})    
  end

  def stop_telemetry(board)
    cmd_name = "PPU_TELEOFF"

    # Send command
    @cmd_sender.send(board,cmd_name,{})    
  end

end