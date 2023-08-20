# frozen_string_literal: true

require 'midi-smtp-server'

# Server class
class MySmtpGw < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("mail received at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}], proxy #{ctx[:server][:proxy] || 'none'}, from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")
  end

end

# flush the log output immediately after each write operation
$stdout.sync = true

# Create a new server instance for listening
# If no ENV settings use default interfaces 127.0.0.1:2525
# Attention: 127.0.0.1 is not accessible in Docker container even when ports are exposed
server = MySmtpGw.new(
  ports: ENV.fetch('HAPROXY_GW_PORTS', MidiSmtpServer::DEFAULT_SMTPD_PORT),
  hosts: ENV.fetch('HAPROXY_GW_HOSTS', MidiSmtpServer::DEFAULT_SMTPD_HOST),
  max_processings: ENV.fetch('HAPROXY_GW_MAX_PROCESSINGS', '').to_s.empty? ? MidiSmtpServer::DEFAULT_SMTPD_MAX_PROCESSINGS : ENV.fetch('HAPROXY_GW_MAX_PROCESSINGS').to_i,
  proxy_extension: true,
  auth_mode: :AUTH_OPTIONAL,
  tls_mode: :TLS_FORBIDDEN,
  logger_severity: ENV.fetch('HAPROXY_GW_DEBUG', '').to_s.empty? ? Logger::INFO : Logger::DEBUG
)

# save flag for Ctrl-C pressed
flag_status_ctrl_c_pressed = false

# try to gracefully shutdown on Ctrl-C
trap('INT') do
  # print an empty line right after ^C
  puts
  # notify flag about Ctrl-C was pressed
  flag_status_ctrl_c_pressed = true
  # signal exit to app
  exit 0
end

# Output for debug
server.logger.info("Starting MySmtpGw [#{MidiSmtpServer::VERSION::STRING}|#{MidiSmtpServer::VERSION::DATE}] ...")

# setup exit code
at_exit do
  # check to shutdown connection
  if server
    # Output for debug
    server.logger.info('Ctrl-C interrupted, exit now...') if flag_status_ctrl_c_pressed
    # info about shutdown
    server.logger.info('Shutdown MySmtpGw...')
    # stop all threads and connections gracefully
    server.stop
  end
  # Output for debug
  server.logger.info('MySmtpGw down!')
end

# Start the server
server.start

# Run on server forever
server.join
