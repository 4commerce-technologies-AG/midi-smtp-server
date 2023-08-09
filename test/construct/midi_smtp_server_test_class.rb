# frozen_string_literal: true

# require the libraries
require 'midi-smtp-server'

# overloaded midi-smtp-server class for test
class MidiSmtpServerTest < MidiSmtpServer::Smtpd

  def initialize(
    ports: MidiSmtpServer::DEFAULT_SMTPD_PORT,
    hosts: MidiSmtpServer::DEFAULT_SMTPD_HOST,
    pre_fork: MidiSmtpServer::DEFAULT_SMTPD_PRE_FORK,
    max_processings: MidiSmtpServer::DEFAULT_SMTPD_MAX_PROCESSINGS,
    max_connections: nil,
    crlf_mode: nil,
    do_dns_reverse_lookup: nil,
    io_waitreadable_sleep: nil,
    io_cmd_timeout: nil,
    io_buffer_chunk_size: nil,
    io_buffer_max_size: nil,
    proxy_extension: nil,
    pipelining_extension: nil,
    internationalization_extensions: nil,
    auth_mode: nil,
    tls_mode: nil,
    tls_cert_path: nil,
    tls_key_path: nil,
    tls_ciphers: nil,
    tls_methods: nil,
    tls_cert_cn: nil,
    tls_cert_san: nil,
    logger: nil,
    logger_severity: nil
  )
    # logger for counting errors during tests if necessary
    @ev_fail_counter = 0

    # disable DEBUG log output as default
    logger_severity = 5 if logger_severity.nil? # Logger::UNKNOWN

    # initialize
    super(
      ports: ports,
      hosts: hosts,
      pre_fork: pre_fork,
      max_processings: max_processings,
      max_connections: max_connections,
      crlf_mode: crlf_mode,
      do_dns_reverse_lookup: do_dns_reverse_lookup,
      io_waitreadable_sleep: io_waitreadable_sleep,
      io_cmd_timeout: io_cmd_timeout,
      io_buffer_chunk_size: io_buffer_chunk_size,
      io_buffer_max_size: io_buffer_max_size,
      proxy_extension: proxy_extension,
      pipelining_extension: pipelining_extension,
      internationalization_extensions: internationalization_extensions,
      auth_mode: auth_mode,
      tls_mode: tls_mode,
      tls_cert_path: tls_cert_path,
      tls_key_path: tls_key_path,
      tls_ciphers: tls_ciphers,
      tls_methods: tls_methods,
      tls_cert_cn: tls_cert_cn,
      tls_cert_san: tls_cert_san,
      logger: logger,
      logger_severity: logger_severity
    )
  end

  # change visibility for testing
  public :process_line
  public :process_reset_session
  public :process_auth_plain
  public :process_auth_login_user
  public :process_auth_login_pass

  # event vars to inspect
  attr_reader :ev_fail_counter
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
    if authorization_id == '' && authentication_id.start_with?('administrator') && authentication == 'password'
      @ev_auth_authorization_id = 'supervisor'
      return @ev_auth_authorization_id
    end
    # otherwise exit with authentication exception
    raise MidiSmtpServer::Smtpd535Exception
  end

  def on_message_data_event(ctx)
    # save local event data
    @ev_message_data = ctx[:message][:data]
    @ev_message_delivered = ctx[:message][:delivered]
    @ev_message_bytesize = ctx[:message][:bytesize]
  end

end
