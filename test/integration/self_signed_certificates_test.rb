# frozen_string_literal: true

class SelfSignedCertificateIntegrationTest < CertificateIntegrationTest

  def setup
    # define the certificates to use
    @use_cert_path = 'test-cert.srv.simple.pem'
    @use_key_path = 'test-cert.srv.key.pem'
    # run the test
    super
  end

  def test_net_smtp_auth_login_and_simple_send_1_mail_with_ssl
    do_net_smtp_auth_login_and_simple_send_1_mail_with_ssl
  end

end

class SelfSignedChainCertificateIntegrationTest < CertificateIntegrationTest

  def setup
    # define the certificates to use
    @use_cert_path = 'test-cert.srv.chain.pem'
    @use_key_path = 'test-cert.srv.key.pem'
    # run the test
    super
  end

  def test_net_smtp_auth_login_and_simple_send_1_mail_with_ssl
    do_net_smtp_auth_login_and_simple_send_1_mail_with_ssl
  end

end

class SelfSignedChainAndKeyCertificateIntegrationTest < CertificateIntegrationTest

  def setup
    # define the certificates to use
    @use_cert_path = 'test-cert.srv.chain-and-key.pem'
    @use_key_path = nil
    # run the test
    super
  end

  def test_net_smtp_auth_login_and_simple_send_1_mail_with_ssl
    do_net_smtp_auth_login_and_simple_send_1_mail_with_ssl
  end

end
