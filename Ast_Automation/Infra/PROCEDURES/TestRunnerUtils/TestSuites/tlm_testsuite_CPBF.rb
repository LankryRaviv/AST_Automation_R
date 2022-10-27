load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/TestSuites/test_suite_tools.rb'
load 'TestRunnerUtils/ast_test_base.rb'


class CPBFTestSuite < Cosmos::TestSuite
  include TestSuiteTools

  def initialize
      super()

      subsystem = "CPBF"
      pattern_string = "test_*.rb"
      subsystem_cosmos_test_object = ASTCOSMOSTestCPBF

      add_tests(subsystem_cosmos_test_object, subsystem, pattern_string)
  end

  def setup
    status_bar("setup")
  end

  def teardown
    status_bar("teardown")
  end
end
