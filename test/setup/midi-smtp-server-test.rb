# require the libraries
require_relative '../../lib/midi-smtp-server'

class MidiSmtpServerTest < MidiSmtpServer::Smtpd

  # disable DEBUG log output
  def initialize(ports = MidiSmtpServer::DEFAULT_SMTPD_PORT, hosts = MidiSmtpServer::DEFAULT_SMTPD_HOST, max_connections = MidiSmtpServer::DEFAULT_SMTPD_MAX_CONNECTIONS, opts = {})
    super
    logger.level = Logger::UNKNOWN
  end

  # change visibilty for testing
  public :process_line
  public :process_reset_session
  public :process_auth_plain
  public :process_auth_login_user
  public :process_auth_login_pass

end
