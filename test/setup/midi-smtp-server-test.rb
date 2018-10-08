# require the libraries
require_relative "../../lib/midi-smtp-server"

class MidiSmtpServerTest < MidiSmtpServer::Smtpd

  # disable DEBUG log output
  def initialize(ports = MidiSmtpServer::DEFAULT_SMTPD_PORT, hosts = MidiSmtpServer::DEFAULT_SMTPD_HOST, max_connections = MidiSmtpServer::DEFAULT_SMTPD_MAX_CONNECTIONS, opts = {})
    super
    logger.level = Logger::UNKNOWN
  end

end
