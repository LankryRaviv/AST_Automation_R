load 'Operations/FSW/UTIL_CmdSender.rb'

## TODO: Cannot implement uptime because there is no predictable command code
class ModuleDPC
  def initialize
    @cmd_sender = CmdSender.new
    @target = 'BW3'
  end

  def set_micron_uart(board, uart_select, control)
    cmd_name = 'MICRON_UART_CONTROL'
    cmd_params = {
      "UART_SELECT": uart_select,
      "CONTROL": control
    }
    @cmd_sender.send(board, cmd_name, cmd_params)
  end
end
