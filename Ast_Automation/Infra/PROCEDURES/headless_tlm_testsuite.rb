require 'cosmos'
require 'cosmos/script'
load 'cosmos/tools/test_runner/test.rb'
load 'C:/AST-COSMOS-REPO/test_runner_main1.rb'


TLMTestSuite1.new.run { |result| puts "#{result.test}:#{result.test_case}:#{result.result}" }
