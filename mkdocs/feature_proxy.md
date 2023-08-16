## Proxy support

There is built-in support for `PROXY` since release `3.2.2`. Find more about proxy extension from [PROXY protocol](https://github.com/haproxy/haproxy/blob/master/doc/proxy-protocol.txt).

The extension is disabled by default. You may initialize your server class like:

```rb
server = MySmtpd.new(ports: 2525, hosts: '127.0.0.1', proxy_extension: true)
```

If you have enabled proxy support you may provide your own proxy event method to check access to your server. The default event method will allow all proxy connections per default.

Your own server class may implement the `on_proxy_event`:

```rb
# check the proxy connection
# if a value is returned, that will be used and stored as proxy information
def on_proxy_event(ctx, proxy_data)
  # if necessary you may change the remote ip and port information
  ctx[:server][:remote_ip] = proxy_data[:source_ip]
  ctx[:server][:remote_host] = proxy_data[:source_ip]
  ctx[:server][:remote_port] = proxy_data[:source_port]
  proxy_data
end
```

Instead changing the `remote_ip` and other `ctx[:server]` vars, you will always have access to the server context proxy data `ctx[:server][:proxy]`.

```rb
def other_event(ctx)
  if ctx[:server][:proxy]
    puts "This is the client IP: #{ctx[:server][:proxy][:source_ip]"
  end
end
```

<br>

### Rules for Proxy support

#### proxy_extension = false (DEFAULT)

1. PROXY commands are ignored and could be catch in a individual method using the `on_process_line_unknown_event`

#### proxy_extension = true

1. Only valid PROXY protocol v1 commands are allowed
2. All invalid PROXY commands causes immediately a drop and close of the connection (Code 421)
3. PROXY command is in general optional and not mandatory even when extension is enabled
4. Strict checking of values on processing like tcp4/6 addresses and port ranges
5. Only ONE PROXY LINE is allowed - check the `accept-proxy` directive if having issues
6. At the `on_proxy_event` you may check the connection data and grant or disallow access.
7. If a `PROXY` command is used later while already in a session it just raises an invalid sequence error

<br>

### Resolv client ip address as hostname (DNS)

If you need for some reason the client hostname you may use the builtin library `resolv` for that job. Checkout the ruby documentation at [Resolv](https://ruby-doc.org/3.2.2/stdlibs/resolv/Resolv.html).

A simple implementation looks like:

```rb
# require the builtin library
require 'resolv'

def on_proxy_event(ctx, proxy_data)
  # update the proxy data
  begin
    proxy_data[:source_host] = Resolv.getname(proxy_data[:source_ip])
  rescue NameError
  end
  # rewrite the remote connection information
  ctx[:server][:remote_ip] = proxy_data[:source_ip]
  ctx[:server][:remote_host] = proxy_data[:source_host]
  ctx[:server][:remote_port] = proxy_data[:source_port]
  # return the values to store as proxy data
  proxy_data
end
```

<br>
