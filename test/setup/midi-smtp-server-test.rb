# require the libraries
require_relative '../../lib/midi-smtp-server'

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

end
