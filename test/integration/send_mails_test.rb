require 'mail'

# Unit test to check commands without TCP
class MailSendUnitTest < Minitest::Test

  # overloaded midi-smtp-server class for test
  class MidiSmtpServerSendMailsTest < MidiSmtpServerTest

    # event vars to inspect
    attr_reader :ev_auth_authentication_id
    attr_reader :ev_auth_authentication
    attr_reader :ev_message_data
    attr_reader :ev_message_delivered
    attr_reader :ev_message_bytesize

    def on_auth_event(_ctx, authorization_id, authentication_id, authentication)
      # save local event data
      @ev_auth_authentication_id = authentication_id
      @ev_auth_authentication = authentication
      # return role when authenticated
      return 'supervisor' if authorization_id == '' && authentication_id == 'administrator' && authentication == 'password'
      # otherwise exit with authentification exception
      raise MidiSmtpServer::Smtpd535Exception
    end

    def on_message_data_event(ctx)
      # save local event data
      @ev_message_data = ctx[:message][:data]
      @ev_message_delivered = ctx[:message][:delivered]
      @ev_message_bytesize = ctx[:message][:bytesize]
    end

  end

  # initialize before tests
  def setup
    # create some message vars and sources
    @envelope_mail_from = 'integration@local.local'
    @envelope_rcpt_to = 'out@local.local'
    @doc_simple_mail = read_message_data_from_file('../data/simple_mail.msg')
    # create service instance
    @smtpd = MidiSmtpServerSendMailsTest.new(
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

  def teardown
    @smtpd.stop
  end

  ### TEST SUITE

  def test_simple_send_1_mail
    net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail
    assert_equal @doc_simple_mail, @smtpd.ev_message_data
  end

  def test_simple_send_10_mails
    10.times do
      net_smtp_send_mail @envelope_mail_from, @envelope_rcpt_to, @doc_simple_mail
    end
    assert_equal @doc_simple_mail, @smtpd.ev_message_data
  end

  ### HELPERS

  def read_message_data_from_file(relative_filename)
    # convert message data to RFC conform CRLF message data
    File.read(File.join(__dir__, relative_filename)).delete("\r").gsub("\n", "\r\n")
  end

  def net_smtp_send_mail(envelope_mail_from, envelope_rcpt_to, message_data)
    # use Net::SMTP to connect and send message
    Net::SMTP.start('127.0.0.1', 5555) do |smtp|
      # when sending mails, send one additional crlf to safe the original linebreaks
      smtp.send_message(message_data + "\r\n", envelope_mail_from, envelope_rcpt_to)
    end
  end

end
