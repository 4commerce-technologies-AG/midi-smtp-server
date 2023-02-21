# frozen_string_literal: true

# Unit test to check commands without TCP
class CertificateIntegrationTest < BaseIntegrationTest

  # allow usage of different certificates by setting this properties
  attr_accessor :use_cert_path, :use_key_path

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
      tls_cert_path: File.join(__dir__, '../data', @use_cert_path),
      tls_key_path: @use_key_path.nil? ? nil : File.join(__dir__, '../data', @use_key_path),
      pipelining_extension: false,
      internationalization_extensions: true
    )
    # start the daemon to run real life integration tests
    @smtpd.start
  end

  ### TEST SUITE

  def helper_net_smtp_auth_login_and_simple_send_1_mail_with_ssl
    net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail, authentication_id: 'administrator', password: 'password', auth_type: :login, tls_enabled: true

    assert_equal @doc_simple_mail, @smtpd.ev_message_data
    assert_equal 'supervisor', @smtpd.ev_auth_authorization_id
  end

end
