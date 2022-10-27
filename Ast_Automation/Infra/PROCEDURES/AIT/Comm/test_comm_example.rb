load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'


# This Test demonstrates the usage of the setup and teardown methods
# as well as defining tests. Notice that the setup and teardown
# methods must be called exactly that. Other test methods must start
# with 'test_' to be picked up by TestRunner.
class TestExampleComm < ASTCOSMOSTestComm # Comm tests must inherit from ASTCOSMOSTestComm
  def initialize
    super()
  end

  def setup
    status_bar("setup")
  end

  def test_realtime_on1_1
    status_bar("test_realtime_on")
  end

  def test_realtime_off1_1
    status_bar("test_realtime_off")
  end

  def test_set_period_permanent_off1_1
    status_bar("test_set_period_permanent_off")
  end

  def test_set_period_temporary_on1_1
    status_bar("test_set_period_temporary_on")

    sid, tid, pkt_name = get_variables(subsystem_name)
  end

  def teardown
    status_bar("teardown")
  end

  def get_variables(subsystem_name)
    # this is a function that won't get added as a test case
    pkt_name = nil
    sid = nil
    tid = nil

    return sid, tid, pkt_name
  end

end
