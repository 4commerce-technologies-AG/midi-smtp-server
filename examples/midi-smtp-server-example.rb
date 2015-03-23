require "midi-smtp-server"
require "mail"

# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  def start
    # initialize and do your own initailizations
    
    # call inherited class method
    super
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

# Output for debug
puts "#{Time.now}: Starting MySmtpd..."

# Create a new server instance listening at all interfaces *:2525
# and accepting a maximum of 4 simultaneous connections
server = MySmtpd.new

# Start the server
server.start

# wait a second
sleep 1

# Run on server forever
server.join

# setup exit code
BEGIN {
  at_exit {
    # check to shutdown connection
    if server
      # Output for debug
      puts "#{Time.now}: Shutdown MySmtpd..."
      # gracefully connections down
      server.shutdown
      # check once if some connection(s) need(s) more time
      sleep 2 unless server.connections == 0 
      # stop all threads and connections
      server.stop
    end
    # Output for debug
    puts "#{Time.now}: MySmtpd down!"
  }
}
