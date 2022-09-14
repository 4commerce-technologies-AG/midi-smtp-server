<h2>Using events</h2>

MidiSmtpServer can be easily customized via subclassing. Simply subclass the MidiSmtpServer class as given in the examples and re-define some of the event handlers.

<br>

### Server welcome response

While connecting from a client, the server will show up with a first local welcome message. The response is build and stored in `ctx` values. You may change the content on overriding the `on_connect_event`.

```rb
  # update local welcome and helo response
  def on_connect_event(ctx)
    ctx[:server][:local_response] = 'My welcome message!'
    ctx[:server][:helo_response] = 'My simple greeting message!'
  end
```

<br>

### HELO/EHLO event response

After HELO or EHLO the server will show a greeting message as well as the capabilities (EHLO). This response is also build and stored in `ctx` values. You may change the content during `on_connect_event` or with extended check in the `on_helo_event`.

If you want to show your local_ip or hostname etc. you may also include the context vars for that. Be aware to expose only necessary internal information and addresses etc.

```rb
  def on_connect_event(ctx)
    ctx[:server][:local_response] = "#{ctx[:server][:local_host]} [#{ctx[:server][:local_ip]}] says welcome!"
  end

  # update helo response
  def on_helo_event(ctx, helo_data)
    ctx[:server][:helo_response] = "#{ctx[:server][:local_host]} [#{ctx[:server][:local_ip]}] is serving you!"
  end
```

<br>

### Modify MAIL FROM, RCPT TO

Since release `1.1.4` the `on_mail_from_event` and `on_rcpt_to_event` allows to return values that should be added to the lists. This is useful if you want to e.g. normalize all incoming addresses. Format defined by RFC for `<path>` as a `MAIL FROM` or `RCPT TO` addresses is:

```
  "<" | <path> | ">"
```

Most mail servers allows also `<path>` only given addresses without leading and ending `< >`.

To make it easier for processing addresses, you are able to normalize them like:

```rb
  # simple rewrite and return value
  def on_mail_from_event(ctx, mail_from_data)
    # strip and normalize addresses like: <path> to path
    mail_from_data.gsub!(/^\s*<\s*(.*)\s*>\s*$/, '\1')
    # we believe in downcase addresses
    mail_from_data.downcase!
    # return address
    mail_from_data
  end

  # rewrite, process more checks and return value
  def on_rcpt_to_event(ctx, rcpt_to_data)
    # strip and normalize addresses like: <path> to path
    rcpt_to_data.gsub!(/^\s*<\s*(.*)\s*>\s*$/, '\1')
    # we believe in downcase addresses
    rcpt_to_data.downcase!
    # Output for debug
    logger.debug("Normalized to: [#{rcpt_to_data}]...")
    # return address
    rcpt_to_data
  end
```

<br>


### Adding and testing headers

Since release `2.3.1` the `on_message_data_start_event` and `on_message_data_headers_event` enable the injection of additional headers like `Received` on DATA streaming. To add a `Received` header before any incoming header, use:

```rb
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

The `Received` header may be given with more or less additional information like encryption, recipient, sender etc. This should be done while being aware of system safety. Don't reveal too much internal information and choose wisely the published attributes.

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

```rb
  # event when headers are received while receiving message DATA
  def on_message_data_headers_event(ctx)
    ctx[:message][:data] << 'X-MyHeader: 1.0' << ctx[:message][:crlf]
  end
```

<br>


### Responding errors

If you return from event class without an exception, the server will respond to client with the appropriate success code, otherwise the client will be noticed about an error.

So you can build SPAM protection, when raising exception while getting `RCPT TO` events.

```rb
  # get each address send in RCPT TO:
  def on_rcpt_to_event(ctx, rcpt_to_data)
    raise MidiSmtpServer::Smtpd550Exception if rcpt_to_data == "not.name@domain.con"
  end
```

You are able to use exceptions on any level of events, so for an example you could raise an exception on `on_message_data_event` if you checked attachments for a pdf-document and fail or so on. If you use the defined `MidiSmtpServer::Smtpd???Exception` classes the remote client gets correct SMTP Server results. For logging purpose the Exception.message is written to log.

When using `MidiSmtpServer::Smtpd421Exception` you are able to abort the active connection to the client by replying `421 Service not available, closing transmission channel`. Be aware, that this Exception will actively close the current connection to the client.

**Attention:** For logging purposes you may set a message to log for yourself - **but** - this message will not be transmitted to the client in order not to leak too much (internal) information outside. SMTP Server replies to clients only standardized ones.

```rb
  # drop connection immediately on SPAM
  def on_rcpt_to_event(ctx, rcpt_to_data)
    raise MidiSmtpServer::Smtpd421Exception, '421 Abort: Identified spammer!' if rcpt_to_data == "not.name@domain.con"
  end
```

In the above example, the message `421 Abort: Identified spammer! is written to log - and - the client receives the standardized message for code 421.

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


### Incoming data validation

With release 2.2.3 there is an extended control about incoming data before processing. New options allow to set a timeout and maximum size of io_buffer for receiving client data up to a complete data line.

```rb
# timeout in seconds before a data line has to be completely sent by client or connection abort
io_cmd_timeout: DEFAULT_IO_CMD_TIMEOUT

# maximum size in bytes to read in buffer for a complete data line from client or connection abort
io_buffer_max_size: DEFAULT_IO_BUFFER_MAX_SIZE
```

There are new events `on_process_line_unknown_event` and `on_message_data_receiving_event` to handle the incoming transmission of unknown commands and message data.

As an example to abort on to many unknown commands to prevent a denial of service attack etc.:

```rb
  # event if process_line has identified an unknown command line
  def on_process_line_unknown_event(ctx, line)
    # check
    raise MidiSmtpServer::Smtpd421Exception.new("421 Abort: too many unknown commands where sent!") if ctx[:server][:exceptions] >= 5
    # otherwise call the super method
    super
  end
```

As an example while receiving message data: abort when message data is going to exceed a maximum size:

```rb
  # event while receiving message DATA
  def on_message_data_receiving_event(ctx)
    raise MidiSmtpServer::Smtpd552Exception if ctx[:message][:data].bytesize > MAX_MSG_SIZE
  end
```

Or to implement something like a Teergrube for spammers etc.:

```rb
  # event while receiving message DATA
  def on_message_data_receiving_event(ctx)
    # don't allow the spammer to continue fast
    # let him wait always 15 seconds before sending next data line
    sleep 15 if ctx[:server][:helo] =~ /domain/
  end
```

Or to check already the message headers before receiving the complete message data. And lots more.

<br>
