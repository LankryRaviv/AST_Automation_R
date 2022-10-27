load_utility('Operations/FSW/UTIL_CmdSender')

target = "BW3"
board = "APC_YP"
pkt = "POWER_CSBATS_TLM"
cmd_sender = CmdSender.new

while true
  if cmd_sender.get_current_val(board, pkt, "BCU1_HEATER_ON_THR") != 16
    cmd("BW3 APC_YP-BCU_SET_HEATER_ON_THRESHOLD with BCU_NUM BCU1, ON_THRESHOLD 16")
    puts("\n\nHEATER 1 ON THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU2_HEATER_ON_THR") != 16
    cmd("BW3 APC_YP-BCU_SET_HEATER_ON_THRESHOLD with BCU_NUM BCU2, ON_THRESHOLD 16")
    puts("\n\nHEATER 2 ON THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU3_HEATER_ON_THR") != 16
    cmd("BW3 APC_YP-BCU_SET_HEATER_ON_THRESHOLD with BCU_NUM BCU3, ON_THRESHOLD 16")
    puts("\n\nHEATER 3 ON THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU4_HEATER_ON_THR") != 16
    cmd("BW3 APC_YP-BCU_SET_HEATER_ON_THRESHOLD with BCU_NUM BCU4, ON_THRESHOLD 16")
    puts("\n\nHEATER 4 ON THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU5_HEATER_ON_THR") != 16
    cmd("BW3 APC_YP-BCU_SET_HEATER_ON_THRESHOLD with BCU_NUM BCU5, ON_THRESHOLD 16")
    puts("\n\nHEATER 5 ON THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU6_HEATER_ON_THR") != 16
    cmd("BW3 APC_YP-BCU_SET_HEATER_ON_THRESHOLD with BCU_NUM BCU6, ON_THRESHOLD 16")
    puts("\n\nHEATER 6 ON THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  
  
  if cmd_sender.get_current_val(board, pkt, "BCU1_HEATER_OFF_THR") != 20
    cmd("BW3 APC_YP-BCU_SET_HEATER_OFF_THRESHOLD with BCU_NUM BCU1, OFF_THRESHOLD 20")
    puts("\n\nHEATER 1 OFF THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU2_HEATER_OFF_THR") != 20
    cmd("BW3 APC_YP-BCU_SET_HEATER_OFF_THRESHOLD with BCU_NUM BCU2, OFF_THRESHOLD 20")
    puts("\n\nHEATER 2 OFF THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU3_HEATER_OFF_THR") != 20
    cmd("BW3 APC_YP-BCU_SET_HEATER_OFF_THRESHOLD with BCU_NUM BCU3, OFF_THRESHOLD 20")
    puts("\n\nHEATER 3 OFF THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU4_HEATER_OFF_THR") != 20
    cmd("BW3 APC_YP-BCU_SET_HEATER_OFF_THRESHOLD with BCU_NUM BCU4, OFF_THRESHOLD 20")
    puts("\n\nHEATER 4 OFF THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU5_HEATER_OFF_THR") != 20
    cmd("BW3 APC_YP-BCU_SET_HEATER_OFF_THRESHOLD with BCU_NUM BCU5, OFF_THRESHOLD 20")
    puts("\n\nHEATER 5 OFF THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end
  if cmd_sender.get_current_val(board, pkt, "BCU6_HEATER_OFF_THR") != 20
    cmd("BW3 APC_YP-BCU_SET_HEATER_OFF_THRESHOLD with BCU_NUM BCU6, OFF_THRESHOLD 20")
    puts("\n\nHEATER 6 OFF THRESHOLD RESET!!!!!!\n\n")
    wait(2)
  end

  cmd_name = "BCU_SET_GSWDT"
  params = {
      "BCU_NUM": "BCU1",
      "TIMEOUT": 86400
  }
  cmd_sender.send("APC_YP", cmd_name, params)
  wait(4)

  params = {
      "BCU_NUM": "BCU2",
      "TIMEOUT": 86400
  }
  cmd_sender.send("APC_YP", cmd_name, params)
  wait(4)

  params = {
      "BCU_NUM": "BCU3",
      "TIMEOUT": 86400
  }
  cmd_sender.send("APC_YP", cmd_name, params)
  wait(4)

  params = {
      "BCU_NUM": "BCU4",
      "TIMEOUT": 86400
  }
  cmd_sender.send("APC_YP", cmd_name, params)
  wait(4)

  params = {
      "BCU_NUM": "BCU5",
      "TIMEOUT": 86400
  }
  cmd_sender.send("APC_YP", cmd_name, params)
  wait(4)

  params = {
      "BCU_NUM": "BCU6",
      "TIMEOUT": 86400
  }
  cmd_sender.send("APC_YP", cmd_name, params)

  wait(300)
end
 