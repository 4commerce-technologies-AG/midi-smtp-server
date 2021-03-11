# frozen_string_literal: true

# require the libraries
require 'logger'
require_relative '../../lib/midi-smtp-server'

# overloaded midi-smtp-server class for test
class MidiSmtpServerLoggingTest < MidiSmtpServer::Smtpd

  attr_reader :log_ctx
  attr_reader :log_severity
  attr_reader :log_msg
  attr_reader :log_err

  def on_logging_event(ctx, severity, msg, err: nil)
    # save log information for testing values
    @log_ctx = ctx
    @log_severity = severity
    @log_msg = msg
    @log_err = err
  end

end

# Specs to check the extended ports and hosts properties on MidiSmtpServer class
describe MidiSmtpServerTest do
  # initialize before tests
  before do
    @smtpd = MidiSmtpServerLoggingTest.new
  end

  def expect_logger_output(severity, msg)
    expect(@smtpd.log_ctx).must_be_nil
    expect(@smtpd.log_severity).must_equal severity
    expect(@smtpd.log_msg).must_equal msg
    expect(@smtpd.log_err).must_be_nil
  end

  describe 'logger output' do
    it 'must log as info' do
      msg = 'A simple info message.'
      @smtpd.logger.info(msg)
      expect_logger_output(Logger::INFO, msg)
    end
    it 'must log as warn' do
      msg = 'A simple warn message.'
      @smtpd.logger.warn(msg)
      expect_logger_output(Logger::WARN, msg)
    end
    it 'must log as error' do
      msg = 'A simple error message.'
      @smtpd.logger.error(msg)
      expect_logger_output(Logger::ERROR, msg)
    end
    it 'must log as fatal' do
      msg = 'A simple fatal message.'
      @smtpd.logger.fatal(msg)
      expect_logger_output(Logger::FATAL, msg)
    end
    it 'must log as debug' do
      msg = 'A simple debug message.'
      @smtpd.logger.debug(msg)
      expect_logger_output(Logger::DEBUG, msg)
    end
  end

  describe 'on_logging_event output' do
    it 'must log as fatal with context and err' do
      severity = Logger::FATAL
      msg = 'A simple fatal message.'
      @smtpd.on_logging_event({ ctx: true }, severity, msg, err: { err: 1 })
      expect(@smtpd.log_ctx[:ctx]).must_equal true
      expect(@smtpd.log_severity).must_equal severity
      expect(@smtpd.log_msg).must_equal msg
      expect(@smtpd.log_err[:err]).must_equal 1
    end
  end
end
