# simple example for midi-smtp-server lib
require "lib/midi-smtp-server"
require "mail"

# Server class
class MySmtpServer < MidiSmtpServer

  def start
    # initialize and do your own initailizations
    
    # call inherited class method
    super
  end

  # get event on HELO:
  def on_helo_event(helo_data, ctx)
    # Output for debug
    puts "#{Time.now}: #{ctx[:server][:remote_ip]} on helo event with data:"
    puts "[#{helo_data}]..."
  end

  # get address send in MAIL FROM:
  def on_mail_from_event(mail_from_data, ctx)
    # Output for debug
    puts "#{Time.now}: #{ctx[:server][:remote_ip]} on mail from event with data:"
    puts "[#{mail_from_data}]..."
  end

  # get each address send in RCPT TO:
  def on_rcpt_to_event(rcpt_to_data, ctx)
    # Output for debug
    puts "#{Time.now}: #{ctx[:server][:remote_ip]} on rcpt to event with data:"
    puts "[#{rcpt_to_data}]..."
  end

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    puts "#{Time.now}: #{ctx[:server][:remote_ip]} on message data event with sender:"
    puts "[#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]..."

    # Just decode message ones to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message])

    # handle incoming mail, just show the message source
    puts @mail.to_s

  end

end

# Output for debug
puts "#{Time.now}: Starting MySmtpServer..."

# Create a new server instance listening at all interfaces *:2525
# and accepting a maximum of 5 simultaneous connections
server = MySmtpServer.new

# we want smtp-server-dialog-logging enabled
server.audit = true

# Start the server
server.start

# wait a second
sleep 1

# Output for debug
puts "#{Time.now}: Ready for connections"

# Run on server forever
server.join

# setup exit code
BEGIN {
  at_exit {
    # check to shutdown connection
    if server
      # Output for debug
      puts "#{Time.now}: Shutdown MySmtpServer..."
      # gracefully connections down
      server.shutdown
      # check once if some connection(s) need(s) more time
      sleep 2 unless server.connections == 0 
      # stop all threads and connections
      server.stop
      # Output for debug
      puts "#{Time.now}: MySmtpServer stopped!"
    end
    # Output for debug
    puts "#{Time.now}: MySmtpServer down!"
  }
}
