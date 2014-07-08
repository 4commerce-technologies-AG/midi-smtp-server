# midi-smtp-server

MidiSmtpServer is a small and highly customizable ruby SMTP-Server inspired from the work and code written by [Aaron Gough](https://github.com/aarongough) and [Peter Cooper](http://peterc.org/). As a library it is mainly designed to be integrated into your projects as serving a SMTP-Server service. The lib will do nothing with your mail and you have to create your own event functions to handle and operate on incoming mails. We are using this in conjunction with [Mikel Lindsaar](https://github.com/mikel) great Mail component (https://github.com/mikel/mail). Time to run your own SMTP-Server service.


## Using the library

To create your own SMTP-Server service simply do by:

```ruby
require "midi-smtp-server"
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
```

## Installation

MidiSmtpServer is packaged as a RubyGem so that you can easily install by entering following at your command line:

  `gem install midi-smtp-server`

Use the component in your project sources by:

  `require 'midi-smtp-server'`


## Customizing the server

MidiSmtpServer can be easy customized via subclassing. Simply subclass the `MidiSmtpServer` class as given in the example above and re-define event handlers:

```ruby
  # get event on HELO:
  def on_helo_event(helo_data, ctx)
  end

  # get address send in MAIL FROM:
  def on_mail_from_event(mail_from_data, ctx)
  end

  # get each address send in RCPT TO:
  def on_rcpt_to_event(rcpt_to_data, ctx)
  end

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
  end
```


## Responding with errors on special conditions

If you return from event class without an exception, the server will respond to client with the appropriate success code, otherwise the client will be noticed about an error.

So you can build SPAM protection, when raising exception while getting `RCPT TO` events.

```ruby
  # get each address send in RCPT TO:
  def on_rcpt_to_event(rcpt_to_data, ctx)
    raise "This address ist not allowed" if rcpt_to_data == "not.name@domain.con"
  end
```

You are able to use exceptions on any level of events, so for an example you could raise an exception on `on_message_data_event` if you checked attachments for a pdf-document and fail or so on.

In case of exceptions, the remote client is noticed about its false transport.

_Currently we are only sending success or ONE false code corresponding to the SMTP state._


## Access to server values and context

You can access some important client and server values by using the `ctx` array when in event methods:

```ruby
  # helo string
  ctx[:helo]

  # local (server's) infos
  ctx[:server][:local_ip]
  ctx[:server][:local_host]
  ctx[:server][:local_port]

  # remote (client) infos
  ctx[:server][:remote_ip]
  ctx[:server][:remote_host]
  ctx[:server][:remote_port]
  
  # envelope mail from
  ctx[:envelope][:from]
  
  # envelope rcpt_to array
  ctx[:envelope][:to][0]

  # access messag in on on_message_data_event
  ctx[:message]
```


## Endless possibilities

We created a SMTP-Server e.g. to receive messages vie SMTP and store them to RabbitMQ Message-Queue-Server:

```ruby
  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Just decode message ones to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message])
    # Publish to rabbit
    @bunny_exchange.publish(@mail.to_s, :headers => { 'x-smtp' => @mail.header.to_s }, :routing_key => "to_queue")
  end
```


## Package

You can find, use and download the gem package from [RubyGems.org](http://rubygems.org/gems/midi-smtp-server)


### Author & Credits

Author: [Tom Freudenberg](http://about.me/tom.freudenberg)

MidiSmtpServer Class is inspired from [MiniSmtpServer Class](https://github.com/aarongough/mini-smtp-server) and code originally written by [Aaron Gough](https://github.com/aarongough) and [Peter Cooper](http://peterc.org/)

Copyright (c) 2014 [Tom Freudenberg](http://www.4commerce.de/), [4commerce technologies AG](http://www.4commerce.de/), released under the MIT license
