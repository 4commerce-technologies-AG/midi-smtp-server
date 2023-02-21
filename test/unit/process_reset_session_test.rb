# frozen_string_literal: true

# Unit test to check session content
class ProcessResetSessionUnitTest < Minitest::Test

  # initialize before tests
  def setup
    @smtpd = MidiSmtpServerTest.new
    @session = {}
  end

  def test_reset_helo
    @smtpd.process_reset_session(@session, connection_initialize: true)

    assert_equal :CMD_HELO, @session[:cmd_sequence]
  end

  def test_reset_rset
    @smtpd.process_reset_session(@session, connection_initialize: false)

    assert_equal :CMD_RSET, @session[:cmd_sequence]
  end

  def test_session_status
    @smtpd.process_reset_session(@session, connection_initialize: true)

    assert_instance_of Hash, @session[:auth_challenge]
    assert_equal '', @session[:ctx][:server][:local_host]
    assert_equal '', @session[:ctx][:server][:local_ip]
    assert_equal '', @session[:ctx][:server][:local_port]
    assert_equal '', @session[:ctx][:server][:local_response]
    assert_equal '', @session[:ctx][:server][:remote_host]
    assert_equal '', @session[:ctx][:server][:remote_ip]
    assert_equal '', @session[:ctx][:server][:remote_port]
    assert_equal '', @session[:ctx][:server][:helo]
    assert_equal '', @session[:ctx][:server][:helo_response]
    assert_equal '', @session[:ctx][:server][:connected]
    assert_equal 0, @session[:ctx][:server][:exceptions]
    assert_equal 0, @session[:ctx][:server][:errors].length
    assert_equal '', @session[:ctx][:server][:authorization_id]
    assert_equal '', @session[:ctx][:server][:authentication_id]
    assert_equal '', @session[:ctx][:server][:authenticated]
    assert_equal '', @session[:ctx][:server][:encrypted]
    assert_equal '', @session[:ctx][:envelope][:from]
    assert_equal 0, @session[:ctx][:envelope][:to].length
    assert_equal '', @session[:ctx][:envelope][:encoding_body]
    assert_equal '', @session[:ctx][:envelope][:encoding_utf8]
    assert_equal (-1), @session[:ctx][:message][:received]
    assert_equal (-1), @session[:ctx][:message][:delivered]
    assert_equal (-1), @session[:ctx][:message][:bytesize]
    assert_equal '', @session[:ctx][:message][:headers]
    assert_equal "\r\n", @session[:ctx][:message][:crlf]
    assert_equal '', @session[:ctx][:message][:data]
  end

end
