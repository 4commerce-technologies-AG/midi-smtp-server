# frozen_string_literal: true

require 'base64'
require 'mail'

# Unit test to check commands without TCP
class ProcessProxyUnitTest < Minitest::Test

  # initialize before tests
  def setup
    @smtpd = MidiSmtpServerTest.new(
      ports: '2525',
      hosts: '127.0.0.1',
      max_processings: 1,
      auth_mode: :AUTH_OPTIONAL,
      tls_mode: :TLS_OPTIONAL,
      proxy_extension: true,
      pipelining_extension: false,
      internationalization_extensions: true
    )
    # prepare a session hash
    @session = {}
    @smtpd.process_reset_session(@session, connection_initialize: true)
    # enter some valid status
    @session[:ctx][:server][:local_host] = 'localhost.local'
    @session[:ctx][:server][:local_ip] = '127.0.0.1'
    @session[:ctx][:server][:local_port] = '2525'
    @session[:ctx][:server][:local_response] = 'Process line test - Welcome'
    @session[:ctx][:server][:remote_host] = 'localhost'
    @session[:ctx][:server][:remote_ip] = '127.0.0.1'
    @session[:ctx][:server][:remote_port] = '65534'
    @session[:ctx][:server][:helo_response] = 'Process line test - Greeting'
    @session[:ctx][:server][:connected] = Time.now
  end

  ### TEST SUITE

  def test_00_proxy_tcp4_valid
    @smtpd.process_line(@session, 'PROXY TCP4 1.1.1.1 2.2.2.2 1111 2222', "\r\n")
    refute_nil @session[:ctx][:server][:proxy]
    assert_equal '1.1.1.1', @session[:ctx][:server][:proxy][:source_ip]
    assert_equal 1111, @session[:ctx][:server][:proxy][:source_port]
    assert_equal '2.2.2.2', @session[:ctx][:server][:proxy][:dest_ip]
    assert_equal 2222, @session[:ctx][:server][:proxy][:dest_port]
  end

  def test_01_proxy_tcp6_valid
    @smtpd.process_line(@session, 'PROXY TCP6 003::0003 4::4 000003333 4444', "\r\n")
    refute_nil @session[:ctx][:server][:proxy]
    assert_equal '3::3', @session[:ctx][:server][:proxy][:source_ip]
    assert_equal 3333, @session[:ctx][:server][:proxy][:source_port]
    assert_equal '4::4', @session[:ctx][:server][:proxy][:dest_ip]
    assert_equal 4444, @session[:ctx][:server][:proxy][:dest_port]
  end

  def test_02_proxy_illegal_command
    assert_raises(MidiSmtpServer::Smtpd421Exception) { @smtpd.process_line(@session, 'PROXY ILLEGAL COMMAND', "\r\n") }
  end

  def test_03_proxy_multiple_proxy_abort
    @smtpd.process_line(@session, 'PROXY TCP4 1.1.1.1 2.2.2.2 1111 2222', "\r\n")
    assert_raises(MidiSmtpServer::Smtpd421Exception) { @smtpd.process_line(@session, 'PROXY TCP6 003::0003 4::4 000003333 4444', "\r\n") }
  end

  def test_04_proxy_illegal_sequence
    @smtpd.process_line(@session, 'EHLO SEQUENCE', "\r\n")
    assert_raises(MidiSmtpServer::Smtpd503Exception) { @smtpd.process_line(@session, 'PROXY UNKNOWN TEST', "\r\n") }
  end

end
