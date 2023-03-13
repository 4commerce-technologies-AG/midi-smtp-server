<h2>Context values</h2>

The server's context object `ctx` is a key part of any connection. It stores various values that can be accessed and manipulated by the server's handlers during the processing of incoming messages. The context object is passed to each handler, allowing them to access and modify its contents as needed. The `ctx` is a thread safe session only context store for an active connection. The term _"the server"_ always reflects this unique context store.

Context values are a powerful feature of the MidiSmtpServer library. They allow handlers to access and modify values that are relevant to the processing of incoming messages. By understanding how context values work, developers can create more sophisticated handlers that can perform complex operations on incoming messages.

<br>

<h2>ctx hash</h2>

#### ctx[:server][:local_response]

This value stores the string that the server sends to the client after the client initiates a connection. It is usually a welcome message that includes the server's name and version.

#### ctx[:server][:helo]

This value stores the HELO/EHLO string sent by the client during the SMTP handshake.

#### ctx[:server][:helo_response]

This value stores the response string sent by the server after the client sends the HELO/EHLO string.

<br>

#### ctx[:server][:local_ip]

This value stores the IP address of the server.

#### ctx[:server][:local_host]

This value stores the hostname of the server.

#### ctx[:server][:local_port]

This value stores the port number that the server is listening on.

#### ctx[:server][:remote_ip]

This value stores the IP address of the client that is connected to the server.

#### ctx[:server][:remote_host]

This value stores the hostname of the client that is connected to the server.

#### ctx[:server][:remote_port]

This value stores the port number that the client is connected on.

<br>

#### ctx[:server][:connected]

This value stores the timestamp (in UTC) when the client connected to the server.

#### ctx[:server][:encrypted]

This value stores the timestamp (in UTC) when the encryption was established between the server and client.

#### ctx[:server][:exceptions]

This value stores an integer counter that tracks the number of exceptions or unknown commands encountered during the session.

#### ctx[:server][:errors]

This value stores an array of error objects that were captured during the session.

<br>

#### ctx[:server][:authorization_id]

This value stores the username that was provided during the AUTH command.

#### ctx[:server][:authentication_id]

This value stores the username that was successfully authenticated during the session.

#### ctx[:server][:authenticated]

This value stores the timestamp (in UTC) when the user was successfully authenticated.

<br>

#### ctx[:envelope][:from]

This value stores the email address from the MAIL FROM command.

#### ctx[:envelope][:to][0]

This value stores the first email address from the RCPT TO command. 

#### ctx[:envelope][:encoding_body]

This value stores the encoding of the message body.

#### ctx[:envelope][:encoding_utf8]

This value stores the encoding of the message headers.

<br>

#### ctx[:message][:received]

This value stores the timestamp (in UTC) when the message data was initially received.

#### ctx[:message][:delivered]

This value stores the timestamp (in UTC) when the message data was completely received.

#### ctx[:message][:headers]

This value is a boolean flag that indicates if the headers of the message have already been received and processed by `on_message_data_headers_event`. 

<br>

#### ctx[:message][:bytesize]

This value stores the size of the message data in bytes.

#### ctx[:message][:crlf]

This value stores the string sequence used for line breaks in the message data.

#### ctx[:message][:data]

This value provides access to the message data while it is being received and processed by the server.

<br>
