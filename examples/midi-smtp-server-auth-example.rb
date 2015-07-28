require "../lib/midi-smtp-server.rb"
require "mail"
require "byebug"

IP_ADDR = "127.0.0.1"
PORT = 2525
MAX_CONNECTIONS = 4
OPTS = {
  :users_path => "./users"
}

class MySmtpd < MidiSmtpServer::Smtpd
  def start
    super
  end

  def on_message_data_event(ctx)
    raise MidiSmtpServer::Smtpd535Exception if(ctx[:is_authenticated] == nil)
    # Output for debug
    logger.debug("[#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message ones to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message source
    logger.debug(@mail.to_s)
  end
end

puts "#{Time.now}: Starting MySmtpd..."

server = MySmtpd.new(PORT, IP_ADDR, MAX_CONNECTIONS, OPTS)
server.start
sleep 1
server.join

BEGIN {
  at_exit {
    if server
      puts "#{Time.now}: Shutdown MySmtpd..."
      server.shutdown
      sleep 2 unless server.connections == 0
      server.stop
    end

    puts "#{Time.now}: MySmtpd down!"
  }
}
