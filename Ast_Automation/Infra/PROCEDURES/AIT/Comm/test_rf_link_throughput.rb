load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem.rb')
load_utility('TestRunnerUtils/test_case_utils.rb')
load_utility('Operations/FSW/FSW_FS_Upload.rb')

# ------------------------------------------------------------------------------------

class RFThroughput < ASTCOSMOSTestComm 
  def initialize(target = "BW3")
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @test_util = ModuleTestCase.new
    @csp_destination = "COSMOS_UMBILICAL"
    @target = target
    super()
  end

  def setup(test_case_name = "RF_THROUGHPUT")
    stack = @test_util.initialize_test_case(test_case_name)
    @board = "APC_" + stack
  end

  def test_uplink_throughput()
    # uplink tested through a file upload
    # first prepare the file location for upload
    file_id = ask("Enter file ID to be used for the uplink test")
    filename = open_file_dialog("./", "Select file to upload")
    use_slim = combo_box("Use Slim File Upload packets?", "Yes", "No") == 'Yes'
    ul_pkt_freq = ask("Enter the period between upload packets in seconds (can use decimal value)")
    file_size = File.size(filename)
    ul_pkt_size = use_slim ? 186 : 1754
    ul_rate = ul_pkt_size * (1/ul_pkt_freq)
    ul_dur = file_size / ul_rate
    msg = "Expected throughput is #{ul_rate} bytes/sec, duration is approx. #{ul_dur.to_i} seconds"
    puts(msg)
    message_box(msg, 'OK', false)
    if use_slim
      FSW_FS_Upload_Slim(ul_pkt_size, file_id, filename, @board, aspect="CRC",test_break=0,period_between_pkt = ul_pkt_freq)
    else
      FSW_FS_Upload(ul_pkt_size, file_id, filename, @board, aspect="CRC",test_break=0,period_between_pkt = ul_pkt_freq)
    end
  end
end