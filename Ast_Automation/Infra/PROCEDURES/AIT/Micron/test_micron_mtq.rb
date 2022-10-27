load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('TestRunnerUtils/test_case_utils.rb')

load_utility('Operations/MICRON/MTQ_Command_Driver.rb')

class MicMTQTest < ASTCOSMOSTestMicron
  def initialize
    @test_util = ModuleTestCase.new
    @mtq = MTQCommandDriver.new
    @link = "MIC_LSL"
    super()
  end

  def setup()
    @link = combo_box("Select a link","MIC_LSL","MIC_HSL")
    @micron_id = ask("Enter the Micron ID")
  end

  def test_a_send_mtq_command()
    if @micron_id.nil?
      @micron_id = ask("Enter the Micron ID")
    end
    mtqa_state = combo_box("Enter the MTQ A State","ON","OFF")
    mtqa_polarity = combo_box("Enter the MTQ A Polarity","NEGATIVE","POSITIVE")
    mtqb_state = combo_box("Enter the MTQ B State","ON","OFF")
    mtqb_polarity = combo_box("Enter the MTQ B Polarity","NEGATIVE","POSITIVE")
    mtqa_time = ask("Enter the MTQ A On Time in deciseconds (max 200)")
    mtqb_time = ask("Enter the MTQ B On Time in deciseconds (max 200)")
    res = @mtq.send_mtq_command(@link, @micron_id, mtqa_state, mtqa_polarity, mtqa_time, mtqb_state, mtqb_polarity, mtqb_time)[0]
    puts("Response to MTQ Enable command is #{res["MIC_ENABLE_MTQ_RESULT_CODE"]}")
  end

  def test_z_turn_off_mtq()
    if @micron_id.nil?
      @micron_id = ask("Enter the Micron ID")
    end
    res = @mtq.send_mtq_command(@link, @micron_id, "OFF", "NEGATIVE", 200, "OFF", "NEGATIVE", 200)[0]
    puts("Response to MTQ Enable (turn off) command is #{res["MIC_ENABLE_MTQ_RESULT_CODE"]}")
  end

  def test_b_mtqa_on_positive_direction()
    if @micron_id.nil?
      @micron_id = ask("Enter the Micron ID")
    end
    @mtq.mtq_command_loop(@link, @micron_id, "ON","POSITIVE",200,"OFF","POSITIVE",200)
  end

  def test_c_mtqa_on_negative_direction()
    if @micron_id.nil?
      @micron_id = ask("Enter the Micron ID")
    end
    @mtq.mtq_command_loop(@link, @micron_id, "ON","NEGATIVE",200,"OFF","POSITIVE",200)
  end

  def test_d_mtqb_on_positive_direction()
    if @micron_id.nil?
      @micron_id = ask("Enter the Micron ID")
    end
    @mtq.mtq_command_loop(@link, @micron_id, "OFF","POSITIVE",200,"ON","POSITIVE",200)
  end

  def test_e_mtqb_on_negative_direction()
    if @micron_id.nil?
      @micron_id = ask("Enter the Micron ID")
    end
    @mtq.mtq_command_loop(@link, @micron_id, "OFF","POSITIVE",200,"ON","NEGATIVE",200)
  end

end
