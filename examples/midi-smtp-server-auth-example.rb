# frozen_string_literal: true

require 'midi-smtp-server'
require 'mail'

# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  # check the authentication
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used for authorization_id
  def on_auth_event(ctx, authorization_id, authentication_id, authentication)
    # to proceed this test use commands ...
    # auth plain
    # > AGFkbWluaXN0cmF0b3IAcGFzc3dvcmQ=
    # auth login
    # > YWRtaW5pc3RyYXRvcg==
    # > cGFzc3dvcmQ=
    if authorization_id == '' && authentication_id == 'administrator' && authentication == 'password'
      # yes
      logger.debug("Authenticated id: #{authentication_id} with authentication: #{authentication} from: #{ctx[:server][:remote_ip]}:#{ctx[:server][:remote_port]}")
      return 'supervisor'
    end
    # otherwise exit with authentication exception
    raise MidiSmtpServer::Smtpd535Exception
  end

  # get address send in MAIL FROM:
  # check status for authentication before process
  def on_mail_from_event(ctx, mail_from_data)
    if authenticated?(ctx)
      # yes
      logger.debug("Proceed with authorized id: #{ctx[:server][:authorization_id]}")
      logger.debug("and authentication id: #{ctx[:server][:authentication_id]}")
    else
      # no
      logger.debug('Proceed with anonymous credentials')
    end
    # return the tested mail_from_data as mail to proceed
    mail_from_data
  end

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("mail received at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}] from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message once to make sure, that this message ist readable
    mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message source
    logger.debug(mail.to_s)
  end

end

# Create a new server instance for listening at localhost interfaces 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections per default
server = MySmtpd.new(auth_mode: :AUTH_OPTIONAL)

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
server.logger.info("Starting MySmtpd [#{MidiSmtpServer::VERSION::STRING}|#{MidiSmtpServer::VERSION::DATE}] (Authentication example) ...")

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
