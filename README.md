# midi-smtp-server

MidiSmtpServer is a small and highly customizable ruby SMTP-Server inspired from the work and code written by [Aaron Gough](https://github.com/aarongough) and [Peter Cooper](http://peterc.org/). As a library it is mainly designed to be integrated into your projects as serving a SMTP-Server service. The lib will do nothing with your mail and you have to create your own event functions to handle and operate on incoming mails. We are using this in conjunction with [Mikel Lindsaar](https://github.com/mikel) great Mail component (https://github.com/mikel/mail). Time to run your own SMTP-Server service.

With version 2.0 the library got a lot of improvements. I suggest everybody using MidiSmtpServer 1.x to switch to 2.x. You may follow the guide (see appendix) how to change your existing code to be compatible with the new release.


## Using the library

To create your own SMTP-Server service simply do by:

```ruby
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
```


## Installation

MidiSmtpServer is packaged as a RubyGem so that you can easily install by entering following at your command line:

  `gem install midi-smtp-server`

Use the component in your project sources by:

  `require 'midi-smtp-server'`


## Customizing the server

MidiSmtpServer can be easy customized via subclassing. Simply subclass the `MidiSmtpServer` class as given in the example above and re-define event handlers:

```ruby
  # get event on CONNECTION
  def on_connect_event(ctx)
  end

  # get event before DISONNECT
  def on_disconnect_event(ctx)
  end

  # get event on HELO:
  def on_helo_event(ctx, helo_data)
  end

  # get address send in MAIL FROM:
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used 
  def on_mail_from_event(ctx, mail_from_data)
  end

  # get each address send in RCPT TO:
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used 
  def on_rcpt_to_event(ctx, rcpt_to_data)
  end

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
  end
```


## Modifying MAIL FROM and RCPT TO addresses

Since release `1.1.4` the `on_mail_from_event` and `on_rcpt_to_event` allows to return values that should be added to the lists. This is useful if you want to e.g. normalize all incoming addresses. Format defined by RFC for `<path>` as a `MAIL FROM` or `RCPT TO` addresses is:

```
  "<" | <path> | ">"
```

Most of the mail servers today allows also `<path>` only given addresses without leading and ending `< >`.

To make it easier for processing addresses, you are able to normalize them like:

```ruby
  # simple rewrite and return value
  def on_mail_from_event(ctx, mail_from_data)
    # strip and normalize addresses like: <path> to path
    mail_from_data.gsub!(/^\s*<\s*(.*)\s*>\s*$/, '\1')
    # we believe in downcased addresses
    mail_from_data.downcase!
    # return address
    return mail_from_data
  end

  # rewrite, process more checks and return value
  def on_rcpt_to_event(ctx, rcpt_to_data)
    # strip and normalize addresses like: <path> to path
    rcpt_to_data.gsub!(/^\s*<\s*(.*)\s*>\s*$/, '\1')
    # we believe in downcased addresses
    rcpt_to_data.downcase!
    # Output for debug
    puts "Normalized to: [#{rcpt_to_data}]..." 
    # return address
    return rcpt_to_data
  end
```


## Responding with errors on special conditions

If you return from event class without an exception, the server will respond to client with the appropriate success code, otherwise the client will be noticed about an error.

So you can build SPAM protection, when raising exception while getting `RCPT TO` events.

```ruby
  # get each address send in RCPT TO:
  def on_rcpt_to_event(rcpt_to_data, ctx)
    raise MidiSmtpServer::Smtpd550Exception if rcpt_to_data == "not.name@domain.con"
  end
```

You are able to use exceptions on any level of events, so for an example you could raise an exception on `on_message_data_event` if you checked attachments for a pdf-document and fail or so on. If you use the defined `MidiSmtpServer::Smtpd???Exception` classes the remote client get's correct SMTP Server results. For logging purpose the default Exception.message is written to log.

Please check RFC821 for correct response dialog sequences:

```
COMMAND-REPLY SEQUENCES

   Each command is listed with its possible replies.  The prefixes
   used before the possible replies are "P" for preliminary (not
   used in SMTP), "I" for intermediate, "S" for success, "F" for
   failure, and "E" for error.  The 421 reply (service not
   available, closing transmission channel) may be given to any
   command if the SMTP-receiver knows it must shut down.  This
   listing forms the basis for the State Diagrams in Section 4.4.

CONNECTION ESTABLISHMENT
   S: 220
   F: 421
HELO
   S: 250
   E: 500, 501, 504, 421
MAIL
   S: 250
   F: 552, 451, 452
   E: 500, 501, 421
RCPT
   S: 250, 251
   F: 550, 551, 552, 553, 450, 451, 452
   E: 500, 501, 503, 421
DATA
   I: 354 -> data -> S: 250
                     F: 552, 554, 451, 452
   F: 451, 554
   E: 500, 501, 503, 421
RSET
   S: 250
   E: 500, 501, 504, 421
NOOP
   S: 250
   E: 500, 421
QUIT
   S: 221
   E: 500
```


## Access to server values and context

You can access some important client and server values by using the `ctx` array when in event methods:

```ruby
  # helo string
  ctx[:server][:helo]

  # local (server's) infos
  ctx[:server][:local_ip]
  ctx[:server][:local_host]
  ctx[:server][:local_port]

  # remote (client) infos
  ctx[:server][:remote_ip]
  ctx[:server][:remote_host]
  ctx[:server][:remote_port]

  # connection timestampe
  ctx[:server][:connected]
  
  # envelope mail from
  ctx[:envelope][:from]
  
  # envelope rcpt_to array
  ctx[:envelope][:to][0]

  # access message in on_message_data_event
  ctx[:message][:delivered]
  ctx[:message][:bytesite]
  ctx[:message][:data]

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


## New to version 2.x

1. Modulelized  
2. Removed dependency to GServer  
3. Additional events to interact with
4. Use logger to log several messages from severity :debug up to :fatal 


## From version 1.x to 2.x

If you are already using MidiSmtpServer at a release 1.x it might be only some straight forward work to get your code work with version 2.x.

#### Class

##### 1.x

```ruby
  MidiSmtpServer.new
```

##### 2.x

```ruby
  MidiSmtpServer::Smtpd.new
```

#### Class initialize

##### 1.x

```ruby
  def initialize(port = 2525, host = "127.0.0.1", max_connections = 4, do_smtp_server_reverse_lookup = true, *args)
```

##### 2.x

```ruby
  def initialize(port = DEFAULT_SMTPD_PORT, host = DEFAULT_SMTPD_HOST, max_connections = 4, opts = {})
  # opts may include
  opts = { do_dns_reverse_lookup: true }
  opts = { logger: myLoggerObject }
```

#### On_event arguments order

##### 1.x

```ruby
  def on_helo_event(helo_data, ctx)
  def on_mail_from_event(mail_from_data, ctx)
  def on_rcpt_to_event(rcpt_to_data, ctx)
```

##### 2.x

```ruby
  def on_helo_event(ctx, helo_data)
  def on_mail_from_event(ctx, mail_from_data)
  def on_rcpt_to_event(ctx, rcpt_to_data)
```

#### Exceptions

##### 1.x

```ruby
  MidiSmtpServerException
  MidiSmtpServer???Exception
```

##### 2.x

```ruby
  MidiSmtpServer::SmtpdException
  MidiSmtpServer::Smtpd???Exception
```

#### Removed elements

##### 1.x

```ruby
  # class vars from gserver
  audit
  debug
```

##### 2.x

```ruby
  # not available anymore, is now controlled vy Logger
```


## Package

You can find, use and download the gem package from [RubyGems.org](http://rubygems.org/gems/midi-smtp-server)

[![Gem Version](https://badge.fury.io/rb/midi-smtp-server.svg)](http://badge.fury.io/rb/midi-smtp-server)


### Author & Credits

Author: [Tom Freudenberg](http://about.me/tom.freudenberg)

[MidiSmtpServer Class](https://github.com/4commerce-technologies-AG/midi-smtp-server/) is inspired from [MiniSmtpServer Class](https://github.com/aarongough/mini-smtp-server) and code originally written by [Aaron Gough](https://github.com/aarongough) and [Peter Cooper](http://peterc.org/)

Copyright (c) 2014-2015 [Tom Freudenberg](http://www.4commerce.de/), [4commerce technologies AG](http://www.4commerce.de/), released under the MIT license
