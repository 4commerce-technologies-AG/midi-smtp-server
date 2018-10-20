<h2>Basic usage</h2>

To create your own SMTP-Server service with DATA processing use this starter file:

```rb
require 'midi-smtp-server'

# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("mail reveived at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}] from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")
    # handle incoming mail, just show the message source
    logger.debug(ctx[:message][:data])
  end

end

# try to gracefully shutdown on Ctrl-C
trap('INT') do
  puts 'Interrupted, exit now...'
  exit 0
end

# Output for debug
puts "#{Time.now}: Starting MySmtpd [#{MidiSmtpServer::VERSION::STRING}|#{MidiSmtpServer::VERSION::DATE}] (Basic usage) ..."

# Create a new server instance listening at localhost interfaces 127.0.0.1:2525
# and processing a maximum of 4 simultaneous sessions
server = MySmtpd.new

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
```

<br>

!!! Note

    You will find a number of ready to use examples at [GitHub/MidiSmtpServer/Examples](https://github.com/4commerce-technologies-AG/midi-smtp-server/tree/master/examples).

<br>
