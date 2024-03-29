# frozen_string_literal: true

# Unit test to check commands without TCP
class BaseIntegrationTest < Minitest::Test

  # initialize before tests
  def setup
    # create some message vars and sources
    @envelope_mail_from = 'integration@local.local'
    @envelope_rcpt_to = 'out@local.local'
    @doc_simple_mail = read_message_data_from_file('../data/simple_mail.msg')
  end

  def teardown
    @smtpd.stop
  end

  ### HELPERS

  def read_message_data_from_file(relative_filename)
    # convert message data to RFC conform CRLF message data
    File.read(File.join(__dir__, relative_filename)).delete("\r").gsub("\n", "\r\n")
  end

  def net_smtp_send_mail(envelope_mail_from, envelope_rcpt_to, message_data, authentication_id: nil, password: nil, auth_type: nil, tls_enabled: false)
    # to verify peer from self signed certificates put the certificate and chain into the client store
    store = OpenSSL::X509::Store.new
    if @smtpd.ssl_context
      store.add_cert(@smtpd.ssl_context.cert)
      @smtpd.ssl_context.extra_chain_cert&.each { |c| store.add_cert(c) }
    end

    # use Net::SMTP to connect and send message
    smtp = Net::SMTP.new('127.0.0.1', 5555)

    if tls_enabled
      smtp.enable_starttls
      smtp.ssl_context_params = { cert_store: store, verify_mode: OpenSSL::SSL::VERIFY_PEER }
    else
      smtp.ssl_context_params = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    end

    smtp.start('Integration Test client', authentication_id, password, auth_type) do
      # when sending mails, send one additional crlf to safe the original linebreaks
      smtp.send_message("#{message_data}\r\n", envelope_mail_from, envelope_rcpt_to)
    end
  end

  def mikel_mail_send_mail(_envelope_mail_from, _envelope_rcpt_to, message_data, authentication_id: nil, password: nil, enable_starttls: false)
    # to verify peer from self signed certificates put the certificate and chain into the client store
    store = OpenSSL::X509::Store.new
    if @smtpd.ssl_context
      store.add_cert(@smtpd.ssl_context.cert)
      @smtpd.ssl_context.extra_chain_cert&.each { |c| store.add_cert(c) }
    end

    m = Mail.read_from_string("#{message_data}\r\n")

    m.delivery_method \
      :smtp,
      address: '127.0.0.1',
      user_name: authentication_id,
      password: password,
      port: 5555,
      enable_starttls_auto: false,
      enable_starttls: enable_starttls,
      openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
      ssl_context_params: { cert_store: store, verify_mode: OpenSSL::SSL::VERIFY_PEER }

    m.deliver
  end

end
