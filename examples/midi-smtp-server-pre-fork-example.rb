# frozen_string_literal: true

require 'midi-smtp-server'
require 'mail'

# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("mail reveived at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}] from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message once to make sure, that this message ist readable
    mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message source
    logger.debug(mail.subject)
  end

end

# Create a new server instance for listening at localhost interfaces 127.0.0.1:2525
# using 2 forks and accepting a maximum of 4 simultaneous connections per default per fork
server = MySmtpd.new(pre_fork: 2)

# save flag for Ctrl-C pressed
flag_status_ctrl_c_pressed = false

# try to gracefully shutdown on Ctrl-C if parent process
trap(:INT) do
  if server&.parent?
    # print an empty line right after ^C
    puts
    # notify flag about Ctrl-C was pressed
    flag_status_ctrl_c_pressed = true
    # signal exit to app
    exit 0
  end
end

# Output for debug
server.logger.info("Starting MySmtpd [#{MidiSmtpServer::VERSION::STRING}|#{MidiSmtpServer::VERSION::DATE}] (Simple example) ...")

# setup exit code
at_exit do
  # shutdown the main process
  if server&.parent?
    # Output for debug
    server.logger.info('Ctrl-C interrupted, exit now...') if flag_status_ctrl_c_pressed
    # info about shutdown
    server.logger.info('Shutdown MySmtpd...')
    # stop all threads and connections gracefully
    server.stop
    # Output for debug
    server.logger.info('MySmtpd down!')
  else
    # shutdown the forked child and disconnect all threads and close connections gracefully
    server.stop
  end
end

# Start the server
server.start

# Run on server forever
server.join
