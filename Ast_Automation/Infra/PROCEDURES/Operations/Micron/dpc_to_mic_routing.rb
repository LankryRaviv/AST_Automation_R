load('Operations/Micron/MICRON_MODULE.rb')
load('Operations/FSW/FSW_DPC.rb')
load('Operations/FSW/FSW_CSP.rb')

class RunDpcMicRouting
  def initialize
    @cmd_sender = CmdSender.new
    @target = "BW3"
    @link = "MIC_LSL"
    @mic = MICRON_MODULE.new
    @dpc = ModuleDPC.new
    @csp = ModuleCSP.new
  end

  def reset_dpcs(uart_status)
    (1..5).each do |dpc_num|
      @csp.reboot("DPC_#{dpc_num.to_s}", true)
      wait(0.5)
    end
    uart_status.each_key do |key|
      uart_status[key] = "ON"
    end
  end

  def reset_dpc(dpc_num, uart_status)
    @csp.reboot("DPC_#{dpc_num.to_s}", true)
    uart_status["DPC_#{dpc_num}".to_sym]
  end

  def disable_uart(dpc_num, uart, uart_status)
    @dpc.set_micron_uart("DPC_#{dpc_num}", uart, "OFF")
    uart_status["DPC_#{dpc_num}-#{uart}".to_sym] = "OFF"
  end

  def disable_all_on_uarts(uart_status)
    uart_status.each do |key, value|
      if value == "ON"
        dpc_num = key.to_s.split("-")[0]
        uart = key.to_s.split("-")[1]
        @dpc.set_micron_uart("#{dpc_num}", uart, "OFF")
        puts("Disabled dpc #{dpc_num} uart #{uart}")
      end
    end
    uart_status.each_key do |key|
      uart_status[key] = "OFF"
    end
  end

  def disable_all_uarts(uart_status)
    (1..5).each do |dpc_num|
      @dpc.set_micron_uart("DPC_#{dpc_num}", "UART2", "OFF")
      wait(1)
      @dpc.set_micron_uart("DPC_#{dpc_num}", "UART4", "OFF")
      wait(1)
    end
    uart_status.each_key do |key|
      uart_status[key] = "OFF"
    end
  end

  def enable_uart_and_ping_micron(dpc_num, uart, micron_id, uart_status)
    @dpc.set_micron_uart("DPC_#{dpc_num}", uart, "ON")
    uart_status["DPC_#{dpc_num}-#{uart}".to_sym] = "ON"
    result = @mic.ping_micron(@link, micron_id, true, false, 2)
    if result
      puts("Micron ping passed for DPC_#{dpc_num.to_s} to Micron #{micron_id.to_s} over UART #{uart}.")
      return true
    else
      puts("Micron ping failed for DPC_#{dpc_num.to_s} to Micron #{micron_id.to_s} over UART #{uart}.")
      return false
    end
  end

end
