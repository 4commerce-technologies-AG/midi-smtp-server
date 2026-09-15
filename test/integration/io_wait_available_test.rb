# frozen_string_literal: true

# Unit test to check commands without TCP
class IoWaitAvailableIntegrationTest < BaseIntegrationTest

  # allow to overload value
  def io_wait_mode
    :IO_WAIT_EVENT
  end

  # allow to overload value
  def io_wait_available
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
      io_wait_mode: io_wait_mode,
      io_wait_available: io_wait_available,
      pipelining_extension: false,
      internationalization_extensions: true
    )
    # start the daemon to run real life integration tests
    @smtpd.start
  end

  ### HELPER

  def measure_io_wait_available
    timer_start = Time.now
    net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail, authentication_id: 'administrator', password: 'password', auth_type: :login, tls_enabled: true
    Time.now - timer_start
  end

end

class IoWaitAvailableIntegrationSlowTest < IoWaitAvailableIntegrationTest

  def io_wait_available
    # use long sleep
    0.5
  end

  ### TEST SUITE

  def test_slow_io_wait_available
    # This test hits IO::WaitReadable exception multiple times
    # For that, this test must run longer than 1 second if the IO mode
    # is :IO_WAIT_SLEEP. Otherwise on EVENT the IO is always as fast
    # as possible. So the assertion must handle that.
    assert_operator measure_io_wait_available, io_wait_mode == :IO_WAIT_SLEEP ? :> : :<, 1
  end

end

class IoWaitAvailableIntegrationFastTest < IoWaitAvailableIntegrationTest

  def io_wait_available
    # use short sleep
    0.05
  end

  ### TEST SUITE

  def test_fast_io_wait_available
    # This test hits IO::WaitReadable exception multiple times
    # For that, this test must run longer than 1 second
    assert_operator measure_io_wait_available, :<, 1
  end

end

class IoWaitAvailableSleepIntegrationSlowTest < IoWaitAvailableIntegrationSlowTest

  def io_wait_mode
    :IO_WAIT_SLEEP
  end

end

class IoWaitAvailableSleepIntegrationFastTest < IoWaitAvailableIntegrationFastTest

  def io_wait_mode
    :IO_WAIT_SLEEP
  end

end
