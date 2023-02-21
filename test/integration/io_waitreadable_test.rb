# frozen_string_literal: true

# Unit test to check commands without TCP
class IoWaitReadableIntegrationTest < BaseIntegrationTest

  # allow to overload value
  def io_waitreadable_sleep
    nil
  end

  # initialize before tests
  def setup
    # create some message vars and sources
    super
    # create service instance
    @smtpd = MidiSmtpServerTest.new(
      ports: '5555',
      hosts: '127.0.0.1',
      max_processings: 1,
      do_dns_reverse_lookup: false,
      auth_mode: :AUTH_OPTIONAL,
      tls_mode: :TLS_REQUIRED,
      io_waitreadable_sleep: io_waitreadable_sleep,
      pipelining_extension: false,
      internationalization_extensions: true
    )
    # start the daemon to run real life integration tests
    @smtpd.start
  end

  ### HELPER

  def measure_io_waitreadable_sleep
    timer_start = Time.now
    net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail, authentication_id: 'administrator', password: 'password', auth_type: :login, tls_enabled: true
    Time.now - timer_start
  end

end

class IoWaitReadableIntegrationSlowTest < IoWaitReadableIntegrationTest

  def io_waitreadable_sleep
    # use long sleep
    0.5
  end

  ### TEST SUITE

  def test_slow_io_waitreadable_sleep
    # This test hits IO::WaitReadable exception multiple times
    # For that, this test must run longer than 1 second
    assert measure_io_waitreadable_sleep > 1
  end

end

class IoWaitReadableIntegrationFastTest < IoWaitReadableIntegrationTest

  def io_waitreadable_sleep
    # use short sleep
    0.05
  end

  ### TEST SUITE

  def test_fast_io_waitreadable_sleep
    # This test hits IO::WaitReadable exception multiple times
    # For that, this test must run longer than 1 second
    assert measure_io_waitreadable_sleep < 1
  end

end
