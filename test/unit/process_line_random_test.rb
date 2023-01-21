# frozen_string_literal: true

# Unit test to check commands without TCP
class ProcessLineRandomUnitTest < Minitest::Test

  # initialize before tests
  def setup
    @smtpd = MidiSmtpServerTest.new(
      ports: '2525',
      hosts: '127.0.0.1',
      max_processings: 1,
      auth_mode: :AUTH_OPTIONAL,
      tls_mode: :TLS_FORBIDDEN,
      pipelining_extension: true,
      internationalization_extensions: true
    )
    @session = {}
  end

  def setup_session
    @smtpd.process_reset_session(@session, connection_initialize: true)
    @session[:ctx][:server][:helo_response] = 'Process line test - Greeting'
  end

  def test_helo
    setup_session
    helo_str = 'Process line unit test'
    result = @smtpd.process_line(@session, "HELO #{helo_str}", "\r\n")

    assert_equal "250 OK #{@session[:ctx][:server][:helo_response]}", result
    assert_equal @session[:ctx][:server][:helo], helo_str
  end

  def test_helo_no_case_strip
    setup_session
    helo_str = '  Process line unit test   '
    result = @smtpd.process_line(@session, "hElO #{helo_str}", "\r\n")

    assert_equal "250 OK #{@session[:ctx][:server][:helo_response]}", result
    assert_equal @session[:ctx][:server][:helo], helo_str.strip
  end

  def test_ehlo_no_case_strip
    setup_session
    helo_str = '  Process line unit test   '
    result = @smtpd.process_line(@session, "eHlO #{helo_str}", "\r\n")

    assert_equal "250-#{@session[:ctx][:server][:helo_response]}\r\n250-8BITMIME\r\n250-SMTPUTF8\r\n250-PIPELINING\r\n250-AUTH LOGIN PLAIN\r\n250 OK", result
    assert_equal @session[:ctx][:server][:helo], helo_str.strip
  end

end
