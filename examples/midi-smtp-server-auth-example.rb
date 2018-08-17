require 'midi-smtp-server'
require 'mail'

# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  def start
    # initialize and do your own initailizations

    # call inherited class method
    super
  end

  # check the authentification
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
      puts "Authenticated id: #{authentication_id} with authentication: #{authentication} from: #{ctx[:server][:remote_ip]}:#{ctx[:server][:remote_port]}"
      return 'supervisor'
    end
    # otherwise exit with authentification exception
    raise MidiSmtpServer::Smtpd535Exception
  end

  # get address send in MAIL FROM:
  # check status for authentication before process
  def on_mail_from_event(ctx, mail_from_data)
    if authenticated?(ctx)
      # yes
      puts "Proceed with authorized id: #{ctx[:server][:authorization_id]}"
      puts "and authentication id: #{ctx[:server][:authentication_id]}"
    else
      # no
      puts 'Proceed with anonymoous credentials'
    end
    # return the tested mail_from_data as mail to proceed
    mail_from_data
  end

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("[#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message ones to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message source
    logger.debug(@mail.to_s)
  end

end

# try to gracefully shutdown on Ctrl-C
trap('INT') do
  puts 'Interrupted, exit now...'
  exit 0
end

# Output for debug
puts "#{Time.now}: Starting MySmtpd (Authentication example) ..."

# Create a new server instance listening at localhost interfaces 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections
server = MySmtpd.new(MidiSmtpServer::DEFAULT_SMTPD_PORT, MidiSmtpServer::DEFAULT_SMTPD_HOST, MidiSmtpServer::DEFAULT_SMTPD_MAX_CONNECTIONS, auth_mode: :AUTH_OPTIONAL)

# setup exit code
at_exit do
  # check to shutdown connection
  if server
    # Output for debug
    puts "#{Time.now}: Shutdown MySmtpd..."
    # stop all threads and connections gracefully
    server.stop
  end
  # Output for debug
  puts "#{Time.now}: MySmtpd down!\n"
end

# Start the server
server.start

# Run on server forever
server.join
