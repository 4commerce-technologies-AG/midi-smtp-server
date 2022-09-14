## Utilization of connections and processings

The options `max_processings` and `max_connections` allows to define the utilization of the running service. The value of `max_processings` will allow to queue processings while active processings have reached the maximum value. The additional (optional) value of `max_connections` will block any additional concurrent TCP connection and respond with SMTP error code 421 on more connections.

E.g.:

```rb
  server = MySmtpd.new(ports: '2525', hosts: '127.0.0.1', max_processings: 4, max_connections: 100)
```

In this example the service will allow 100 concurrent TCP connections but just process 4 of them simultaneously until all connections have been handled. If there are more than 100 concurrent TCP connections, those will be closed by error `421 Service too busy or not available`. That error code will _normally_ ensure, that the sender would try again after a while.

This allows to calculate the utilization of your service by limiting the connections and processings.

### Calculate utilization

It depends on the system resources (RAM, CPU) how many threads and connections your service may handle simultaneously but it should reflect also how many messages it has to proceed per time interval.

For processing 1.000.000 mails per 24 hours, it may divided by seconds per day (24 * 60 * 60 = 86.400). This results in 11.5 mails per second. If the average processing time per mail is 15 seconds (long runner), then the service might have an overlap of 15 times 11.5 connections simultaneously. If that is expected, then `max_processings` of 172 should be fine.

If you need 1.000.000 mail per hour than probably 416 simultaneously processed threads should be fine.

The number of `max_connections` should always be equal or higher than `max_processings`. In the above examples it should be fine to use 512 or 1024 if your system does fit with its resources. If an unlimited number of concurrent TCP connections should be allowed, then set the value for `max_connections` to `nil` (which is also the default when not specified).

<br>
