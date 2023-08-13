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
