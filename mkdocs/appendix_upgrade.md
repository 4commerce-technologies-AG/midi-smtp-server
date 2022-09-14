<h2>Upgrade library</h2>

We suggest everybody using MidiSmtpServer to switch at least to latest 2.3.y. or best to 3.x. The update is painless and mostly without any source code changes.

For upgrades from previous versions or outdated MiniSmtpServer gem you may follow this guide (appendix) how to change your existing code to be compatible with the latest releases.

<br>

### Upgrade to 3.x

If you are already using MidiSmtpServer 2.x it is an easy forward path to get your code ready for MidiSmtpServer version 3.x. Most important for the 3.x release:

* bound to Ruby 2.6+
* supports Ruby 3+
* method arguments for `new`, `join`, `stop` are defined as keyword arguments

<h4>MINOR INCOMPATIBILITY to 2.x.</h4>

All arguments for `new`, `join`, `stop` must be named.

Please use:

```rb
daemon = MySmtpd.new(ports: '2525', hosts: '127.0.0.1', max_processings: 4)
```

instead of:

```rb
daemon = MySmtpd.new('2525', '127.0.0.1', 4)
```

Anything else is still compatible to previous releases >=2.3.0.

<br>

### Upgrade to 2.x

If you are already using some MidiSmtpServer 2.x it will be only some straight forward work to use your code with MidiSmtpServer version 2.x.

<br>

### Upgrade from 1.x

If you are already using MidiSmtpServer it might be only some straight forward work to get your code ready for MidiSmtpServer version 2.x.

<h4>Class</h4>

<h5>1.x</h5>

```rb
  MidiSmtpServer.new
```

<h5>2.x</h5>

```rb
  MidiSmtpServer::Smtpd.new
```

<br>

<h4>Class initialize</h4>

<h5>1.x</h5>

```rb
  def initialize(port = 2525, host = "127.0.0.1", max_connections = 4, do_smtp_server_reverse_lookup = true, *args)
```

<h5>2.x</h5>

```rb
  def initialize(ports = DEFAULT_SMTPD_PORT, hosts = DEFAULT_SMTPD_HOST, max_processings = 4, opts = {})
  # opts may include
  opts = { do_dns_reverse_lookup: true }
  opts = { logger: myLoggerObject }
```

<br>

<h4>On_event arguments order</h4>

<h5>1.x</h5>

```rb
  def on_helo_event(helo_data, ctx)
  def on_mail_from_event(mail_from_data, ctx)
  def on_rcpt_to_event(rcpt_to_data, ctx)
```

<h5>2.x</h5>

```rb
  def on_helo_event(ctx, helo_data)
  def on_mail_from_event(ctx, mail_from_data)
  def on_rcpt_to_event(ctx, rcpt_to_data)
```

<br>

<h4>Exceptions</h4>

<h5>1.x</h5>

```rb
  MidiSmtpServerException
  # use your correct exception id instead of 123
  MidiSmtpServer123Exception
```

<h5>2.x</h5>

```rb
  MidiSmtpServer::SmtpdException
  # use your correct exception id instead of 123
  MidiSmtpServer::Smtpd123Exception
```

<br>

<h4>Removed elements</h4>

<h5>1.x</h5>

```rb
  # class vars from gserver
  audit
  debug
```

<h5>2.x</h5>

```rb
  # not available anymore, is now controlled by Logger
```

<br>

### Upgrade from MiniSmtpServer

If you are a MiniSmtpServer user, it should request only some few work on your codes.

<h4>Class</h4>

<h5>MiniSmtpServer</h5>

```rb
  MiniSmtpServer.new
```

<h5>MidiSmtpServer</h5>

```rb
  MidiSmtpServer::Smtpd.new
```

<br>

<h4>Class initialize</h4>

<h5>MiniSmtpServer</h5>

```rb
  def initialize(port = 2525, host = "127.0.0.1", max_connections = 4, *args)
```

<h5>MidiSmtpServer</h5>

```rb
  def initialize(ports = DEFAULT_SMTPD_PORT, hosts = DEFAULT_SMTPD_HOST, max_processings = 4, opts = {})
  # opts may include
  opts = { do_dns_reverse_lookup: true }
  opts = { logger: myLoggerObject }
```

<br>

<h4>On_event methods</h4>

<h5>MiniSmtpServer</h5>

```rb
  def new_message_event(message_hash)
  # message_hash[:from]
  # message_hash[:to]
  # message_hash[:data]
```

<h5>MidiSmtpServer</h5>

```rb
  def on_message_data_event(ctx)
  ctx[:envelope][:from]
  ctx[:envelope][:to]
  ctx[:message][:data]
```

<br>

<h4>Removed elements</h4>

<h5>MiniSmtpServer</h5>

```rb
  # class vars from gserver
  audit
  debug
```

<h5>MidiSmtpServer</h5>

```rb
  # not available anymore, is now controlled by Logger
```

<br>
