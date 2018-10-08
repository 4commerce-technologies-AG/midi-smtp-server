# Unit test to check commands without TCP

class ProcessLineUnitTest < Minitest::Test

  class MidiSmtpServerProcessLineTest < MidiSmtpServerTest

    # event vars to inspect
    attr_reader :ev_ctx_server_local_host
    attr_reader :ev_helo_data

    def on_helo_event(ctx, helo_data)
      @ev_ctx_server_local_host = ctx[:server][:local_host]
      @ev_helo_data = helo_data
    end

  end

  # Runs tests in alphabetical order, instead of random order.
  i_suck_and_my_tests_are_order_dependent!

  # initialize before tests
  def setup
    @smtpd = MidiSmtpServerProcessLineTest.new(
      '2525',
      '127.0.0.1',
      1,
      auth_mode: :AUTH_OPTIONAL,
      tls_mode: :TLS_OPTIONAL,
      pipelining_extension: false,
      internationalization_extensions: true
    )
    # prepare a session hash
    @session = {}
    @smtpd.process_reset_session(@session, true)
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

  def test_ehlo
    helo_str = 'Process line unit test'
    result = @smtpd.process_line(@session, "EHLO #{helo_str}")
    assert_equal "250-#{@session[:ctx][:server][:helo_response]}\r\n250-8BITMIME\r\n250-SMTPUTF8\r\n250-AUTH LOGIN PLAIN\r\n250-STARTTLS\r\n250 OK", result
    assert_equal @session[:ctx][:server][:helo], helo_str
    # check event values
    refute_empty @smtpd.ev_helo_data
    assert_equal @smtpd.ev_ctx_server_local_host, @session[:ctx][:server][:local_host]
  end

end
