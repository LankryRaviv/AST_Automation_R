require 'cosmos'
require 'cosmos/script'

load 'cosmos/tools/test_runner/test.rb'
load 'C:/AST-COSMOS-REPO/procedures/utils/CSV_Reader.rb'
load 'C:/AST-COSMOS-REPO/procedures/AIT/FSW/generic_tlm_test.rb'
class HeadlessTLMGenTests
  def run_tests
    values = CSVReader.new.extract_test_setup
    values.each do | row |
        genericTest = GenericTLMTest.new
        genericTest.set_board(row)
        genericTest.run { |result| puts "#{result.test}:#{result.test_case}:#{result.result}" }
    end
  end
end
x = HeadlessTLMGenTests.new
x.run_tests