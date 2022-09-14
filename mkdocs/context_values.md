<h2>Context values</h2>

You can access important client and server states and values by using the `ctx` array when in any event method:

<br>

<h2>ctx hash</h2>

```rb
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
  # array with captured exception`s error objects
  ctx[:server][:errors]

  # authentication infos
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

  # envelope encoding settings
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
