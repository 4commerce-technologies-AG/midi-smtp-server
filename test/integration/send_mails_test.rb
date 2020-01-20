# frozen_string_literal: true

require 'mail'

# Unit test to check commands without TCP
class SendMailsIntegrationTest < BaseIntegrationTest

  # initialize before tests
  def setup
    # create some message vars and sources
    super
    # create service instance
    @smtpd = MidiSmtpServerTest.new(
      '5555',
      '127.0.0.1',
      1,
      do_dns_reverse_lookup: false,
      auth_mode: :AUTH_OPTIONAL,
      tls_mode: :TLS_OPTIONAL,
      pipelining_extension: false,
      internationalization_extensions: true
    )
    # start the daemon to run real life integration tests
    @smtpd.start
  end

  ### TEST SUITE

  def test_net_smtp_simple_send_1_mail
    net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail
    assert_equal @doc_simple_mail, @smtpd.ev_message_data
  end

  def test_net_smtp_simple_send_10_mails
    10.times do
      net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail
    end
    assert_equal @doc_simple_mail, @smtpd.ev_message_data
  end

  def test_net_smtp_auth_plain_and_simple_send_1_mail
    net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail, 'administrator', 'password', :plain
    assert_equal @doc_simple_mail, @smtpd.ev_message_data
    assert_equal 'supervisor', @smtpd.ev_auth_authorization_id
  end

  def test_net_smtp_auth_login_and_simple_send_1_mail
    net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail, 'administrator', 'password', :login
    assert_equal @doc_simple_mail, @smtpd.ev_message_data
    assert_equal 'supervisor', @smtpd.ev_auth_authorization_id
  end

  def test_net_smtp_auth_plain_fail
    assert_raises(Net::SMTPAuthenticationError) { net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail, 'administrator', 'error_password', :plain }
  end

  def test_mikel_mail_simple_send_1_mail
    mikel_mail_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail
    assert_equal @doc_simple_mail, @smtpd.ev_message_data
  end

  def test_mikel_mail_simple_send_1_mail_starttls
    mikel_mail_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail, 'administrator', 'password', true
    assert_equal @doc_simple_mail, @smtpd.ev_message_data
    assert_equal 'supervisor', @smtpd.ev_auth_authorization_id
  end

end
