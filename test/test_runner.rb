# frozen_string_literal: true

# test_runner.rb will automatically include all tests and specs
# to easily access and run all tests

# to get a more verbose output just run:
# ruby -I lib test/test_runner.rb -v

# to just run selected (regular expression) tests use:
# ruby -I lib test/test_runner.rb -v -n /connections/
# this will run only the tests and specs containing
# _connections_ in their method_name or describe_text

# Runs all tests before Ruby exits, using `Kernel#at_exit`.
require 'minitest/autorun'

# Enables rainbow-coloured test output.
require 'minitest/pride'

# require all test files
test_files = []

# search relative test folder
Dir.chdir(File.dirname(__FILE__)) do
  test_files += Dir.glob('setup/**/*.rb')
  test_files += Dir.glob('specs/**/*_test.rb')
  test_files += Dir.glob('unit/**/*_test.rb')
  test_files += Dir.glob('integration/**/*_test.rb')
end

# require each test
test_files.each do |test_file|
  require_relative test_file
end
