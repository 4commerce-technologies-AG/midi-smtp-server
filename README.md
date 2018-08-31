# midi-smtp-server

MidiSmtpServer is a small and highly customizable ruby SMTP-Server inspired from the work and code written by [Aaron Gough](https://github.com/aarongough) and [Peter Cooper](http://peterc.org/). As a library it is mainly designed to be integrated into your projects as serving a SMTP-Server service. The lib will do nothing with your mail and you have to create your own event functions to handle and operate on incoming mails. We are using this in conjunction with [Mikel Lindsaar](https://github.com/mikel) great Mail component (https://github.com/mikel/mail). Time to run your own SMTP-Server service.

With version 2.x the library gots a lot of improvements (2.2.x Encryption [StartTLS], 2.1 Authentication [AUTH], 2.1.1 significant speed improvement, etc.). We suggest everybody using MidiSmtpServer 1.x or 2.x to switch at least to 2.2.3. For upgrades from version 1.x you may follow the guide (see appendix) how to change your existing code to be compatible with the new release.


## Using the library

To create your own SMTP-Server service simply do by:

```ruby
require 'midi-smtp-server'
require 'mail'

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

# try to gracefully shutdown on Ctrl-C
trap('INT') do
  puts 'Interrupted, exit now...'
  exit 0
end

# Output for debug
puts "#{Time.now}: Starting MySmtpd..."

# Create a new server instance listening at localhost interfaces 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections
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


## Installation

MidiSmtpServer is packaged as a RubyGem so that you can easily install by entering following at your command line:

  `gem install midi-smtp-server`

Use the component in your project sources by:

  `require 'midi-smtp-server'`


## Customizing the server

MidiSmtpServer can be easy customized via subclassing. Simply subclass the `MidiSmtpServer` class as given in the example above and re-define event handlers:

```ruby
  # event on CONNECTION
  def on_connect_event(ctx)
  end

  # event before DISONNECT
  def on_disconnect_event(ctx)
  end

  # event on HELO/EHLO:
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

  # event while receiving message DATA
  def on_message_data_receiving_event(ctx)
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

Most mail servers allows also `<path>` only given addresses without leading and ending `< >`.

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
  def on_rcpt_to_event(ctx, rcpt_to_data)
    raise MidiSmtpServer::Smtpd550Exception if rcpt_to_data == "not.name@domain.con"
  end
```

You are able to use exceptions on any level of events, so for an example you could raise an exception on `on_message_data_event` if you checked attachments for a pdf-document and fail or so on. If you use the defined `MidiSmtpServer::Smtpd???Exception` classes the remote client get's correct SMTP Server results. For logging purpose the default Exception.message is written to log.

When using `MidiSmtpServer::Smtpd421Exception` you are able to abort the active connection to the client by replying `421 Service not available, closing transmission channel`. Be aware, that this Exception will actively close the current connection to the client. For logging purposes you may append a message to yourself, this will not be transmitted to the client.

```ruby
  # drop connection immediately on SPAM
  def on_rcpt_to_event(ctx, rcpt_to_data)
    raise MidiSmtpServer::Smtpd421Exception.new("421 Abort: Identified spammer!") if rcpt_to_data == "not.name@domain.con"
  end
```

Please check RFC821 and additional for correct response dialog sequences:

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
AUTH
   S: 235
   F: 530, 534, 535, 454
   E: 500, 421
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

  # connection timestamp (utc)
  ctx[:server][:connected]

  # authentification infos
  ctx[:server][:authorization_id]
  ctx[:server][:authentication_id]

  # successful authentication timestamp (utc)
  ctx[:server][:authenticated]

  # timestamp (utc) when encryption was established
  ctx[:server][:encrypted]

  # envelope mail from
  ctx[:envelope][:from]

  # envelope rcpt_to array
  ctx[:envelope][:to][0]

  # timestamp (utc) when message data was completly received
  ctx[:message][:delivered]

  # access message in on_message_data_event and on_message_data_receiving_event
  ctx[:message][:bytesize]
  ctx[:message][:data]

```


## Incoming data validation

With release 2.2.3 there is an extended control about incoming data before processing. New options allow to set a timeout and maximum size of io_buffer for receiving client data up to a complete data line.

```ruby
# timeout in seconds before a data line has to be completely sent by client or connection abort
opts = { io_cmd_timeout: DEFAULT_IO_CMD_TIMEOUT }

# maximum size in bytes to read in buffer for a complete data line from client or connection abort
opts = { io_buffer_max_size: DEFAULT_IO_BUFFER_MAX_SIZE }
```

There is also a new event which may be used to handle the incoming transmission of message data.

As an example: abort when message data is going to exceed a maximum size:

```ruby
  # event while receiving message DATA
  def on_message_data_receiving_event(ctx)
    raise MidiSmtpServer::Smtpd552Exception if ctx[:message][:data].bytesize > MAX_MSG_SIZE
  end
```

Or to implement something like a Teergrube for spammers etc.:

```ruby
  # event while receiving message DATA
  def on_message_data_receiving_event(ctx)
    # don't allow the spammer to continue fast
    # let him wait always 15 seconds before sending next data line
    sleep 15 if ctx[:server][:helo] =~ /domain/
  end
```

Or to check already the message headers before receiving the complete message data. And lots more.


## Authentication support

There is built-in authentication support for `AUTH LOGIN` and `AUTH PLAIN` since release `2.1.0`. If you want to enable authentication you have to set the appropriate value to `auth_mode` opts.

Allowed values are:

```ruby
# no authentication is allowed (mostly for internal services)
opts = { auth_mode: :AUTH_FORBIDDEN }

# authentication is optional (you may grant higher possibilities if authenticated)
opts = { auth_mode: :AUTH_OPTIONAL }

# session must be authenticated before service may be used for mail transport
opts = { auth_mode: :AUTH_REQUIRED }
```

You may initialize your server class like:

```ruby
server = MySmtpd.new(2525, '127.0.0.1', 4, auth_mode: :AUTH_REQUIRED)
```

If you have enabled authentication you should provide your own user and access methods to grant access to your server. The default event method will deny all access per default.

Your own server class should implement the `on_auth_event`:

```ruby
# check the authentification
# if any value returned, that will be used for ongoing processing
# otherwise the original value will be used for authorization_id
def on_auth_event(ctx, authorization_id, authentication_id, authentication)
  if authentication_id == "test" && authentication == "demo"
    return authentication_id
  else
    raise Smtpd535Exception
  end
end
```

Most of the time the `authorization_id` field will be empty. It allows optional (like described in [RFC 4954](http://www.ietf.org/rfc/rfc4954.txt)) to define an _authorization role_ which will be used, when the _authentication id_ has successfully entered. So the `authorization_id` is a request to become a role after authentication. In case that the `authorization_id` is empty it is supposed to be the same as the `authentication_id`.

We suggest you to return the `authentication_id` on a successful auth event if you do not have special interests on other usage.


## Authentication status in mixed mode

If you have enabled optional authentication like described before, you may access helpers and values from context `ctx` while processing events to check the status of currents session authentication.

```ruby
def on_rcpt_to_event(ctx, rcpt_to_data)
  # check if this session was authenticated already
  if authenticated?(ctx)
    # yes
    puts "Proceed with authorized id: #{ctx[:server][:authorization_id]}"
    puts "and authentication id: #{ctx[:server][:authentication_id]}"
  else
    # no
    puts "Proceed with anonymoous credentials"
  end
end
```


## Encryption

Since release `2.2.1` the SMTP-Server supports STARTTLS by using `openssl` gem.
If you want to enable encryption you have to set the appropriate value to `tls_mode` opts.

Allowed values are:

```ruby
# no encryption is allowed (mostly for internal services)
opts = { tls_mode: :TLS_FORBIDDEN }

# encryption is optional
opts = { tls_mode: :TLS_OPTIONAL }

# client must initialize encryption before service may be used for mail exchange
opts = { tls_mode: :TLS_REQUIRED }
```

You may enable TLS on your server class like:

```ruby
server = MySmtpd.new(2525, '127.0.0.1', 4, tls_mode: :TLS_OPTIONAL)
```

Do not forget to also install or require the `openssl` gem if you want to enable encryption.

When using `tls_mode: :TLS_REQUIRED` your server will enforce the client to always use STARTTLS before accepting transmission of data like described in [RFC 3207](https://tools.ietf.org/html/rfc3207).

For security reasons check the "Table of the ciphers (and their priorities)" on [OWASP Foundation](https://www.owasp.org/index.php/TLS_Cipher_String_Cheat_Sheet). Per default the `Advanced+ (A+)` cipher-string will be used as well as `TLSv1.2 only`.

You may change ciphers and methods on your server class like:

```ruby
server = MySmtpd.new(2525, '127.0.0.1', 4, { tls_mode: :TLS_OPTIONAL, tls_ciphers: TLS_CIPHERS_ADVANCED_PLUS, tls_methods: TLS_METHODS_ADVANCED })
```

Predefined ciphers and methods strings are available as CONSTs:

```ruby
# Advanced+ (A+) _Default_
opts = { tls_ciphers: TLS_CIPHERS_ADVANCED_PLUS, tls_methods: TLS_METHODS_ADVANCED }

# Advanced (A)
opts = { tls_ciphers: TLS_CIPHERS_ADVANCED, tls_methods: TLS_METHODS_ADVANCED }

# Broad Compatibility (B)
opts = { tls_ciphers: TLS_CIPHERS_BROAD, tls_methods: TLS_METHODS_ADVANCED }

# Widest Compatibility (C)
opts = { tls_ciphers: TLS_CIPHERS_WIDEST, tls_methods: TLS_METHODS_LEGACY }

# Legacy (C-)
opts = { tls_ciphers: TLS_CIPHERS_LEGACY, tls_methods: TLS_METHODS_LEGACY }
```


## Certificates

As long as `tls_mode` is set to `:TLS:OPTIONAL` or `:TLS_REQUIRED` and no certificate or key path is given on class initialization, the internal TlsTransport class will create a certificate by itself. This should be only used for testing or debugging purposes and not in production environments. The memory only certificate is valid for 90 days from instantiating the class.

You better should generate a certificate by yourself or use a professional trust-center like [LetsEncrypt](https://letsencrypt.org/).

#### Quick guide to create a certificate

If interested in detail, read the whole story at [www.thenativeweb.io](https://www.thenativeweb.io/blog/2017-12-29-11-51-the-openssl-beginners-guide-to-creating-ssl-certificates/).

```bash
# create a private key
openssl genrsa -out key.pem 4096
# create a certificate signing request (CSR)
openssl req -new -key key.pem -out csr.pem
# create a SSL certificate
openssl x509 -in csr.pem -out cert.pem -req -signkey key.pem -days 90
```

You may use your certificate and key on your server class like:

```ruby
server = MySmtpd.new(2525, '127.0.0.1', 4, { tls_mode: :TLS_OPTIONAL, tls_cert_path: 'cert.pem', tls_key_path: 'key.pem' })
```


## Test encrypted communication

While working with encrypted communication it is sometimes hard to test and check during development or debugging. Therefore you should look at the GNU tool `gnutls-cli`. Use this tool to connect to your running SMTP-server and proceed with encrypted communication.

```bash
# use --insecure when using self created certificates
gnutls-cli --insecure -s -p 2525 127.0.0.1
```

After launching `gnutls-cli` start the SMTP dialog by sending `EHLO` and `STARTSSL` commands. Next press Ctrl-D on your keyboard to run the handshake for SSL communication between `gnutls-cli` and your server. When ready you may follow up with the delivery dialog for SMTP.


## Endless operation purposes

E.g. create a SMTP-Server to receive messages via SMTP and store them to RabbitMQ Message-Queue-Server:

```ruby
  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Just decode message ones to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message])
    # Publish to rabbit
    @bunny_exchange.publish(@mail.to_s, :headers => { 'x-smtp' => @mail.header.to_s }, :routing_key => "to_queue")
  end
```

E.g. create a SMTP-Server to receive messages via SMTP and forward them plain or processed to services like Slack, Trello, Redmine, ...


## MidiSmtpServer::Smtpd Class documentation

You will find a detailed description of class methods and parameters at [RubyDoc](http://www.rubydoc.info/gems/midi-smtp-server/MidiSmtpServer/Smtpd)


## New to version 2.2.3

1. Control and validation on incoming data [see Incoming data validation](https://github.com/4commerce-technologies-AG/midi-smtp-server#incoming-data-validation)


## New to version 2.2.1

1. Builtin optional support of STARTTLS encryption
2. Added examples for a simple midi-smtp-server with TLS support


## New to version 2.2.x

1. Rubocop configuration and passed source code verification
2. Modified examples for a simple midi-smtp-server with and without auth
3. Enhanced `serve_service` (previously `start`)
4. Optionally gracefully shutdown when service `stop` (default gracefully)


## New to version 2.1.1

1. Huge speed improvement on receiving large message data (1.000+ faster)


## New to version 2.1

1. Authentication PLAIN, LOGIN
2. Safe `join` will catch and rescue `Interrupt`


## New to version 2.x

1. Modulelized
2. Removed dependency to GServer
3. Additional events to interact with
4. Use logger to log several messages from severity :debug up to :fatal


## From version 1.x to 2.x

If you are already using MidiSmtpServer at a release 1.x it might be only some straight forward work to get your code work with version 2.x.

<details>
<summary>Open / Close details</summary>

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
  # not available anymore, is now controlled by Logger
```
</details>


## Package

You can find, use and download the gem package from [RubyGems.org](http://rubygems.org/gems/midi-smtp-server)

You can find the full documentation on [RubyDoc.info](http://www.rubydoc.info/gems/midi-smtp-server/MidiSmtpServer)

[![Gem Version](https://badge.fury.io/rb/midi-smtp-server.svg)](http://badge.fury.io/rb/midi-smtp-server)


### Author & Credits

Author: [Tom Freudenberg](http://about.me/tom.freudenberg)

[MidiSmtpServer Class](https://github.com/4commerce-technologies-AG/midi-smtp-server/) is inspired from [MiniSmtpServer Class](https://github.com/aarongough/mini-smtp-server) and code originally written by [Aaron Gough](https://github.com/aarongough) and [Peter Cooper](http://peterc.org/)

Copyright (c) 2014-2018 [Tom Freudenberg](http://www.4commerce.de/), [4commerce technologies AG](http://www.4commerce.de/), released under the MIT license
