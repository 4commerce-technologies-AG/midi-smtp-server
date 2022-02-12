# frozen_string_literal: true

# to test communictaion with ssl server use gnutls-cli tool
# > gnutls-cli --insecure -s -p 2525 127.0.0.1

require 'midi-smtp-server'
require 'mail'

# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  def on_process_line_unknown_event(ctx, line)
    # check
    raise MidiSmtpServer::Smtpd421Exception, 'Connection Abort: Too many unknown commands where sent!' if ctx[:server][:exceptions] >= 5
    # otherwise call the super method
    super
  end

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("mail reveived at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}] from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message ones to make sure, that this message ist readable
    mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message source
    logger.debug(mail.to_s)
  end

end

# Create a new server instance for listening at localhost interfaces 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections per default
server = MySmtpd.new(tls_mode: :TLS_OPTIONAL)

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
server.logger.info("Starting MySmtpd [#{MidiSmtpServer::VERSION::STRING}|#{MidiSmtpServer::VERSION::DATE}] (Encryption example) ...")

# setup exit code
at_exit do
  # check to shutdown connection
  if server
    # Output for debug
    server.logger.info('Ctrl-C interrupted, exit now...') if flag_status_ctrl_c_pressed
    # info about shutdown
    server.logger.info('Shutdown MySmtpd...')
    # stop all threads and connections gracefully
    server.stop
  end
  # Output for debug
  server.logger.info('MySmtpd down!')
end

# Start the server
server.start

# Run on server forever
server.join
