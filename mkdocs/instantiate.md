<h2>Setup service</h2>

You may setup your SMTP-Server service on multiple IPv4 and IPv6 addresses and ports. That will create separate threads and TCPServers on each address and port. For that any address and port may be used as a status and condition e.g. for checking SPAM and content etc.

<br>

### IPv4 and IPv6 ready

The underlying ruby component [TCPServer](https://ruby-doc.org/stdlib-2.5.0/libdoc/socket/rdoc/TCPServer.html) allows support for IPv4 and IPv6 communication. If using the `DEFAULT_SMTPD_HOST` as your hosts option than explicitly IPv4 `127.0.0.1` will be enabled. If using the string `localhost` it depends on your _hosts_ file. If that contains a line like `::1 localhost` you might enable your server instance on IPv6 localhost only. Be aware of that when running and accessing your service.

<br>

### Ports and addresses

Since version 2.3.0 you may define multiple ports and hosts or ip addresses at once when initializing the class. The ports and hosts arguments may be comma separated strings with multiple ports and addresses like:

```rb
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

### Hosts, wildcard, interface detection

Since version 2.3.2 the `hosts` parameter allows the `"*"` wildcard to make sure that this wildcard should really identify and service on all (local) system interfaces. The initialization will identify all valid IPv4 and IPv6 addresses on all (local) system interfaces. In addition the initialization will resolve all IPv4 and IPv6 addresses for all given hostnames. During startup a debug log message will print out the information to be aware of the listening ports and addresses. If an address is defined more than once like when using `"localhost, 127.0.0.1, ::1"`, the component will raise an exception that port and address is already in use.

Remember that your service will start a separate TCPServer Listen Thread for any given unique IP address. This helps routing and message verification while optionally checking the incoming message endpoints.

The IP address `0.0.0.0` is defined as _ANY ADDRESS_ and for that special address, your service will be bound with only _one_ Thread but to all local IP addresses. This could be used for easy Docker configuration when a port should be exposed to the host. But also here it is suggested to use a specific port and address e.g. set via `--env ENV=""` arguments to Docker and your service.

For production usage it is highly suggested to use only specific IPv4 and IPv6 addresses for your services and not a wildcard or the ANY address.

<br>
