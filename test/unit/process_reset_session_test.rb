class ResetSessionUnitTest < Minitest::Test

  # initialize before tests
  def setup
    @smtpd = MidiSmtpServerTest.new
    @session = {}
  end

  def test_process_reset_session_helo
    @smtpd.process_reset_session(@session, true)
    assert_equal :CMD_HELO, @session[:cmd_sequence]
  end

  def test_process_reset_session_rset
    @smtpd.process_reset_session(@session, false)
    assert_equal :CMD_RSET, @session[:cmd_sequence]
  end

end
