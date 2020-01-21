# frozen_string_literal: true

# require the libraries
require_relative '../../lib/midi-smtp-server'

# overloaded midi-smtp-server class for test
class MidiSmtpServerTest < MidiSmtpServer::Smtpd

  def initialize(ports = MidiSmtpServer::DEFAULT_SMTPD_PORT, hosts = MidiSmtpServer::DEFAULT_SMTPD_HOST, max_processings = MidiSmtpServer::DEFAULT_SMTPD_MAX_PROCESSINGS, opts = {})
    # disable DEBUG log output
    opts[:logger_severity] = 5 # Logger::UNKNOWN
    # initialize
    super(ports, hosts, max_processings, opts)
  end

  # change visibilty for testing
  public :process_line
  public :process_reset_session
  public :process_auth_plain
  public :process_auth_login_user
  public :process_auth_login_pass

  # event vars to inspect
  attr_reader :ev_auth_authentication_id
  attr_reader :ev_auth_authentication
  attr_reader :ev_auth_authorization_id
  attr_reader :ev_message_data
  attr_reader :ev_message_delivered
  attr_reader :ev_message_bytesize

  def on_auth_event(_ctx, authorization_id, authentication_id, authentication)
    # save local event data
    @ev_auth_authentication_id = authentication_id
    @ev_auth_authentication = authentication
    # return role when authenticated
    if authorization_id == '' && authentication_id == 'administrator' && authentication == 'password'
      @ev_auth_authorization_id = 'supervisor'
      return @ev_auth_authorization_id
    end
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
