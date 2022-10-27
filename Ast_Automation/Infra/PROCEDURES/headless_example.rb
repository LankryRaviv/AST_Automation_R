# This example can be run on the command line directly (from the PROCEDURES folder) with:
# >ruby headless_example.rb

# This load will change the current directory to COSMOS-CONF\cosmos-local\procedures so that
# the cosmos imports will work. They need a reference to a cosmos config system.txt file
load '..\COSMOS-CONF\cosmos-local\procedures\cosmos_imports.rb'

# Now change the directory back to PROCEDURES so that the tests' imports will work
Dir.chdir __dir__

# Load all of the test suites
load 'TestRunnerUtils\TestSuites\test_runner_main.rb'

# Run an individual test suite and print the results. Can be any of the test suites
FSWTestSuite.new.run{ |result| puts "#{result.test}:#{result.test_case}:#{result.result}" }
