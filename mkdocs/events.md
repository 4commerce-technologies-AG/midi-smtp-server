<h2>Events</h2>

MidiSmtpServer can be easily customized via subclassing. Simply subclass the `MidiSmtpServer` class as given in the example and re-define some of the event handlers.

<br>

### on_logging_event

```rb
  # event on LOGGING
  # the exposed logger property is from class MidiSmtpServer::ForwardingLogger
  # and pushes any logging message to this on_logging_event.
  # if logging occurs from inside session, the _ctx should be not nil
  # if logging occurs from an error, the err object should be filled
  def on_logging_event(ctx, severity, msg, err: nil)
  end
```

<br>

### on_connect_event

```rb
  # event on CONNECTION
  # you may change the ctx[:server][:local_response] and
  # you may change the ctx[:server][:helo_response] in here so
  # that these will be used as local welcome and greeting strings
  # the values are not allowed to return CR nor LF chars and will be stripped
  def on_connect_event(ctx)
  end
```

<br>

### on_disconnect_event

```rb
  # event before DISONNECT
  def on_disconnect_event(ctx)
  end
```

<br>

### on_helo_event

```rb
  # event on HELO/EHLO
  # you may change the ctx[:server][:helo_response] in here so
  # that this will be used as greeting string
  # the value is not allowed to return CR nor LF chars and will be stripped
  def on_helo_event(ctx, helo_data)
  end
```

<br>

### on_mail_from_event

```rb
  # get address send in MAIL FROM
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used
  def on_mail_from_event(ctx, mail_from_data)
  end
```

<br>

### on_rcpt_to_event

```rb
  # get each address send in RCPT TO
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used
  def on_rcpt_to_event(ctx, rcpt_to_data)
  end
```

<br>

### on_message_data_start_event

```rb
  # event when beginning with message DATA
  def on_message_data_start_event(ctx)
  end
```

<br>

### on_message_data_receiving_event

```rb
  # event while receiving message DATA
  def on_message_data_receiving_event(ctx)
  end
```

<br>

### on_message_data_headers_event

```rb
  # event when headers are received while receiving message DATA
  def on_message_data_headers_event(ctx)
  end
```

<br>

### on_message_data_event

```rb
  # get each message after DATA <message>
  def on_message_data_event(ctx)
  end
```

<br>

### on_process_line_unknown_event

```rb
  # event when process_line identifies an unknown command line
  # allows to abort sessions for a series of unknown activities to
  # prevent denial of service attacks etc.
  def on_process_line_unknown_event(ctx, line)
  end
```

<br>
