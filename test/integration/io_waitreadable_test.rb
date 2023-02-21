# frozen_string_literal: true

# Unit test to check commands without TCP
class IoWaitReadableIntegrationTest < BaseIntegrationTest

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
      io_waitreadable_sleep: 0.3,
      pipelining_extension: false,
      internationalization_extensions: true
    )
    # start the daemon to run real life integration tests
    @smtpd.start
  end

  ### TEST SUITE

  def test_io_waitreadable_sleep
    start_time = Time.now
    net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail, authentication_id: 'administrator', password: 'password', auth_type: :login, tls_enabled: true
    runtime = Time.now - start_time

    # This test hits IO::WaitReadable exception 11 times.
    assert_operator runtime, :>, 3.3
  end

end
