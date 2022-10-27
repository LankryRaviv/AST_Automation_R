load 'cosmos/tools/test_runner/test.rb'
load 'C:/COSMOS/ast-master/procedures/utils/Test_File_Parser.rb'
load 'C:/COSMOS/ast-master/procedures/utils/CSV_Reader.rb'
load 'C:/COSMOS/ast-master/procedures/AIT/FSW/generic_tlm_test.rb'
class GenericTLMTestSuite < Cosmos::TestSuite
  def initialize
    super()

    values = CSVReader.new.extract_test_setup
    values.each do | row |
        generic_test = GenericTLMTest.new
        generic_test.set_board(row)
        add_test(generic_test)
    end
    puts "initialize complete"
  end

  def setup
  end

  def teardown
  end
end
