<h2>Basic usage</h2>

To derive your own SMTP-Server service with DATA processing simply do:

```rb
# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("[#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message once to make sure, that this message ist readable
    mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message subject
    logger.debug(mail.subject)
  end

end
```

<br>

<h2>Operation purposes</h2>

As already introduced, there is an endless field of application for SMTP&nbsp;services. Create your own SMTP&nbsp;Server as a mail&nbsp;gateway to clean up routed emails from spam and virus content or process incoming mails by your proper functions. Create your forwarding service to put messages into a service like Slack, Trello, Redmine, Twitter, Facebook, Instagram and others.

This source code shows the example to receive messages via SMTP and store them to RabbitMQ (Message-Queue-Server) for subsequent processings etc.:

```rb
  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Just decode message once to make sure, that this message ist readable
    mail = Mail.read_from_string(ctx[:message])

    # Publish to rabbit
    @bunny_exchange.publish(mail.to_s, :headers => { 'x-smtp' => mail.header.to_s }, :routing_key => "to_queue")
  end
```

<br>

<h2>Working examples</h2>

This is a fully functional starter for a SMTP-Server service with DATA processing:

```rb
# frozen_string_literal: true

require 'midi-smtp-server'

# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("mail received at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}] from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # handle incoming mail, just show the message source
    logger.debug(ctx[:message][:data])
  end

end

# Create a new server instance for listening at localhost interfaces 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections per default
server = MySmtpd.new

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
server.logger.info("Starting MySmtpd [#{MidiSmtpServer::VERSION::STRING}|#{MidiSmtpServer::VERSION::DATE}] (Basic usage) ...")

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
```

<br>

!!! Note

    You will find a number of ready to use examples at [GitHub/MidiSmtpServer/Examples](https://github.com/4commerce-technologies-AG/midi-smtp-server/tree/master/examples).

<br>
