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
