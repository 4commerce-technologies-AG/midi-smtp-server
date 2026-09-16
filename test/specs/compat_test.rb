# frozen_string_literal: true

require 'stringio'

# Specs to check the backward compatibility shim of the deprecated
# io_waitreadable_sleep option (replaced by io_wait_mode / io_wait_available)
describe MidiSmtpServer::Smtpd do
  describe 'deprecated io_waitreadable_sleep' do
    it 'must map to :IO_WAIT_SLEEP mode with the given time' do
      smtpd = MidiSmtpServer::Smtpd.new(io_waitreadable_sleep: 0.5, logger_severity: Logger::ERROR)
      expect(smtpd.io_wait_mode).must_equal :IO_WAIT_SLEEP
      expect(smtpd.io_wait_available).must_equal 0.5
    end

    it 'must raise when combined with io_wait_available' do
      err = expect { MidiSmtpServer::Smtpd.new(io_wait_available: 0.1, io_waitreadable_sleep: 0.1) }.must_raise RuntimeError
      assert_match(/Not allowed to use io_wait_available and deprecated io_waitreadable_sleep/, err.message)
    end

    it 'must log a deprecation warning' do
      log = StringIO.new
      MidiSmtpServer::Smtpd.new(io_waitreadable_sleep: 0.5, logger: Logger.new(log))
      assert_match(/Deprecated: "io_waitreadable_sleep" was replaced/, log.string)
    end
  end
end
