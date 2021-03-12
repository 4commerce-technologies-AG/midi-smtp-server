# frozen_string_literal: true

require 'rake/testtask'

module Rake

  # A helper class to create easily test tasks for MidiSmtpServer library
  class MidiSmtpServerTestTask < TestTask

    # Create a testing task.
    # rubocop: disable Lint/MissingSuper
    def initialize(name)
      @name = name
      @libs = ['lib']
      @pattern = nil
      @options = nil
      @test_files = FileList['test/minitest.rb', 'test/construct/*_patch.rb', 'test/construct/*_class.rb']
      @verbose = false
      @warning = false
      @loader = :rake
      @ruby_opts = []
      @description = nil
      @deps = []
      if @name.is_a?(Hash)
        @deps = @name.values.first
        @name = @name.keys.first
      end
      yield self if block_given?
      define
    end
    # rubocop: enable Lint/MissingSuper

    def desc=(description)
      @description = description
    end

    def add_test_files(groups)
      groups = [] << groups unless groups.is_a?(Array)
      groups.each { |group| @test_files.include("test/#{group}/*_test.rb") }
    end

  end

end
