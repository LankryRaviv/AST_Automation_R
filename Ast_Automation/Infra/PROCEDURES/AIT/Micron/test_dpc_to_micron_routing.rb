load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('TestRunnerUtils/test_case_utils.rb')
load('Operations/Micron/MICRON_MODULE.rb')
load('Operations/Micron/dpc_to_mic_routing.rb')

class DPCToMicronRouting < ASTCOSMOSTestMicron
  def initialize
    @mic = MICRON_MODULE.new
    @dpc = RunDpcMicRouting.new
    @test_util = ModuleTestCase.new
    @uart_status = {"DPC_1-UART2": "ON",
                    "DPC_1-UART4": "ON",
                    "DPC_2-UART2": "ON",
                    "DPC_2-UART4": "ON",
                    "DPC_3-UART2": "ON",
                    "DPC_3-UART4": "ON",
                    "DPC_4-UART2": "ON",
                    "DPC_4-UART4": "ON",
                    "DPC_5-UART2": "ON",
                    "DPC_5-UART4": "ON",
                  }
    super()
  end

  def setup()
    @link = 'MIC_LSL'
  end

  def test_reset_all_dpcs()
    @dpc.reset_dpcs(@uart_status)
  end

  def test_reset_single_dpc()
    dpc_select = message_box("Select a DPC to reset","1","2","3","4","5")
    @dpc.reset_dpc(dpc_select, @uart_status)
  end

  def test_disable_single_uart()
    dpc_select = message_box("Select the DPC","1","2","3","4","5")
    uart_select = message_box("Select UART to disable","UART2","UART4")
    puts("before disable: #{@uart_status}")
    @dpc.disable_uart(dpc_select, uart_select, @uart_status)
    puts("after disable: #{@uart_status}")
  end

  def test_disable_all_uarts()
    puts("before disable all: #{@uart_status}")
    @dpc.disable_all_uarts(@uart_status)
    puts("after disable all: #{@uart_status}")
  end

  def test_disable_all_on_uarts()
    @dpc.disable_all_on_uarts(@uart_status)
  end

  def test_link_mic_77()
    # mic 77 connects to dpc2/UART4 and dpc5/UART4
    @dpc.disable_all_on_uarts(@uart_status)
    result = @dpc.enable_uart_and_ping_micron(5, 'UART4', 77, @uart_status)
    if result
      Cosmos::Test.puts("Ping Micron 77 passed for DPC_5")
    else
      Cosmos::Test.puts("Ping Micron 77 failed for DPC_5")
    end
  end

  def test_link_mic_104()
    # mic 104 connects to dpc2/UART4 and dpc5/UART4
    @dpc.disable_all_on_uarts(@uart_status)
    result = @dpc.enable_uart_and_ping_micron(2, 'UART4', 104, @uart_status)
    if result
      Cosmos::Test.puts("Ping Micron 104 passed for DPC_2")
    else
      Cosmos::Test.puts("Ping Micron 104 failed for DPC_2")
    end
  end

  def test_link_mic_78()
    # mic 78 connects to dpc2/UART2 and dpc5/UART2
    @dpc.disable_all_on_uarts(@uart_status)
    result = @dpc.enable_uart_and_ping_micron(2, 'UART2', 78, @uart_status)
    if result
      Cosmos::Test.puts("Ping Micron 78 passed for DPC_2")
    else
      Cosmos::Test.puts("Ping Micron 78 failed for DPC_2")
    end
    
  end

  def test_link_mic_90()
    # mic 90 connects to dpc2/UART2 and dpc5/UART2
    @dpc.disable_all_on_uarts(@uart_status)
    result = @dpc.enable_uart_and_ping_micron(5, 'UART2', 90, @uart_status)
    if result
      Cosmos::Test.puts("Ping Micron 90 passed for DPC_5")
    else
      Cosmos::Test.puts("Ping Micron 90 failed for DPC_5")
    end
  end

  def test_link_mic_107()
    # mic 107 connects to dpc3/UART4 and dpc4/UART4
    @dpc.disable_all_on_uarts(@uart_status)
    result = @dpc.enable_uart_and_ping_micron(3, 'UART4', 107, @uart_status)
    if result
      Cosmos::Test.puts("Ping Micron 107 passed for DPC_3")
    else
      Cosmos::Test.puts("Ping Micron 107 failed for DPC_3")
    end
  end

  def test_link_mic_119()
    # mic 119 connects to dpc3/UART4 and dpc4/UART4
    @dpc.disable_all_on_uarts(@uart_status)
    result = @dpc.enable_uart_and_ping_micron(4, 'UART4', 119, @uart_status)
    if result
      Cosmos::Test.puts("Ping Micron 119 passed for DPC_4")
    else
      Cosmos::Test.puts("Ping Micron 119 failed for DPC_4")
    end
  end

  def test_link_mic_120()
    # mic 120 connects to dpc3/UART2 and dpc4/UART2
    @dpc.disable_all_on_uarts(@uart_status)
    result = @dpc.enable_uart_and_ping_micron(3, 'UART2', 120, @uart_status)
    if result
      Cosmos::Test.puts("Ping Micron 120 passed for DPC_3")
    else
      Cosmos::Test.puts("Ping Micron 120 failed for DPC_3")
    end
  end

  def test_link_mic_93()
    # mic 93 connects to dpc3/UART2 and dpc4/UART2
    @dpc.disable_all_on_uarts(@uart_status)
    result = @dpc.enable_uart_and_ping_micron(4, 'UART2', 93, @uart_status)
    if result
      Cosmos::Test.puts("Ping Micron 93 passed for DPC_4")
    else
      Cosmos::Test.puts("Ping Micron 93 failed for DPC_4")
    end
  end

  def test_all_links()
    test_link_mic_77()
    test_link_mic_78()
    test_link_mic_90()
    test_link_mic_93()
    test_link_mic_104()
    test_link_mic_107()
    test_link_mic_119()
    test_link_mic_120()
  end

end