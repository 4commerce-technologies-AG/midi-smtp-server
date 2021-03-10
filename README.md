<p align="center" style="margin-bottom: 2em">
  <img src="https://raw.githubusercontent.com/4commerce-technologies-AG/midi-smtp-server/master/mkdocs/img/midi-smtp-server-logo.png" alt="MidiSmtpServer Logo" width="40%"/>
</p>

<h3 align="center">MidiSmtpServer</h3>
<p align="center">
  <strong>The highly customizable ruby SMTP-Service library</strong>
</p>
<p align="center">
-- Mail-Server, SMTP-Service, MTA, Email-Gateway & Router, Mail-Automation --
</p>

<br>


## MidiSmtpServer

MidiSmtpServer is the highly customizable ruby SMTP-Server and SMTP-Service library with builtin support for AUTH and SSL/STARTTLS, 8BITMIME and SMTPUTF8, IPv4 and IPv6 and additional features.

As a library it is mainly designed to be integrated into your projects as serving a SMTP-Server service. The lib will do nothing with your mail and you have to create your own event functions to handle and operate on incoming mails. We are using this in conjunction with [Mikel Lindsaar](https://github.com/mikel) great Mail component (https://github.com/mikel/mail). Time to run your own SMTP-Server service.

Checkout all the features and improvements (2.3.x Multiple ports and addresses, 2.2.x Encryption [StartTLS], 2.1.0 Authentication [AUTH], 2.1.1 significant speed improvement, etc.) and get more details from section [changes and updates](https://github.com/4commerce-technologies-AG/midi-smtp-server#changes-and-updates).

MidiSmtpServer is an extremely flexible library and almost any aspect of SMTP communications can be handled by deriving its events and using its configuration options.

<br>


## Using the library

To derive your own SMTP-Server service with DATA processing simply do:

```ruby
# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("[#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message once to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message subject
    logger.debug(@mail.subject)
  end

end
```

Please checkout the source codes from [Examples](https://github.com/4commerce-technologies-AG/midi-smtp-server/tree/master/examples) for working SMTP-Services.

<br>


## Operation purposes

There is an endless field of application for SMTP&nbsp;services. You want to create your own SMTP&nbsp;Server as a mail&nbsp;gateway to clean up routed emails from spam and virus content. Incoming mails may be processed and handled native and by proper functions. A SMTP&nbsp;daemon can receive messages and forward them to a service like Slack, Trello, Redmine, Twitter, Facebook, Instagram and others.

This source code shows the example to receive messages via SMTP and store them to RabbitMQ (Message-Queue-Server) for subsequent processings etc.:

```ruby
  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Just decode message once to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message])

    # Publish to rabbit
    @bunny_exchange.publish(@mail.to_s, :headers => { 'x-smtp' => @mail.header.to_s }, :routing_key => "to_queue")
  end
```

<br>


## Installation

MidiSmtpServer is packaged as a RubyGem so that you can easily install by entering following at your command line:

  `gem install midi-smtp-server`

Use the component in your project sources by:

  `require 'midi-smtp-server'`

<br>


## Customizing the server

MidiSmtpServer can be easily customized via subclassing. Simply subclass the `MidiSmtpServer` class as given in the example above and re-define event handlers:

```ruby
  # event on CONNECTION
  # you may change the ctx[:server][:local_response] and
  # you may change the ctx[:server][:helo_response] in here so
  # that these will be used as local welcome and greeting strings
  # the values are not allowed to return CR nor LF chars and will be stripped
  def on_connect_event(ctx)
  end

  # event before DISONNECT
  def on_disconnect_event(ctx)
  end

  # event on HELO/EHLO
  # you may change the ctx[:server][:helo_response] in here so
  # that this will be used as greeting string
  # the value is not allowed to return CR nor LF chars and will be stripped
  def on_helo_event(ctx, helo_data)
  end

  # get address send in MAIL FROM
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used
  def on_mail_from_event(ctx, mail_from_data)
  end

  # get each address send in RCPT TO
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used
  def on_rcpt_to_event(ctx, rcpt_to_data)
  end

  # event when beginning with message DATA
  def on_message_data_start_event(ctx)
  end

  # event while receiving message DATA
  def on_message_data_receiving_event(ctx)
  end

  # event when headers are received while receiving message DATA
  def on_message_data_headers_event(ctx)
  end

  # get each message after DATA <message>
  def on_message_data_event(ctx)
  end

  # event when process_line identifies an unknown command line
  # allows to abort sessions for a series of unknown activities to
  # prevent denial of service attacks etc.
  def on_process_line_unknown_event(ctx, line)
  end
```

<br>


## IPv4 and IPv6 ready

The underlaying ruby component [TCPServer](https://ruby-doc.org/stdlib-2.5.0/libdoc/socket/rdoc/TCPServer.html) allows support for IPv4 and IPv6 communication. If using the `DEFAULT_SMTPD_HOST` as your hosts option than explicitely IPv4 `127.0.0.1` will be enabled. If using the string `localhost` it depends on your _hosts_ file. If that contains a line like `::1 localhost` you might enable your server instance on IPv6 localhost only. Be aware of that when accessing your service.

<br>


## Multiple ports and addresses

Since version 2.3.0 you may define multiple ports and hosts or ip addresses at once when initializing the class. The ports and hosts arguments may be comma seperated strings with multiple ports and addresses like:

``` ruby
  # use port 2525 on all addresses
  server = MySmtpd.new(ports: '2525', hosts: '127.0.0.1, ::1, 192.168.0.1')
  # use ports 2525 and 3535 on all addresses
  server = MySmtpd.new(ports: '2525:3535', hosts: '127.0.0.1, ::1, 192.168.0.1')
  # use port 2525 on first address 127.0.0.1 and port 3535 on second address (and above)
  server = MySmtpd.new(ports: '2525, 3535', hosts: '127.0.0.1, ::1, 192.168.0.1')
  # use port 2525 on first address, port 3535 on second address, port 2525 on third
  server = MySmtpd.new(ports: '2525, 3535, 2525', hosts: '127.0.0.1, ::1, 192.168.0.1')
  # use port 2525 on first address, ports 2525 and 3535 on second address, port 2525 on third
  server = MySmtpd.new(ports: '2525, 2525:3535, 2525', hosts: '127.0.0.1, ::1, 192.168.0.1')
```

You may write any combination of ports and addresses that should be served. That allows complex servers with optionally different services identified by different ports and addresses. There are also `ports` and `hosts` reader for this values available.

<br>


## Hosts, hosts wildcard and interface detection

Since version 2.3.2 the `hosts` parameter allows the `"*"` wildcard to make sure that this wildcard should really identifiy and service on all (local) system interfaces. The initialization will identify all valid IPv4 and IPv6 addresses on all (local) system interfaces. In addition the initialization will resolve all IPv4 and IPv6 addresses for all given hostnames. During startup a debug log message will print out the information to be aware of the listening ports and addresses. If an address is defined more than once like when using `"localhost, 127.0.0.1, ::1"`, the component will raise an exception that port and address is already in use.

For production usage it is highly suggested to use only specific IPv4 and IPv6 addresses for your services.

<br>


## Utilization of connections and processings

The options `max_processings` and `max_connections` allows to define the utilization of the running service. The value of `max_processings` will allow to queue processings while active processings have reached the maximum value. The additional (optional) value of `max_connections` will block any additional concurrent TCP connection and respond with SMTP error code 421 on more connections.

E.g.:

``` ruby
  server = MySmtpd.new(ports: '2525', hosts: '127.0.0.1', max_processings: 4, max_connections: 100)
```

In this example the service will allow 100 concurrent TCP connections but just process 4 of them simultaneously until all connections have been handled. If there are more than 100 concurrent TCP connections, those will be closed by error `421 Service too busy or not available`. That error code will _normally_ ensure, that the sender would try again after a while.

This allows to calculate the utilization of your service by limiting the connections and processings.

#### Calculate utilization

It depends on the system resources (RAM, CPU) how many threads and connections your service may handle simultaniously but it should reflect also how many messages it has to proceed per time interval.

For processing 1.000.000 mails per 24 hours, it may divided by seconds per day (24 * 60 * 60 = 86.400). This results in 11.5 mails per second. If the average processing time per mail is 15 seconds (long runner), then the service might have an overlap of 15 times 11.5 connections simultaniously. If that is expected, then `max_processings` of 172 should be fine.

If you need 1.000.000 mail per hour than propably 416 simultaniously processed threads should be fine.

The number of `max_connections` should always be equal or higher than `max_processings`. In the above examples it should be fine to use 512 or 1024 if your system does fit with its resources. If an unlimited number of concurrent TCP connections should be allowed, then set the value for `max_connections` to `nil` (which is also the default when not specified).

<br>


## Modifying welcome and greeting responses

While connecting from a client, the server will show up with a first local welcome message and after HELO or EHLO with a greeting message as well as the capabilities (EHLO). The response messages are build and stored in `ctx` values. You may change the content during `on_connect_event` and `on_helo_event`.

``` ruby
  # update local welcome and helo response
  def on_connect_event(ctx)
    ctx[:server][:local_response] = 'My welcome message!'
    ctx[:server][:helo_response] = 'My greeting message!'
  end
```

If you want to show your local_ip or hostname etc. you may also include the context vars for that. Be aware to expose only necessary internal information and addresses etc.

``` ruby
  # update local welcome and helo response
  def on_connect_event(ctx)
    ctx[:server][:local_response] = "#{ctx[:server][:local_host]} [#{ctx[:server][:local_ip]}] says welcome!"
    ctx[:server][:helo_response] = "#{ctx[:server][:local_host]} [#{ctx[:server][:local_ip]}] is serving you!"
  end
```

<br>


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
    mail_from_data
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
    rcpt_to_data
  end
```

<br>


## Adding and testing headers

Since release `2.3.1` the `on_message_data_start_event` and `on_message_data_headers_event` enable the injection of additional headers like `Received` on DATA streaming. To add a `Received` header before any incoming header, use:

```ruby
  # event when beginning with message DATA
  def on_message_data_start_event(ctx)
    ctx[:message][:data] <<
      "Received: " <<
      "from #{ctx[:server][:remote_host]} (#{ctx[:server][:remote_ip]}) " <<
      "by #{ctx[:server][:local_host]} (#{ctx[:server][:local_ip]}) " <<
      "with MySmtpd Server; " <<
      Time.now.strftime("%a, %d %b %Y %H:%M:%S %z") <<
      ctx[:message][:crlf]
  end
```

The `Received` header may be given with more or less additional information like encryption, recipient, sender etc. This should be done while being aware of system safety. Don't reveal too much internal information and choose wisely the published atrributes.

Samples for `Received` headers are:

```
Received: from localhost ([127.0.0.1])
  by mail.domain.test with esmtp (Exim 4.86)
  (envelope-from <user@sample.com>)
  id 3gIFk7-0006RC-FG
  for my.user@mydomain.net; Thu, 01 Nov 2018 12:00:00 +0000
```

```
Received: from localhost ([127.0.0.1:10025])
  by mail.domain.test with ESMTPSA id 3gIFk7-0006RC-FG
  for <my.user@mydomain.net>
  (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
  Thu, 01 Nov 2018 12:00:00 +0000
```

To append special headers or do some checks on transmitted headers, the `on_message_data_headers_event` is called when end of header transmission was automatically discovered.

```ruby
  # event when headers are received while receiving message DATA
  def on_message_data_headers_event(ctx)
    ctx[:message][:data] << 'X-MyHeader: 1.0' << ctx[:message][:crlf]
  end
```

<br>


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

<br>


## Access to server values and context

You can access some important client and server values by using the `ctx` array when in event methods:

```ruby
  # welcome, helo/ehlo (client) and response strings
  ctx[:server][:local_response]
  ctx[:server][:helo]
  ctx[:server][:helo_response]

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

  # counter (int) of exceptions / unknown commands
  ctx[:server][:exceptions]

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

  # envelope enconding settings
  ctx[:message][:encoding_body]
  ctx[:message][:encoding_utf8]

  # timestamp (utc) when message data was initialized
  ctx[:message][:received]

  # timestamp (utc) when message data was completely received
  ctx[:message][:delivered]

  # flag to identify if headers already completed while receiving message data stream
  ctx[:message][:headers]

  # access message data size when message data was completely received
  ctx[:message][:bytesize]

  # string sequence for message data line-breaks
  ctx[:message][:crlf]

  # access message data while receiving message stream
  ctx[:message][:data]

```

<br>


## Incoming data validation

With release 2.2.3 there is an extended control about incoming data before processing. New options allow to set a timeout and maximum size of io_buffer for receiving client data up to a complete data line.

```ruby
# timeout in seconds before a data line has to be completely sent by client or connection abort
io_cmd_timeout: DEFAULT_IO_CMD_TIMEOUT

# maximum size in bytes to read in buffer for a complete data line from client or connection abort
io_buffer_max_size: DEFAULT_IO_BUFFER_MAX_SIZE
```

There are new events `on_process_line_unknown_event` and `on_message_data_receiving_event` to handle the incoming transmission of unknown commands and message data.

As an example to abort on to many unknown commands to prevent a denial of service attack etc.:

```ruby
  # event if process_line has identified an unknown command line
  def on_process_line_unknown_event(ctx, line)
    # check
    raise MidiSmtpServer::Smtpd421Exception.new("421 Abort: too many unknown commands where sent!") if ctx[:server][:exceptions] >= 5
    # otherwise call the super method
    super
  end
```

As an example while receiving message data: abort when message data is going to exceed a maximum size:

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

<br>


## 8BITMIME and SMTPUTF8 support

Since version 2.3.0 there is builtin optional internationalization support via SMTP 8BITMIME and SMTPUTF8 extension described in [RFC6152](https://tools.ietf.org/html/rfc6152) and [RFC6531](https://tools.ietf.org/html/rfc6531).

The extensions are disabled by default and could be enabled by:

```ruby
# enable internationalization SMTP extensions
internationalization_extensions: true
```

When enabled and sender is using the 8BITMIME and SMTPUTF8 capabilities, the given enconding information about body and message encoding are set by `MAIL FROM` command. The encodings are read by MidiSmtpServer and published at context vars `ctx[:envelope][:encoding_body]` and `ctx[:envelope][:encoding_utf8]`.

Possible values for `ctx[:envelope][:encoding_body]` are:

1. `""` (default, not set by client)
2. `"7bit"` (strictly 7bit)
3. `"8bitmime"` (strictly 8bit)

Possible values for `ctx[:envelope][:encoding_utf8]` are:

1. `""` (default, not set by client)
2. `"utf8"` (utf-8 is enabled for headers and body)

Even when `"8bitmime"` was set, you have to decide the correct encoding like `utf-8` or `iso-8859-1` etc. If also `"utf8"` was set, then encoding should be `utf-8`.

<br>


## Authentication support

There is built-in authentication support for `AUTH LOGIN` and `AUTH PLAIN` since release `2.1.0`. If you want to enable authentication you have to set the appropriate value to `auth_mode` option.

Allowed values are:

```ruby
# no authentication is allowed (mostly for internal services)
auth_mode: :AUTH_FORBIDDEN

# authentication is optional (you may grant higher possibilities if authenticated)
auth_mode: :AUTH_OPTIONAL

# session must be authenticated before service may be used for mail transport
auth_mode: :AUTH_REQUIRED
```

You may initialize your server class like:

```ruby
server = MySmtpd.new(ports: 2525, hosts: '127.0.0.1', auth_mode: :AUTH_REQUIRED)
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

<br>


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

<br>


## Encryption

Since release `2.2.1` the SMTP-Server supports STARTTLS by using `openssl` gem.
If you want to enable encryption you have to set the appropriate value to `tls_mode` option.

Allowed values are:

```ruby
# no encryption is allowed (mostly for internal services)
tls_mode: :TLS_FORBIDDEN

# encryption is optional
tls_mode: :TLS_OPTIONAL

# client must initialize encryption before service may be used for mail exchange
tls_mode: :TLS_REQUIRED
```

You may enable TLS on your server class like:

```ruby
server = MySmtpd.new(ports: 2525, hosts: '127.0.0.1', tls_mode: :TLS_OPTIONAL)
```

Do not forget to also install or require the `openssl` gem if you want to enable encryption.

When using `tls_mode: :TLS_REQUIRED` your server will enforce the client to always use STARTTLS before accepting transmission of data like described in [RFC 3207](https://tools.ietf.org/html/rfc3207).

For security reasons check the "Table of the ciphers (and their priorities)" on [OWASP Foundation](https://www.owasp.org/index.php/TLS_Cipher_String_Cheat_Sheet). Per default the `Advanced+ (A+)` cipher-string will be used as well as `TLSv1.2 only`.

You may change ciphers and methods on your server class like:

```ruby
server = MySmtpd.new(
  ports: 2525,
  hosts: '127.0.0.1',
  tls_mode: :TLS_OPTIONAL,
  tls_ciphers: TLS_CIPHERS_ADVANCED_PLUS,
  tls_methods: TLS_METHODS_ADVANCED
)
```

Predefined ciphers and methods strings are available as CONSTs:

```ruby
# Advanced+ (A+) _Default_
tls_ciphers: TLS_CIPHERS_ADVANCED_PLUS
tls_methods: TLS_METHODS_ADVANCED

# Advanced (A)
tls_ciphers: TLS_CIPHERS_ADVANCED
tls_methods: TLS_METHODS_ADVANCED

# Broad Compatibility (B)
tls_ciphers: TLS_CIPHERS_BROAD
tls_methods: TLS_METHODS_ADVANCED

# Widest Compatibility (C)
tls_ciphers: TLS_CIPHERS_WIDEST
tls_methods: TLS_METHODS_LEGACY

# Legacy (C-)
tls_ciphers: TLS_CIPHERS_LEGACY
tls_methods: TLS_METHODS_LEGACY
```

<br>


## Certificates

As long as `tls_mode` is set to `:TLS_OPTIONAL` or `:TLS_REQUIRED` and no certificate or key path is given on class initialization, the internal TlsTransport class will create a certificate by itself. This should be only used for testing or debugging purposes and not in production environments. The memory only certificate is valid for 90 days from instantiating the class.

To prevent client errors like `hostname does not match` the certificate is enriched by `subjectAltNames` and will include all hostnames and addresses which were identified on initialization. The automatic certificate subject and subjectAltName may also be manually set by `tls_cert_cn` and `tls_cert_san` parameter.

In general and for production you better should generate a certificate by your own authority or use a professional trust-center like [LetsEncrypt](https://letsencrypt.org/) and more.

#### Quick guide to create a certificate

If interested in detail, read the whole story at [www.thenativeweb.io](https://www.thenativeweb.io/blog/2017-12-29-11-51-the-openssl-beginners-guide-to-creating-ssl-certificates/). Please check also the information about SSL-SAN like [support.dnsimple.com](https://support.dnsimple.com/articles/what-is-ssl-san/).

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
server = MySmtpd.new(
  ports: 2525,
  hosts: '127.0.0.1',
  tls_mode: :TLS_OPTIONAL,
  tls_cert_path: 'cert.pem',
  tls_key_path: 'key.pem'
)
```

<br>


## Expose active SSLContext

To access the current daemon´s SSL-Context (OpenSSL::SSL::SSLContext), e.g. for inspecting the self signed certificate, this object is exposed as property `ssl_context`.

```ruby
  cert = my_smtpd.ssl_context&.cert
```

<br>


## Test encrypted communication

While working with encrypted communication it is sometimes hard to test and check during development or debugging. Therefore you should look at the GNU tool `gnutls-cli`. Use this tool to connect to your running SMTP-server and proceed with encrypted communication.

```bash
# use --insecure when using self created certificates
gnutls-cli --insecure -s -p 2525 127.0.0.1
```

After launching `gnutls-cli` start the SMTP dialog by sending `EHLO` and `STARTSSL` commands. Next press Ctrl-D on your keyboard to run the handshake for SSL communication between `gnutls-cli` and your server. When ready you may follow up with the delivery dialog for SMTP.

<br>


## Attacks on email communication

You should take care of your project and the communication which it will handle. At least there are a number of attack possibilities even against email communication. It is important to know some of the attacks to write safe codes. Here are just a few starting links about that:

1. [SMTP Injection via recipient (and sender) email addresses](https://www.mbsd.jp/Whitepaper/smtpi.pdf)
1. [Measuring E-Mail Header Injections on the World Wide Web](https://www.cs.ucsb.edu/~vigna/publications/2018_SAC_MailHeaderInjection.pdf)
1. [DDoS Protections for SMTP Servers](https://pdfs.semanticscholar.org/e942/d110f9686a438fccbac1d97db48c24ab84a7.pdf)
1. [Use timeouts to prevent SMTP DoS attacks](https://security.stackexchange.com/a/180267)
1. [Check HELO/EHLO arguments](https://serverfault.com/a/667555)

Be aware that with enabled option of [PIPELINING](https://tools.ietf.org/html/rfc2920) you can't figure out sender or recipient address injection by the SMTP server. From point of security PIPELINING should be disabled as it is per default since version 2.3.0 on this component.

```ruby
# PIPELINING ist not allowed (false) per _Default_
pipelining_extension: DEFAULT_PIPELINING_EXTENSION
```

<br>


## RFC(2)822 - CR LF modes

There is a difference between the conformity of RFC 2822 and best practise.

In [RFC 2822](https://www.ietf.org/rfc/rfc2822.txt) it says that strictly each line has to end up by CR (code 13) followed by LF (code 10). And in addition that the chars CR (code 13) and LF (code 10) should not be used particulary. If looking on Qmails implementation, they will revoke any traffic which is not conform to the above per default.

In real world, it is established, that also a line ending with single LF (code 10) is good practise. So if trying other mailservers like Exim or Exchange or Gmail, you may enter your message either ended by CRLF or single LF.

Also the DATA ending sequence of CRLF.CRLF (CR LF DOT CR LF) may be send as LF.LF (LF DOT LF).

Since version 2.3.0 the component allows to decide by option `crlf_mode` how to handle the line termination codes. Be aware that `CRLF_ENSURE` is enabled by default.

```ruby
# Allow CRLF and LF but always make sure that CRLF is added to message data. _Default_
crlf_mode: CRLF_ENSURE

# Allow CRLF and LF and do not change the incoming data.
crlf_mode: CRLF_LEAVE

# Only allow CRLF otherwise raise an exception
crlf_mode: CRLF_STRICT
```

To understand the modes in details:

#### CRLF_ENSURE

1. Read input buffer and search for LF (code 10)
2. Use bytes from buffer start to LF as TEXTLINE
3. Heal by deleting any occurence of char CR (code 13) and char LF (code 10) from TEXTLINE
4. Append cleaned TEXTLINE and RFC conform pair of CRLF to message data buffer

* As result you will have a clean RFC 2822 conform message input data
* In best case the data is 100% equal to the original input because that already was CRLF conform
* Other input data maybe have changed for the linebreaks but the message is conform yet

#### CRLF_LEAVE

1. Read input buffer and search for LF (code 10)
2. Use bytes from buffer start to LF as TEXTLINE
3. Append TEXTLINE as is to message data buffer

* As result you may have a non clean RFC 2822 conform message input data
* Other libraries like `Mail` may have parsing errors

#### CRLF_STRICT

1. Read input buffer and search for CRLF (code 13 code 10)
2. Use bytes from buffer start to CRLF as TEXTLINE
3. Raise exception if TEXTLINE contains any single CR or LF
3. Append TEXTLINE as is to message data buffer

* As result you will have a clean RFC 2822 conform message input data
* The data is 100% equal to the original input because that already was CRLF conform
* You maybe drop mails while in real world not all senders are working RFC conform

<br>


## Reliable code

Since version 2.3 implementation and integration tests by minitest framework are added to this repository. While the implementation tests are mostly checking the components, the integration tests try to verify the correct exchange of messages for different scenarios.

You may run all tests through the `test_runner.rb` helper:

``` bash
  ruby -I lib test/test_runner.rb
```

or with more verbose output:

``` bash
  ruby -I lib test/test_runner.rb -v
```

To just run some selected (by regular expression) tests, you may use the `-n filter` option. The example will run only the tests and specs containing the word _connections_ in their method_name or describe_text:

``` bash
  ruby -I lib test/test_runner.rb -v -n /connections/
```

Be aware that the filter is case sensitive.

<br>


## Changes and updates

We suggest everybody using MidiSmtpServer 1.x or 2.x to switch at least to latest 2.3.y. The update is painless and without any source code changes if already using some 2.x release :sunglasses:

For upgrades from version 1.x or from _Mini_SmtpServer you may follow the guides (see appendix) how to change your existing code to be compatible with the latest 2.x releases.

#### 3.0.0 (2020-03-08)

1. Enable support for Ruby 3.0
2. Bound to ruby 2.6+
3. Updated rubocop linter and code styles
4. Fix tests for Net/Smtp of Ruby 3.0 ([check PR 22 on Net/Smtp](https://github.com/ruby/net-smtp/pull/22))
5. Fix tests for minitest 6 deprecated warnings `obj.must_equal`
6. New exposed [active SSLContext](https://github.com/4commerce-technologies-AG/midi-smtp-server#expose-active-sslcontext)
7. Dropped deprecated method `host` - please use `hosts.join(', ')` instead
8. Dropped deprecated method `port` - please use `ports.join(', ')` instead
9. Dropped deprecated empty wildcard `""` support on initialize - please use specific hostnames and / or ip-addresses or star wildcard `"*"` only
10. Align tests with Rubocop style and coding enforcements


#### 2.3.2 (2020-01-21)

1. New [hosts wildcard and interface detection](https://github.com/4commerce-technologies-AG/midi-smtp-server#hosts-hosts-wildcard-and-interface-detection)
2. Extended [Certificates](https://github.com/4commerce-technologies-AG/midi-smtp-server#certificates) with subjectAltName
3. Bound to ruby 2.3+
4. Full support for `# frozen_string_literal: true` optimization
5. Updated rubocop linter
6. Rich enhancements to tests


#### 2.3.1 (2018-11-01)

1. New [events for header inspection and addons](https://github.com/4commerce-technologies-AG/midi-smtp-server#adding-and-testing-headers)
2. New [MidiSmtpServer micro homepage](https://4commerce-technologies-ag.github.io/midi-smtp-server/)
3. New [ReadTheDocs manual](https://midi-smtp-server.readthedocs.io/)
4. New [Recipe for Slack MTA](https://midi-smtp-server.readthedocs.io/cookbook_recipe_slack_mta/)


#### 2.3.0 (2018-10-17)

1. Support [IPv4 and IPv6 (documentation)](https://github.com/4commerce-technologies-AG/midi-smtp-server#ipv4-and-ipv6-ready)
2. Support binding of [multiple ports and hosts / ip addresses](https://github.com/4commerce-technologies-AG/midi-smtp-server#multiple-ports-and-addresses)
3. Handle [utilization of connections and processings](https://github.com/4commerce-technologies-AG/midi-smtp-server#utilization-of-connections-and-processings)
4. Support of RFC(2)822 [CR LF modes](https://github.com/4commerce-technologies-AG/midi-smtp-server#rfc2822---cr-lf-modes)
5. Support (optionally) SMTP [PIPELINING](https://tools.ietf.org/html/rfc2920) extension
6. Support (optionally) SMTP [8BITMIME](https://github.com/4commerce-technologies-AG/midi-smtp-server#8bitmime-and-smtputf8-support) extension
7. Support (optionally) SMTP [SMTPUTF8](https://github.com/4commerce-technologies-AG/midi-smtp-server#8bitmime-and-smtputf8-support) extension
8. SMTP PIPELINING, 8BITMIME and SMTPUTF8 extensions are _disabled_ by default
9. Support modification of local welcome and greeting messages
10. Documentation and Links about security and [email attacks](https://github.com/4commerce-technologies-AG/midi-smtp-server#attacks-on-email-communication)
11. Added [implementation and integration testing](https://github.com/4commerce-technologies-AG/midi-smtp-server#reliable-code)


#### 2.2.3

1. Control and validation on incoming data [see Incoming data validation](https://github.com/4commerce-technologies-AG/midi-smtp-server#incoming-data-validation)


#### 2.2.1

1. Builtin optional support of STARTTLS encryption
2. Added examples for a simple midi-smtp-server with TLS support


#### 2.2.x

1. Rubocop configuration and passed source code verification
2. Modified examples for a simple midi-smtp-server with and without auth
3. Enhanced `serve_service` (previously `start`)
4. Optionally gracefully shutdown when service `stop` (default gracefully)


#### 2.1.1

1. Huge speed improvement on receiving large message data (1.000+ faster)


#### 2.1.0

1. Authentication PLAIN, LOGIN
2. Safe `join` will catch and rescue `Interrupt`


#### 2.x

1. Modulized
2. Removed dependency to GServer
3. Additional events to interact with
4. Use logger to log several messages from severity :debug up to :fatal

<br>


## Upgrade to 3.x

If you are already using MidiSmtpServer 2.x it is an easy forward path to get your code ready for MidiSmtpServer version 3.x. Most important that the 3.x release is bound to Ruby 2.6+.


## Upgrade to 2.x

If you are already using MidiSmtpServer it might be only some straight forward work to get your code ready for MidiSmtpServer version 2.x. Also if you are a _Mini_SmtpServer user, it should request only some few work on your codes.


#### Upgrade from 1.x

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
  def initialize(ports = DEFAULT_SMTPD_PORT, hosts = DEFAULT_SMTPD_HOST, max_processings = 4, opts = {})
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


#### Upgrade from MiniSmtpServer

<details>
<summary>Open / Close details</summary>

#### Class

##### MiniSmtpServer

```ruby
  MiniSmtpServer.new
```

##### MidiSmtpServer

```ruby
  MidiSmtpServer::Smtpd.new
```

#### Class initialize

##### MiniSmtpServer

```ruby
  def initialize(port = 2525, host = "127.0.0.1", max_connections = 4, *args)
```

##### MidiSmtpServer

```ruby
  def initialize(ports = DEFAULT_SMTPD_PORT, hosts = DEFAULT_SMTPD_HOST, max_processings = 4, opts = {})
  # opts may include
  opts = { do_dns_reverse_lookup: true }
  opts = { logger: myLoggerObject }
```

#### On_event methods

##### MiniSmtpServer

```ruby
  def new_message_event(message_hash)
  # message_hash[:from]
  # message_hash[:to]
  # message_hash[:data]
```

##### MidiSmtpServer

```ruby
  def on_message_data_event(ctx)
  ctx[:envelope][:from]
  ctx[:envelope][:to]
  ctx[:message][:data]
```

#### Removed elements

##### MiniSmtpServer

```ruby
  # class vars from gserver
  audit
  debug
```

##### MidiSmtpServer

```ruby
  # not available anymore, is now controlled by Logger
```
</details>

<br>


## Gem Package

You may find, use and download the gem package on [RubyGems.org](http://rubygems.org/gems/midi-smtp-server).

[![Gem Version](https://badge.fury.io/rb/midi-smtp-server.svg)](http://badge.fury.io/rb/midi-smtp-server) &nbsp;

<br>

## Documentation

**[Project homepage](https://4commerce-technologies-ag.github.io/midi-smtp-server)** - you will find a micro-site at [Github](https://4commerce-technologies-ag.github.io/midi-smtp-server)

**[Class documentation](http://www.rubydoc.info/gems/midi-smtp-server/MidiSmtpServer/Smtpd)** - you will find a detailed description at [RubyDoc](http://www.rubydoc.info/gems/midi-smtp-server/MidiSmtpServer/Smtpd)

**[Library manual](https://midi-smtp-server.readthedocs.io/)** - you will find a manual (in progress) at [ReadTheDocs](https://midi-smtp-server.readthedocs.io/)

<br>


## Author & Credits

Author: [Tom Freudenberg](http://about.me/tom.freudenberg)

[MidiSmtpServer Class](https://github.com/4commerce-technologies-AG/midi-smtp-server/) is inspired from [MiniSmtpServer Class](https://github.com/aarongough/mini-smtp-server) and code written by [Aaron Gough](https://github.com/aarongough) and [Peter Cooper](http://peterc.org/)

Copyright (c) 2014-2021 [Tom Freudenberg](http://www.4commerce.de/), [4commerce technologies AG](http://www.4commerce.de/), released under the MIT license
